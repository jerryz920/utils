package numtheory

import (
	"fmt"
)

// accepts two list of integers, compute such that
// x = a0 mod n0
// x = a1 mod n1
// x = a2 mod n2
// ...
func ChineseReminder(a []int64, n []int64) (int64, error) {
	if a == nil || n == nil || len(a) != len(n) {
		return 0, fmt.Errorf("invalid argument")
	}

	/// There is risk of overflow anyway...
	var product int64 = 1
	for _, ni := range n {
		product *= ni
	}

	var sum int64 = 0
	for i, ni := range n {
		_, x, _ := ExtendedGcd(product/ni, ni)
		sum += (a[i] * (product / ni) * x) % product
	}
	return sum, nil
}
