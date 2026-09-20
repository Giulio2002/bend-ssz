// Reference side of the native SSZ benchmark: pinned go-eth2-client v0.27.2
// (which embeds pinned fastssz v0.1.4 generated code) and, for the contract's
// non-container types, the pinned fastssz hasher used directly.
//
// Usage: go-bench <contract type> <impl key> <input file> <operation> <ops>
//
// The program first checks correctness outside any measured window: the input
// must unmarshal, re-marshal to exactly the input bytes, and produce a root,
// all of which are printed for the harness to compare with the Bend side. It
// then runs the requested operation `ops` times and reports the elapsed
// nanoseconds. Input reading, implementation selection and - for serialize and
// hash_tree_root - the one preparatory unmarshal are outside the timing, which
// mirrors the Bend driver exactly.
package main

import (
	"bytes"
	"fmt"
	"os"
	"runtime"
	"strconv"
	"time"

	ssz "github.com/ferranbt/fastssz"
)

type sszObject interface {
	UnmarshalSSZ([]byte) error
	MarshalSSZ() ([]byte, error)
	HashTreeRoot() ([32]byte, error)
}

// A contract type with no go-eth2-client type: a fixed-width blob or a byte
// list. Marshalling is a copy and hashing uses the pinned fastssz hasher,
// which is what fastssz's generator emits for exactly these shapes.
type simpleSpec struct {
	fixed   bool
	size    int
	limit   int
	boolean bool
}

type simpleValue struct {
	spec simpleSpec
	data []byte
}

func (s *simpleValue) UnmarshalSSZ(b []byte) error {
	if s.spec.fixed {
		if len(b) != s.spec.size {
			return fmt.Errorf("expected %d bytes, got %d", s.spec.size, len(b))
		}
		if s.spec.boolean && b[0] > 1 {
			return fmt.Errorf("not a boolean: 0x%02x", b[0])
		}
	} else if len(b) > s.spec.limit {
		return fmt.Errorf("list of %d bytes exceeds limit %d", len(b), s.spec.limit)
	}
	s.data = make([]byte, len(b))
	copy(s.data, b)
	return nil
}

func (s *simpleValue) MarshalSSZ() ([]byte, error) {
	out := make([]byte, len(s.data))
	copy(out, s.data)
	return out, nil
}

func (s *simpleValue) HashTreeRoot() ([32]byte, error) {
	hh := ssz.NewHasher()
	if s.spec.fixed {
		hh.PutBytes(s.data)
	} else {
		index := hh.Index()
		hh.Append(s.data)
		hh.FillUpTo32()
		hh.MerkleizeWithMixin(index, uint64(len(s.data)), uint64((s.spec.limit+31)/32))
	}
	root, err := hh.HashRoot()
	ssz.DefaultHasherPool.Put(hh)
	return root, err
}

var (
	sinkObject sszObject
	sinkBytes  []byte
	sinkRoot   [32]byte
)

func must(err error) {
	if err != nil {
		panic(err)
	}
}

func build(typeName, impl string) func() sszObject {
	if impl == "simple" {
		spec, ok := simpleSpecs[typeName]
		if !ok {
			panic("no simple specification for " + typeName)
		}
		return func() sszObject { return &simpleValue{spec: spec} }
	}
	make, ok := containerImpls[impl]
	if !ok {
		panic("no reference implementation " + impl)
	}
	return make
}

func main() {
	runtime.GOMAXPROCS(1)
	if len(os.Args) != 6 {
		panic("usage: go-bench <type> <impl> <input> <operation> <ops>")
	}
	typeName, impl, path, operation := os.Args[1], os.Args[2], os.Args[3], os.Args[4]
	ops, err := strconv.Atoi(os.Args[5])
	must(err)
	data, err := os.ReadFile(path)
	must(err)
	create := build(typeName, impl)

	// Correctness first, untimed.
	prepared := create()
	must(prepared.UnmarshalSSZ(data))
	encoded, err := prepared.MarshalSSZ()
	must(err)
	root, err := prepared.HashTreeRoot()
	must(err)
	var rootsum uint64
	for _, b := range root {
		rootsum += uint64(b)
	}
	fmt.Printf("ROUNDTRIP=%v ROOTSUM=%d\n", bytes.Equal(encoded, data), rootsum)

	var acc uint64
	start := time.Now()
	switch operation {
	case "deserialize":
		for i := 0; i < ops; i++ {
			object := create()
			must(object.UnmarshalSSZ(data))
			sinkObject = object
			acc += uint64(len(data))
		}
	case "serialize":
		for i := 0; i < ops; i++ {
			out, err := prepared.MarshalSSZ()
			must(err)
			sinkBytes = out
			acc += uint64(len(out)) + uint64(out[0])
		}
	case "hash_tree_root":
		for i := 0; i < ops; i++ {
			r, err := prepared.HashTreeRoot()
			must(err)
			sinkRoot = r
			acc += uint64(r[0])
		}
	default:
		panic("unknown operation " + operation)
	}
	elapsed := time.Since(start)
	runtime.KeepAlive(sinkObject)
	runtime.KeepAlive(sinkBytes)
	runtime.KeepAlive(sinkRoot)
	fmt.Printf("OP=%s OPS=%d NS=%d CHECK=%d\n", operation, ops, elapsed.Nanoseconds(), acc)
}
