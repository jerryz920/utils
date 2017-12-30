
.PHONY: all clean

LDFLAGS = $(shell pkg-config --libs protobuf)
CFLAGS = $(shell pkg-config --cflags protobuf) -std=c++14

all: test
	
test: example.pb.o test.o
	g++ $(CFLAGS) -o test $^ $(LDFLAGS)

example.pb.o: example.pb.cc
	g++ -c $(CFLAGS) $^ -o $@

example.pb.cc example.pb.h: example.proto
	protoc --cpp_out=. $^

test.o: example.pb.h test.cc
	g++ -c $(CFLAGS) test.cc -o $@


clean:
	rm -f *.o test


