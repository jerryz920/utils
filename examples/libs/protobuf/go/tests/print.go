package main

import (
	"fmt"
	"io/ioutil"
	"os"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
	example "github.com/jerryz920/utils/examples/libs/protobuf/go"
)

func readback(name string) example.Statement {
	sdata, err := ioutil.ReadFile(name)
	if err != nil {
		fmt.Println("error reading the file tmp: ", err)
		os.Exit(1)
	}

	var s1 example.Statement
	if err = proto.Unmarshal(sdata, &s1); err != nil {
		fmt.Printf("error unmarshal data from %s %s:", name, err)
		os.Exit(1)
	}
	return s1
}

func main() {
	var s example.Statement = example.Statement{
		Keyvalues: make(map[string]uint64),
	}

	s.Id = 1
	s.Type = example.Statement_ATTEST
	s.Heroes = &example.Statement_Justice{"1234"}
	s.Keyvalues["1"] = 19412
	s.Auths = append(s.Auths, &example.Statement_AuthID{"1.1.1.1", 100, 200})
	any, err := ptypes.MarshalAny(&example.Statement_AuthID{"2.2.2.2", 1000, 2000})
	if err != nil {
		fmt.Println("error in marshal any message ", err)
		os.Exit(1)
	}

	s.Details = any
	ss := s.String()
	ioutil.WriteFile("tmp", []byte(ss), 0644)

	data, err := proto.Marshal(&s)
	if err != nil {
		fmt.Println("error marshaling protobuf: ", err)
		os.Exit(1)
	}

	ioutil.WriteFile("tmp1", data, 0644)

	s2 := readback("tmp1")
	fmt.Println("keyvalue: ", s2.Keyvalues["1"])
}
