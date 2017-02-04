package main

import "C"

//export GoAdd
func GoAdd(a, b C.int) C.int {
	return a + b
}

func main() {} // Required but ignored
