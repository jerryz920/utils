#!/usr/bin/python


from xml.etree import cElementTree as ET
import requests
import time
import sys


router_stats="http://192.168.1.254/xslt?PAGE=C_2_5"
dfname1="tmp1.xml"
dfname2="tmp2.xml"


def download(fname):
    resp = requests.get(router_stats)
    requests.exceptions.ProxyError
    if resp.status_code != requests.codes.ok:
        resp.raise_for_status()

    with open(fname, "w") as f:
        f.write(resp.content)

def parse(fname):
    tree = ET.parse(fname)
    result={}
    ns={"default": "http://www.w3.org/1999/xhtml"}
    for item in tree.findall(".//default:form[@action=\"xslt?PAGE=C_2_5_POST_STATS\"]", ns):
        for tb in item:
            if tb.tag.endswith("table"):
                trs = tb.findall("./default:tr", ns)
                for tr in trs:
                    tds = tr.findall("default:td", ns)
                    result[tds[0].text] = (float(tds[5].text), float(tds[7].text))

                    #for td in tr.findall("default:td", ns):
                    #    print td.text
    for i in range(1,5):
        result["Port %s" % i] = [0, 0]
    for item in tree.findall(".//default:table[@class=\"centerdata\"]", ns):
        for tr in item:
            if tr.tag.endswith("tr"):
                for i in range(1,5):
                    for td in tr.findall("./default:td[@headers=\"PORTS Port%dTX BYTE\"]" % i, ns):
                        t = float(td.text)
                        result["Port %s" % i][0] = t
                    for td in tr.findall("./default:td[@headers=\"PORTS Port%dRX BYTE\"]" % i, ns):
                        r = float(td.text)
                        result["Port %s" % i][1] = r
    return result

def display(r1, r2, t):

    print "recv: "
    for k, v2 in r2.iteritems():
        v1 = r1.get(k)
        if v1:
            rate = (v2[0] - v1[0]) / t / 1000.0
            if rate > 10:
                print k, rate

    print "send: "
    for k, v2 in r2.iteritems():
        v1 = r1.get(k)
        if v1:
            rate = (v2[1] - v1[1]) / t / 1000.0
            if rate > 10:
                print k, rate




def monitor(fetch):
    if fetch:
        download(dfname1)
        t1 = time.time()
    else:
        t1 = 0
    time.sleep(2)

    if fetch:
        download(dfname2)
        t2 = time.time()
    else:
        t2 = 2
    res1 = parse(dfname1)
    res2 = parse(dfname2)
    display(res1, res2, t2-t1)


if __name__ == "__main__":

    if len(sys.argv) >= 2:
        monitor(False)
    else:
        while True:
            monitor(True)



