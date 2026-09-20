import Base
import ../src/ssz.bend as API
import ../types/schema.bend as T
import ../types/primitive.bend as Primitive
import ./schemas.bend as Names

# Native benchmark driver: one measured operation, repeated `SSZ_OPS` times,
# on one workload of one type.
#
# Only the public API is measured (`API.deserialize`, `API.serialize`,
# `API.hash_tree_root`); the compact decoder is reached through it exactly as
# a caller would reach it. Everything else - reading the file, selecting the
# schema, and for the serialize and root operations decoding the input once to
# obtain the value - happens outside the timed window, and the reference
# driver excludes the symmetric preparation.
#
# Each iteration's result is folded into an accumulator that is carried into
# the next iteration and printed at the end, so no call can be dropped, and
# the loop cannot collapse to a single evaluation.

def settle() -> IO(Unit): IO.sleep(5)

def sized(pair: File & Result<&1, &1, U32 & String, U32>) -> IO(File & U32):
  (file, result) = pair
  do IO<File & U32>:
    n : U32 <- IO.pass(U32, result)
    return (file, n)

def loaded(pair: File & Result<&1, &1, U32 & String, +List<U32>>) -> IO(+List<U32>):
  (file, result) = pair
  do IO<+List<U32>>:
    File.close(file)
    IO.pass(+List<U32>, result)

def read_sized(handle: File & U32, +path: String) -> IO(+List<U32>):
  (file, +size) = handle
  do IO<+List<U32>>:
    File.close(file)
    opened : File <- IO.try(File, File.open(path, "r"))
    pair : File & Result<&1, &1, U32 & String, +List<U32>> <- File.read_at(opened, 0, size)
    loaded(pair)

def read_all(+path: String) -> IO(+List<U32>):
  do IO<+List<U32>>:
    file : File <- IO.try(File, File.open(path, "r"))
    pair : File & Result<&1, &1, U32 & String, U32> <- File.size(file)
    got : File & U32 <- sized(pair)
    read_sized(got, path)

def env(name: String) -> IO(String): IO.try(String, IO.get_env(name))

def chosen(r: Maybe<&2, T.Schema>) -> IO(T.Schema):
  match r:
    case None{}: IO.die(T.Schema, 2, "unknown type name")
    case Some{s}: IO.pure(T.Schema, s)

def counted(r: Maybe<&2, Nat>) -> IO(Nat):
  match r:
    case None{}: IO.die(Nat, 2, "SSZ_OPS is not a number")
    case Some{n}: IO.pure(Nat, n)

def decoded(r: Maybe<&2, T.Value>) -> IO(T.Value):
  match r:
    case None{}: IO.die(T.Value, 1, "deserialize rejected the workload")
    case Some{v}: IO.pure(T.Value, v)

def bytes_of(r: Maybe<&2, +List<U32>>) -> IO(+List<U32>):
  match r:
    case None{}: IO.die(+List<U32>, 1, "operation rejected the workload")
    case Some{v}: IO.pure(+List<U32>, v)

# Consume a result: every byte and every leaf contributes to the accumulator.
def fold_bytes(bs: +List<U32>, acc: U32) -> U32:
  match bs:
    case Nil{}: acc
    case Con{b, t}: fold_bytes(t, U32.add(acc, b))

def fold_uint(u: Primitive.UInt) -> U32:
  match u:
    case Primitive.UInt{a, b, c, d, e, f, g, h}: U32.add(U32.add(U32.add(a, b), U32.add(c, d)), U32.add(U32.add(e, f), U32.add(g, h)))

def fold_bits(bs: +List<Bool>, acc: U32) -> U32:
  match bs:
    case Nil{}: acc
    case Con{b, t}: fold_bits(t, U32.add(acc, Bool.to_u32(b)))

def fold_value(v: T.Value, acc: U32) -> U32:
  match v:
    case T.BooleanValue{b}: U32.add(acc, Bool.to_u32(b))
    case T.UnsignedValue{u}: U32.add(acc, fold_uint(u))
    case T.BytesValue{bs}: fold_bytes(bs, acc)
    case T.BitsValue{bs}: fold_bits(bs, acc)
    case T.Sequence{items}: fold_value(items, acc)
    case T.Items{h, t}: fold_value(t, fold_value(h, acc))
    case T.EmptyItems{}: acc
    case T.Selected{s, x}: fold_value(x, U32.add(acc, s))
    case T.NullValue{}: acc

def maybe_value(r: Maybe<&2, T.Value>, acc: U32) -> U32:
  match r:
    case None{}: acc
    case Some{v}: fold_value(v, acc)

def maybe_bytes(r: Maybe<&2, +List<U32>>, acc: U32) -> U32:
  match r:
    case None{}: acc
    case Some{bs}: fold_bytes(bs, acc)

# The measured loops. The accumulator carries a data dependency from each
# iteration into the next.
def loop_deserialize(+n: Nat, +schema: T.Schema, +input: +List<U32>, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop_deserialize(p, schema, input, maybe_value(API.deserialize(schema, input), acc))

def loop_serialize(+n: Nat, +schema: T.Schema, +value: T.Value, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop_serialize(p, schema, value, maybe_bytes(API.serialize(schema, value), acc))

def loop_root(+n: Nat, +schema: T.Schema, +value: T.Value, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p: loop_root(p, schema, value, maybe_bytes(API.hash_tree_root(schema, value), acc))

def report(+op: String, +ops: Nat, +start: Nat, +stop: Nat, +acc: U32) -> IO(Unit):
  IO.print("OP=" ++ op ++ " OPS=" ++ Nat.show(ops) ++ " MS=" ++ Nat.show(Nat.sub(stop, start)) ++ " CHECK=" ++ U32.show(acc))

def run_deserialize(+ops: Nat, +schema: T.Schema, +input: +List<U32>) -> IO(Unit):
  do IO<Unit>:
    settle()
    start : Nat <- IO.now()
    acc : U32 = loop_deserialize(ops, schema, input, 0)
    stop : Nat <- IO.now()
    report("deserialize", ops, start, stop, acc)

def run_serialize(+ops: Nat, +schema: T.Schema, +value: T.Value) -> IO(Unit):
  do IO<Unit>:
    settle()
    start : Nat <- IO.now()
    acc : U32 = loop_serialize(ops, schema, value, 0)
    stop : Nat <- IO.now()
    report("serialize", ops, start, stop, acc)

def run_root(+ops: Nat, +schema: T.Schema, +value: T.Value) -> IO(Unit):
  do IO<Unit>:
    settle()
    start : Nat <- IO.now()
    acc : U32 = loop_root(ops, schema, value, 0)
    stop : Nat <- IO.now()
    report("hash_tree_root", ops, start, stop, acc)

# Correctness before timing: the workload must decode, re-serialize to exactly
# the input bytes, and produce a root. The checks are printed for the harness
# to compare against the reference implementation and are not timed.
def equal_bytes(a: +List<U32>, b: +List<U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Nil{} Con{y, ys}: False{}
    case Con{x, xs} Nil{}: False{}
    case Con{x, xs} Con{y, ys}: Bool.and(U32.is_eq(x, y), equal_bytes(xs, ys))

def verify(+schema: T.Schema, +input: +List<U32>, +value: T.Value) -> IO(Unit):
  do IO<Unit>:
    encoded : +List<U32> <- bytes_of(API.serialize(schema, value))
    digest : +List<U32> <- bytes_of(API.hash_tree_root(schema, value))
    IO.print("ROUNDTRIP=" ++ Bool.show(equal_bytes(encoded, input)) ++ " ROOTSUM=" ++ U32.show(fold_bytes(digest, 0)))

def verify_if(ok: Bool, +schema: T.Schema, +input: +List<U32>, +value: T.Value) -> IO(Unit):
  match ok:
    case False{}: IO.pure(Unit, Unit{})
    case True{}: verify(schema, input, value)

def dispatch_root(is_root: Bool, +ops: Nat, +schema: T.Schema, +value: T.Value) -> IO(Unit):
  match is_root:
    case True{}: run_root(ops, schema, value)
    case False{}: IO.die(Unit, 2, "unknown operation")

def dispatch_serialize(is_serialize: Bool, +op: String, +ops: Nat, +schema: T.Schema, +value: T.Value) -> IO(Unit):
  match is_serialize:
    case True{}: run_serialize(ops, schema, value)
    case False{}: dispatch_root(String.eq(op, "hash_tree_root"), ops, schema, value)

def dispatch(is_deserialize: Bool, +op: String, +ops: Nat, +schema: T.Schema, +input: +List<U32>, +value: T.Value) -> IO(Unit):
  match is_deserialize:
    case True{}: run_deserialize(ops, schema, input)
    case False{}: dispatch_serialize(String.eq(op, "serialize"), op, ops, schema, value)

def main() -> IO(Unit):
  do IO<Unit>:
    name : String <- env("SSZ_TYPE")
    path : String <- env("SSZ_INPUT")
    +op : String <- env("SSZ_OP")
    count : String <- env("SSZ_OPS")
    +ops : Nat <- counted(Nat.read(count))
    +schema : T.Schema <- chosen(Names.schema_of(name))
    +input : +List<U32> <- read_all(path)
    +value : T.Value <- decoded(API.deserialize(schema, input))
    +check : String <- env("SSZ_VERIFY")
    verify_if(String.eq(check, "1"), schema, input, value)
    dispatch(String.eq(op, "deserialize"), op, ops, schema, input, value)
