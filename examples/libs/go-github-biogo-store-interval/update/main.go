package main

import (
	"fmt"

	"github.com/biogo/store/interval"
)

type IntIndex struct {
	Id    uintptr
	L     int
	R     int
	Value int
}

func (i IntIndex) Overlap(other interval.IntRange) bool {
	return i.L < other.End && i.R > other.Start
}

func (i IntIndex) ID() uintptr {
	return uintptr(i.Id)
}

func (i IntIndex) Range() interval.IntRange {
	return interval.IntRange{i.L, i.R}
}

func main() {

	tree := interval.IntTree{}
	///// Note that if we put in &IntIndex later we could change the values.
	tree.Insert(IntIndex{1, 2, 5, 1}, false)
	tree.Insert(IntIndex{2, 3, 6, 1}, false)
	tree.Insert(IntIndex{3, 4, 7, 1}, false)
	tree.Insert(IntIndex{4, 5, 8, 1}, false)

	vals := tree.Get(&IntIndex{1, 3, 6, 0})
	for _, v := range vals {
		fmt.Printf("range = %v\n", v.Range())
		x := v.(IntIndex)
		fmt.Printf("value = %d\n", x.Value)
		x.Value += 2
	}
	vals = tree.Get(&IntIndex{1, 3, 6, 0})
	for _, v := range vals {
		fmt.Printf("range = %v\n", v.Range())
		x := v.(IntIndex)
		fmt.Printf("value = %d\n", x.Value)
	}
}
