import Base
import ../src/packed.bend as P
import ../spec/primitives.bend as SP
import ./packed_pack.bend as PP
import ./packed_pack_acc.bend as PA

# The packer accepts exactly the byte strings the specification calls bytes.
# `packed_pack.bend` proves the chunk view under this hypothesis; completeness
# needs the hypothesis itself, from the domain of the encoding.
law step_domain:
  for +b0: U32
  for +b1: U32
  for +b2: U32
  for +b3: U32
  for +b4: U32
  for +b5: U32
  for +b6: U32
  for +b7: U32
  for +b8: U32
  for +b9: U32
  for +b10: U32
  for +b11: U32
  for +b12: U32
  for +b13: U32
  for +b14: U32
  for +b15: U32
  for +b16: U32
  for +b17: U32
  for +b18: U32
  for +b19: U32
  for +b20: U32
  for +b21: U32
  for +b22: U32
  for +b23: U32
  for +b24: U32
  for +b25: U32
  for +b26: U32
  for +b27: U32
  for +b28: U32
  for +b29: U32
  for +b30: U32
  for +b31: U32
  for +rest: P.Packing
  {P.packing_domain(P.pack_step(b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16, b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, b28, b29, b30, b31, rest)) == Bool.and(U32.is_lt(b0, 256), Bool.and(U32.is_lt(b1, 256), Bool.and(U32.is_lt(b2, 256), Bool.and(U32.is_lt(b3, 256), Bool.and(U32.is_lt(b4, 256), Bool.and(U32.is_lt(b5, 256), Bool.and(U32.is_lt(b6, 256), Bool.and(U32.is_lt(b7, 256), Bool.and(U32.is_lt(b8, 256), Bool.and(U32.is_lt(b9, 256), Bool.and(U32.is_lt(b10, 256), Bool.and(U32.is_lt(b11, 256), Bool.and(U32.is_lt(b12, 256), Bool.and(U32.is_lt(b13, 256), Bool.and(U32.is_lt(b14, 256), Bool.and(U32.is_lt(b15, 256), Bool.and(U32.is_lt(b16, 256), Bool.and(U32.is_lt(b17, 256), Bool.and(U32.is_lt(b18, 256), Bool.and(U32.is_lt(b19, 256), Bool.and(U32.is_lt(b20, 256), Bool.and(U32.is_lt(b21, 256), Bool.and(U32.is_lt(b22, 256), Bool.and(U32.is_lt(b23, 256), Bool.and(U32.is_lt(b24, 256), Bool.and(U32.is_lt(b25, 256), Bool.and(U32.is_lt(b26, 256), Bool.and(U32.is_lt(b27, 256), Bool.and(U32.is_lt(b28, 256), Bool.and(U32.is_lt(b29, 256), Bool.and(U32.is_lt(b30, 256), Bool.and(U32.is_lt(b31, 256), P.packing_domain(rest))))))))))))))))))))))))))))))))) : Bool}
def step_domain(b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16, b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, b28, b29, b30, b31, rest):
  match rest:
    case P.Packing{l, d, c}: {==}

law pack_spec_domain:
  for +xs: +List<U32>
  {P.packing_domain(P.pack_spec_go(xs, xs)) == SP.bytes_domain(xs) : Bool}
def pack_spec_domain(xs):
  match xs:
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Con{b30, Con{b31, t}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      Equal.trans(Bool, P.packing_domain(P.pack_step(b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16, b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, b28, b29, b30, b31, P.pack_spec_go(t, t))), Bool.and(U32.is_lt(b0, 256), Bool.and(U32.is_lt(b1, 256), Bool.and(U32.is_lt(b2, 256), Bool.and(U32.is_lt(b3, 256), Bool.and(U32.is_lt(b4, 256), Bool.and(U32.is_lt(b5, 256), Bool.and(U32.is_lt(b6, 256), Bool.and(U32.is_lt(b7, 256), Bool.and(U32.is_lt(b8, 256), Bool.and(U32.is_lt(b9, 256), Bool.and(U32.is_lt(b10, 256), Bool.and(U32.is_lt(b11, 256), Bool.and(U32.is_lt(b12, 256), Bool.and(U32.is_lt(b13, 256), Bool.and(U32.is_lt(b14, 256), Bool.and(U32.is_lt(b15, 256), Bool.and(U32.is_lt(b16, 256), Bool.and(U32.is_lt(b17, 256), Bool.and(U32.is_lt(b18, 256), Bool.and(U32.is_lt(b19, 256), Bool.and(U32.is_lt(b20, 256), Bool.and(U32.is_lt(b21, 256), Bool.and(U32.is_lt(b22, 256), Bool.and(U32.is_lt(b23, 256), Bool.and(U32.is_lt(b24, 256), Bool.and(U32.is_lt(b25, 256), Bool.and(U32.is_lt(b26, 256), Bool.and(U32.is_lt(b27, 256), Bool.and(U32.is_lt(b28, 256), Bool.and(U32.is_lt(b29, 256), Bool.and(U32.is_lt(b30, 256), Bool.and(U32.is_lt(b31, 256), P.packing_domain(P.pack_spec_go(t, t)))))))))))))))))))))))))))))))))), SP.bytes_domain(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Con{b30, Con{b31, t}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}),
        step_domain(b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15, b16, b17, b18, b19, b20, b21, b22, b23, b24, b25, b26, b27, b28, b29, b30, b31, P.pack_spec_go(t, t)),
        Equal.cong(Bool, Bool, r => Bool.and(U32.is_lt(b0, 256), Bool.and(U32.is_lt(b1, 256), Bool.and(U32.is_lt(b2, 256), Bool.and(U32.is_lt(b3, 256), Bool.and(U32.is_lt(b4, 256), Bool.and(U32.is_lt(b5, 256), Bool.and(U32.is_lt(b6, 256), Bool.and(U32.is_lt(b7, 256), Bool.and(U32.is_lt(b8, 256), Bool.and(U32.is_lt(b9, 256), Bool.and(U32.is_lt(b10, 256), Bool.and(U32.is_lt(b11, 256), Bool.and(U32.is_lt(b12, 256), Bool.and(U32.is_lt(b13, 256), Bool.and(U32.is_lt(b14, 256), Bool.and(U32.is_lt(b15, 256), Bool.and(U32.is_lt(b16, 256), Bool.and(U32.is_lt(b17, 256), Bool.and(U32.is_lt(b18, 256), Bool.and(U32.is_lt(b19, 256), Bool.and(U32.is_lt(b20, 256), Bool.and(U32.is_lt(b21, 256), Bool.and(U32.is_lt(b22, 256), Bool.and(U32.is_lt(b23, 256), Bool.and(U32.is_lt(b24, 256), Bool.and(U32.is_lt(b25, 256), Bool.and(U32.is_lt(b26, 256), Bool.and(U32.is_lt(b27, 256), Bool.and(U32.is_lt(b28, 256), Bool.and(U32.is_lt(b29, 256), Bool.and(U32.is_lt(b30, 256), Bool.and(U32.is_lt(b31, 256), r)))))))))))))))))))))))))))))))), P.packing_domain(P.pack_spec_go(t, t)), SP.bytes_domain(t), pack_spec_domain(t)))
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Con{b30, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Con{b30, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Con{b29, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Con{b28, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Con{b27, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Con{b26, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Con{b25, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Con{b24, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Nil{}}}}}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Con{b23, Nil{}}}}}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Nil{}}}}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Con{b22, Nil{}}}}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Nil{}}}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Con{b21, Nil{}}}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Nil{}}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Con{b20, Nil{}}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Nil{}}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Con{b19, Nil{}}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Nil{}}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Con{b18, Nil{}}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Nil{}}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Con{b17, Nil{}}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Nil{}}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Con{b16, Nil{}}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Nil{}}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Con{b15, Nil{}}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Nil{}}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Con{b14, Nil{}}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Nil{}}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Con{b13, Nil{}}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Nil{}}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Con{b12, Nil{}}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Nil{}}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Con{b11, Nil{}}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Nil{}}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Con{b10, Nil{}}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Nil{}}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Con{b9, Nil{}}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Nil{}}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Con{b8, Nil{}}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Nil{}}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, Nil{}}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Nil{}}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Nil{}}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Nil{}}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Nil{}}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Nil{}}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Nil{}}}}}})
    case Con{b0, Con{b1, Con{b2, Con{b3, Nil{}}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Con{b3, Nil{}}}}})
    case Con{b0, Con{b1, Con{b2, Nil{}}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Con{b2, Nil{}}}})
    case Con{b0, Con{b1, Nil{}}}:
      PP.small_domain_correct(Con{b0, Con{b1, Nil{}}})
    case Con{b0, Nil{}}:
      PP.small_domain_correct(Con{b0, Nil{}})
    case Nil{}:
      PP.small_domain_correct(Nil{})

law pack_list_domain:
  for +xs: +List<U32>
  for +domain: {SP.bytes_domain(xs) == True{} : Bool}
  {P.packing_domain(P.pack_list(xs)) == True{} : Bool}
def pack_list_domain(xs, domain):
  Equal.trans(Bool, P.packing_domain(P.pack_list(xs)), SP.bytes_domain(xs), True{},
    Equal.trans(Bool, P.packing_domain(P.pack_list(xs)), P.packing_domain(P.pack_spec_go(xs, xs)), SP.bytes_domain(xs),
      Equal.cong(P.Packing, Bool, P.packing_domain, P.pack_list(xs), P.pack_spec(xs), PA.pack_list_spec(xs)),
      pack_spec_domain(xs)),
    domain)
