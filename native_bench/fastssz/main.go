// Reference side of the native comparison: pinned fastssz / go-eth2-client.
//
// The workload and the phase boundaries mirror native_bench/driver.bend
// exactly: read the file, print a marker and sleep so the harness can read
// resident size while this process is idle, decode, force the decoded value
// with a checksum fold, mark, serialize, mark, write, mark. Go's own
// allocator high-water is printed next to the harness measurement because the
// Go runtime, unlike the Bend runtime, can return memory to the system.
package main

import (
	"fmt"
	"os"
	"runtime"
	"time"

	"github.com/attestantio/go-eth2-client/spec/fulu"
	"github.com/attestantio/go-eth2-client/spec/phase0"
)

func must(err error) {
	if err != nil {
		panic(err)
	}
}

func settle() {
	time.Sleep(150 * time.Millisecond)
}

// Touch every decoded field so the value is fully materialised and consumed
// inside the measured window, like the Bend driver's checksum fold.
func checksum(state *fulu.BeaconState) uint64 {
	var sum uint64
	sum += state.GenesisTime + uint64(state.Slot) + uint64(state.Fork.Epoch)
	for _, r := range state.GenesisValidatorsRoot {
		sum += uint64(r)
	}
	for _, root := range state.BlockRoots {
		for _, b := range root {
			sum += uint64(b)
		}
	}
	for _, root := range state.StateRoots {
		for _, b := range root {
			sum += uint64(b)
		}
	}
	for _, root := range state.HistoricalRoots {
		for _, b := range root {
			sum += uint64(b)
		}
	}
	for _, mix := range state.RANDAOMixes {
		for _, b := range mix {
			sum += uint64(b)
		}
	}
	for _, v := range state.Slashings {
		sum += uint64(v)
	}
	for _, v := range state.Balances {
		sum += uint64(v)
	}
	for _, v := range state.InactivityScores {
		sum += v
	}
	for _, v := range state.Validators {
		sum += uint64(v.EffectiveBalance) + uint64(v.ActivationEpoch)
		for _, b := range v.PublicKey {
			sum += uint64(b)
		}
	}
	for _, p := range state.PreviousEpochParticipation {
		sum += uint64(p)
	}
	for _, p := range state.CurrentEpochParticipation {
		sum += uint64(p)
	}
	for _, c := range []*phase0.Checkpoint{state.PreviousJustifiedCheckpoint, state.CurrentJustifiedCheckpoint, state.FinalizedCheckpoint} {
		sum += uint64(c.Epoch)
		for _, b := range c.Root {
			sum += uint64(b)
		}
	}
	for _, k := range state.CurrentSyncCommittee.Pubkeys {
		for _, b := range k {
			sum += uint64(b)
		}
	}
	for _, k := range state.NextSyncCommittee.Pubkeys {
		for _, b := range k {
			sum += uint64(b)
		}
	}
	for _, s := range state.HistoricalSummaries {
		for _, b := range s.BlockSummaryRoot {
			sum += uint64(b)
		}
	}
	for _, d := range state.PendingDeposits {
		sum += uint64(d.Amount)
	}
	for _, w := range state.PendingPartialWithdrawals {
		sum += uint64(w.Amount)
	}
	for _, c := range state.PendingConsolidations {
		sum += uint64(c.SourceIndex)
	}
	for _, l := range state.ProposerLookahead {
		sum += uint64(l)
	}
	sum += uint64(state.LatestExecutionPayloadHeader.BlockNumber)
	return sum
}

// stop ends the process at a phase boundary. The harness measures a phase's
// true high-water mark by running a fresh process that stops at the end of
// that phase and reading the kernel's peak resident size for the whole
// (identical) prefix, so every phase boundary must be a possible exit.
func stop(state *fulu.BeaconState) {
	fmt.Println("PHASE=stopped")
	runtime.KeepAlive(state)
	settle()
	os.Exit(0)
}

func main() {
	runtime.GOMAXPROCS(1)
	mode := os.Getenv("SSZ_PHASES")
	if mode == "" {
		mode = "all"
	}
	data, err := os.ReadFile(os.Getenv("SSZ_INPUT"))
	must(err)

	fmt.Println("PHASE=baseline")
	settle()
	if mode == "input" {
		stop(nil)
	}

	start := time.Now()
	state := new(fulu.BeaconState)
	must(state.UnmarshalSSZ(data))
	sum := checksum(state)
	elapsed := time.Since(start)
	fmt.Printf("DECODE_NS=%d CHECKSUM=%d\n", elapsed.Nanoseconds(), sum)
	fmt.Println("PHASE=decoded")
	settle()
	if mode == "decode" {
		stop(state)
	}

	rstart := time.Now()
	root, err := state.HashTreeRoot()
	must(err)
	var rootsum uint64
	for _, b := range root {
		rootsum += uint64(b)
	}
	fmt.Printf("ROOT_NS=%d ROOTSUM=%d\n", time.Since(rstart).Nanoseconds(), rootsum)
	fmt.Println("PHASE=rooted")
	settle()
	if mode == "root" {
		stop(state)
	}

	sstart := time.Now()
	encoded, err := state.MarshalSSZ()
	must(err)
	fmt.Printf("SERIALIZE_NS=%d\n", time.Since(sstart).Nanoseconds())
	fmt.Println("PHASE=serialized")
	settle()

	must(os.WriteFile(os.Getenv("SSZ_OUTPUT"), encoded, 0600))
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)
	// Cumulative bytes allocated and address space obtained from the system:
	// neither is a resident high-water mark, they are recorded alongside the
	// kernel measurement as the Go runtime's own accounting.
	fmt.Printf("GO_TOTAL_ALLOC=%d GO_HEAP_SYS=%d\n", stats.TotalAlloc, stats.Sys)
	fmt.Println("PHASE=done")
	runtime.KeepAlive(state)
	runtime.KeepAlive(encoded)
	settle()
}
