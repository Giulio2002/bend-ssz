import Base
import ./nat_order.bend as Order
import ./word_facts.bend as W
import ../src/packing.bend as Pack
import ../src/bit_packing.bend as Bits
import ../src/bit_root.bend as Root
import ../spec/bit_packing.bend as Model
import ../src/primitives.bend as Bytes
import ./packing.bend as P
import ./bit_packing.bend as B

# A counting invariant for the actual byte packer's partial buffer.
def occupied(xs: +List<U32>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{h, t}: True{}

def count(n: Nat, room: Nat, used: Bool) -> Nat:
  match n:
    case 0n: Bool.pick(Nat, used, 1n, 0n)
    case 1n+p:
      match room:
        case 0n: 1n+count(p, 31n, False{})
        case 1n+r: count(p, r, True{})

law reverse_length:
  for -A: Data
  for +xs: +List<A>
  for +ys: +List<A>
  {List.length(&2, A, List.reverse.go(&2, A, xs, ys)) == Nat.add(List.length(&2, A, xs), List.length(&2, A, ys)) : Nat}
def reverse_length(A, xs, ys):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %P.add_succ(List.length(&2, A, t), List.length(&2, A, ys)) : {List.length(&2, A, List.reverse.go(&2, A, t, h <> ys)) == _ : Nat}
      reverse_length(A, t, h <> ys)

law finish_length:
  for +room: Nat
  for +buffer: +List<U32>
  for +cs: +List<+List<U32>>
  {List.length(&2, +List<U32>, Pack.finish(room, buffer, cs)) == Nat.add(count(0n, room, occupied(buffer)), List.length(&2, +List<U32>, cs)) : Nat}
def finish_length(room, buffer, cs):
  match buffer:
    case Nil{}:
      Equal.trans(Nat, List.length(&2, +List<U32>, List.reverse(&2, +List<U32>, cs)), Nat.add(List.length(&2, +List<U32>, cs), 0n), List.length(&2, +List<U32>, cs), reverse_length(+List<U32>, cs, []), P.add_zero(List.length(&2, +List<U32>, cs)))
    case Con{h, t}:
      Equal.trans(Nat, List.length(&2, +List<U32>, Pack.finish(room, h <> t, cs)), Nat.add(1n+List.length(&2, +List<U32>, cs), 0n), 1n+List.length(&2, +List<U32>, cs), reverse_length(+List<U32>, List.append(&2, U32, h <> t, Bytes.pad(1n+room, [])) <> cs, []), P.add_zero(1n+List.length(&2, +List<U32>, cs)))

law snoc_occupied:
  for +xs: +List<U32>
  for h: U32
  {occupied(List.append(&2, U32, xs, [h])) == True{} : Bool}
def snoc_occupied(xs, h):
  match xs:
    case Nil{}: {==}
    case Con{a, t}: {==}

law scan_length:
  for +xs: +List<U32>
  for +room: Nat
  for +buffer: +List<U32>
  for +cs: +List<+List<U32>>
  {List.length(&2, +List<U32>, Pack.scan(xs, room, buffer, cs)) == Nat.add(count(List.length(&2, U32, xs), room, occupied(buffer)), List.length(&2, +List<U32>, cs)) : Nat}
def scan_length(xs, room, buffer, cs):
  match xs:
    case Nil{}: finish_length(room, buffer, cs)
    case Con{h, t}:
      match room:
        case 0n:
          %P.add_succ(count(List.length(&2, U32, t), 31n, False{}), List.length(&2, +List<U32>, cs)) : {List.length(&2, +List<U32>, Pack.scan(t, 31n, [], List.append(&2, U32, buffer, [h]) <> cs)) == _ : Nat}
          scan_length(t, 31n, [], List.append(&2, U32, buffer, [h]) <> cs)
        case 1n+r:
          %snoc_occupied(buffer, h) : {List.length(&2, +List<U32>, Pack.scan(t, r, List.append(&2, U32, buffer, [h]), cs)) == Nat.add(count(List.length(&2, U32, t), r, _), List.length(&2, +List<U32>, cs)) : Nat}
          scan_length(t, r, List.append(&2, U32, buffer, [h]), cs)

# Quotient accumulation commutes with adding one to the initial quotient.
law quotient_successor:
  for +n: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  {Nat.div.fin(Nat.divmod.go(n, m, 1n+d, r)) == 1n+Nat.div.fin(Nat.divmod.go(n, m, d, r)) : Nat}
def quotient_successor(n, m, d, r):
  match n:
    case 0n: {==}
    case 1n+p:
      match m:
        case 0n: quotient_successor(p, r, 1n+d, 0n)
        case 1n+q: quotient_successor(p, q, d, 1n+r)

# The 256 residual cases are the intrinsic bits per SSZ chunk; the final
# recursive case proves the claim for arbitrarily many chunks.
law count_bits:
  for +n: Nat
  {count(Model.byte_count(n), 31n, False{}) == Root.chunk_limit(n) : Nat}
def count_bits(n):
  match n:
    case 0n: {==}
    case 1n: {==}
    case 2n: {==}
    case 3n: {==}
    case 4n: {==}
    case 5n: {==}
    case 6n: {==}
    case 7n: {==}
    case 8n: {==}
    case 9n: {==}
    case 10n: {==}
    case 11n: {==}
    case 12n: {==}
    case 13n: {==}
    case 14n: {==}
    case 15n: {==}
    case 16n: {==}
    case 17n: {==}
    case 18n: {==}
    case 19n: {==}
    case 20n: {==}
    case 21n: {==}
    case 22n: {==}
    case 23n: {==}
    case 24n: {==}
    case 25n: {==}
    case 26n: {==}
    case 27n: {==}
    case 28n: {==}
    case 29n: {==}
    case 30n: {==}
    case 31n: {==}
    case 32n: {==}
    case 33n: {==}
    case 34n: {==}
    case 35n: {==}
    case 36n: {==}
    case 37n: {==}
    case 38n: {==}
    case 39n: {==}
    case 40n: {==}
    case 41n: {==}
    case 42n: {==}
    case 43n: {==}
    case 44n: {==}
    case 45n: {==}
    case 46n: {==}
    case 47n: {==}
    case 48n: {==}
    case 49n: {==}
    case 50n: {==}
    case 51n: {==}
    case 52n: {==}
    case 53n: {==}
    case 54n: {==}
    case 55n: {==}
    case 56n: {==}
    case 57n: {==}
    case 58n: {==}
    case 59n: {==}
    case 60n: {==}
    case 61n: {==}
    case 62n: {==}
    case 63n: {==}
    case 64n: {==}
    case 65n: {==}
    case 66n: {==}
    case 67n: {==}
    case 68n: {==}
    case 69n: {==}
    case 70n: {==}
    case 71n: {==}
    case 72n: {==}
    case 73n: {==}
    case 74n: {==}
    case 75n: {==}
    case 76n: {==}
    case 77n: {==}
    case 78n: {==}
    case 79n: {==}
    case 80n: {==}
    case 81n: {==}
    case 82n: {==}
    case 83n: {==}
    case 84n: {==}
    case 85n: {==}
    case 86n: {==}
    case 87n: {==}
    case 88n: {==}
    case 89n: {==}
    case 90n: {==}
    case 91n: {==}
    case 92n: {==}
    case 93n: {==}
    case 94n: {==}
    case 95n: {==}
    case 96n: {==}
    case 97n: {==}
    case 98n: {==}
    case 99n: {==}
    case 100n: {==}
    case 101n: {==}
    case 102n: {==}
    case 103n: {==}
    case 104n: {==}
    case 105n: {==}
    case 106n: {==}
    case 107n: {==}
    case 108n: {==}
    case 109n: {==}
    case 110n: {==}
    case 111n: {==}
    case 112n: {==}
    case 113n: {==}
    case 114n: {==}
    case 115n: {==}
    case 116n: {==}
    case 117n: {==}
    case 118n: {==}
    case 119n: {==}
    case 120n: {==}
    case 121n: {==}
    case 122n: {==}
    case 123n: {==}
    case 124n: {==}
    case 125n: {==}
    case 126n: {==}
    case 127n: {==}
    case 128n: {==}
    case 129n: {==}
    case 130n: {==}
    case 131n: {==}
    case 132n: {==}
    case 133n: {==}
    case 134n: {==}
    case 135n: {==}
    case 136n: {==}
    case 137n: {==}
    case 138n: {==}
    case 139n: {==}
    case 140n: {==}
    case 141n: {==}
    case 142n: {==}
    case 143n: {==}
    case 144n: {==}
    case 145n: {==}
    case 146n: {==}
    case 147n: {==}
    case 148n: {==}
    case 149n: {==}
    case 150n: {==}
    case 151n: {==}
    case 152n: {==}
    case 153n: {==}
    case 154n: {==}
    case 155n: {==}
    case 156n: {==}
    case 157n: {==}
    case 158n: {==}
    case 159n: {==}
    case 160n: {==}
    case 161n: {==}
    case 162n: {==}
    case 163n: {==}
    case 164n: {==}
    case 165n: {==}
    case 166n: {==}
    case 167n: {==}
    case 168n: {==}
    case 169n: {==}
    case 170n: {==}
    case 171n: {==}
    case 172n: {==}
    case 173n: {==}
    case 174n: {==}
    case 175n: {==}
    case 176n: {==}
    case 177n: {==}
    case 178n: {==}
    case 179n: {==}
    case 180n: {==}
    case 181n: {==}
    case 182n: {==}
    case 183n: {==}
    case 184n: {==}
    case 185n: {==}
    case 186n: {==}
    case 187n: {==}
    case 188n: {==}
    case 189n: {==}
    case 190n: {==}
    case 191n: {==}
    case 192n: {==}
    case 193n: {==}
    case 194n: {==}
    case 195n: {==}
    case 196n: {==}
    case 197n: {==}
    case 198n: {==}
    case 199n: {==}
    case 200n: {==}
    case 201n: {==}
    case 202n: {==}
    case 203n: {==}
    case 204n: {==}
    case 205n: {==}
    case 206n: {==}
    case 207n: {==}
    case 208n: {==}
    case 209n: {==}
    case 210n: {==}
    case 211n: {==}
    case 212n: {==}
    case 213n: {==}
    case 214n: {==}
    case 215n: {==}
    case 216n: {==}
    case 217n: {==}
    case 218n: {==}
    case 219n: {==}
    case 220n: {==}
    case 221n: {==}
    case 222n: {==}
    case 223n: {==}
    case 224n: {==}
    case 225n: {==}
    case 226n: {==}
    case 227n: {==}
    case 228n: {==}
    case 229n: {==}
    case 230n: {==}
    case 231n: {==}
    case 232n: {==}
    case 233n: {==}
    case 234n: {==}
    case 235n: {==}
    case 236n: {==}
    case 237n: {==}
    case 238n: {==}
    case 239n: {==}
    case 240n: {==}
    case 241n: {==}
    case 242n: {==}
    case 243n: {==}
    case 244n: {==}
    case 245n: {==}
    case 246n: {==}
    case 247n: {==}
    case 248n: {==}
    case 249n: {==}
    case 250n: {==}
    case 251n: {==}
    case 252n: {==}
    case 253n: {==}
    case 254n: {==}
    case 255n: {==}
    case 256n+p:
      %Equal.sym(Nat, Nat.div.fin(Nat.divmod.go(Nat.add(p, 255n), 255n, 1n, 0n)), 1n+Root.chunk_limit(p), quotient_successor(Nat.add(p, 255n), 255n, 0n, 0n)) : {1n+count(Model.byte_count(p), 31n, False{}) == _ : Nat}
      Equal.cong(Nat, Nat, x => 1n+x, count(Model.byte_count(p), 31n, False{}), Root.chunk_limit(p), count_bits(p))

law chunks_length:
  for +bits: +List<Bool>
  {List.length(&2, +List<U32>, Root.chunks(bits)) == Root.chunk_limit(List.length(&2, Bool, bits)) : Nat}
def chunks_length(bits):
  %count_bits(List.length(&2, Bool, bits)) : {List.length(&2, +List<U32>, Root.chunks(bits)) == _ : Nat}
  %B.pack_length(bits) : {List.length(&2, +List<U32>, Root.chunks(bits)) == count(_, 31n, False{}) : Nat}
  %P.add_zero(count(List.length(&2, U32, Bits.pack(bits)), 31n, False{})) : {List.length(&2, +List<U32>, Root.chunks(bits)) == _ : Nat}
  scan_length(Bits.pack(bits), 31n, [], [])

law quotient_lower:
  for +n: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  {Nat.is_le(d, Nat.div.fin(Nat.divmod.go(n, m, d, r))) == True{} : Bool}
def quotient_lower(n, m, d, r):
  match n:
    case 0n: Order.reflexive(d)
    case 1n+p:
      match m:
        case 0n:
          Order.transitive(d, 1n+d, Nat.div.fin(Nat.divmod.go(p, r, 1n+d, 0n)), Order.step_right(d, d, Order.reflexive(d)), quotient_lower(p, r, 1n+d, 0n))
        case 1n+q: quotient_lower(p, q, d, 1n+r)

law quotient_monotone:
  for +a: Nat
  for +b: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  for le: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Nat.div.fin(Nat.divmod.go(a, m, d, r)), Nat.div.fin(Nat.divmod.go(b, m, d, r))) == True{} : Bool}
def quotient_monotone(a, b, m, d, r, le):
  match a b:
    case 0n 0n: Order.reflexive(d)
    case 0n 1n+q: quotient_lower(1n+q, m, d, r)
    case 1n+p 0n:
      Empty.absurd({Nat.is_le(Nat.div.fin(Nat.divmod.go(1n+p, m, d, r)), d) == True{} : Bool}, W.false_true(le))
    case 1n+p 1n+q:
      match m:
        case 0n: quotient_monotone(p, q, r, 1n+d, 0n, le)
        case 1n+s: quotient_monotone(p, q, s, d, 1n+r, le)

law chunk_limit_monotone:
  for +a: Nat
  for +b: Nat
  for le: {Nat.is_le(a, b) == True{} : Bool}
  {Nat.is_le(Root.chunk_limit(a), Root.chunk_limit(b)) == True{} : Bool}
def chunk_limit_monotone(a, b, le):
  quotient_monotone(Nat.add(a, 255n), Nat.add(b, 255n), 255n, 0n, 0n, Order.add_right(a, b, 255n, le))

law list_chunk_bound:
  for +capacity: Nat
  for +bits: +List<Bool>
  for valid: {Nat.is_le(List.length(&2, Bool, bits), capacity) == True{} : Bool}
  {Nat.is_le(List.length(&2, +List<U32>, Root.chunks(bits)), Root.chunk_limit(capacity)) == True{} : Bool}
def list_chunk_bound(capacity, bits, valid):
  %Equal.sym(Nat, List.length(&2, +List<U32>, Root.chunks(bits)), Root.chunk_limit(List.length(&2, Bool, bits)), chunks_length(bits)) : {Nat.is_le(_, Root.chunk_limit(capacity)) == True{} : Bool}
  chunk_limit_monotone(List.length(&2, Bool, bits), capacity, valid)
