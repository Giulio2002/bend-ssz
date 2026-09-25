import Base
import ./src/sha256.bend as H
import 0xe4067e0d858024083f36a7abe7281e89/spec/crypto/sha.bend as FIPS
import 0xe4067e0d858024083f36a7abe7281e89/proofs/crypto/sha/laws.bend as SHA_Laws
import 0xe4067e0d858024083f36a7abe7281e89/proofs/crypto/sha/correctness.bend as Checked

law hash_refines_fips:
  for +xs: +List<U32>
  {H.hash(xs) == FIPS.sha256_bytes(xs) : +List<U32>}

def hash_refines_fips(xs):
  SHA_Laws.sha256_bytes_correct(xs)

law hash_length:
  for +xs: +List<U32>
  {List.length(&2, U32, H.hash(xs)) == 32n : Nat}

def hash_length(xs):
  SHA_Laws.sha256_bytes_length(xs)
