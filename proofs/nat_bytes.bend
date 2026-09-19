import Base
import ./bit_vector_inverse.bend as Inverse
import ./bit_chunk_count.bend as Count
import ./tree.bend as Tree
import ./nat_order.bend as Order
import ./packing.bend as Pack
import ./word_facts.bend as W
import ./primitive_invariants.bend as V
import ../src/nat_bytes.bend as I
import ../spec/nat_bytes.bend as S
import ../src/primitives.bend as R
import ../spec/primitives.bend as P
import ./primitives.bend as Basic

law prepend_optional:
  for ok: Bool
  for +b: U32
  for +xs: +List<U32>
  {I.prepend(b, P.optional(ok, xs)) == P.optional(ok, b <> xs) : Maybe<&2, +List<U32>>}
def prepend_optional(ok, b, xs):
  match ok:
    case False{}: {==}
    case True{}: {==}

law zero_correct:
  for +ok: Bool
  {I.zero_gate(ok) == P.optional(ok, []) : Maybe<&2, +List<U32>>}
def zero_correct(ok):
  match ok:
    case False{}: {==}
    case True{}: {==}

law pair_correct:
  for +width: Nat
  for qr: Nat & Nat
  for recur: @+n: Nat -> {I.encode(width, n) == S.encoding(width, n) : Maybe<&2, +List<U32>>}
  {I.encode_pair(qr, q => I.encode(width, q)) == P.optional(S.fits(width, Nat.div.fin(qr)), U32.from_nat(Nat.mod.fin(qr)) <> S.digits(width, Nat.div.fin(qr))) : Maybe<&2, +List<U32>>}
def pair_correct(width, qr, recur):
  (+q, +r) = qr
  %Equal.sym(Maybe<&2, +List<U32>>, I.encode(width, q), S.encoding(width, q), recur(q)) : {I.prepend(U32.from_nat(r), _) == P.optional(S.fits(width, q), U32.from_nat(r) <> S.digits(width, q)) : Maybe<&2, +List<U32>>}
  prepend_optional(S.fits(width, q), U32.from_nat(r), S.digits(width, q))

law encode_correct:
  for +width: Nat
  for +n: Nat
  {I.encode(width, n) == S.encoding(width, n) : Maybe<&2, +List<U32>>}
def encode_correct(width, n):
  match width:
    case 0n: zero_correct(Nat.is_eq(n, 0n))
    case 1n+p: pair_correct(p, Nat.divmod(n, 256n), x => encode_correct(p, x))

law optional_acceptance:
  for +ok: Bool
  for xs: +List<U32>
  {R.is_some(P.optional(ok, xs)) == ok : Bool}
def optional_acceptance(ok, xs):
  match ok:
    case False{}: {==}
    case True{}: {==}

law encode_acceptance:
  for +width: Nat
  for +n: Nat
  {R.is_some(I.encode(width, n)) == S.fits(width, n) : Bool}
def encode_acceptance(width, n):
  %Equal.sym(Maybe<&2, +List<U32>>, I.encode(width, n), S.encoding(width, n), encode_correct(width, n)) : {R.is_some(_) == S.fits(width, n) : Bool}
  optional_acceptance(S.fits(width, n), S.digits(width, n))

law digits_length:
  for +width: Nat
  for +n: Nat
  {List.length(&2, U32, S.digits(width, n)) == width : Nat}
def digits_length(width, n):
  match width:
    case 0n: {==}
    case 1n+p:
      Equal.cong(Nat, Nat, x => 1n+x, List.length(&2, U32, S.digits(p, Nat.div(n, 256n))), p, digits_length(p, Nat.div(n, 256n)))

law remainder_bound:
  for +n: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  for +sum: {Nat.add(m, r) == 255n : Nat}
  {Nat.is_le(Nat.mod.fin(Nat.divmod.go(n, m, d, r)), 255n) == True{} : Bool}
def remainder_bound(n, m, d, r, sum):
  match n:
    case 0n:
      %sum : {Nat.is_le(r, _) == True{} : Bool}
      Order.left_below_sum(m, r)
    case 1n+p:
      match m:
        case 0n:
          remainder_bound(p, r, 1n+d, 0n, Equal.trans(Nat, Nat.add(r, 0n), r, 255n, Pack.add_zero(r), sum))
        case 1n+q:
          remainder_bound(p, q, d, 1n+r, Equal.trans(Nat, Nat.add(q, 1n+r), 1n+Nat.add(q, r), 255n, Pack.add_succ(q, r), sum))

law mod_byte_bound:
  for +n: Nat
  {Nat.is_le(Nat.mod(n, 256n), 255n) == True{} : Bool}
def mod_byte_bound(n): remainder_bound(n, 255n, 0n, 0n, {==})

# Exhaustive intrinsic byte positions, followed by exclusion of every larger
# natural. This is not a bound on the encoded input n.
law small_byte:
  for +n: Nat
  for bound: {Nat.is_le(n, 255n) == True{} : Bool}
  {U32.is_lt(U32.from_nat(n), 256) == True{} : Bool}
def small_byte(n, bound):
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
    case 256n+p: Empty.absurd({U32.is_lt(U32.from_nat(256n+p), 256) == True{} : Bool}, W.false_true(bound))

law digits_domain:
  for +width: Nat
  for +n: Nat
  {P.bytes_domain(S.digits(width, n)) == True{} : Bool}
def digits_domain(width, n):
  match width:
    case 0n: {==}
    case 1n+p:
      V.and_true(U32.is_lt(U32.from_nat(Nat.mod(n, 256n)), 256), P.bytes_domain(S.digits(p, Nat.div(n, 256n))), small_byte(Nat.mod(n, 256n), mod_byte_bound(n)), digits_domain(p, Nat.div(n, 256n)))

law digits_scope:
  for +width: Nat
  for +n: Nat
  {P.byte_scope(width, S.digits(width, n)) == True{} : Bool}
def digits_scope(width, n):
  Pack.scope_from_size(S.digits(width, n), width, digits_length(width, n), digits_domain(width, n))

law optional_scope:
  for ok: Bool
  for +n: Nat
  Tree.result_scope(P.optional(ok, S.digits(32n, n)))
def optional_scope(ok, n):
  match ok:
    case False{}: Unit{}
    case True{}: digits_scope(32n, n)

law length_scope:
  for +n: Nat
  Tree.result_scope(I.encode(32n, n))
def length_scope(n):
  %Equal.sym(Maybe<&2, +List<U32>>, I.encode(32n, n), S.encoding(32n, n), encode_correct(32n, n)) : Tree.result_scope(_)
  optional_scope(S.fits(32n, n), n)

law fits_monotone:
  for +width: Nat
  for +a: Nat
  for +b: Nat
  for le: {Nat.is_le(a, b) == True{} : Bool}
  for fit: {S.fits(width, b) == True{} : Bool}
  {S.fits(width, a) == True{} : Bool}
def fits_monotone(width, a, b, le, fit):
  match width:
    case 0n:
      match a b:
        case 0n 0n: {==}
        case 0n 1n+q: {==}
        case 1n+p 0n: Empty.absurd({False{} == True{} : Bool}, W.false_true(le))
        case 1n+p 1n+q: Empty.absurd({False{} == True{} : Bool}, W.false_true(fit))
    case 1n+p:
      fits_monotone(p, Nat.div(a, 256n), Nat.div(b, 256n), Count.quotient_monotone(a, b, 255n, 0n, 0n, le), fit)

# Arithmetic value of Base's quotient/remainder pair. The proof below connects
# the actual division recurrence to n = remainder + 256 * quotient.
def pair_value(qr: Nat & Nat) -> Nat:
  (q, r) = qr
  Nat.add(r, Nat.mul(q, 256n))

law division_reset:
  for +p: Nat
  for +d: Nat
  for +r: Nat
  for equal: {r == 255n : Nat}
  for recur: {pair_value(Nat.divmod.go(p, r, 1n+d, 0n)) == Nat.add(p, Nat.mul(1n+d, 256n)) : Nat}
  {pair_value(Nat.divmod.go(p, r, 1n+d, 0n)) == 1n+Nat.add(p, Nat.add(r, Nat.mul(d, 256n))) : Nat}
def division_reset(p, d, r, equal, recur):
  %Equal.sym(Nat, r, 255n, equal) : {pair_value(Nat.divmod.go(p, r, 1n+d, 0n)) == 1n+Nat.add(p, Nat.add(_, Nat.mul(d, 256n))) : Nat}
  %Pack.add_succ(p, Nat.add(255n, Nat.mul(d, 256n))) : {pair_value(Nat.divmod.go(p, r, 1n+d, 0n)) == _ : Nat}
  recur

law division_value:
  for +n: Nat
  for +m: Nat
  for +d: Nat
  for +r: Nat
  for +sum: {Nat.add(m, r) == 255n : Nat}
  {pair_value(Nat.divmod.go(n, m, d, r)) == Nat.add(n, Nat.add(r, Nat.mul(d, 256n))) : Nat}
def division_value(n, m, d, r, sum):
  match n:
    case 0n: {==}
    case 1n+p:
      match m:
        case 0n:
          division_reset(p, d, r, sum, division_value(p, r, 1n+d, 0n, Equal.trans(Nat, Nat.add(r, 0n), r, 255n, Pack.add_zero(r), sum)))
        case 1n+q:
          %Pack.add_succ(p, Nat.add(r, Nat.mul(d, 256n))) : {pair_value(Nat.divmod.go(p, q, d, 1n+r)) == _ : Nat}
          division_value(p, q, d, 1n+r, Equal.trans(Nat, Nat.add(q, 1n+r), 1n+Nat.add(q, r), 255n, Pack.add_succ(q, r), sum))

law pair_projection:
  for qr: Nat & Nat
  {pair_value(qr) == Nat.add(Nat.mod.fin(qr), Nat.mul(Nat.div.fin(qr), 256n)) : Nat}
def pair_projection(qr):
  (q, r) = qr
  {==}

law division_recompose:
  for +n: Nat
  {Nat.add(Nat.mod(n, 256n), Nat.mul(Nat.div(n, 256n), 256n)) == n : Nat}
def division_recompose(n):
  %pair_projection(Nat.divmod(n, 256n)) : {_ == n : Nat}
  Equal.trans(Nat, pair_value(Nat.divmod(n, 256n)), Nat.add(n, 0n), n, division_value(n, 255n, 0n, 0n, {==}), Pack.add_zero(n))

law small_exact:
  for +n: Nat
  for bound: {Nat.is_le(n, 255n) == True{} : Bool}
  {U32.to_nat(U32.from_nat(n)) == n : Nat}
def small_exact(n, bound):
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
    case 256n+p: Empty.absurd({U32.to_nat(U32.from_nat(256n+p)) == 256n+p : Nat}, W.false_true(bound))

law digits_value:
  for +width: Nat
  for +n: Nat
  for fit: {S.fits(width, n) == True{} : Bool}
  {S.value(S.digits(width, n)) == n : Nat}
def digits_value(width, n, fit):
  match width:
    case 0n: Equal.sym(Nat, n, 0n, Inverse.nat_equal_sound(n, 0n, fit))
    case 1n+p:
      %Equal.sym(Nat, U32.to_nat(U32.from_nat(Nat.mod(n, 256n))), Nat.mod(n, 256n), small_exact(Nat.mod(n, 256n), mod_byte_bound(n))) : {Nat.add(_, Nat.mul(S.value(S.digits(p, Nat.div(n, 256n))), 256n)) == n : Nat}
      %Equal.sym(Nat, S.value(S.digits(p, Nat.div(n, 256n))), Nat.div(n, 256n), digits_value(p, Nat.div(n, 256n), fit)) : {Nat.add(Nat.mod(n, 256n), Nat.mul(_, 256n)) == n : Nat}
      division_recompose(n)

def decoded_value(result: Maybe<&2, +List<U32>>) -> Maybe<&2, Nat>:
  match result:
    case None{}: None{}
    case Some{xs}: Some{S.value(xs)}

law optional_value:
  for +ok: Bool
  for +width: Nat
  for +n: Nat
  for fit: {ok == True{} : Bool} -> {S.fits(width, n) == True{} : Bool}
  {decoded_value(P.optional(ok, S.digits(width, n))) == Bool.pick(Maybe<&2, Nat>, ok, Some{n}, None{}) : Maybe<&2, Nat>}
def optional_value(ok, width, n, fit):
  match ok:
    case False{}: {==}
    case True{}:
      Equal.cong(Nat, Maybe<&2, Nat>, v => Some{v}, S.value(S.digits(width, n)), n, digits_value(width, n, fit({==})))

# Every accepted conversion has exactly the original mathematical value,
# including natural inputs larger than the runtime Nat transport range.
law encode_exact_value:
  for +width: Nat
  for +n: Nat
  {decoded_value(I.encode(width, n)) == Bool.pick(Maybe<&2, Nat>, S.fits(width, n), Some{n}, None{}) : Maybe<&2, Nat>}
def encode_exact_value(width, n):
  %Equal.sym(Maybe<&2, +List<U32>>, I.encode(width, n), S.encoding(width, n), encode_correct(width, n)) : {decoded_value(_) == Bool.pick(Maybe<&2, Nat>, S.fits(width, n), Some{n}, None{}) : Maybe<&2, Nat>}
  optional_value(S.fits(width, n), width, n, e => e)

law zero_fits:
  for +width: Nat
  {S.fits(width, 0n) == True{} : Bool}
def zero_fits(width):
  match width:
    case 0n: {==}
    case 1n+p: zero_fits(p)

law fits_extend:
  for +width: Nat
  for +extra: Nat
  for +n: Nat
  for fit: {S.fits(width, n) == True{} : Bool}
  {S.fits(Nat.add(width, extra), n) == True{} : Bool}
def fits_extend(width, extra, n, fit):
  match width:
    case 0n:
      %Equal.sym(Nat, n, 0n, Inverse.nat_equal_sound(n, 0n, fit)) : {S.fits(extra, _) == True{} : Bool}
      zero_fits(extra)
    case 1n+p: fits_extend(p, extra, Nat.div(n, 256n), fit)
