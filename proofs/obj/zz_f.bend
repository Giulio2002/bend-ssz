import Base
import ../../src/buffer.bend as B
import ../../src/obj.bend as O
import ../../types/FuluContributionAndProof_def_generated.bend as D
import ../../types/FuluContributionAndProof_encode_ssz_generated.bend as E
import ../../types/FuluSignedContributionAndProof_def_generated.bend as D2
import ../../types/FuluSignedContributionAndProof_encode_ssz_generated.bend as E2

def f1() -> {Pair.snd(D.ContributionAndProof, U32, Pair.snd(Array<U32>, D.ContributionAndProof & U32, E.ContributionAndProof_putk(O.out_at(7n), 0, D.ContributionAndProof_default()))) == 0 : U32}:
  {==}
def f2() -> {Pair.snd(D2.SignedContributionAndProof, U32, Pair.snd(Array<U32>, D2.SignedContributionAndProof & U32, E2.SignedContributionAndProof_putk(O.out_at(7n), 0, D2.SignedContributionAndProof_default()))) == 0 : U32}:
  {==}
