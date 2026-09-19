package main

import (
	"bytes"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"github.com/attestantio/go-eth2-client/spec/fulu"
	"os"
	"runtime"
	"strconv"
	"time"
)

var sinkBytes []byte
var sinkRoot [32]byte
var sinkState *fulu.BeaconState

func must(err error) {
	if err != nil {
		panic(err)
	}
}
func main() {
	runtime.GOMAXPROCS(1)
	data, err := os.ReadFile(os.Args[1])
	must(err)
	expected, err := hex.DecodeString(os.Args[2])
	must(err)
	count, err := strconv.Atoi(os.Args[3])
	must(err)
	state := new(fulu.BeaconState)
	must(state.UnmarshalSSZ(data))
	encoded, err := state.MarshalSSZ()
	must(err)
	if !bytes.Equal(data, encoded) {
		panic("bytes mismatch")
	}
	root, err := state.HashTreeRoot()
	must(err)
	if !bytes.Equal(root[:], expected) {
		panic("root mismatch")
	}
	ops := []struct {
		name string
		run  func()
	}{
		{"deserialize", func() { s := new(fulu.BeaconState); must(s.UnmarshalSSZ(data)); sinkState = s }},
		{"serialize", func() { var e error; sinkBytes, e = state.MarshalSSZ(); must(e) }},
		{"hash_tree_root", func() { var e error; sinkRoot, e = state.HashTreeRoot(); must(e) }},
	}
	results := map[string]any{}
	for _, op := range ops {
		op.run()
		samples := []float64{}
		counts := []int{}
		for s := 0; s < count; s++ {
			n := 0
			start := time.Now()
			for time.Since(start) < 300*time.Millisecond {
				op.run()
				n++
			}
			samples = append(samples, float64(time.Since(start).Nanoseconds())/float64(n))
			counts = append(counts, n)
		}
		results[op.name] = map[string]any{"ns_per_op": samples, "iterations": counts}
	}
	must(json.NewEncoder(os.Stdout).Encode(map[string]any{"implementation": "fastssz/go", "bytes": len(data), "verified": true, "operations": results, "go": runtime.Version()}))
	fmt.Fprintln(os.Stderr, "fastssz complete")
}
