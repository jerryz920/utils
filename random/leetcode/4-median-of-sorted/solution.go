package main

import (
	"log"
	"math"
	"math/rand"
	"sort"
)

func median(v []int) float64 {
	if len(v)%2 == 0 {
		i := len(v) / 2
		j := len(v)/2 - 1
		return float64(v[i]+v[j]) / 2
	} else {
		return float64(v[(len(v)-1)/2])
	}
}

func findMedianSortedArrays(nums1 []int, nums2 []int) float64 {

	if len(nums1) == 0 && len(nums2) == 0 {
		return 0
	}
	if len(nums1) == 0 {
		return median(nums2)
	}
	if len(nums2) == 0 {
		return median(nums1)
	}

	if len(nums1) > len(nums2) {
		nums1, nums2 = nums2, nums1
	}

	left, right, half := 0, len(nums1), (len(nums1)+len(nums2)+1)/2

	for left <= right {
		i := (left + right) / 2
		j := half - i
		/// Try to find an i so that nums2[j-1] < nums[i] and nums1[i-1] < nums2[j]
		if i < len(nums1) && nums2[j-1] > nums1[i] {
			left = i + 1
		} else if i > 0 && nums1[i-1] > nums2[j] {
			right = i - 1
		} else {
			var maxleft, maxright = 0.0, 0.0
			if i == 0 {
				maxleft = float64(nums2[j-1])
			} else if j == 0 {
				maxleft = float64(nums1[i-1])
			} else {
				maxleft = math.Max(float64(nums1[i-1]), float64(nums2[j-1]))
			}

			if (len(nums1)+len(nums2))%2 == 1 {
				return maxleft
			}
			if i == len(nums1) {
				maxright = float64(nums2[j])
			} else if j == len(nums2) {
				maxright = float64(nums1[i])
			} else {
				maxright = math.Min(float64(nums1[i]), float64(nums2[j]))
			}
			return (maxleft + maxright) / 2.0
		}
	}

	return 0.0
}

var (
	tests = [][3][]int{
		[3][]int{
			[]int{1, 2},
			[]int{3, 4},
			[]int{2, 3},
		},
		[3][]int{
			[]int{1, 3},
			[]int{2},
			[]int{2},
		},
		[3][]int{
			[]int{1},
			[]int{2},
			[]int{1, 2},
		},
		[3][]int{
			[]int{},
			[]int{2},
			[]int{2},
		},
		[3][]int{
			[]int{1},
			[]int{},
			[]int{1},
		},
		[3][]int{
			[]int{1, 2, 3, 4},
			[]int{},
			[]int{2, 3},
		},
		[3][]int{
			[]int{1, 2, 5},
			[]int{2},
			[]int{2, 2},
		},
		[3][]int{
			[]int{1, 5},
			[]int{2},
			[]int{2},
		},
		[3][]int{
			[]int{2, 5},
			[]int{2},
			[]int{2},
		},
		[3][]int{
			[]int{1, 5, 5},
			[]int{2},
			[]int{2, 5},
		},
		[3][]int{
			[]int{1, 2, 5},
			[]int{2, 3},
			[]int{2},
		},
		[3][]int{
			[]int{1, 3, 4, 5},
			[]int{2, 6, 7},
			[]int{4},
		},
		[3][]int{
			[]int{1, 3, 4, 5},
			[]int{2, 3, 4, 6},
			[]int{3, 4},
		},
	}
)

func generate(n int) {
	for i := 0; i < n; i++ {

		data := [3][]int{
			make([]int, 0),
			make([]int, 0),
			make([]int, 0),
		}

		n1 := rand.Intn(1000) + 1
		n2 := rand.Intn(1000) + 1

		for j := 0; j < n1; j++ {
			data[0] = append(data[0], rand.Intn(1000))
		}
		for j := 0; j < n2; j++ {
			data[1] = append(data[1], rand.Intn(1000))
		}
		sort.Ints(data[0])
		sort.Ints(data[1])
		tmp := make([]int, 0, n1+n2)
		tmp = append(tmp, data[0]...)
		tmp = append(tmp, data[1]...)
		sort.Ints(tmp)

		if len(tmp)%2 == 0 {
			data[2] = append(data[2], tmp[len(tmp)/2-1])
			data[2] = append(data[2], tmp[len(tmp)/2])
		} else {
			data[2] = append(data[2], tmp[(len(tmp)-1)/2])
		}
		tests = append(tests, data)
	}
}

func run() {
	for i := 0; i < len(tests); i++ {
		input := tests[i]
		out := float64(findMedianSortedArrays(input[0], input[1]))
		if len(input[2]) == 2 {
			if math.Abs(out-float64(input[2][0]+input[2][1])/2.0) > 1E-4 {
				log.Fatal("fails on input %v, output is %v\n", input, out)
			}
		} else if math.Abs(out-float64(input[2][0])) > 1E-4 {
			log.Fatal("fails on input %v, output is %v\n", input, out)
		}
	}
}

func main() {
	/// Add some random tests
	generate(1)
	run()

}
