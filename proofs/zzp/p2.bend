import Base
import ../../src/obj.bend as O
import ../../src/buffer.bend as B
import ../../src/digest.bend as D

def r15(+hl: Nat, h: B.Buf, o: O.Words, +seg: U32) -> B.Buf & (O.Words & D.Digest): O.mix_count(hl, 3n, O.words_root(hl, h, o, 15, seg))

def lem(+hl: Nat, -h: B.Buf, -o: O.Words, +dU: U32, +seg: U32) -> {O.mix_count(hl, 3n, O.words_root(hl, h, o, dU, seg)) == O.mix_count(hl, 3n, O.words_root(hl, h, o, dU, seg)) : B.Buf & (O.Words & D.Digest)}: {==}

def use(+hl: Nat, -h: B.Buf, -o: O.Words, +seg: U32) -> {r15(hl, h, o, seg) == O.mix_count(hl, 3n, O.words_root(hl, h, o, 15, seg)) : B.Buf & (O.Words & D.Digest)}:
  lem(hl, h, o, 15, seg)
