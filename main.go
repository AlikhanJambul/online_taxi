package main

import "fmt"

func main() {
	test1 := []int{1, 2, 1, 2, 1, 2, 3, 1, 3, 2}
	test2 := []int{1}
	test3 := []int{3, 3, 3, 2, 2, 1}

	fmt.Println(topKFrequent(test1, 2))
	fmt.Println(topKFrequent(test2, 1))
	fmt.Println(topKFrequent(test3, 2))

}

func topKFrequent(nums []int, k int) []int {
	mp := make(map[int]int)

	for _, r := range nums {
		mp[r]++
	}

	slc := make([][]int, len(nums)+1, len(nums)+1)

	for k, v := range mp {
		str := fmt.Sprintf("key: %d, value: %d\n", k, v)

		fmt.Println(str)

		slc[v] = append(slc[v], k)
	}

	fmt.Println(slc)

	result := []int{}

	for i := len(slc) - 1; i >= 0; i-- {
		if len(slc[i]) == 0 {
			continue
		}

		result = append(result, slc[i]...)
	}

	return result[:k]
}

//if len(slc[i]) == k && len(result) == 0 {
//	result = slc[i]
//	break
//}
//
//
