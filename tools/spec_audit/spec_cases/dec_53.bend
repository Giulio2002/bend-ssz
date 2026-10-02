import Base
import ../../../types/schema.bend as T
import ../../../types/primitive.bend as P
import ../../../spec/codec.bend as Codec
import ../../../spec/primitives.bend as Prim
import ../../../spec/bit_decode.bend as BitDec
import ../../../spec/bytes.bend as Bytes
import ../../../spec/byte_list.bend as ByteList
import ../../../spec/bit_root.bend as BitRoot
import ../../../spec/byte_root.bend as ByteRoot
import ../../../spec/layout_decoding.bend as Lay
import ../../../spec/limits.bend as Limits
import ../../../spec/progressive.bend as Prog
import ../../../spec/mixing.bend as Mix
import ../../../spec/packing.bend as Pack
import ../../../proofs/obj/generic_specs.bend as G
import ../../../spec/fulu_schemas.bend as F

def c872() -> {ByteList.decoding(2n, [5]) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c873() -> {ByteList.decoding(2n, [5]) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c874() -> {ByteList.decoding(2n, [5, 42]) == Some{[5, 42]} : Maybe<&2, +List<U32>>}:
  {==}

def c875() -> {ByteList.decoding(2n, [5, 42, 79]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c876() -> {ByteList.decoding(31n, []) == Some{[]} : Maybe<&2, +List<U32>>}:
  {==}

def c877() -> {ByteList.decoding(31n, [5]) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c878() -> {ByteList.decoding(31n, [5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54]) == Some{[5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54]} : Maybe<&2, +List<U32>>}:
  {==}

def c879() -> {ByteList.decoding(31n, [5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91]) == Some{[5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91]} : Maybe<&2, +List<U32>>}:
  {==}

def c880() -> {ByteList.decoding(31n, [5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91, 128]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c881() -> {ByteList.decoding(32n, []) == Some{[]} : Maybe<&2, +List<U32>>}:
  {==}

def c882() -> {ByteList.decoding(32n, [5]) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c883() -> {ByteList.decoding(32n, [5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91]) == Some{[5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91]} : Maybe<&2, +List<U32>>}:
  {==}

def c884() -> {ByteList.decoding(32n, [5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91, 128]) == Some{[5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c885() -> {ByteList.decoding(32n, [5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91, 128, 165]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c886() -> {ByteList.decoding(33n, []) == Some{[]} : Maybe<&2, +List<U32>>}:
  {==}

def c887() -> {ByteList.decoding(33n, [5]) == Some{[5]} : Maybe<&2, +List<U32>>}:
  {==}

def c888() -> {ByteList.decoding(33n, [5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91, 128]) == Some{[5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91, 128]} : Maybe<&2, +List<U32>>}:
  {==}

def c889() -> {ByteList.decoding(33n, [5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91, 128, 165]) == Some{[5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91, 128, 165]} : Maybe<&2, +List<U32>>}:
  {==}

def c890() -> {ByteList.decoding(33n, [5, 42, 79, 116, 153, 190, 227, 8, 45, 82, 119, 156, 193, 230, 11, 48, 85, 122, 159, 196, 233, 14, 51, 88, 125, 162, 199, 236, 17, 54, 91, 128, 165, 202]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c891() -> {Bytes.vector_decoding(2n, [1, 256]) == None{} : Maybe<&2, +List<U32>>}:
  {==}

def c892() -> {BitDec.bitlist_deserialize(8n, [1, 1000]) == None{} : Maybe<&2, +List<Bool>>}:
  {==}
