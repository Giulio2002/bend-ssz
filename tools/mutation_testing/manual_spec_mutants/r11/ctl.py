import sys, json, concurrent.futures as cf
sys.path.insert(0, "tools/mutation_testing/manual_spec_mutants")
from runner import check
A="proofs/api/"
R=[A+"FuluBeaconBlockBody_decode_ssz_proof_generated.bend", A+"FuluExecutionPayload_decode_ssz_proof_generated.bend", A+"ComplexTestStruct_decode_ssz_proof_generated.bend", A+"CompatibleUnionABCA_decode_ssz_proof_generated.bend"]
with cf.ThreadPoolExecutor(4) as ex:
    for r, c in zip(R, ex.map(lambda r: check(".", ".", r, 120), R)):
        print(r, c["verdict"], c["secs"], c["msg"][:200], flush=True)
