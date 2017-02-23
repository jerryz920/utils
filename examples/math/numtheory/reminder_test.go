package numtheory

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestChineseReminder(t *testing.T) {
	a := []int64{2, 3, 2}
	n := []int64{3, 5, 7}

	v, _ := ChineseReminder(a, n)
	assert.Equal(t, v, int64(23), "reminder output")

}
