# File-time inventory, partial (tools/file_times.py on origin/main 3ff8d509)

State: 371 of 8844 root files timed (tier 0: the e2e witness/comp/decrep/dwh files, in order; proofs/api and the rest not started),
4 checks at a time under nice 19, cpu = user + sys seconds, one run, other workers' load on the machine (cpu inflates with load through the
checker's parallel GC: the same file measured 330 and 555 cpu s; BUN_JSC_numberOfGCMarkers=1 makes cpu close to wall). Raw results: the server,
/srv/ssz-optimization/agents/filetimes/out2/results.jsonl (not in the repository tree).

```
371 files timed, 25 over 120 s of cpu (or timeout/error); 0 with wall > 120 s but cpu below (load artifact)

decrep/comp: 11 files, 4202 cpu s
  cpu    799.8 s  wall   487.9 s   10026 MB pass    e2e/FuluBeaconBlock_e2e_comp_generated.bend  [slowest import: e2e/FuluBeaconBlock_e2e_decrep_generated.bend 532 s]
  cpu    593.5 s  wall   365.6 s    9982 MB pass    e2e/FuluBeaconBlockBody_e2e_comp_generated.bend  [slowest import: e2e/FuluBeaconBlockBody_e2e_decrep_generated.bend 474 s]
  cpu    532.5 s  wall   333.1 s    9230 MB pass    e2e/FuluBeaconBlock_e2e_decrep_generated.bend  [slowest import: e2e/FuluExecutionPayload_e2e_decrep_generated.bend 61 s]
  cpu    474.2 s  wall   295.0 s    9097 MB pass    e2e/FuluBeaconBlockBody_e2e_decrep_generated.bend  [slowest import: e2e/FuluExecutionPayload_e2e_decrep_generated.bend 61 s]
  cpu    455.3 s  wall   286.0 s    9988 MB pass    e2e/FuluSignedBeaconBlock_e2e_comp_generated.bend  [slowest import: e2e/FuluSignedBeaconBlock_e2e_decrep_generated.bend 405 s]
  cpu    404.9 s  wall   251.5 s    9827 MB pass    e2e/FuluSignedBeaconBlock_e2e_decrep_generated.bend  [slowest import: e2e/FuluExecutionPayload_e2e_decrep_generated.bend 61 s]
  cpu    308.3 s  wall   202.7 s    9274 MB pass    e2e/FuluBeaconState_e2e_comp_generated.bend  [slowest import: e2e/FuluBeaconState_e2e_decrep_generated.bend 155 s]
  cpu    175.7 s  wall   117.6 s    7326 MB pass    e2e/FuluLightClientUpdate_e2e_comp_generated.bend  [slowest import: e2e/FuluLightClientUpdate_e2e_decrep_generated.bend 63 s]
  cpu    174.2 s  wall   113.3 s    7352 MB pass    e2e/FuluExecutionPayload_e2e_comp_generated.bend  [slowest import: e2e/FuluExecutionPayload_e2e_decrep_generated.bend 61 s]
  cpu    154.8 s  wall   111.0 s   10552 MB pass    e2e/FuluBeaconState_e2e_decrep_generated.bend
  cpu    128.5 s  wall    93.5 s    7019 MB pass    e2e/FuluHistoricalBatch_e2e_comp_generated.bend

e2e dec: 8 files, 3672 cpu s
  cpu    850.3 s  wall   520.8 s   10009 MB pass    e2e/FuluBeaconBlock_e2e_decode_witness_generated.bend  [slowest import: e2e/FuluBeaconBlock_e2e_comp_generated.bend 800 s]
  cpu    841.1 s  wall   509.4 s    9940 MB pass    e2e/FuluBeaconBlockBody_e2e_decode_witness_generated.bend  [slowest import: e2e/FuluBeaconBlockBody_e2e_comp_generated.bend 593 s]
  cpu    726.0 s  wall   439.6 s    9970 MB pass    e2e/FuluSignedBeaconBlock_e2e_decode_witness_generated.bend  [slowest import: e2e/FuluSignedBeaconBlock_e2e_comp_generated.bend 455 s]
  cpu    596.9 s  wall   360.6 s    7591 MB pass    e2e/FuluLightClientFinalityUpdate_e2e_decode_witness_generated.bend  [slowest import: e2e/FuluLightClientFinalityUpdate_e2e_comp_generated.bend 82 s]
  cpu    192.2 s  wall   180.0 s    7600 MB pass    e2e/FuluLightClientBootstrap_e2e_decode_witness_generated.bend  [slowest import: e2e/FuluLightClientBootstrap_e2e_dwh_all_generated.bend 186 s]
  cpu    186.9 s  wall   123.5 s    7753 MB pass    e2e/ProgressiveComplexTestStruct_e2e_decode_witness_generated.bend  [slowest import: e2e/ProgressiveComplexTestStruct_e2e_comp_generated.bend 90 s]
  cpu    141.1 s  wall   121.9 s    9557 MB pass    e2e/ProgressiveBitsStruct_e2e_decode_witness_generated.bend  [slowest import: e2e/ProgressiveBitsStruct_e2e_comp_generated.bend 111 s]
  cpu    137.5 s  wall   105.4 s   10461 MB pass    e2e/FuluExecutionPayload_e2e_decode_witness_generated.bend  [slowest import: e2e/FuluExecutionPayload_e2e_comp_generated.bend 174 s]

witness: 6 files, 1917 cpu s
  cpu    553.7 s  wall   345.5 s    8957 MB pass    e2e/FuluBeaconState_e2e_witness_generated.bend
  cpu    389.4 s  wall   249.0 s    8696 MB pass    e2e/FuluBeaconBlockBody_e2e_witness_generated.bend
  cpu    309.6 s  wall   197.9 s    8441 MB pass    e2e/FuluBeaconBlock_e2e_witness_generated.bend
  cpu    285.1 s  wall   182.3 s    8705 MB pass    e2e/FuluSignedBeaconBlock_e2e_witness_generated.bend
  cpu    192.8 s  wall   131.8 s    7067 MB pass    e2e/FuluBeaconState_e2e_set_witness_generated.bend
  cpu    186.4 s  wall   175.5 s    5496 MB pass    e2e/FuluLightClientBootstrap_e2e_dwh_all_generated.bend  [slowest import: e2e/FuluLightClientBootstrap_e2e_dwh_base_generated.bend 3 s]
```

## closure_self_times on e2e/FuluBeaconBlockBody_e2e_decrep_generated.bend (partial: 128 of 424 modules)

The file's own definitions cost little: its header (the 77 imports alone) takes 353 s wall of 388 s. The cost is the import closure:
no module adds more than ~10 s of its own definitions (var_winx_ExecutionPayload 10, var_winx_l16_Deposit 7, vua_fixb 5), the closure is
hundreds of modules of 1 to 40 s each (var_winx_BeaconBlockBody 39 s of which 2 s its own).

```
128 of 424 modules measured
   35.4 s self   352.7 s imports   388.2 s full  e2e/FuluBeaconBlockBody_e2e_decrep_generated.bend
   10.2 s self    13.5 s imports    23.7 s full  proofs/obj/var_winx_ExecutionPayload.bend
    7.4 s self    16.1 s imports    23.4 s full  proofs/obj/var_winx_l16_Deposit.bend
    4.8 s self    12.0 s imports    16.8 s full  proofs/obj/vua_fixb.bend
    2.3 s self     5.4 s imports     7.7 s full  proofs/obj/vua_fix.bend
    2.1 s self    37.1 s imports    39.2 s full  proofs/obj/var_winx_BeaconBlockBody.bend
    1.5 s self    15.4 s imports    16.8 s full  proofs/obj/var_winx_ExecutionRequests.bend
    1.4 s self    16.5 s imports    17.9 s full  proofs/obj/var_winx_l16_ProposerSlashing.bend
    1.3 s self     6.4 s imports     7.7 s full  proofs/obj/var_winx_bits131072.bend
    1.1 s self    11.8 s imports    12.9 s full  proofs/obj/var_winx_l8192_DepositRequest.bend
    1.0 s self     9.7 s imports    10.8 s full  proofs/obj/var_winx_Attestation.bend
    1.0 s self     8.7 s imports     9.7 s full  proofs/obj/var_winx_IndexedAttestation.bend
    0.8 s self     7.8 s imports     8.6 s full  proofs/obj/vbx.bend
    0.7 s self     5.4 s imports     6.2 s full  proofs/obj/vbrt.bend
    0.6 s self     4.5 s imports     5.2 s full  proofs/obj/vmul.bend
```
