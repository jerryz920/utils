package gcd

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/assert"
)

func test(x, y, expected int64, t *testing.T) {
	var d, a, b int64
	d, a, b = ExtendedGcd(x, y)
	assert.Equal(t, d, expected, fmt.Sprintf("gcd of %d, %d", x, y))
	assert.Equal(t, d, a*x+b*y, fmt.Sprintf("%d * %d + %d * %d = %d", a, x, b, y, d))
}

func TestExtendedGcd(t *testing.T) {
	test(1, 1, 1, t)
	test(1, 2, 1, t)
	test(2, 1, 1, t)
	test(36, 16, 4, t)
	test(2, 2, 2, t)
	test(4, 2, 2, t)
	test(7, 2, 1, t)
	test(2, 7, 1, t)
	test(11, 7, 1, t)
	test(19, 7, 1, t)
	test(91, 13, 13, t)
	test(13, 65, 13, t)
	test(36, 16, 4, t)
	test(36, 63, 9, t)
	test(144, 100, 4, t)
	test(122, 100, 2, t)
	test(120, 100, 20, t)
}
