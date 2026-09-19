import Base
import ../src/bit_packing.bend as P
import ../src/bit_decoding.bend as O
import ../src/bit_decode.bend as D
import ../spec/primitives.bend as Domain
import ./power_division.bend as Words
import ./word_split.bend as Split
import ./integer_decoding.bend as Integer
import ./primitive_invariants.bend as V

law octet_inverse:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +b7: Bool
  {O.octet(P.octet(b0, b1, b2, b3, b4, b5, b6, b7)) == [b0, b1, b2, b3, b4, b5, b6, b7] : +List<Bool>}
def octet_inverse(b0, b1, b2, b3, b4, b5, b6, b7):
  match b0 b1 b2 b3 b4 b5 b6 b7:
    case False{} False{} False{} False{} False{} False{} False{} False{}: {==}
    case True{} False{} False{} False{} False{} False{} False{} False{}: {==}
    case False{} True{} False{} False{} False{} False{} False{} False{}: {==}
    case True{} True{} False{} False{} False{} False{} False{} False{}: {==}
    case False{} False{} True{} False{} False{} False{} False{} False{}: {==}
    case True{} False{} True{} False{} False{} False{} False{} False{}: {==}
    case False{} True{} True{} False{} False{} False{} False{} False{}: {==}
    case True{} True{} True{} False{} False{} False{} False{} False{}: {==}
    case False{} False{} False{} True{} False{} False{} False{} False{}: {==}
    case True{} False{} False{} True{} False{} False{} False{} False{}: {==}
    case False{} True{} False{} True{} False{} False{} False{} False{}: {==}
    case True{} True{} False{} True{} False{} False{} False{} False{}: {==}
    case False{} False{} True{} True{} False{} False{} False{} False{}: {==}
    case True{} False{} True{} True{} False{} False{} False{} False{}: {==}
    case False{} True{} True{} True{} False{} False{} False{} False{}: {==}
    case True{} True{} True{} True{} False{} False{} False{} False{}: {==}
    case False{} False{} False{} False{} True{} False{} False{} False{}: {==}
    case True{} False{} False{} False{} True{} False{} False{} False{}: {==}
    case False{} True{} False{} False{} True{} False{} False{} False{}: {==}
    case True{} True{} False{} False{} True{} False{} False{} False{}: {==}
    case False{} False{} True{} False{} True{} False{} False{} False{}: {==}
    case True{} False{} True{} False{} True{} False{} False{} False{}: {==}
    case False{} True{} True{} False{} True{} False{} False{} False{}: {==}
    case True{} True{} True{} False{} True{} False{} False{} False{}: {==}
    case False{} False{} False{} True{} True{} False{} False{} False{}: {==}
    case True{} False{} False{} True{} True{} False{} False{} False{}: {==}
    case False{} True{} False{} True{} True{} False{} False{} False{}: {==}
    case True{} True{} False{} True{} True{} False{} False{} False{}: {==}
    case False{} False{} True{} True{} True{} False{} False{} False{}: {==}
    case True{} False{} True{} True{} True{} False{} False{} False{}: {==}
    case False{} True{} True{} True{} True{} False{} False{} False{}: {==}
    case True{} True{} True{} True{} True{} False{} False{} False{}: {==}
    case False{} False{} False{} False{} False{} True{} False{} False{}: {==}
    case True{} False{} False{} False{} False{} True{} False{} False{}: {==}
    case False{} True{} False{} False{} False{} True{} False{} False{}: {==}
    case True{} True{} False{} False{} False{} True{} False{} False{}: {==}
    case False{} False{} True{} False{} False{} True{} False{} False{}: {==}
    case True{} False{} True{} False{} False{} True{} False{} False{}: {==}
    case False{} True{} True{} False{} False{} True{} False{} False{}: {==}
    case True{} True{} True{} False{} False{} True{} False{} False{}: {==}
    case False{} False{} False{} True{} False{} True{} False{} False{}: {==}
    case True{} False{} False{} True{} False{} True{} False{} False{}: {==}
    case False{} True{} False{} True{} False{} True{} False{} False{}: {==}
    case True{} True{} False{} True{} False{} True{} False{} False{}: {==}
    case False{} False{} True{} True{} False{} True{} False{} False{}: {==}
    case True{} False{} True{} True{} False{} True{} False{} False{}: {==}
    case False{} True{} True{} True{} False{} True{} False{} False{}: {==}
    case True{} True{} True{} True{} False{} True{} False{} False{}: {==}
    case False{} False{} False{} False{} True{} True{} False{} False{}: {==}
    case True{} False{} False{} False{} True{} True{} False{} False{}: {==}
    case False{} True{} False{} False{} True{} True{} False{} False{}: {==}
    case True{} True{} False{} False{} True{} True{} False{} False{}: {==}
    case False{} False{} True{} False{} True{} True{} False{} False{}: {==}
    case True{} False{} True{} False{} True{} True{} False{} False{}: {==}
    case False{} True{} True{} False{} True{} True{} False{} False{}: {==}
    case True{} True{} True{} False{} True{} True{} False{} False{}: {==}
    case False{} False{} False{} True{} True{} True{} False{} False{}: {==}
    case True{} False{} False{} True{} True{} True{} False{} False{}: {==}
    case False{} True{} False{} True{} True{} True{} False{} False{}: {==}
    case True{} True{} False{} True{} True{} True{} False{} False{}: {==}
    case False{} False{} True{} True{} True{} True{} False{} False{}: {==}
    case True{} False{} True{} True{} True{} True{} False{} False{}: {==}
    case False{} True{} True{} True{} True{} True{} False{} False{}: {==}
    case True{} True{} True{} True{} True{} True{} False{} False{}: {==}
    case False{} False{} False{} False{} False{} False{} True{} False{}: {==}
    case True{} False{} False{} False{} False{} False{} True{} False{}: {==}
    case False{} True{} False{} False{} False{} False{} True{} False{}: {==}
    case True{} True{} False{} False{} False{} False{} True{} False{}: {==}
    case False{} False{} True{} False{} False{} False{} True{} False{}: {==}
    case True{} False{} True{} False{} False{} False{} True{} False{}: {==}
    case False{} True{} True{} False{} False{} False{} True{} False{}: {==}
    case True{} True{} True{} False{} False{} False{} True{} False{}: {==}
    case False{} False{} False{} True{} False{} False{} True{} False{}: {==}
    case True{} False{} False{} True{} False{} False{} True{} False{}: {==}
    case False{} True{} False{} True{} False{} False{} True{} False{}: {==}
    case True{} True{} False{} True{} False{} False{} True{} False{}: {==}
    case False{} False{} True{} True{} False{} False{} True{} False{}: {==}
    case True{} False{} True{} True{} False{} False{} True{} False{}: {==}
    case False{} True{} True{} True{} False{} False{} True{} False{}: {==}
    case True{} True{} True{} True{} False{} False{} True{} False{}: {==}
    case False{} False{} False{} False{} True{} False{} True{} False{}: {==}
    case True{} False{} False{} False{} True{} False{} True{} False{}: {==}
    case False{} True{} False{} False{} True{} False{} True{} False{}: {==}
    case True{} True{} False{} False{} True{} False{} True{} False{}: {==}
    case False{} False{} True{} False{} True{} False{} True{} False{}: {==}
    case True{} False{} True{} False{} True{} False{} True{} False{}: {==}
    case False{} True{} True{} False{} True{} False{} True{} False{}: {==}
    case True{} True{} True{} False{} True{} False{} True{} False{}: {==}
    case False{} False{} False{} True{} True{} False{} True{} False{}: {==}
    case True{} False{} False{} True{} True{} False{} True{} False{}: {==}
    case False{} True{} False{} True{} True{} False{} True{} False{}: {==}
    case True{} True{} False{} True{} True{} False{} True{} False{}: {==}
    case False{} False{} True{} True{} True{} False{} True{} False{}: {==}
    case True{} False{} True{} True{} True{} False{} True{} False{}: {==}
    case False{} True{} True{} True{} True{} False{} True{} False{}: {==}
    case True{} True{} True{} True{} True{} False{} True{} False{}: {==}
    case False{} False{} False{} False{} False{} True{} True{} False{}: {==}
    case True{} False{} False{} False{} False{} True{} True{} False{}: {==}
    case False{} True{} False{} False{} False{} True{} True{} False{}: {==}
    case True{} True{} False{} False{} False{} True{} True{} False{}: {==}
    case False{} False{} True{} False{} False{} True{} True{} False{}: {==}
    case True{} False{} True{} False{} False{} True{} True{} False{}: {==}
    case False{} True{} True{} False{} False{} True{} True{} False{}: {==}
    case True{} True{} True{} False{} False{} True{} True{} False{}: {==}
    case False{} False{} False{} True{} False{} True{} True{} False{}: {==}
    case True{} False{} False{} True{} False{} True{} True{} False{}: {==}
    case False{} True{} False{} True{} False{} True{} True{} False{}: {==}
    case True{} True{} False{} True{} False{} True{} True{} False{}: {==}
    case False{} False{} True{} True{} False{} True{} True{} False{}: {==}
    case True{} False{} True{} True{} False{} True{} True{} False{}: {==}
    case False{} True{} True{} True{} False{} True{} True{} False{}: {==}
    case True{} True{} True{} True{} False{} True{} True{} False{}: {==}
    case False{} False{} False{} False{} True{} True{} True{} False{}: {==}
    case True{} False{} False{} False{} True{} True{} True{} False{}: {==}
    case False{} True{} False{} False{} True{} True{} True{} False{}: {==}
    case True{} True{} False{} False{} True{} True{} True{} False{}: {==}
    case False{} False{} True{} False{} True{} True{} True{} False{}: {==}
    case True{} False{} True{} False{} True{} True{} True{} False{}: {==}
    case False{} True{} True{} False{} True{} True{} True{} False{}: {==}
    case True{} True{} True{} False{} True{} True{} True{} False{}: {==}
    case False{} False{} False{} True{} True{} True{} True{} False{}: {==}
    case True{} False{} False{} True{} True{} True{} True{} False{}: {==}
    case False{} True{} False{} True{} True{} True{} True{} False{}: {==}
    case True{} True{} False{} True{} True{} True{} True{} False{}: {==}
    case False{} False{} True{} True{} True{} True{} True{} False{}: {==}
    case True{} False{} True{} True{} True{} True{} True{} False{}: {==}
    case False{} True{} True{} True{} True{} True{} True{} False{}: {==}
    case True{} True{} True{} True{} True{} True{} True{} False{}: {==}
    case False{} False{} False{} False{} False{} False{} False{} True{}: {==}
    case True{} False{} False{} False{} False{} False{} False{} True{}: {==}
    case False{} True{} False{} False{} False{} False{} False{} True{}: {==}
    case True{} True{} False{} False{} False{} False{} False{} True{}: {==}
    case False{} False{} True{} False{} False{} False{} False{} True{}: {==}
    case True{} False{} True{} False{} False{} False{} False{} True{}: {==}
    case False{} True{} True{} False{} False{} False{} False{} True{}: {==}
    case True{} True{} True{} False{} False{} False{} False{} True{}: {==}
    case False{} False{} False{} True{} False{} False{} False{} True{}: {==}
    case True{} False{} False{} True{} False{} False{} False{} True{}: {==}
    case False{} True{} False{} True{} False{} False{} False{} True{}: {==}
    case True{} True{} False{} True{} False{} False{} False{} True{}: {==}
    case False{} False{} True{} True{} False{} False{} False{} True{}: {==}
    case True{} False{} True{} True{} False{} False{} False{} True{}: {==}
    case False{} True{} True{} True{} False{} False{} False{} True{}: {==}
    case True{} True{} True{} True{} False{} False{} False{} True{}: {==}
    case False{} False{} False{} False{} True{} False{} False{} True{}: {==}
    case True{} False{} False{} False{} True{} False{} False{} True{}: {==}
    case False{} True{} False{} False{} True{} False{} False{} True{}: {==}
    case True{} True{} False{} False{} True{} False{} False{} True{}: {==}
    case False{} False{} True{} False{} True{} False{} False{} True{}: {==}
    case True{} False{} True{} False{} True{} False{} False{} True{}: {==}
    case False{} True{} True{} False{} True{} False{} False{} True{}: {==}
    case True{} True{} True{} False{} True{} False{} False{} True{}: {==}
    case False{} False{} False{} True{} True{} False{} False{} True{}: {==}
    case True{} False{} False{} True{} True{} False{} False{} True{}: {==}
    case False{} True{} False{} True{} True{} False{} False{} True{}: {==}
    case True{} True{} False{} True{} True{} False{} False{} True{}: {==}
    case False{} False{} True{} True{} True{} False{} False{} True{}: {==}
    case True{} False{} True{} True{} True{} False{} False{} True{}: {==}
    case False{} True{} True{} True{} True{} False{} False{} True{}: {==}
    case True{} True{} True{} True{} True{} False{} False{} True{}: {==}
    case False{} False{} False{} False{} False{} True{} False{} True{}: {==}
    case True{} False{} False{} False{} False{} True{} False{} True{}: {==}
    case False{} True{} False{} False{} False{} True{} False{} True{}: {==}
    case True{} True{} False{} False{} False{} True{} False{} True{}: {==}
    case False{} False{} True{} False{} False{} True{} False{} True{}: {==}
    case True{} False{} True{} False{} False{} True{} False{} True{}: {==}
    case False{} True{} True{} False{} False{} True{} False{} True{}: {==}
    case True{} True{} True{} False{} False{} True{} False{} True{}: {==}
    case False{} False{} False{} True{} False{} True{} False{} True{}: {==}
    case True{} False{} False{} True{} False{} True{} False{} True{}: {==}
    case False{} True{} False{} True{} False{} True{} False{} True{}: {==}
    case True{} True{} False{} True{} False{} True{} False{} True{}: {==}
    case False{} False{} True{} True{} False{} True{} False{} True{}: {==}
    case True{} False{} True{} True{} False{} True{} False{} True{}: {==}
    case False{} True{} True{} True{} False{} True{} False{} True{}: {==}
    case True{} True{} True{} True{} False{} True{} False{} True{}: {==}
    case False{} False{} False{} False{} True{} True{} False{} True{}: {==}
    case True{} False{} False{} False{} True{} True{} False{} True{}: {==}
    case False{} True{} False{} False{} True{} True{} False{} True{}: {==}
    case True{} True{} False{} False{} True{} True{} False{} True{}: {==}
    case False{} False{} True{} False{} True{} True{} False{} True{}: {==}
    case True{} False{} True{} False{} True{} True{} False{} True{}: {==}
    case False{} True{} True{} False{} True{} True{} False{} True{}: {==}
    case True{} True{} True{} False{} True{} True{} False{} True{}: {==}
    case False{} False{} False{} True{} True{} True{} False{} True{}: {==}
    case True{} False{} False{} True{} True{} True{} False{} True{}: {==}
    case False{} True{} False{} True{} True{} True{} False{} True{}: {==}
    case True{} True{} False{} True{} True{} True{} False{} True{}: {==}
    case False{} False{} True{} True{} True{} True{} False{} True{}: {==}
    case True{} False{} True{} True{} True{} True{} False{} True{}: {==}
    case False{} True{} True{} True{} True{} True{} False{} True{}: {==}
    case True{} True{} True{} True{} True{} True{} False{} True{}: {==}
    case False{} False{} False{} False{} False{} False{} True{} True{}: {==}
    case True{} False{} False{} False{} False{} False{} True{} True{}: {==}
    case False{} True{} False{} False{} False{} False{} True{} True{}: {==}
    case True{} True{} False{} False{} False{} False{} True{} True{}: {==}
    case False{} False{} True{} False{} False{} False{} True{} True{}: {==}
    case True{} False{} True{} False{} False{} False{} True{} True{}: {==}
    case False{} True{} True{} False{} False{} False{} True{} True{}: {==}
    case True{} True{} True{} False{} False{} False{} True{} True{}: {==}
    case False{} False{} False{} True{} False{} False{} True{} True{}: {==}
    case True{} False{} False{} True{} False{} False{} True{} True{}: {==}
    case False{} True{} False{} True{} False{} False{} True{} True{}: {==}
    case True{} True{} False{} True{} False{} False{} True{} True{}: {==}
    case False{} False{} True{} True{} False{} False{} True{} True{}: {==}
    case True{} False{} True{} True{} False{} False{} True{} True{}: {==}
    case False{} True{} True{} True{} False{} False{} True{} True{}: {==}
    case True{} True{} True{} True{} False{} False{} True{} True{}: {==}
    case False{} False{} False{} False{} True{} False{} True{} True{}: {==}
    case True{} False{} False{} False{} True{} False{} True{} True{}: {==}
    case False{} True{} False{} False{} True{} False{} True{} True{}: {==}
    case True{} True{} False{} False{} True{} False{} True{} True{}: {==}
    case False{} False{} True{} False{} True{} False{} True{} True{}: {==}
    case True{} False{} True{} False{} True{} False{} True{} True{}: {==}
    case False{} True{} True{} False{} True{} False{} True{} True{}: {==}
    case True{} True{} True{} False{} True{} False{} True{} True{}: {==}
    case False{} False{} False{} True{} True{} False{} True{} True{}: {==}
    case True{} False{} False{} True{} True{} False{} True{} True{}: {==}
    case False{} True{} False{} True{} True{} False{} True{} True{}: {==}
    case True{} True{} False{} True{} True{} False{} True{} True{}: {==}
    case False{} False{} True{} True{} True{} False{} True{} True{}: {==}
    case True{} False{} True{} True{} True{} False{} True{} True{}: {==}
    case False{} True{} True{} True{} True{} False{} True{} True{}: {==}
    case True{} True{} True{} True{} True{} False{} True{} True{}: {==}
    case False{} False{} False{} False{} False{} True{} True{} True{}: {==}
    case True{} False{} False{} False{} False{} True{} True{} True{}: {==}
    case False{} True{} False{} False{} False{} True{} True{} True{}: {==}
    case True{} True{} False{} False{} False{} True{} True{} True{}: {==}
    case False{} False{} True{} False{} False{} True{} True{} True{}: {==}
    case True{} False{} True{} False{} False{} True{} True{} True{}: {==}
    case False{} True{} True{} False{} False{} True{} True{} True{}: {==}
    case True{} True{} True{} False{} False{} True{} True{} True{}: {==}
    case False{} False{} False{} True{} False{} True{} True{} True{}: {==}
    case True{} False{} False{} True{} False{} True{} True{} True{}: {==}
    case False{} True{} False{} True{} False{} True{} True{} True{}: {==}
    case True{} True{} False{} True{} False{} True{} True{} True{}: {==}
    case False{} False{} True{} True{} False{} True{} True{} True{}: {==}
    case True{} False{} True{} True{} False{} True{} True{} True{}: {==}
    case False{} True{} True{} True{} False{} True{} True{} True{}: {==}
    case True{} True{} True{} True{} False{} True{} True{} True{}: {==}
    case False{} False{} False{} False{} True{} True{} True{} True{}: {==}
    case True{} False{} False{} False{} True{} True{} True{} True{}: {==}
    case False{} True{} False{} False{} True{} True{} True{} True{}: {==}
    case True{} True{} False{} False{} True{} True{} True{} True{}: {==}
    case False{} False{} True{} False{} True{} True{} True{} True{}: {==}
    case True{} False{} True{} False{} True{} True{} True{} True{}: {==}
    case False{} True{} True{} False{} True{} True{} True{} True{}: {==}
    case True{} True{} True{} False{} True{} True{} True{} True{}: {==}
    case False{} False{} False{} True{} True{} True{} True{} True{}: {==}
    case True{} False{} False{} True{} True{} True{} True{} True{}: {==}
    case False{} True{} False{} True{} True{} True{} True{} True{}: {==}
    case True{} True{} False{} True{} True{} True{} True{} True{}: {==}
    case False{} False{} True{} True{} True{} True{} True{} True{}: {==}
    case True{} False{} True{} True{} True{} True{} True{} True{}: {==}
    case False{} True{} True{} True{} True{} True{} True{} True{}: {==}
    case True{} True{} True{} True{} True{} True{} True{} True{}: {==}

law embedded_reencode:
  for +w: Word(8n)
  {P.pack(O.octet(Words.embed8(w))) == [Words.embed8(w)] : +List<U32>}
def embedded_reencode(w):
  match w:
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{False{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}
    case WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WCon{True{}, WNil{}}}}}}}}}: {==}

law octet_reencode:
  for +x: U32
  for e: {U32.is_lt(x, 256) == True{} : Bool}
  {P.pack(O.octet(x)) == [x] : +List<U32>}
def octet_reencode(x, e):
  %Equal.sym(U32, x, Words.embed8(Split.take(8n, 32n, Words.bits(x))), Integer.byte_shape(x, e)) : {P.pack(O.octet(_)) == [_] : +List<U32>}
  embedded_reencode(Split.take(8n, 32n, Words.bits(x)))

law repack_expanded:
  for +xs: +List<U32>
  for +e: {Domain.bytes_domain(xs) == True{} : Bool}
  {P.pack(D.expand(xs)) == xs : +List<U32>}
def repack_expanded(xs, e):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %octet_reencode(h, V.and_left(U32.is_lt(h, 256), Domain.bytes_domain(t), e)) :
        {P.pack(D.expand(xs)) == List.append(&2, U32, _, t) : +List<U32>}
      %repack_expanded(t, V.and_right(U32.is_lt(h, 256), Domain.bytes_domain(t), e)) :
        {P.pack(D.expand(xs)) == List.append(&2, U32, P.pack(O.octet(h)), _) : +List<U32>}
      {==}

law take_packed:
  for +bits: +List<Bool>
  {D.take(List.length(&2, Bool, bits), D.expand(P.pack(bits))) == Some{bits} : Maybe<&2, +List<Bool>>}
def take_packed(bits):
  match bits:
    case Nil{}: {==}
    case Con{b0, Nil{}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, False{}, False{}, False{}, False{}, False{}, False{}, False{})), [b0, False{}, False{}, False{}, False{}, False{}, False{}, False{}], octet_inverse(b0, False{}, False{}, False{}, False{}, False{}, False{}, False{})) : {D.take(List.length(&2, Bool, bits), List.append(&2, Bool, _, D.expand([]))) == Some{bits} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Nil{}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, False{}, False{}, False{}, False{}, False{}, False{})), [b0, b1, False{}, False{}, False{}, False{}, False{}, False{}], octet_inverse(b0, b1, False{}, False{}, False{}, False{}, False{}, False{})) : {D.take(List.length(&2, Bool, bits), List.append(&2, Bool, _, D.expand([]))) == Some{bits} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Nil{}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, False{}, False{}, False{}, False{}, False{})), [b0, b1, b2, False{}, False{}, False{}, False{}, False{}], octet_inverse(b0, b1, b2, False{}, False{}, False{}, False{}, False{})) : {D.take(List.length(&2, Bool, bits), List.append(&2, Bool, _, D.expand([]))) == Some{bits} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Nil{}}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, b3, False{}, False{}, False{}, False{})), [b0, b1, b2, b3, False{}, False{}, False{}, False{}], octet_inverse(b0, b1, b2, b3, False{}, False{}, False{}, False{})) : {D.take(List.length(&2, Bool, bits), List.append(&2, Bool, _, D.expand([]))) == Some{bits} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Nil{}}}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, b3, b4, False{}, False{}, False{})), [b0, b1, b2, b3, b4, False{}, False{}, False{}], octet_inverse(b0, b1, b2, b3, b4, False{}, False{}, False{})) : {D.take(List.length(&2, Bool, bits), List.append(&2, Bool, _, D.expand([]))) == Some{bits} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Nil{}}}}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, b3, b4, b5, False{}, False{})), [b0, b1, b2, b3, b4, b5, False{}, False{}], octet_inverse(b0, b1, b2, b3, b4, b5, False{}, False{})) : {D.take(List.length(&2, Bool, bits), List.append(&2, Bool, _, D.expand([]))) == Some{bits} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Nil{}}}}}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, b3, b4, b5, b6, False{})), [b0, b1, b2, b3, b4, b5, b6, False{}], octet_inverse(b0, b1, b2, b3, b4, b5, b6, False{})) : {D.take(List.length(&2, Bool, bits), List.append(&2, Bool, _, D.expand([]))) == Some{bits} : Maybe<&2, +List<Bool>>}
      {==}
    case Con{b0, Con{b1, Con{b2, Con{b3, Con{b4, Con{b5, Con{b6, Con{b7, tail}}}}}}}}:
      %Equal.sym(+List<Bool>, O.octet(P.octet(b0, b1, b2, b3, b4, b5, b6, b7)), [b0, b1, b2, b3, b4, b5, b6, b7], octet_inverse(b0, b1, b2, b3, b4, b5, b6, b7)) : {D.take(List.length(&2, Bool, bits), List.append(&2, Bool, _, D.expand(P.pack(tail)))) == Some{bits} : Maybe<&2, +List<Bool>>}
      Equal.cong(Maybe<&2, +List<Bool>>, Maybe<&2, +List<Bool>>, r => D.cons(b0, D.cons(b1, D.cons(b2, D.cons(b3, D.cons(b4, D.cons(b5, D.cons(b6, D.cons(b7, r)))))))), D.take(List.length(&2, Bool, tail), D.expand(P.pack(tail))), Some{tail}, take_packed(tail))
