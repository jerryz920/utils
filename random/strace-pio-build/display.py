#!/usr/bin/env
import os
import sys
import pygraphviz as pgv
import urllib

def parse_pid(fname):
    # every file is in format fname.pid
    return int(fname.split(".")[1])

def parse_childpid(strace_line):
    return int(strace_line.split("=")[-1])

def parse_cmd(strace_line):
    # execve("<cmd>", args...)
    args = get_args(strace_line)
    return args[0], scan_args(args[1])

def scan_args(args):
    results = []
    struct_depth = 0
    call_depth=0
    array_depth = 0
    quoted = 0
    escape = 0
    cur = bytearray("")
    for b in args:
        if quoted == 1:
            if b == '\\' and escape != 1:
                escape = 1
                cur.append(b)
            elif b == '"':
                if escape == 1:
                    escape = 0
                    cur.append(b)
                else:
                    quoted = 0
            else:
                if escape == 1:
                    escape = 0
                cur.append(b)
        else:
            if b == '"':
                quoted = 1
            elif struct_depth > 0:
                if b == '{':
                    struct_depth += 1
                    cur.append(b)
                elif b == '}':
                    if struct_depth > 1:
                        cur.append(b)
                    struct_depth -= 1
                else:
                    cur.append(b)
            elif call_depth > 0:
                if b == '(':
                    call_depth += 1
                    cur.append(b)
                elif b == ')':
                    call_depth -= 1
                    cur.append(b)
                else:
                    cur.append(b)
            elif array_depth > 0:
                if b == '[':
                    array_depth += 1
                    cur.append(b)
                elif b == ']':
                    if array_depth > 1:
                        cur.append(b)
                    array_depth -= 1
                else:
                    cur.append(b)
            else:
                if b == '{':
                    struct_depth += 1
                elif b == '[':
                    array_depth += 1
                elif b == '(':
                    call_depth += 1
                    cur.append(b)
                elif b == ',':
                    results.append(str(cur))
                    cur = bytearray("")
                else:
                    cur.append(b)

    if len(cur) > 0:
        results.append(str(cur))
    return results


def get_args(strace_line):
    first = strace_line.find("(")
    second = strace_line.rfind(")")
    return scan_args(strace_line[first+1:second])

def resolve_ip(ip_arg):
    # we have pulled the quote in scan_args... This might be a problem
    if ip_arg.find("inet_pton") != -1:
        return get_args(ip_arg)[1]
    else:
        return get_args(ip_arg)[0]

def pull_port_arg(arg):
    # xxx_port = htons(<port>)
    first = arg.find('(')
    second = arg.rfind(')')
    return int(arg[first+1:second])


def parse_endpoint(strace_line):
    # connect(AF_INET, ... sin_port=htons(<port>), ... sin_addr=inet_addr("<ip>")
    # connect(AF_INET6, ... sin6_port=htons(<port>), ... sin6_addr=inet_pton(... ,"<ip>",...)
    # sendto(fd, ... {sin_port=htons(<port>), sin_addr=inet_addr("<ip>")})
    # and the ipv6 counter part
    # recvfrom(fd, ... {sin_port=htons(<port>), sin_addr=inet_addr("<ip>")})
    # sendmsg, recvmsg not seen so far, leave them
    port = -1
    ip = ""
    args = get_args(strace_line)
    if strace_line.startswith("connect"):
        addr_args = scan_args(args[1])
    else:
        if args[4].strip() == "NULL":
            return None, None
        addr_args = scan_args(args[4])

    port = pull_port_arg(addr_args[1])
    ip = resolve_ip(addr_args[2])
    return ip, port



class Proc:
    def __init__(self, pid):
        self.pid = pid
        self.children = []
        self.remote_endpoints = set()
        self.cmd = None
        self.args = []

    def append(self, child):
        self.children.append(child)

    def setexec(self, cmd, args):
        self.cmd = cmd
        self.args = args

    def add_comm(self, ip, port):
        self.remote_endpoints.add((ip,port))

    def dump(self):
        print("\tcmd: %s, args: %s" % (self.cmd, self.args))
        if len(self.children) > 0:
            print("\tchildren: %s" % (",".join(map(lambda i: str(i), self.children))))
        if len(self.remote_endpoints) > 0:
            print("\tendpoints:")
            for ip,port in self.remote_endpoints:
                print("\t\t%s:%s" % (ip, port))

def is_failure(strace_line):
    try:
        return int(strace_line.split("=")[-1]) < 0
    except ValueError:
        return True

def extract_relationships(trace_path):
    traces = os.listdir(trace_path)
    results = {}
    parent = {}
    for tfile in traces:
        # skip the script and special files
        if tfile.endswith(".sh") or tfile.startswith("."):
            continue
        mypid = parse_pid(tfile)
        results[mypid] = Proc(mypid)
        with open(os.path.join(trace_path, tfile), "r") as f:
            for l in f:
                l = l.strip()
                if l.startswith("clone(") or l.startswith("vfork("):
                    # mark the children
                    if is_failure(l):
                        print("skipped line %s" % l)
                        continue
                    childpid = parse_childpid(l)
                    results[mypid].append(childpid)
                    parent[childpid] = mypid
                elif l.startswith("execve("):
                    if is_failure(l):
                        print("skipped line %s" % l)
                        continue
                    # extract the cmd name
                    results[mypid].setexec(*parse_cmd(l))
                elif l.startswith("connect(") or l.startswith("sendto") or \
                        l.startswith("recvfrom("):
                    # extract the communication address
                    # skip if the result is none 0
                    if is_failure(l):
                        print("skipped line %s" % l)
                        continue
                    if l.find("AF_UNSPEC") != -1 or l.find("AF_NETLINK") != -1:
                        continue
                    ip, port = parse_endpoint(l)
                    if ip:
                        results[mypid].add_comm(ip, port)

    # backfill the cmd if child does not invoke execve
    for pid, p in results.iteritems():
        if p.cmd == None:
            cur = p
            backfill = []
            fillcmd = "default"
            fillargs = "default"
            while cur.cmd == None:
                backfill.append(cur)
                ppid = parent.get(cur.pid)
                if ppid == None:
                    break
                pp = results[ppid]
                if pp.cmd != None:
                    fillcmd = pp.cmd
                    fillargs = pp.args
                    break
                cur = pp
            for child in backfill:
                child.setexec(fillcmd, fillargs)

    return results

def gen_label(p):
    if len(p.args) > 0:
        escaped_args = map(lambda arg: urllib.quote(arg.replace('|', "\\|"), safe=''), p.args[1:])
        index = 0
        arg_labels = []
        for arg in escaped_args:
            arg_labels.append("<a%d> %s" % (index, arg))
            index += 1
        return '<fpid> %d | <f0> %s | %s' % (p.pid, p.cmd, "|".join(arg_labels))
    else:
        return '<fpid> %d | <f0> %s' % (p.pid, p.cmd)


def gen_port_label(ip, ports):
    if len(ports) == 0:
        return "<ip> %s | <port> noport" % ip
    else:
        port_labels = []
        for p in ports:
            port_labels.append("<f%d> %d" % (p, p))
        return " <ip> %s | %s " % (ip, "|".join(port_labels))


if __name__ == "__main__":
    default_path = "cleaned"
    if len(sys.argv) > 1:
        default_path = sys.argv[1]
    results = extract_relationships(default_path)
    g = pgv.AGraph(strict=True, directed=True)
    all_ips = {}
    g.graph_attr.update(rankdir="LR")
    g.node_attr.update(shape='record',fontsize=14)
    for pid, p in results.iteritems():
        g.add_node(pid, label=gen_label(p))
        node = g.get_node(pid)
        for ip, port in p.remote_endpoints:
            if not ip in all_ips:
                all_ips[ip] = []
            all_ips[ip].append(port)
    for ip, ports in all_ips.iteritems():
        g.add_node(ip, label=gen_port_label(ip, ports),color="blue")
    for pid, p in results.iteritems():
        for child in p.children:
            g.add_edge(pid, child)
        for ip, port in p.remote_endpoints:
            g.add_edge(pid, ip, headport="f%d" % port, color="blue")

    g.write("test.dot")
















