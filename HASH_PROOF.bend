import Base
import ./src/sha256.bend as H
import ./vendor/bend_sha256/fips.bend as FIPS
import ./vendor/bend_sha256/LAWS.bend as SHA_Laws
import ./vendor/bend_sha256/CORRECTNESS.bend as Checked

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
