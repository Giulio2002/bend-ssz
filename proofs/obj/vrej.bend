import Base
import ../../spec/layout.bend as Layout
import ../../spec/nat_bytes.bend as N
import ../../types/schema.bend as S
import ../compact/found_generated.bend as F
import ./vspec.bend as VS

# Variable-size rejection, specification side: the offset layout of fixed
# parts of arbitrary BYTE lists around one variable part. Whatever the parts'
# bytes, the layout puts the offset (the fixed size) right after the fixed
# parts before the variable one, and its length is the fixed size plus the
# payload's length. The generated rejection laws (codegen/var_laws.py) invert
# the spec encoding to this shape.

def bfix(wss: +List<+List<U32>>) -> +List<S.Part>:
  match wss:
    case Nil{}: []
    case Con{ws, t}: S.Fixed{ws} <> bfix(t)

def bcat(wss: +List<+List<U32>>) -> +List<U32>:
  match wss:
    case Nil{}: []
    case Con{ws, t}: List.append(&2, U32, ws, bcat(t))

def lens(wss: +List<+List<U32>>) -> Nat:
  match wss:
    case Nil{}: 0n
    case Con{ws, t}: Nat.add(List.length(&2, U32, ws), lens(t))

def fpb(+pre: +List<+List<U32>>, +Y: +List<U32>, +post: +List<+List<U32>>) -> +List<S.Part>:
  List.append(&2, S.Part, bfix(pre), Con{S.Variable{Y}, bfix(post)})

def FZ(+pre: +List<+List<U32>>, +post: +List<+List<U32>>) -> Nat: Nat.add(lens(pre), 4n+lens(post))

def OUT(+pre: +List<+List<U32>>, +Y: +List<U32>, +post: +List<+List<U32>>) -> +List<U32>:
  List.append(&2, U32, Layout.fixed_parts(fpb(pre, Y, post), Layout.fixed_size(fpb(pre, Y, post))), Layout.payloads(fpb(pre, Y, post)))

law size_bfix:
  for +wss: +List<+List<U32>>
  {Layout.fixed_size(bfix(wss)) == lens(wss) : Nat}
def size_bfix(wss):
  match wss:
    case Nil{}: {==}
    case Con{+ws, +t}:
      %Equal.sym(Nat, Layout.fixed_size(bfix(t)), lens(t), size_bfix(t)) : {Nat.add(List.length(&2, U32, ws), _) == Nat.add(List.length(&2, U32, ws), lens(t)) : Nat}
      {==}

law fp_bfix:
  for +wss: +List<+List<U32>>
  for +off: Nat
  {Layout.fixed_parts(bfix(wss), off) == bcat(wss) : +List<U32>}
def fp_bfix(wss, off):
  match wss:
    case Nil{}: {==}
    case Con{+ws, +t}:
      %Equal.sym(+List<U32>, Layout.fixed_parts(bfix(t), off), bcat(t), fp_bfix(t, off)) : {List.append(&2, U32, ws, _) == List.append(&2, U32, ws, bcat(t)) : +List<U32>}
      {==}

law pay_bfix:
  for +wss: +List<+List<U32>>
  {Layout.payloads(bfix(wss)) == [] : +List<U32>}
def pay_bfix(wss):
  match wss:
    case Nil{}: {==}
    case Con{+ws, +t}: pay_bfix(t)

law len_bcat:
  for +wss: +List<+List<U32>>
  {List.length(&2, U32, bcat(wss)) == lens(wss) : Nat}
def len_bcat(wss):
  match wss:
    case Nil{}: {==}
    case Con{+ws, +t}:
      %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, ws, bcat(t))), Nat.add(List.length(&2, U32, ws), List.length(&2, U32, bcat(t))), VS.len_app(ws, bcat(t))) :
        {_ == Nat.add(List.length(&2, U32, ws), lens(t)) : Nat}
      %Equal.sym(Nat, List.length(&2, U32, bcat(t)), lens(t), len_bcat(t)) : {Nat.add(List.length(&2, U32, ws), _) == Nat.add(List.length(&2, U32, ws), lens(t)) : Nat}
      {==}

law fpb_size:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  {Layout.fixed_size(fpb(pre, Y, post)) == FZ(pre, post) : Nat}
def fpb_size(pre, Y, post):
  match pre:
    case Nil{}:
      %Equal.sym(Nat, Layout.fixed_size(bfix(post)), lens(post), size_bfix(post)) : {4n+_ == 4n+lens(post) : Nat}
      {==}
    case Con{+ws, +t}:
      %Equal.sym(Nat, Layout.fixed_size(fpb(t, Y, post)), FZ(t, post), fpb_size(t, Y, post)) :
        {Nat.add(List.length(&2, U32, ws), _) == Nat.add(Nat.add(List.length(&2, U32, ws), lens(t)), 4n+lens(post)) : Nat}
      Equal.sym(Nat, Nat.add(Nat.add(List.length(&2, U32, ws), lens(t)), 4n+lens(post)), Nat.add(List.length(&2, U32, ws), Nat.add(lens(t), 4n+lens(post))),
        F.nat__add_assoc(List.length(&2, U32, ws), lens(t), 4n+lens(post)))

law fpb_pay:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  {Layout.payloads(fpb(pre, Y, post)) == List.append(&2, U32, Y, []) : +List<U32>}
def fpb_pay(pre, Y, post):
  match pre:
    case Nil{}:
      %Equal.sym(+List<U32>, Layout.payloads(bfix(post)), [], pay_bfix(post)) : {List.append(&2, U32, Y, _) == List.append(&2, U32, Y, []) : +List<U32>}
      {==}
    case Con{+ws, +t}: fpb_pay(t, Y, post)

law fpb_fp:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  for +off: Nat
  {Layout.fixed_parts(fpb(pre, Y, post), off) == List.append(&2, U32, bcat(pre), List.append(&2, U32, N.digits(4n, off), bcat(post))) : +List<U32>}
def fpb_fp(pre, Y, post, off):
  match pre:
    case Nil{}:
      %Equal.sym(+List<U32>, Layout.fixed_parts(bfix(post), Nat.add(off, List.length(&2, U32, Y))), bcat(post), fp_bfix(post, Nat.add(off, List.length(&2, U32, Y)))) :
        {List.append(&2, U32, N.digits(4n, off), _) == List.append(&2, U32, N.digits(4n, off), bcat(post)) : +List<U32>}
      {==}
    case Con{+ws, +t}:
      %Equal.sym(+List<U32>, Layout.fixed_parts(fpb(t, Y, post), off), List.append(&2, U32, bcat(t), List.append(&2, U32, N.digits(4n, off), bcat(post))), fpb_fp(t, Y, post, off)) :
        {List.append(&2, U32, ws, _) == List.append(&2, U32, List.append(&2, U32, ws, bcat(t)), List.append(&2, U32, N.digits(4n, off), bcat(post))) : +List<U32>}
      Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, ws, bcat(t)), List.append(&2, U32, N.digits(4n, off), bcat(post))),
        List.append(&2, U32, ws, List.append(&2, U32, bcat(t), List.append(&2, U32, N.digits(4n, off), bcat(post)))),
        VS.app_assoc(ws, bcat(t), List.append(&2, U32, N.digits(4n, off), bcat(post))))

def OUTX(+pre: +List<+List<U32>>, +Y: +List<U32>, +post: +List<+List<U32>>) -> +List<U32>:
  List.append(&2, U32, List.append(&2, U32, bcat(pre), List.append(&2, U32, N.digits(4n, FZ(pre, post)), bcat(post))), Y)

law out_eq:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  {OUT(pre, Y, post) == OUTX(pre, Y, post) : +List<U32>}
def out_eq(pre, Y, post):
  %Equal.sym(Nat, Layout.fixed_size(fpb(pre, Y, post)), FZ(pre, post), fpb_size(pre, Y, post)) :
    {List.append(&2, U32, Layout.fixed_parts(fpb(pre, Y, post), _), Layout.payloads(fpb(pre, Y, post))) == OUTX(pre, Y, post) : +List<U32>}
  %Equal.sym(+List<U32>, Layout.fixed_parts(fpb(pre, Y, post), FZ(pre, post)), List.append(&2, U32, bcat(pre), List.append(&2, U32, N.digits(4n, FZ(pre, post)), bcat(post))), fpb_fp(pre, Y, post, FZ(pre, post))) :
    {List.append(&2, U32, _, Layout.payloads(fpb(pre, Y, post))) == OUTX(pre, Y, post) : +List<U32>}
  %Equal.sym(+List<U32>, Layout.payloads(fpb(pre, Y, post)), List.append(&2, U32, Y, []), fpb_pay(pre, Y, post)) :
    {List.append(&2, U32, List.append(&2, U32, bcat(pre), List.append(&2, U32, N.digits(4n, FZ(pre, post)), bcat(post))), _) == OUTX(pre, Y, post) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, Y, []), Y, VS.app_nil(Y)) :
    {List.append(&2, U32, List.append(&2, U32, bcat(pre), List.append(&2, U32, N.digits(4n, FZ(pre, post)), bcat(post))), _) == OUTX(pre, Y, post) : +List<U32>}
  {==}

# The four bytes after the fixed parts before the variable one are the offset.
law out_off:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  {VS.bt(4n, VS.bdr(lens(pre), OUT(pre, Y, post))) == N.digits(4n, FZ(pre, post)) : +List<U32>}
def out_off(pre, Y, post):
  +D = List.append(&2, U32, N.digits(4n, FZ(pre, post)), bcat(post))
  %Equal.sym(+List<U32>, OUT(pre, Y, post), OUTX(pre, Y, post), out_eq(pre, Y, post)) :
    {VS.bt(4n, VS.bdr(lens(pre), _)) == N.digits(4n, FZ(pre, post)) : +List<U32>}
  %len_bcat(pre) :
    {VS.bt(4n, VS.bdr(_, List.append(&2, U32, List.append(&2, U32, bcat(pre), D), Y))) == N.digits(4n, FZ(pre, post)) : +List<U32>}
  %Equal.sym(+List<U32>, List.append(&2, U32, List.append(&2, U32, bcat(pre), D), Y), List.append(&2, U32, bcat(pre), List.append(&2, U32, D, Y)), VS.app_assoc(bcat(pre), D, Y)) :
    {VS.bt(4n, VS.bdr(List.length(&2, U32, bcat(pre)), _)) == N.digits(4n, FZ(pre, post)) : +List<U32>}
  %Equal.sym(+List<U32>, VS.bdr(List.length(&2, U32, bcat(pre)), List.append(&2, U32, bcat(pre), List.append(&2, U32, D, Y))), List.append(&2, U32, D, Y), VS.bdr_app(bcat(pre), List.append(&2, U32, D, Y))) :
    {VS.bt(4n, _) == N.digits(4n, FZ(pre, post)) : +List<U32>}
  {==}

# The layout's length: the fixed size plus the payload's length.
law out_len:
  for +pre: +List<+List<U32>>
  for +Y: +List<U32>
  for +post: +List<+List<U32>>
  {List.length(&2, U32, OUT(pre, Y, post)) == Nat.add(FZ(pre, post), List.length(&2, U32, Y)) : Nat}
def out_len(pre, Y, post):
  +D = List.append(&2, U32, N.digits(4n, FZ(pre, post)), bcat(post))
  +A = List.append(&2, U32, bcat(pre), D)
  %Equal.sym(+List<U32>, OUT(pre, Y, post), OUTX(pre, Y, post), out_eq(pre, Y, post)) :
    {List.length(&2, U32, _) == Nat.add(FZ(pre, post), List.length(&2, U32, Y)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, List.append(&2, U32, A, Y)), Nat.add(List.length(&2, U32, A), List.length(&2, U32, Y)), VS.len_app(A, Y)) :
    {_ == Nat.add(FZ(pre, post), List.length(&2, U32, Y)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, A), Nat.add(List.length(&2, U32, bcat(pre)), List.length(&2, U32, D)), VS.len_app(bcat(pre), D)) :
    {Nat.add(_, List.length(&2, U32, Y)) == Nat.add(FZ(pre, post), List.length(&2, U32, Y)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, D), Nat.add(List.length(&2, U32, N.digits(4n, FZ(pre, post))), List.length(&2, U32, bcat(post))), VS.len_app(N.digits(4n, FZ(pre, post)), bcat(post))) :
    {Nat.add(Nat.add(List.length(&2, U32, bcat(pre)), _), List.length(&2, U32, Y)) == Nat.add(FZ(pre, post), List.length(&2, U32, Y)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, bcat(pre)), lens(pre), len_bcat(pre)) :
    {Nat.add(Nat.add(_, Nat.add(List.length(&2, U32, N.digits(4n, FZ(pre, post))), List.length(&2, U32, bcat(post)))), List.length(&2, U32, Y)) == Nat.add(FZ(pre, post), List.length(&2, U32, Y)) : Nat}
  %Equal.sym(Nat, List.length(&2, U32, bcat(post)), lens(post), len_bcat(post)) :
    {Nat.add(Nat.add(lens(pre), Nat.add(List.length(&2, U32, N.digits(4n, FZ(pre, post))), _)), List.length(&2, U32, Y)) == Nat.add(FZ(pre, post), List.length(&2, U32, Y)) : Nat}
  {==}
