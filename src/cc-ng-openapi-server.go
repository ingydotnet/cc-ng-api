package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	if _, err := os.Stat("./v2/openapi.json"); os.IsNotExist(err) {
		panic("./v2/openapi.json does not exist.")
	}
	if _, err := os.Stat("./v3/openapi.json"); os.IsNotExist(err) {
		panic("./v3/openapi.json does not exist.")
	}

	http.HandleFunc("/v2/openapi", func(w http.ResponseWriter, r *http.Request) {
		dat, err := ioutil.ReadFile("./v2/openapi.json")
		check(err)
		fmt.Fprint(w, string(dat))
	})
	http.HandleFunc("/v3/openapi", func(w http.ResponseWriter, r *http.Request) {
		dat, err := ioutil.ReadFile("./v3/openapi.json")
		check(err)
		fmt.Fprint(w, string(dat))
	})

	fmt.Println("Running on http://localhost:8080")

	log.Fatal(http.ListenAndServe(":8080", nil))
}

func check(e error) {
	if e != nil {
		panic(e)
	}
}
