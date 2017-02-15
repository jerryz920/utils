
.phony: clean all


all: ipshow

ipshow: ipshow.c
	gcc -g $^ -o $@ -I/usr/include/libnl3 -lnl-3 -lnl-route-3

clean:
	rm -f ipshow
