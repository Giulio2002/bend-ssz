import Base
import ../../../src/buffer.bend as B
import ../../../src/obj.bend as O
import ../../../benchmarks/compact/objio.bend as IOx

# Crash hunt round 5, probe R: the O.* copy helpers on edge counts (inputs of one or two words). SSZ_CASE, SSZ_ARG = n:
#  1 O.words_slice(Words{2 words, 8}, 0, n)         2 O.words_blit(Words{2 words, 8}, 0, Words{2 words, n})
# Prints the length of the result (a value), or does not return.

def show(pair: O.Words & O.Words) -> IO(Unit):
  (a, b) = pair
  match b:
    case O.Words{ws, +n}: IO.print("done n=" ++ U32.show(n))

def go(+c: U32, +n: U32) -> IO(Unit):
  match c:
    case 1: show(O.words_slice(O.Words{Array.new(U32, 1n, 7), 8}, 0, n))
    case _: show(O.words_blit(O.Words{Array.new(U32, 1n, 7), 8}, 0, O.Words{Array.new(U32, 1n, 9), n}))

def main() -> IO(Unit):
  do IO<Unit>:
    +c : U32 <- IOx.env_u32("SSZ_CASE")
    +n : U32 <- IOx.env_u32("SSZ_ARG")
    go(c, n)
