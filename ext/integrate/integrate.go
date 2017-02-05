package main

import (
	"io/ioutil"
	"net/http"
	"runtime"

	"github.com/jeffail/tunny"
)

import "C"

var pool *tunny.WorkPool

type DownloadResult struct {
	err  error
	data string
}

// export Init
func Init() *C.char {
	numCPUs := runtime.NumCPU()
	runtime.GOMAXPROCS(numCPUs + 1)

	var err error
	pool, err = tunny.CreatePool(numCPUs, func(arg interface{}) interface{} {
		url, _ := arg.(string)

		resp, downloadErr := http.Get(url)
		if downloadErr != nil {
			return DownloadResult{err: downloadErr, data: ""}
		}

		text, readErr := ioutil.ReadAll(resp.Body)
		if readErr != nil {
			return DownloadResult{data: "", err: readErr}
		}

		return DownloadResult{data: string(text), err: nil}
	}).Open()

	if err != nil {
		return C.CString(err.Error())
	}

	return C.CString("")
}

// export DownloadChapters
func DownloadChapters(chapters **C.char, length C.int) {

}

//export GoAdd
func GoAdd(a, b C.int) C.int {
	return a + b
}

func main() {} // Required but ignored
