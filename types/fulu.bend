import Base
import ../types/schema.bend as T
import ../types/primitive.bend as P
import ../src/ssz.bend as API
import ../spec/fulu_schemas.bend as Spec
import ../types/fulu_cschema.bend as Compact
import ../src/buffer.bend as Buf
import ../src/access.bend as Access
import ../src/digest.bend as Digest
import ../src/cschema.bend as CS

def Node0() -> Data: Bool
def Node0.to_value(v: Node0()) -> T.Value: T.BooleanValue{v}
def Node0.from_value(value: T.Value) -> Maybe<&2, Node0()>:
  match value:
    case T.BooleanValue{v}: Some{v}
    case _: None{}
def Node0.schema() -> T.Schema: Spec.Schema0()

def Node1() -> Data: P.UInt
def Node1.to_value(v: Node1()) -> T.Value: T.UnsignedValue{v}
def Node1.from_value(value: T.Value) -> Maybe<&2, Node1()>:
  match value:
    case T.UnsignedValue{v}: Some{v}
    case _: None{}
def Node1.schema() -> T.Schema: Spec.Schema1()

def Node2() -> Data: P.UInt
def Node2.to_value(v: Node2()) -> T.Value: T.UnsignedValue{v}
def Node2.from_value(value: T.Value) -> Maybe<&2, Node2()>:
  match value:
    case T.UnsignedValue{v}: Some{v}
    case _: None{}
def Node2.schema() -> T.Schema: Spec.Schema2()

def Node3() -> Data: P.UInt
def Node3.to_value(v: Node3()) -> T.Value: T.UnsignedValue{v}
def Node3.from_value(value: T.Value) -> Maybe<&2, Node3()>:
  match value:
    case T.UnsignedValue{v}: Some{v}
    case _: None{}
def Node3.schema() -> T.Schema: Spec.Schema3()

def Node4() -> Data: P.UInt
def Node4.to_value(v: Node4()) -> T.Value: T.UnsignedValue{v}
def Node4.from_value(value: T.Value) -> Maybe<&2, Node4()>:
  match value:
    case T.UnsignedValue{v}: Some{v}
    case _: None{}
def Node4.schema() -> T.Schema: Spec.Schema4()

def Node5() -> Data: +List<U32>
def Node5.to_value(v: Node5()) -> T.Value: T.BytesValue{v}
def Node5.from_value(value: T.Value) -> Maybe<&2, Node5()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node5.schema() -> T.Schema: Spec.Schema5()

def Node6() -> Data: +List<U32>
def Node6.to_value(v: Node6()) -> T.Value: T.BytesValue{v}
def Node6.from_value(value: T.Value) -> Maybe<&2, Node6()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node6.schema() -> T.Schema: Spec.Schema6()

def Node7() -> Data: +List<U32>
def Node7.to_value(v: Node7()) -> T.Value: T.BytesValue{v}
def Node7.from_value(value: T.Value) -> Maybe<&2, Node7()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node7.schema() -> T.Schema: Spec.Schema7()

def Node8() -> Data: +List<U32>
def Node8.to_value(v: Node8()) -> T.Value: T.BytesValue{v}
def Node8.from_value(value: T.Value) -> Maybe<&2, Node8()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node8.schema() -> T.Schema: Spec.Schema8()

def Node9() -> Data: +List<U32>
def Node9.to_value(v: Node9()) -> T.Value: T.BytesValue{v}
def Node9.from_value(value: T.Value) -> Maybe<&2, Node9()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node9.schema() -> T.Schema: Spec.Schema9()

def Node10() -> Data: +List<U32>
def Node10.to_value(v: Node10()) -> T.Value: T.BytesValue{v}
def Node10.from_value(value: T.Value) -> Maybe<&2, Node10()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node10.schema() -> T.Schema: Spec.Schema10()

def Node11() -> Data: +List<U32>
def Node11.to_value(v: Node11()) -> T.Value: T.BytesValue{v}
def Node11.from_value(value: T.Value) -> Maybe<&2, Node11()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node11.schema() -> T.Schema: Spec.Schema11()

def Node7.seq_to_go(xs: +List<Node7()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: Node7.seq_to_go(t, T.Items{Node7.to_value(h), acc})

def Node7.seq_to(xs: +List<Node7()>) -> T.Value:
  Node7.seq_to_go(List.reverse(&2, Node7(), xs), T.EmptyItems{})

def Node7.seq_step(result: Maybe<&2, Node7()>, acc: +List<Node7()>, next: +List<Node7()> -> Maybe<&2, +List<Node7()>>) -> Maybe<&2, +List<Node7()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def Node7.seq_from_go(value: T.Value, acc: +List<Node7()>) -> Maybe<&2, +List<Node7()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, Node7(), acc)}
    case T.Items{h, t}: Node7.seq_step(Node7.from_value(h), acc, next => Node7.seq_from_go(t, next))
    case _: None{}

def Node7.seq_from(value: T.Value) -> Maybe<&2, +List<Node7()>>:
  Node7.seq_from_go(value, [])

def Node12() -> Data: +List<Node7()>
def Node12.to_value(v: Node12()) -> T.Value: T.Sequence{Node7.seq_to(v)}
def Node12.from_value(value: T.Value) -> Maybe<&2, Node12()>:
  match value:
    case T.Sequence{v}: Node7.seq_from(v)
    case _: None{}
def Node12.schema() -> T.Schema: Spec.Schema12()

type Fork is Data:
  Fork{previous_version: Node6(), current_version: Node6(), epoch: Node3()}
def ForkValue() -> Data: Fork
def ForkValue.to_value(v: ForkValue()) -> T.Value:
  Fork{previous_version, current_version, epoch} = v
  T.Sequence{T.Items{Node6.to_value(previous_version), T.Items{Node6.to_value(current_version), T.Items{Node3.to_value(epoch), T.EmptyItems{}}}}}
def ForkValue.assemble(a0: Maybe<&2, Node6()>, a1: Maybe<&2, Node6()>, a2: Maybe<&2, Node3()>) -> Maybe<&2, ForkValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{Fork{v0, v1, v2}}
    case _ _ _: None{}
def ForkValue.from_value(v: T.Value) -> Maybe<&2, ForkValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: ForkValue.assemble(Node6.from_value(v0), Node6.from_value(v1), Node3.from_value(v2))
    case _: None{}
def ForkValue.schema() -> T.Schema: Spec.Schema13()

def Node15() -> Data: +List<Bool>
def Node15.to_value(v: Node15()) -> T.Value: T.BitsValue{v}
def Node15.from_value(value: T.Value) -> Maybe<&2, Node15()>:
  match value:
    case T.BitsValue{v}: Some{v}
    case _: None{}
def Node15.schema() -> T.Schema: Spec.Schema14()

type SyncAggregate is Data:
  SyncAggregate{sync_committee_bits: Node15(), sync_committee_signature: Node9()}
def SyncAggregateValue() -> Data: SyncAggregate
def SyncAggregateValue.to_value(v: SyncAggregateValue()) -> T.Value:
  SyncAggregate{sync_committee_bits, sync_committee_signature} = v
  T.Sequence{T.Items{Node15.to_value(sync_committee_bits), T.Items{Node9.to_value(sync_committee_signature), T.EmptyItems{}}}}
def SyncAggregateValue.assemble(a0: Maybe<&2, Node15()>, a1: Maybe<&2, Node9()>) -> Maybe<&2, SyncAggregateValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{SyncAggregate{v0, v1}}
    case _ _: None{}
def SyncAggregateValue.from_value(v: T.Value) -> Maybe<&2, SyncAggregateValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: SyncAggregateValue.assemble(Node15.from_value(v0), Node9.from_value(v1))
    case _: None{}
def SyncAggregateValue.schema() -> T.Schema: Spec.Schema15()

type SyncAggregatorSelectionData is Data:
  SyncAggregatorSelectionData{slot: Node3(), subcommittee_index: Node3()}
def SyncAggregatorSelectionDataValue() -> Data: SyncAggregatorSelectionData
def SyncAggregatorSelectionDataValue.to_value(v: SyncAggregatorSelectionDataValue()) -> T.Value:
  SyncAggregatorSelectionData{slot, subcommittee_index} = v
  T.Sequence{T.Items{Node3.to_value(slot), T.Items{Node3.to_value(subcommittee_index), T.EmptyItems{}}}}
def SyncAggregatorSelectionDataValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node3()>) -> Maybe<&2, SyncAggregatorSelectionDataValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{SyncAggregatorSelectionData{v0, v1}}
    case _ _: None{}
def SyncAggregatorSelectionDataValue.from_value(v: T.Value) -> Maybe<&2, SyncAggregatorSelectionDataValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: SyncAggregatorSelectionDataValue.assemble(Node3.from_value(v0), Node3.from_value(v1))
    case _: None{}
def SyncAggregatorSelectionDataValue.schema() -> T.Schema: Spec.Schema16()

type PowBlock is Data:
  PowBlock{block_hash: Node7(), parent_hash: Node7(), total_difficulty: Node4()}
def PowBlockValue() -> Data: PowBlock
def PowBlockValue.to_value(v: PowBlockValue()) -> T.Value:
  PowBlock{block_hash, parent_hash, total_difficulty} = v
  T.Sequence{T.Items{Node7.to_value(block_hash), T.Items{Node7.to_value(parent_hash), T.Items{Node4.to_value(total_difficulty), T.EmptyItems{}}}}}
def PowBlockValue.assemble(a0: Maybe<&2, Node7()>, a1: Maybe<&2, Node7()>, a2: Maybe<&2, Node4()>) -> Maybe<&2, PowBlockValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{PowBlock{v0, v1, v2}}
    case _ _ _: None{}
def PowBlockValue.from_value(v: T.Value) -> Maybe<&2, PowBlockValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: PowBlockValue.assemble(Node7.from_value(v0), Node7.from_value(v1), Node4.from_value(v2))
    case _: None{}
def PowBlockValue.schema() -> T.Schema: Spec.Schema17()

type PendingConsolidation is Data:
  PendingConsolidation{source_index: Node3(), target_index: Node3()}
def PendingConsolidationValue() -> Data: PendingConsolidation
def PendingConsolidationValue.to_value(v: PendingConsolidationValue()) -> T.Value:
  PendingConsolidation{source_index, target_index} = v
  T.Sequence{T.Items{Node3.to_value(source_index), T.Items{Node3.to_value(target_index), T.EmptyItems{}}}}
def PendingConsolidationValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node3()>) -> Maybe<&2, PendingConsolidationValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{PendingConsolidation{v0, v1}}
    case _ _: None{}
def PendingConsolidationValue.from_value(v: T.Value) -> Maybe<&2, PendingConsolidationValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: PendingConsolidationValue.assemble(Node3.from_value(v0), Node3.from_value(v1))
    case _: None{}
def PendingConsolidationValue.schema() -> T.Schema: Spec.Schema18()

type PendingPartialWithdrawal is Data:
  PendingPartialWithdrawal{validator_index: Node3(), amount: Node3(), withdrawable_epoch: Node3()}
def PendingPartialWithdrawalValue() -> Data: PendingPartialWithdrawal
def PendingPartialWithdrawalValue.to_value(v: PendingPartialWithdrawalValue()) -> T.Value:
  PendingPartialWithdrawal{validator_index, amount, withdrawable_epoch} = v
  T.Sequence{T.Items{Node3.to_value(validator_index), T.Items{Node3.to_value(amount), T.Items{Node3.to_value(withdrawable_epoch), T.EmptyItems{}}}}}
def PendingPartialWithdrawalValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node3()>, a2: Maybe<&2, Node3()>) -> Maybe<&2, PendingPartialWithdrawalValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{PendingPartialWithdrawal{v0, v1, v2}}
    case _ _ _: None{}
def PendingPartialWithdrawalValue.from_value(v: T.Value) -> Maybe<&2, PendingPartialWithdrawalValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: PendingPartialWithdrawalValue.assemble(Node3.from_value(v0), Node3.from_value(v1), Node3.from_value(v2))
    case _: None{}
def PendingPartialWithdrawalValue.schema() -> T.Schema: Spec.Schema19()

type VoluntaryExit is Data:
  VoluntaryExit{epoch: Node3(), validator_index: Node3()}
def VoluntaryExitValue() -> Data: VoluntaryExit
def VoluntaryExitValue.to_value(v: VoluntaryExitValue()) -> T.Value:
  VoluntaryExit{epoch, validator_index} = v
  T.Sequence{T.Items{Node3.to_value(epoch), T.Items{Node3.to_value(validator_index), T.EmptyItems{}}}}
def VoluntaryExitValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node3()>) -> Maybe<&2, VoluntaryExitValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{VoluntaryExit{v0, v1}}
    case _ _: None{}
def VoluntaryExitValue.from_value(v: T.Value) -> Maybe<&2, VoluntaryExitValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: VoluntaryExitValue.assemble(Node3.from_value(v0), Node3.from_value(v1))
    case _: None{}
def VoluntaryExitValue.schema() -> T.Schema: Spec.Schema20()

type SignedVoluntaryExit is Data:
  SignedVoluntaryExit{message: VoluntaryExitValue(), signature: Node9()}
def SignedVoluntaryExitValue() -> Data: SignedVoluntaryExit
def SignedVoluntaryExitValue.to_value(v: SignedVoluntaryExitValue()) -> T.Value:
  SignedVoluntaryExit{message, signature} = v
  T.Sequence{T.Items{VoluntaryExitValue.to_value(message), T.Items{Node9.to_value(signature), T.EmptyItems{}}}}
def SignedVoluntaryExitValue.assemble(a0: Maybe<&2, VoluntaryExitValue()>, a1: Maybe<&2, Node9()>) -> Maybe<&2, SignedVoluntaryExitValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{SignedVoluntaryExit{v0, v1}}
    case _ _: None{}
def SignedVoluntaryExitValue.from_value(v: T.Value) -> Maybe<&2, SignedVoluntaryExitValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: SignedVoluntaryExitValue.assemble(VoluntaryExitValue.from_value(v0), Node9.from_value(v1))
    case _: None{}
def SignedVoluntaryExitValue.schema() -> T.Schema: Spec.Schema21()

type HistoricalSummary is Data:
  HistoricalSummary{block_summary_root: Node7(), state_summary_root: Node7()}
def HistoricalSummaryValue() -> Data: HistoricalSummary
def HistoricalSummaryValue.to_value(v: HistoricalSummaryValue()) -> T.Value:
  HistoricalSummary{block_summary_root, state_summary_root} = v
  T.Sequence{T.Items{Node7.to_value(block_summary_root), T.Items{Node7.to_value(state_summary_root), T.EmptyItems{}}}}
def HistoricalSummaryValue.assemble(a0: Maybe<&2, Node7()>, a1: Maybe<&2, Node7()>) -> Maybe<&2, HistoricalSummaryValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{HistoricalSummary{v0, v1}}
    case _ _: None{}
def HistoricalSummaryValue.from_value(v: T.Value) -> Maybe<&2, HistoricalSummaryValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: HistoricalSummaryValue.assemble(Node7.from_value(v0), Node7.from_value(v1))
    case _: None{}
def HistoricalSummaryValue.schema() -> T.Schema: Spec.Schema22()

def Node24() -> Data: +List<Bool>
def Node24.to_value(v: Node24()) -> T.Value: T.BitsValue{v}
def Node24.from_value(value: T.Value) -> Maybe<&2, Node24()>:
  match value:
    case T.BitsValue{v}: Some{v}
    case _: None{}
def Node24.schema() -> T.Schema: Spec.Schema23()

type SyncCommitteeContribution is Data:
  SyncCommitteeContribution{slot: Node3(), beacon_block_root: Node7(), subcommittee_index: Node3(), aggregation_bits: Node24(), signature: Node9()}
def SyncCommitteeContributionValue() -> Data: SyncCommitteeContribution
def SyncCommitteeContributionValue.to_value(v: SyncCommitteeContributionValue()) -> T.Value:
  SyncCommitteeContribution{slot, beacon_block_root, subcommittee_index, aggregation_bits, signature} = v
  T.Sequence{T.Items{Node3.to_value(slot), T.Items{Node7.to_value(beacon_block_root), T.Items{Node3.to_value(subcommittee_index), T.Items{Node24.to_value(aggregation_bits), T.Items{Node9.to_value(signature), T.EmptyItems{}}}}}}}
def SyncCommitteeContributionValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node7()>, a2: Maybe<&2, Node3()>, a3: Maybe<&2, Node24()>, a4: Maybe<&2, Node9()>) -> Maybe<&2, SyncCommitteeContributionValue()>:
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: Some{SyncCommitteeContribution{v0, v1, v2, v3, v4}}
    case _ _ _ _ _: None{}
def SyncCommitteeContributionValue.from_value(v: T.Value) -> Maybe<&2, SyncCommitteeContributionValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.EmptyItems{}}}}}}}: SyncCommitteeContributionValue.assemble(Node3.from_value(v0), Node7.from_value(v1), Node3.from_value(v2), Node24.from_value(v3), Node9.from_value(v4))
    case _: None{}
def SyncCommitteeContributionValue.schema() -> T.Schema: Spec.Schema24()

type ContributionAndProof is Data:
  ContributionAndProof{aggregator_index: Node3(), contribution: SyncCommitteeContributionValue(), selection_proof: Node9()}
def ContributionAndProofValue() -> Data: ContributionAndProof
def ContributionAndProofValue.to_value(v: ContributionAndProofValue()) -> T.Value:
  ContributionAndProof{aggregator_index, contribution, selection_proof} = v
  T.Sequence{T.Items{Node3.to_value(aggregator_index), T.Items{SyncCommitteeContributionValue.to_value(contribution), T.Items{Node9.to_value(selection_proof), T.EmptyItems{}}}}}
def ContributionAndProofValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, SyncCommitteeContributionValue()>, a2: Maybe<&2, Node9()>) -> Maybe<&2, ContributionAndProofValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{ContributionAndProof{v0, v1, v2}}
    case _ _ _: None{}
def ContributionAndProofValue.from_value(v: T.Value) -> Maybe<&2, ContributionAndProofValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: ContributionAndProofValue.assemble(Node3.from_value(v0), SyncCommitteeContributionValue.from_value(v1), Node9.from_value(v2))
    case _: None{}
def ContributionAndProofValue.schema() -> T.Schema: Spec.Schema25()

type SignedContributionAndProof is Data:
  SignedContributionAndProof{message: ContributionAndProofValue(), signature: Node9()}
def SignedContributionAndProofValue() -> Data: SignedContributionAndProof
def SignedContributionAndProofValue.to_value(v: SignedContributionAndProofValue()) -> T.Value:
  SignedContributionAndProof{message, signature} = v
  T.Sequence{T.Items{ContributionAndProofValue.to_value(message), T.Items{Node9.to_value(signature), T.EmptyItems{}}}}
def SignedContributionAndProofValue.assemble(a0: Maybe<&2, ContributionAndProofValue()>, a1: Maybe<&2, Node9()>) -> Maybe<&2, SignedContributionAndProofValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{SignedContributionAndProof{v0, v1}}
    case _ _: None{}
def SignedContributionAndProofValue.from_value(v: T.Value) -> Maybe<&2, SignedContributionAndProofValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: SignedContributionAndProofValue.assemble(ContributionAndProofValue.from_value(v0), Node9.from_value(v1))
    case _: None{}
def SignedContributionAndProofValue.schema() -> T.Schema: Spec.Schema26()

type SyncCommitteeMessage is Data:
  SyncCommitteeMessage{slot: Node3(), beacon_block_root: Node7(), validator_index: Node3(), signature: Node9()}
def SyncCommitteeMessageValue() -> Data: SyncCommitteeMessage
def SyncCommitteeMessageValue.to_value(v: SyncCommitteeMessageValue()) -> T.Value:
  SyncCommitteeMessage{slot, beacon_block_root, validator_index, signature} = v
  T.Sequence{T.Items{Node3.to_value(slot), T.Items{Node7.to_value(beacon_block_root), T.Items{Node3.to_value(validator_index), T.Items{Node9.to_value(signature), T.EmptyItems{}}}}}}
def SyncCommitteeMessageValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node7()>, a2: Maybe<&2, Node3()>, a3: Maybe<&2, Node9()>) -> Maybe<&2, SyncCommitteeMessageValue()>:
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: Some{SyncCommitteeMessage{v0, v1, v2, v3}}
    case _ _ _ _: None{}
def SyncCommitteeMessageValue.from_value(v: T.Value) -> Maybe<&2, SyncCommitteeMessageValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.EmptyItems{}}}}}}: SyncCommitteeMessageValue.assemble(Node3.from_value(v0), Node7.from_value(v1), Node3.from_value(v2), Node9.from_value(v3))
    case _: None{}
def SyncCommitteeMessageValue.schema() -> T.Schema: Spec.Schema27()

type Eth1Block is Data:
  Eth1Block{timestamp: Node3(), deposit_root: Node7(), deposit_count: Node3()}
def Eth1BlockValue() -> Data: Eth1Block
def Eth1BlockValue.to_value(v: Eth1BlockValue()) -> T.Value:
  Eth1Block{timestamp, deposit_root, deposit_count} = v
  T.Sequence{T.Items{Node3.to_value(timestamp), T.Items{Node7.to_value(deposit_root), T.Items{Node3.to_value(deposit_count), T.EmptyItems{}}}}}
def Eth1BlockValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node7()>, a2: Maybe<&2, Node3()>) -> Maybe<&2, Eth1BlockValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{Eth1Block{v0, v1, v2}}
    case _ _ _: None{}
def Eth1BlockValue.from_value(v: T.Value) -> Maybe<&2, Eth1BlockValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: Eth1BlockValue.assemble(Node3.from_value(v0), Node7.from_value(v1), Node3.from_value(v2))
    case _: None{}
def Eth1BlockValue.schema() -> T.Schema: Spec.Schema28()

type BeaconBlockHeader is Data:
  BeaconBlockHeader{slot: Node3(), proposer_index: Node3(), parent_root: Node7(), state_root: Node7(), body_root: Node7()}
def BeaconBlockHeaderValue() -> Data: BeaconBlockHeader
def BeaconBlockHeaderValue.to_value(v: BeaconBlockHeaderValue()) -> T.Value:
  BeaconBlockHeader{slot, proposer_index, parent_root, state_root, body_root} = v
  T.Sequence{T.Items{Node3.to_value(slot), T.Items{Node3.to_value(proposer_index), T.Items{Node7.to_value(parent_root), T.Items{Node7.to_value(state_root), T.Items{Node7.to_value(body_root), T.EmptyItems{}}}}}}}
def BeaconBlockHeaderValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node3()>, a2: Maybe<&2, Node7()>, a3: Maybe<&2, Node7()>, a4: Maybe<&2, Node7()>) -> Maybe<&2, BeaconBlockHeaderValue()>:
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: Some{BeaconBlockHeader{v0, v1, v2, v3, v4}}
    case _ _ _ _ _: None{}
def BeaconBlockHeaderValue.from_value(v: T.Value) -> Maybe<&2, BeaconBlockHeaderValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.EmptyItems{}}}}}}}: BeaconBlockHeaderValue.assemble(Node3.from_value(v0), Node3.from_value(v1), Node7.from_value(v2), Node7.from_value(v3), Node7.from_value(v4))
    case _: None{}
def BeaconBlockHeaderValue.schema() -> T.Schema: Spec.Schema29()

type SignedBeaconBlockHeader is Data:
  SignedBeaconBlockHeader{message: BeaconBlockHeaderValue(), signature: Node9()}
def SignedBeaconBlockHeaderValue() -> Data: SignedBeaconBlockHeader
def SignedBeaconBlockHeaderValue.to_value(v: SignedBeaconBlockHeaderValue()) -> T.Value:
  SignedBeaconBlockHeader{message, signature} = v
  T.Sequence{T.Items{BeaconBlockHeaderValue.to_value(message), T.Items{Node9.to_value(signature), T.EmptyItems{}}}}
def SignedBeaconBlockHeaderValue.assemble(a0: Maybe<&2, BeaconBlockHeaderValue()>, a1: Maybe<&2, Node9()>) -> Maybe<&2, SignedBeaconBlockHeaderValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{SignedBeaconBlockHeader{v0, v1}}
    case _ _: None{}
def SignedBeaconBlockHeaderValue.from_value(v: T.Value) -> Maybe<&2, SignedBeaconBlockHeaderValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: SignedBeaconBlockHeaderValue.assemble(BeaconBlockHeaderValue.from_value(v0), Node9.from_value(v1))
    case _: None{}
def SignedBeaconBlockHeaderValue.schema() -> T.Schema: Spec.Schema30()

type ProposerSlashing is Data:
  ProposerSlashing{signed_header_1: SignedBeaconBlockHeaderValue(), signed_header_2: SignedBeaconBlockHeaderValue()}
def ProposerSlashingValue() -> Data: ProposerSlashing
def ProposerSlashingValue.to_value(v: ProposerSlashingValue()) -> T.Value:
  ProposerSlashing{signed_header_1, signed_header_2} = v
  T.Sequence{T.Items{SignedBeaconBlockHeaderValue.to_value(signed_header_1), T.Items{SignedBeaconBlockHeaderValue.to_value(signed_header_2), T.EmptyItems{}}}}
def ProposerSlashingValue.assemble(a0: Maybe<&2, SignedBeaconBlockHeaderValue()>, a1: Maybe<&2, SignedBeaconBlockHeaderValue()>) -> Maybe<&2, ProposerSlashingValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{ProposerSlashing{v0, v1}}
    case _ _: None{}
def ProposerSlashingValue.from_value(v: T.Value) -> Maybe<&2, ProposerSlashingValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: ProposerSlashingValue.assemble(SignedBeaconBlockHeaderValue.from_value(v0), SignedBeaconBlockHeaderValue.from_value(v1))
    case _: None{}
def ProposerSlashingValue.schema() -> T.Schema: Spec.Schema31()

def Node33() -> Data: +List<Node7()>
def Node33.to_value(v: Node33()) -> T.Value: T.Sequence{Node7.seq_to(v)}
def Node33.from_value(value: T.Value) -> Maybe<&2, Node33()>:
  match value:
    case T.Sequence{v}: Node7.seq_from(v)
    case _: None{}
def Node33.schema() -> T.Schema: Spec.Schema32()

type HistoricalBatch is Data:
  HistoricalBatch{block_roots: Node33(), state_roots: Node33()}
def HistoricalBatchValue() -> Data: HistoricalBatch
def HistoricalBatchValue.to_value(v: HistoricalBatchValue()) -> T.Value:
  HistoricalBatch{block_roots, state_roots} = v
  T.Sequence{T.Items{Node33.to_value(block_roots), T.Items{Node33.to_value(state_roots), T.EmptyItems{}}}}
def HistoricalBatchValue.assemble(a0: Maybe<&2, Node33()>, a1: Maybe<&2, Node33()>) -> Maybe<&2, HistoricalBatchValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{HistoricalBatch{v0, v1}}
    case _ _: None{}
def HistoricalBatchValue.from_value(v: T.Value) -> Maybe<&2, HistoricalBatchValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: HistoricalBatchValue.assemble(Node33.from_value(v0), Node33.from_value(v1))
    case _: None{}
def HistoricalBatchValue.schema() -> T.Schema: Spec.Schema33()

type Eth1Data is Data:
  Eth1Data{deposit_root: Node7(), deposit_count: Node3(), block_hash: Node7()}
def Eth1DataValue() -> Data: Eth1Data
def Eth1DataValue.to_value(v: Eth1DataValue()) -> T.Value:
  Eth1Data{deposit_root, deposit_count, block_hash} = v
  T.Sequence{T.Items{Node7.to_value(deposit_root), T.Items{Node3.to_value(deposit_count), T.Items{Node7.to_value(block_hash), T.EmptyItems{}}}}}
def Eth1DataValue.assemble(a0: Maybe<&2, Node7()>, a1: Maybe<&2, Node3()>, a2: Maybe<&2, Node7()>) -> Maybe<&2, Eth1DataValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{Eth1Data{v0, v1, v2}}
    case _ _ _: None{}
def Eth1DataValue.from_value(v: T.Value) -> Maybe<&2, Eth1DataValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: Eth1DataValue.assemble(Node7.from_value(v0), Node3.from_value(v1), Node7.from_value(v2))
    case _: None{}
def Eth1DataValue.schema() -> T.Schema: Spec.Schema34()

type Checkpoint is Data:
  Checkpoint{epoch: Node3(), root: Node7()}
def CheckpointValue() -> Data: Checkpoint
def CheckpointValue.to_value(v: CheckpointValue()) -> T.Value:
  Checkpoint{epoch, root} = v
  T.Sequence{T.Items{Node3.to_value(epoch), T.Items{Node7.to_value(root), T.EmptyItems{}}}}
def CheckpointValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node7()>) -> Maybe<&2, CheckpointValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{Checkpoint{v0, v1}}
    case _ _: None{}
def CheckpointValue.from_value(v: T.Value) -> Maybe<&2, CheckpointValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: CheckpointValue.assemble(Node3.from_value(v0), Node7.from_value(v1))
    case _: None{}
def CheckpointValue.schema() -> T.Schema: Spec.Schema35()

type AttestationData is Data:
  AttestationData{slot: Node3(), index: Node3(), beacon_block_root: Node7(), source: CheckpointValue(), target: CheckpointValue()}
def AttestationDataValue() -> Data: AttestationData
def AttestationDataValue.to_value(v: AttestationDataValue()) -> T.Value:
  AttestationData{slot, index, beacon_block_root, source, target} = v
  T.Sequence{T.Items{Node3.to_value(slot), T.Items{Node3.to_value(index), T.Items{Node7.to_value(beacon_block_root), T.Items{CheckpointValue.to_value(source), T.Items{CheckpointValue.to_value(target), T.EmptyItems{}}}}}}}
def AttestationDataValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node3()>, a2: Maybe<&2, Node7()>, a3: Maybe<&2, CheckpointValue()>, a4: Maybe<&2, CheckpointValue()>) -> Maybe<&2, AttestationDataValue()>:
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: Some{AttestationData{v0, v1, v2, v3, v4}}
    case _ _ _ _ _: None{}
def AttestationDataValue.from_value(v: T.Value) -> Maybe<&2, AttestationDataValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.EmptyItems{}}}}}}}: AttestationDataValue.assemble(Node3.from_value(v0), Node3.from_value(v1), Node7.from_value(v2), CheckpointValue.from_value(v3), CheckpointValue.from_value(v4))
    case _: None{}
def AttestationDataValue.schema() -> T.Schema: Spec.Schema36()

type SingleAttestation is Data:
  SingleAttestation{committee_index: Node3(), attester_index: Node3(), data: AttestationDataValue(), signature: Node9()}
def SingleAttestationValue() -> Data: SingleAttestation
def SingleAttestationValue.to_value(v: SingleAttestationValue()) -> T.Value:
  SingleAttestation{committee_index, attester_index, data, signature} = v
  T.Sequence{T.Items{Node3.to_value(committee_index), T.Items{Node3.to_value(attester_index), T.Items{AttestationDataValue.to_value(data), T.Items{Node9.to_value(signature), T.EmptyItems{}}}}}}
def SingleAttestationValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node3()>, a2: Maybe<&2, AttestationDataValue()>, a3: Maybe<&2, Node9()>) -> Maybe<&2, SingleAttestationValue()>:
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: Some{SingleAttestation{v0, v1, v2, v3}}
    case _ _ _ _: None{}
def SingleAttestationValue.from_value(v: T.Value) -> Maybe<&2, SingleAttestationValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.EmptyItems{}}}}}}: SingleAttestationValue.assemble(Node3.from_value(v0), Node3.from_value(v1), AttestationDataValue.from_value(v2), Node9.from_value(v3))
    case _: None{}
def SingleAttestationValue.schema() -> T.Schema: Spec.Schema37()

def Node39() -> Data: +List<Bool>
def Node39.to_value(v: Node39()) -> T.Value: T.BitsValue{v}
def Node39.from_value(value: T.Value) -> Maybe<&2, Node39()>:
  match value:
    case T.BitsValue{v}: Some{v}
    case _: None{}
def Node39.schema() -> T.Schema: Spec.Schema38()

def Node40() -> Data: +List<Bool>
def Node40.to_value(v: Node40()) -> T.Value: T.BitsValue{v}
def Node40.from_value(value: T.Value) -> Maybe<&2, Node40()>:
  match value:
    case T.BitsValue{v}: Some{v}
    case _: None{}
def Node40.schema() -> T.Schema: Spec.Schema39()

type Attestation is Data:
  Attestation{aggregation_bits: Node39(), data: AttestationDataValue(), signature: Node9(), committee_bits: Node40()}
def AttestationValue() -> Data: Attestation
def AttestationValue.to_value(v: AttestationValue()) -> T.Value:
  Attestation{aggregation_bits, data, signature, committee_bits} = v
  T.Sequence{T.Items{Node39.to_value(aggregation_bits), T.Items{AttestationDataValue.to_value(data), T.Items{Node9.to_value(signature), T.Items{Node40.to_value(committee_bits), T.EmptyItems{}}}}}}
def AttestationValue.assemble(a0: Maybe<&2, Node39()>, a1: Maybe<&2, AttestationDataValue()>, a2: Maybe<&2, Node9()>, a3: Maybe<&2, Node40()>) -> Maybe<&2, AttestationValue()>:
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: Some{Attestation{v0, v1, v2, v3}}
    case _ _ _ _: None{}
def AttestationValue.from_value(v: T.Value) -> Maybe<&2, AttestationValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.EmptyItems{}}}}}}: AttestationValue.assemble(Node39.from_value(v0), AttestationDataValue.from_value(v1), Node9.from_value(v2), Node40.from_value(v3))
    case _: None{}
def AttestationValue.schema() -> T.Schema: Spec.Schema40()

type AggregateAndProof is Data:
  AggregateAndProof{aggregator_index: Node3(), aggregate: AttestationValue(), selection_proof: Node9()}
def AggregateAndProofValue() -> Data: AggregateAndProof
def AggregateAndProofValue.to_value(v: AggregateAndProofValue()) -> T.Value:
  AggregateAndProof{aggregator_index, aggregate, selection_proof} = v
  T.Sequence{T.Items{Node3.to_value(aggregator_index), T.Items{AttestationValue.to_value(aggregate), T.Items{Node9.to_value(selection_proof), T.EmptyItems{}}}}}
def AggregateAndProofValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, AttestationValue()>, a2: Maybe<&2, Node9()>) -> Maybe<&2, AggregateAndProofValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{AggregateAndProof{v0, v1, v2}}
    case _ _ _: None{}
def AggregateAndProofValue.from_value(v: T.Value) -> Maybe<&2, AggregateAndProofValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: AggregateAndProofValue.assemble(Node3.from_value(v0), AttestationValue.from_value(v1), Node9.from_value(v2))
    case _: None{}
def AggregateAndProofValue.schema() -> T.Schema: Spec.Schema41()

type SignedAggregateAndProof is Data:
  SignedAggregateAndProof{message: AggregateAndProofValue(), signature: Node9()}
def SignedAggregateAndProofValue() -> Data: SignedAggregateAndProof
def SignedAggregateAndProofValue.to_value(v: SignedAggregateAndProofValue()) -> T.Value:
  SignedAggregateAndProof{message, signature} = v
  T.Sequence{T.Items{AggregateAndProofValue.to_value(message), T.Items{Node9.to_value(signature), T.EmptyItems{}}}}
def SignedAggregateAndProofValue.assemble(a0: Maybe<&2, AggregateAndProofValue()>, a1: Maybe<&2, Node9()>) -> Maybe<&2, SignedAggregateAndProofValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{SignedAggregateAndProof{v0, v1}}
    case _ _: None{}
def SignedAggregateAndProofValue.from_value(v: T.Value) -> Maybe<&2, SignedAggregateAndProofValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: SignedAggregateAndProofValue.assemble(AggregateAndProofValue.from_value(v0), Node9.from_value(v1))
    case _: None{}
def SignedAggregateAndProofValue.schema() -> T.Schema: Spec.Schema42()

def Node44() -> Data: +List<Bool>
def Node44.to_value(v: Node44()) -> T.Value: T.BitsValue{v}
def Node44.from_value(value: T.Value) -> Maybe<&2, Node44()>:
  match value:
    case T.BitsValue{v}: Some{v}
    case _: None{}
def Node44.schema() -> T.Schema: Spec.Schema43()

type PendingAttestation is Data:
  PendingAttestation{aggregation_bits: Node44(), data: AttestationDataValue(), inclusion_delay: Node3(), proposer_index: Node3()}
def PendingAttestationValue() -> Data: PendingAttestation
def PendingAttestationValue.to_value(v: PendingAttestationValue()) -> T.Value:
  PendingAttestation{aggregation_bits, data, inclusion_delay, proposer_index} = v
  T.Sequence{T.Items{Node44.to_value(aggregation_bits), T.Items{AttestationDataValue.to_value(data), T.Items{Node3.to_value(inclusion_delay), T.Items{Node3.to_value(proposer_index), T.EmptyItems{}}}}}}
def PendingAttestationValue.assemble(a0: Maybe<&2, Node44()>, a1: Maybe<&2, AttestationDataValue()>, a2: Maybe<&2, Node3()>, a3: Maybe<&2, Node3()>) -> Maybe<&2, PendingAttestationValue()>:
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: Some{PendingAttestation{v0, v1, v2, v3}}
    case _ _ _ _: None{}
def PendingAttestationValue.from_value(v: T.Value) -> Maybe<&2, PendingAttestationValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.EmptyItems{}}}}}}: PendingAttestationValue.assemble(Node44.from_value(v0), AttestationDataValue.from_value(v1), Node3.from_value(v2), Node3.from_value(v3))
    case _: None{}
def PendingAttestationValue.schema() -> T.Schema: Spec.Schema44()

def Node3.seq_to_go(xs: +List<Node3()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: Node3.seq_to_go(t, T.Items{Node3.to_value(h), acc})

def Node3.seq_to(xs: +List<Node3()>) -> T.Value:
  Node3.seq_to_go(List.reverse(&2, Node3(), xs), T.EmptyItems{})

def Node3.seq_step(result: Maybe<&2, Node3()>, acc: +List<Node3()>, next: +List<Node3()> -> Maybe<&2, +List<Node3()>>) -> Maybe<&2, +List<Node3()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def Node3.seq_from_go(value: T.Value, acc: +List<Node3()>) -> Maybe<&2, +List<Node3()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, Node3(), acc)}
    case T.Items{h, t}: Node3.seq_step(Node3.from_value(h), acc, next => Node3.seq_from_go(t, next))
    case _: None{}

def Node3.seq_from(value: T.Value) -> Maybe<&2, +List<Node3()>>:
  Node3.seq_from_go(value, [])

def Node46() -> Data: +List<Node3()>
def Node46.to_value(v: Node46()) -> T.Value: T.Sequence{Node3.seq_to(v)}
def Node46.from_value(value: T.Value) -> Maybe<&2, Node46()>:
  match value:
    case T.Sequence{v}: Node3.seq_from(v)
    case _: None{}
def Node46.schema() -> T.Schema: Spec.Schema45()

type IndexedAttestation is Data:
  IndexedAttestation{attesting_indices: Node46(), data: AttestationDataValue(), signature: Node9()}
def IndexedAttestationValue() -> Data: IndexedAttestation
def IndexedAttestationValue.to_value(v: IndexedAttestationValue()) -> T.Value:
  IndexedAttestation{attesting_indices, data, signature} = v
  T.Sequence{T.Items{Node46.to_value(attesting_indices), T.Items{AttestationDataValue.to_value(data), T.Items{Node9.to_value(signature), T.EmptyItems{}}}}}
def IndexedAttestationValue.assemble(a0: Maybe<&2, Node46()>, a1: Maybe<&2, AttestationDataValue()>, a2: Maybe<&2, Node9()>) -> Maybe<&2, IndexedAttestationValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{IndexedAttestation{v0, v1, v2}}
    case _ _ _: None{}
def IndexedAttestationValue.from_value(v: T.Value) -> Maybe<&2, IndexedAttestationValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: IndexedAttestationValue.assemble(Node46.from_value(v0), AttestationDataValue.from_value(v1), Node9.from_value(v2))
    case _: None{}
def IndexedAttestationValue.schema() -> T.Schema: Spec.Schema46()

type AttesterSlashing is Data:
  AttesterSlashing{attestation_1: IndexedAttestationValue(), attestation_2: IndexedAttestationValue()}
def AttesterSlashingValue() -> Data: AttesterSlashing
def AttesterSlashingValue.to_value(v: AttesterSlashingValue()) -> T.Value:
  AttesterSlashing{attestation_1, attestation_2} = v
  T.Sequence{T.Items{IndexedAttestationValue.to_value(attestation_1), T.Items{IndexedAttestationValue.to_value(attestation_2), T.EmptyItems{}}}}
def AttesterSlashingValue.assemble(a0: Maybe<&2, IndexedAttestationValue()>, a1: Maybe<&2, IndexedAttestationValue()>) -> Maybe<&2, AttesterSlashingValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{AttesterSlashing{v0, v1}}
    case _ _: None{}
def AttesterSlashingValue.from_value(v: T.Value) -> Maybe<&2, AttesterSlashingValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: AttesterSlashingValue.assemble(IndexedAttestationValue.from_value(v0), IndexedAttestationValue.from_value(v1))
    case _: None{}
def AttesterSlashingValue.schema() -> T.Schema: Spec.Schema47()

type ForkData is Data:
  ForkData{current_version: Node6(), genesis_validators_root: Node7()}
def ForkDataValue() -> Data: ForkData
def ForkDataValue.to_value(v: ForkDataValue()) -> T.Value:
  ForkData{current_version, genesis_validators_root} = v
  T.Sequence{T.Items{Node6.to_value(current_version), T.Items{Node7.to_value(genesis_validators_root), T.EmptyItems{}}}}
def ForkDataValue.assemble(a0: Maybe<&2, Node6()>, a1: Maybe<&2, Node7()>) -> Maybe<&2, ForkDataValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{ForkData{v0, v1}}
    case _ _: None{}
def ForkDataValue.from_value(v: T.Value) -> Maybe<&2, ForkDataValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: ForkDataValue.assemble(Node6.from_value(v0), Node7.from_value(v1))
    case _: None{}
def ForkDataValue.schema() -> T.Schema: Spec.Schema48()

type SigningData is Data:
  SigningData{object_root: Node7(), domain: Node7()}
def SigningDataValue() -> Data: SigningData
def SigningDataValue.to_value(v: SigningDataValue()) -> T.Value:
  SigningData{object_root, domain} = v
  T.Sequence{T.Items{Node7.to_value(object_root), T.Items{Node7.to_value(domain), T.EmptyItems{}}}}
def SigningDataValue.assemble(a0: Maybe<&2, Node7()>, a1: Maybe<&2, Node7()>) -> Maybe<&2, SigningDataValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{SigningData{v0, v1}}
    case _ _: None{}
def SigningDataValue.from_value(v: T.Value) -> Maybe<&2, SigningDataValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: SigningDataValue.assemble(Node7.from_value(v0), Node7.from_value(v1))
    case _: None{}
def SigningDataValue.schema() -> T.Schema: Spec.Schema49()

type DepositRequest is Data:
  DepositRequest{pubkey: Node8(), withdrawal_credentials: Node7(), amount: Node3(), signature: Node9(), index: Node3()}
def DepositRequestValue() -> Data: DepositRequest
def DepositRequestValue.to_value(v: DepositRequestValue()) -> T.Value:
  DepositRequest{pubkey, withdrawal_credentials, amount, signature, index} = v
  T.Sequence{T.Items{Node8.to_value(pubkey), T.Items{Node7.to_value(withdrawal_credentials), T.Items{Node3.to_value(amount), T.Items{Node9.to_value(signature), T.Items{Node3.to_value(index), T.EmptyItems{}}}}}}}
def DepositRequestValue.assemble(a0: Maybe<&2, Node8()>, a1: Maybe<&2, Node7()>, a2: Maybe<&2, Node3()>, a3: Maybe<&2, Node9()>, a4: Maybe<&2, Node3()>) -> Maybe<&2, DepositRequestValue()>:
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: Some{DepositRequest{v0, v1, v2, v3, v4}}
    case _ _ _ _ _: None{}
def DepositRequestValue.from_value(v: T.Value) -> Maybe<&2, DepositRequestValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.EmptyItems{}}}}}}}: DepositRequestValue.assemble(Node8.from_value(v0), Node7.from_value(v1), Node3.from_value(v2), Node9.from_value(v3), Node3.from_value(v4))
    case _: None{}
def DepositRequestValue.schema() -> T.Schema: Spec.Schema50()

type PendingDeposit is Data:
  PendingDeposit{pubkey: Node8(), withdrawal_credentials: Node7(), amount: Node3(), signature: Node9(), slot: Node3()}
def PendingDepositValue() -> Data: PendingDeposit
def PendingDepositValue.to_value(v: PendingDepositValue()) -> T.Value:
  PendingDeposit{pubkey, withdrawal_credentials, amount, signature, slot} = v
  T.Sequence{T.Items{Node8.to_value(pubkey), T.Items{Node7.to_value(withdrawal_credentials), T.Items{Node3.to_value(amount), T.Items{Node9.to_value(signature), T.Items{Node3.to_value(slot), T.EmptyItems{}}}}}}}
def PendingDepositValue.assemble(a0: Maybe<&2, Node8()>, a1: Maybe<&2, Node7()>, a2: Maybe<&2, Node3()>, a3: Maybe<&2, Node9()>, a4: Maybe<&2, Node3()>) -> Maybe<&2, PendingDepositValue()>:
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: Some{PendingDeposit{v0, v1, v2, v3, v4}}
    case _ _ _ _ _: None{}
def PendingDepositValue.from_value(v: T.Value) -> Maybe<&2, PendingDepositValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.EmptyItems{}}}}}}}: PendingDepositValue.assemble(Node8.from_value(v0), Node7.from_value(v1), Node3.from_value(v2), Node9.from_value(v3), Node3.from_value(v4))
    case _: None{}
def PendingDepositValue.schema() -> T.Schema: Spec.Schema51()

def Node8.seq_to_go(xs: +List<Node8()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: Node8.seq_to_go(t, T.Items{Node8.to_value(h), acc})

def Node8.seq_to(xs: +List<Node8()>) -> T.Value:
  Node8.seq_to_go(List.reverse(&2, Node8(), xs), T.EmptyItems{})

def Node8.seq_step(result: Maybe<&2, Node8()>, acc: +List<Node8()>, next: +List<Node8()> -> Maybe<&2, +List<Node8()>>) -> Maybe<&2, +List<Node8()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def Node8.seq_from_go(value: T.Value, acc: +List<Node8()>) -> Maybe<&2, +List<Node8()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, Node8(), acc)}
    case T.Items{h, t}: Node8.seq_step(Node8.from_value(h), acc, next => Node8.seq_from_go(t, next))
    case _: None{}

def Node8.seq_from(value: T.Value) -> Maybe<&2, +List<Node8()>>:
  Node8.seq_from_go(value, [])

def Node53() -> Data: +List<Node8()>
def Node53.to_value(v: Node53()) -> T.Value: T.Sequence{Node8.seq_to(v)}
def Node53.from_value(value: T.Value) -> Maybe<&2, Node53()>:
  match value:
    case T.Sequence{v}: Node8.seq_from(v)
    case _: None{}
def Node53.schema() -> T.Schema: Spec.Schema52()

type SyncCommittee is Data:
  SyncCommittee{pubkeys: Node53(), aggregate_pubkey: Node8()}
def SyncCommitteeValue() -> Data: SyncCommittee
def SyncCommitteeValue.to_value(v: SyncCommitteeValue()) -> T.Value:
  SyncCommittee{pubkeys, aggregate_pubkey} = v
  T.Sequence{T.Items{Node53.to_value(pubkeys), T.Items{Node8.to_value(aggregate_pubkey), T.EmptyItems{}}}}
def SyncCommitteeValue.assemble(a0: Maybe<&2, Node53()>, a1: Maybe<&2, Node8()>) -> Maybe<&2, SyncCommitteeValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{SyncCommittee{v0, v1}}
    case _ _: None{}
def SyncCommitteeValue.from_value(v: T.Value) -> Maybe<&2, SyncCommitteeValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: SyncCommitteeValue.assemble(Node53.from_value(v0), Node8.from_value(v1))
    case _: None{}
def SyncCommitteeValue.schema() -> T.Schema: Spec.Schema53()

type DepositData is Data:
  DepositData{pubkey: Node8(), withdrawal_credentials: Node7(), amount: Node3(), signature: Node9()}
def DepositDataValue() -> Data: DepositData
def DepositDataValue.to_value(v: DepositDataValue()) -> T.Value:
  DepositData{pubkey, withdrawal_credentials, amount, signature} = v
  T.Sequence{T.Items{Node8.to_value(pubkey), T.Items{Node7.to_value(withdrawal_credentials), T.Items{Node3.to_value(amount), T.Items{Node9.to_value(signature), T.EmptyItems{}}}}}}
def DepositDataValue.assemble(a0: Maybe<&2, Node8()>, a1: Maybe<&2, Node7()>, a2: Maybe<&2, Node3()>, a3: Maybe<&2, Node9()>) -> Maybe<&2, DepositDataValue()>:
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: Some{DepositData{v0, v1, v2, v3}}
    case _ _ _ _: None{}
def DepositDataValue.from_value(v: T.Value) -> Maybe<&2, DepositDataValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.EmptyItems{}}}}}}: DepositDataValue.assemble(Node8.from_value(v0), Node7.from_value(v1), Node3.from_value(v2), Node9.from_value(v3))
    case _: None{}
def DepositDataValue.schema() -> T.Schema: Spec.Schema54()

def Node56() -> Data: +List<Node7()>
def Node56.to_value(v: Node56()) -> T.Value: T.Sequence{Node7.seq_to(v)}
def Node56.from_value(value: T.Value) -> Maybe<&2, Node56()>:
  match value:
    case T.Sequence{v}: Node7.seq_from(v)
    case _: None{}
def Node56.schema() -> T.Schema: Spec.Schema55()

type Deposit is Data:
  Deposit{proof: Node56(), data: DepositDataValue()}
def DepositValue() -> Data: Deposit
def DepositValue.to_value(v: DepositValue()) -> T.Value:
  Deposit{proof, data} = v
  T.Sequence{T.Items{Node56.to_value(proof), T.Items{DepositDataValue.to_value(data), T.EmptyItems{}}}}
def DepositValue.assemble(a0: Maybe<&2, Node56()>, a1: Maybe<&2, DepositDataValue()>) -> Maybe<&2, DepositValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{Deposit{v0, v1}}
    case _ _: None{}
def DepositValue.from_value(v: T.Value) -> Maybe<&2, DepositValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: DepositValue.assemble(Node56.from_value(v0), DepositDataValue.from_value(v1))
    case _: None{}
def DepositValue.schema() -> T.Schema: Spec.Schema56()

type DepositMessage is Data:
  DepositMessage{pubkey: Node8(), withdrawal_credentials: Node7(), amount: Node3()}
def DepositMessageValue() -> Data: DepositMessage
def DepositMessageValue.to_value(v: DepositMessageValue()) -> T.Value:
  DepositMessage{pubkey, withdrawal_credentials, amount} = v
  T.Sequence{T.Items{Node8.to_value(pubkey), T.Items{Node7.to_value(withdrawal_credentials), T.Items{Node3.to_value(amount), T.EmptyItems{}}}}}
def DepositMessageValue.assemble(a0: Maybe<&2, Node8()>, a1: Maybe<&2, Node7()>, a2: Maybe<&2, Node3()>) -> Maybe<&2, DepositMessageValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{DepositMessage{v0, v1, v2}}
    case _ _ _: None{}
def DepositMessageValue.from_value(v: T.Value) -> Maybe<&2, DepositMessageValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: DepositMessageValue.assemble(Node8.from_value(v0), Node7.from_value(v1), Node3.from_value(v2))
    case _: None{}
def DepositMessageValue.schema() -> T.Schema: Spec.Schema57()

type Validator is Data:
  Validator{pubkey: Node8(), withdrawal_credentials: Node7(), effective_balance: Node3(), slashed: Node0(), activation_eligibility_epoch: Node3(), activation_epoch: Node3(), exit_epoch: Node3(), withdrawable_epoch: Node3()}
def ValidatorValue() -> Data: Validator
def ValidatorValue.to_value(v: ValidatorValue()) -> T.Value:
  Validator{pubkey, withdrawal_credentials, effective_balance, slashed, activation_eligibility_epoch, activation_epoch, exit_epoch, withdrawable_epoch} = v
  T.Sequence{T.Items{Node8.to_value(pubkey), T.Items{Node7.to_value(withdrawal_credentials), T.Items{Node3.to_value(effective_balance), T.Items{Node0.to_value(slashed), T.Items{Node3.to_value(activation_eligibility_epoch), T.Items{Node3.to_value(activation_epoch), T.Items{Node3.to_value(exit_epoch), T.Items{Node3.to_value(withdrawable_epoch), T.EmptyItems{}}}}}}}}}}
def ValidatorValue.assemble(a0: Maybe<&2, Node8()>, a1: Maybe<&2, Node7()>, a2: Maybe<&2, Node3()>, a3: Maybe<&2, Node0()>, a4: Maybe<&2, Node3()>, a5: Maybe<&2, Node3()>, a6: Maybe<&2, Node3()>, a7: Maybe<&2, Node3()>) -> Maybe<&2, ValidatorValue()>:
  match a0 a1 a2 a3 a4 a5 a6 a7:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7}: Some{Validator{v0, v1, v2, v3, v4, v5, v6, v7}}
    case _ _ _ _ _ _ _ _: None{}
def ValidatorValue.from_value(v: T.Value) -> Maybe<&2, ValidatorValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.Items{v5, T.Items{v6, T.Items{v7, T.EmptyItems{}}}}}}}}}}: ValidatorValue.assemble(Node8.from_value(v0), Node7.from_value(v1), Node3.from_value(v2), Node0.from_value(v3), Node3.from_value(v4), Node3.from_value(v5), Node3.from_value(v6), Node3.from_value(v7))
    case _: None{}
def ValidatorValue.schema() -> T.Schema: Spec.Schema58()

def Node59() -> Data: +List<Node7()>
def Node59.to_value(v: Node59()) -> T.Value: T.Sequence{Node7.seq_to(v)}
def Node59.from_value(value: T.Value) -> Maybe<&2, Node59()>:
  match value:
    case T.Sequence{v}: Node7.seq_from(v)
    case _: None{}
def Node59.schema() -> T.Schema: Spec.Schema59()

def Node60() -> Data: +List<U32>
def Node60.to_value(v: Node60()) -> T.Value: T.BytesValue{v}
def Node60.from_value(value: T.Value) -> Maybe<&2, Node60()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node60.schema() -> T.Schema: Spec.Schema60()

type ConsolidationRequest is Data:
  ConsolidationRequest{source_address: Node11(), source_pubkey: Node8(), target_pubkey: Node8()}
def ConsolidationRequestValue() -> Data: ConsolidationRequest
def ConsolidationRequestValue.to_value(v: ConsolidationRequestValue()) -> T.Value:
  ConsolidationRequest{source_address, source_pubkey, target_pubkey} = v
  T.Sequence{T.Items{Node11.to_value(source_address), T.Items{Node8.to_value(source_pubkey), T.Items{Node8.to_value(target_pubkey), T.EmptyItems{}}}}}
def ConsolidationRequestValue.assemble(a0: Maybe<&2, Node11()>, a1: Maybe<&2, Node8()>, a2: Maybe<&2, Node8()>) -> Maybe<&2, ConsolidationRequestValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{ConsolidationRequest{v0, v1, v2}}
    case _ _ _: None{}
def ConsolidationRequestValue.from_value(v: T.Value) -> Maybe<&2, ConsolidationRequestValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: ConsolidationRequestValue.assemble(Node11.from_value(v0), Node8.from_value(v1), Node8.from_value(v2))
    case _: None{}
def ConsolidationRequestValue.schema() -> T.Schema: Spec.Schema61()

type WithdrawalRequest is Data:
  WithdrawalRequest{source_address: Node11(), validator_pubkey: Node8(), amount: Node3()}
def WithdrawalRequestValue() -> Data: WithdrawalRequest
def WithdrawalRequestValue.to_value(v: WithdrawalRequestValue()) -> T.Value:
  WithdrawalRequest{source_address, validator_pubkey, amount} = v
  T.Sequence{T.Items{Node11.to_value(source_address), T.Items{Node8.to_value(validator_pubkey), T.Items{Node3.to_value(amount), T.EmptyItems{}}}}}
def WithdrawalRequestValue.assemble(a0: Maybe<&2, Node11()>, a1: Maybe<&2, Node8()>, a2: Maybe<&2, Node3()>) -> Maybe<&2, WithdrawalRequestValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{WithdrawalRequest{v0, v1, v2}}
    case _ _ _: None{}
def WithdrawalRequestValue.from_value(v: T.Value) -> Maybe<&2, WithdrawalRequestValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: WithdrawalRequestValue.assemble(Node11.from_value(v0), Node8.from_value(v1), Node3.from_value(v2))
    case _: None{}
def WithdrawalRequestValue.schema() -> T.Schema: Spec.Schema62()

def DepositRequestValue.seq_to_go(xs: +List<DepositRequestValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: DepositRequestValue.seq_to_go(t, T.Items{DepositRequestValue.to_value(h), acc})

def DepositRequestValue.seq_to(xs: +List<DepositRequestValue()>) -> T.Value:
  DepositRequestValue.seq_to_go(List.reverse(&2, DepositRequestValue(), xs), T.EmptyItems{})

def DepositRequestValue.seq_step(result: Maybe<&2, DepositRequestValue()>, acc: +List<DepositRequestValue()>, next: +List<DepositRequestValue()> -> Maybe<&2, +List<DepositRequestValue()>>) -> Maybe<&2, +List<DepositRequestValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def DepositRequestValue.seq_from_go(value: T.Value, acc: +List<DepositRequestValue()>) -> Maybe<&2, +List<DepositRequestValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, DepositRequestValue(), acc)}
    case T.Items{h, t}: DepositRequestValue.seq_step(DepositRequestValue.from_value(h), acc, next => DepositRequestValue.seq_from_go(t, next))
    case _: None{}

def DepositRequestValue.seq_from(value: T.Value) -> Maybe<&2, +List<DepositRequestValue()>>:
  DepositRequestValue.seq_from_go(value, [])

def Node64() -> Data: +List<DepositRequestValue()>
def Node64.to_value(v: Node64()) -> T.Value: T.Sequence{DepositRequestValue.seq_to(v)}
def Node64.from_value(value: T.Value) -> Maybe<&2, Node64()>:
  match value:
    case T.Sequence{v}: DepositRequestValue.seq_from(v)
    case _: None{}
def Node64.schema() -> T.Schema: Spec.Schema63()

def WithdrawalRequestValue.seq_to_go(xs: +List<WithdrawalRequestValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: WithdrawalRequestValue.seq_to_go(t, T.Items{WithdrawalRequestValue.to_value(h), acc})

def WithdrawalRequestValue.seq_to(xs: +List<WithdrawalRequestValue()>) -> T.Value:
  WithdrawalRequestValue.seq_to_go(List.reverse(&2, WithdrawalRequestValue(), xs), T.EmptyItems{})

def WithdrawalRequestValue.seq_step(result: Maybe<&2, WithdrawalRequestValue()>, acc: +List<WithdrawalRequestValue()>, next: +List<WithdrawalRequestValue()> -> Maybe<&2, +List<WithdrawalRequestValue()>>) -> Maybe<&2, +List<WithdrawalRequestValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def WithdrawalRequestValue.seq_from_go(value: T.Value, acc: +List<WithdrawalRequestValue()>) -> Maybe<&2, +List<WithdrawalRequestValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, WithdrawalRequestValue(), acc)}
    case T.Items{h, t}: WithdrawalRequestValue.seq_step(WithdrawalRequestValue.from_value(h), acc, next => WithdrawalRequestValue.seq_from_go(t, next))
    case _: None{}

def WithdrawalRequestValue.seq_from(value: T.Value) -> Maybe<&2, +List<WithdrawalRequestValue()>>:
  WithdrawalRequestValue.seq_from_go(value, [])

def Node65() -> Data: +List<WithdrawalRequestValue()>
def Node65.to_value(v: Node65()) -> T.Value: T.Sequence{WithdrawalRequestValue.seq_to(v)}
def Node65.from_value(value: T.Value) -> Maybe<&2, Node65()>:
  match value:
    case T.Sequence{v}: WithdrawalRequestValue.seq_from(v)
    case _: None{}
def Node65.schema() -> T.Schema: Spec.Schema64()

def ConsolidationRequestValue.seq_to_go(xs: +List<ConsolidationRequestValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: ConsolidationRequestValue.seq_to_go(t, T.Items{ConsolidationRequestValue.to_value(h), acc})

def ConsolidationRequestValue.seq_to(xs: +List<ConsolidationRequestValue()>) -> T.Value:
  ConsolidationRequestValue.seq_to_go(List.reverse(&2, ConsolidationRequestValue(), xs), T.EmptyItems{})

def ConsolidationRequestValue.seq_step(result: Maybe<&2, ConsolidationRequestValue()>, acc: +List<ConsolidationRequestValue()>, next: +List<ConsolidationRequestValue()> -> Maybe<&2, +List<ConsolidationRequestValue()>>) -> Maybe<&2, +List<ConsolidationRequestValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def ConsolidationRequestValue.seq_from_go(value: T.Value, acc: +List<ConsolidationRequestValue()>) -> Maybe<&2, +List<ConsolidationRequestValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, ConsolidationRequestValue(), acc)}
    case T.Items{h, t}: ConsolidationRequestValue.seq_step(ConsolidationRequestValue.from_value(h), acc, next => ConsolidationRequestValue.seq_from_go(t, next))
    case _: None{}

def ConsolidationRequestValue.seq_from(value: T.Value) -> Maybe<&2, +List<ConsolidationRequestValue()>>:
  ConsolidationRequestValue.seq_from_go(value, [])

def Node66() -> Data: +List<ConsolidationRequestValue()>
def Node66.to_value(v: Node66()) -> T.Value: T.Sequence{ConsolidationRequestValue.seq_to(v)}
def Node66.from_value(value: T.Value) -> Maybe<&2, Node66()>:
  match value:
    case T.Sequence{v}: ConsolidationRequestValue.seq_from(v)
    case _: None{}
def Node66.schema() -> T.Schema: Spec.Schema65()

type ExecutionRequests is Data:
  ExecutionRequests{deposits: Node64(), withdrawals: Node65(), consolidations: Node66()}
def ExecutionRequestsValue() -> Data: ExecutionRequests
def ExecutionRequestsValue.to_value(v: ExecutionRequestsValue()) -> T.Value:
  ExecutionRequests{deposits, withdrawals, consolidations} = v
  T.Sequence{T.Items{Node64.to_value(deposits), T.Items{Node65.to_value(withdrawals), T.Items{Node66.to_value(consolidations), T.EmptyItems{}}}}}
def ExecutionRequestsValue.assemble(a0: Maybe<&2, Node64()>, a1: Maybe<&2, Node65()>, a2: Maybe<&2, Node66()>) -> Maybe<&2, ExecutionRequestsValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{ExecutionRequests{v0, v1, v2}}
    case _ _ _: None{}
def ExecutionRequestsValue.from_value(v: T.Value) -> Maybe<&2, ExecutionRequestsValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: ExecutionRequestsValue.assemble(Node64.from_value(v0), Node65.from_value(v1), Node66.from_value(v2))
    case _: None{}
def ExecutionRequestsValue.schema() -> T.Schema: Spec.Schema66()

type BLSToExecutionChange is Data:
  BLSToExecutionChange{validator_index: Node3(), from_bls_pubkey: Node8(), to_execution_address: Node11()}
def BLSToExecutionChangeValue() -> Data: BLSToExecutionChange
def BLSToExecutionChangeValue.to_value(v: BLSToExecutionChangeValue()) -> T.Value:
  BLSToExecutionChange{validator_index, from_bls_pubkey, to_execution_address} = v
  T.Sequence{T.Items{Node3.to_value(validator_index), T.Items{Node8.to_value(from_bls_pubkey), T.Items{Node11.to_value(to_execution_address), T.EmptyItems{}}}}}
def BLSToExecutionChangeValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node8()>, a2: Maybe<&2, Node11()>) -> Maybe<&2, BLSToExecutionChangeValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{BLSToExecutionChange{v0, v1, v2}}
    case _ _ _: None{}
def BLSToExecutionChangeValue.from_value(v: T.Value) -> Maybe<&2, BLSToExecutionChangeValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: BLSToExecutionChangeValue.assemble(Node3.from_value(v0), Node8.from_value(v1), Node11.from_value(v2))
    case _: None{}
def BLSToExecutionChangeValue.schema() -> T.Schema: Spec.Schema67()

type SignedBLSToExecutionChange is Data:
  SignedBLSToExecutionChange{message: BLSToExecutionChangeValue(), signature: Node9()}
def SignedBLSToExecutionChangeValue() -> Data: SignedBLSToExecutionChange
def SignedBLSToExecutionChangeValue.to_value(v: SignedBLSToExecutionChangeValue()) -> T.Value:
  SignedBLSToExecutionChange{message, signature} = v
  T.Sequence{T.Items{BLSToExecutionChangeValue.to_value(message), T.Items{Node9.to_value(signature), T.EmptyItems{}}}}
def SignedBLSToExecutionChangeValue.assemble(a0: Maybe<&2, BLSToExecutionChangeValue()>, a1: Maybe<&2, Node9()>) -> Maybe<&2, SignedBLSToExecutionChangeValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{SignedBLSToExecutionChange{v0, v1}}
    case _ _: None{}
def SignedBLSToExecutionChangeValue.from_value(v: T.Value) -> Maybe<&2, SignedBLSToExecutionChangeValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: SignedBLSToExecutionChangeValue.assemble(BLSToExecutionChangeValue.from_value(v0), Node9.from_value(v1))
    case _: None{}
def SignedBLSToExecutionChangeValue.schema() -> T.Schema: Spec.Schema68()

def Node70() -> Data: +List<U32>
def Node70.to_value(v: Node70()) -> T.Value: T.BytesValue{v}
def Node70.from_value(value: T.Value) -> Maybe<&2, Node70()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node70.schema() -> T.Schema: Spec.Schema69()

def Node71() -> Data: +List<U32>
def Node71.to_value(v: Node71()) -> T.Value: T.BytesValue{v}
def Node71.from_value(value: T.Value) -> Maybe<&2, Node71()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node71.schema() -> T.Schema: Spec.Schema70()

type ExecutionPayloadHeader is Data:
  ExecutionPayloadHeader{parent_hash: Node7(), fee_recipient: Node11(), state_root: Node7(), receipts_root: Node7(), logs_bloom: Node70(), prev_randao: Node7(), block_number: Node3(), gas_limit: Node3(), gas_used: Node3(), timestamp: Node3(), extra_data: Node71(), base_fee_per_gas: Node4(), block_hash: Node7(), transactions_root: Node7(), withdrawals_root: Node7(), blob_gas_used: Node3(), excess_blob_gas: Node3()}
def ExecutionPayloadHeaderValue() -> Data: ExecutionPayloadHeader
def ExecutionPayloadHeaderValue.to_value(v: ExecutionPayloadHeaderValue()) -> T.Value:
  ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas} = v
  T.Sequence{T.Items{Node7.to_value(parent_hash), T.Items{Node11.to_value(fee_recipient), T.Items{Node7.to_value(state_root), T.Items{Node7.to_value(receipts_root), T.Items{Node70.to_value(logs_bloom), T.Items{Node7.to_value(prev_randao), T.Items{Node3.to_value(block_number), T.Items{Node3.to_value(gas_limit), T.Items{Node3.to_value(gas_used), T.Items{Node3.to_value(timestamp), T.Items{Node71.to_value(extra_data), T.Items{Node4.to_value(base_fee_per_gas), T.Items{Node7.to_value(block_hash), T.Items{Node7.to_value(transactions_root), T.Items{Node7.to_value(withdrawals_root), T.Items{Node3.to_value(blob_gas_used), T.Items{Node3.to_value(excess_blob_gas), T.EmptyItems{}}}}}}}}}}}}}}}}}}}
def ExecutionPayloadHeaderValue.assemble(a0: Maybe<&2, Node7()>, a1: Maybe<&2, Node11()>, a2: Maybe<&2, Node7()>, a3: Maybe<&2, Node7()>, a4: Maybe<&2, Node70()>, a5: Maybe<&2, Node7()>, a6: Maybe<&2, Node3()>, a7: Maybe<&2, Node3()>, a8: Maybe<&2, Node3()>, a9: Maybe<&2, Node3()>, a10: Maybe<&2, Node71()>, a11: Maybe<&2, Node4()>, a12: Maybe<&2, Node7()>, a13: Maybe<&2, Node7()>, a14: Maybe<&2, Node7()>, a15: Maybe<&2, Node3()>, a16: Maybe<&2, Node3()>) -> Maybe<&2, ExecutionPayloadHeaderValue()>:
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16}: Some{ExecutionPayloadHeader{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}}
    case _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: None{}
def ExecutionPayloadHeaderValue.from_value(v: T.Value) -> Maybe<&2, ExecutionPayloadHeaderValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.Items{v5, T.Items{v6, T.Items{v7, T.Items{v8, T.Items{v9, T.Items{v10, T.Items{v11, T.Items{v12, T.Items{v13, T.Items{v14, T.Items{v15, T.Items{v16, T.EmptyItems{}}}}}}}}}}}}}}}}}}}: ExecutionPayloadHeaderValue.assemble(Node7.from_value(v0), Node11.from_value(v1), Node7.from_value(v2), Node7.from_value(v3), Node70.from_value(v4), Node7.from_value(v5), Node3.from_value(v6), Node3.from_value(v7), Node3.from_value(v8), Node3.from_value(v9), Node71.from_value(v10), Node4.from_value(v11), Node7.from_value(v12), Node7.from_value(v13), Node7.from_value(v14), Node3.from_value(v15), Node3.from_value(v16))
    case _: None{}
def ExecutionPayloadHeaderValue.schema() -> T.Schema: Spec.Schema71()

type Withdrawal is Data:
  Withdrawal{index: Node3(), validator_index: Node3(), address: Node11(), amount: Node3()}
def WithdrawalValue() -> Data: Withdrawal
def WithdrawalValue.to_value(v: WithdrawalValue()) -> T.Value:
  Withdrawal{index, validator_index, address, amount} = v
  T.Sequence{T.Items{Node3.to_value(index), T.Items{Node3.to_value(validator_index), T.Items{Node11.to_value(address), T.Items{Node3.to_value(amount), T.EmptyItems{}}}}}}
def WithdrawalValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node3()>, a2: Maybe<&2, Node11()>, a3: Maybe<&2, Node3()>) -> Maybe<&2, WithdrawalValue()>:
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: Some{Withdrawal{v0, v1, v2, v3}}
    case _ _ _ _: None{}
def WithdrawalValue.from_value(v: T.Value) -> Maybe<&2, WithdrawalValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.EmptyItems{}}}}}}: WithdrawalValue.assemble(Node3.from_value(v0), Node3.from_value(v1), Node11.from_value(v2), Node3.from_value(v3))
    case _: None{}
def WithdrawalValue.schema() -> T.Schema: Spec.Schema72()

def Node60.seq_to_go(xs: +List<Node60()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: Node60.seq_to_go(t, T.Items{Node60.to_value(h), acc})

def Node60.seq_to(xs: +List<Node60()>) -> T.Value:
  Node60.seq_to_go(List.reverse(&2, Node60(), xs), T.EmptyItems{})

def Node60.seq_step(result: Maybe<&2, Node60()>, acc: +List<Node60()>, next: +List<Node60()> -> Maybe<&2, +List<Node60()>>) -> Maybe<&2, +List<Node60()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def Node60.seq_from_go(value: T.Value, acc: +List<Node60()>) -> Maybe<&2, +List<Node60()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, Node60(), acc)}
    case T.Items{h, t}: Node60.seq_step(Node60.from_value(h), acc, next => Node60.seq_from_go(t, next))
    case _: None{}

def Node60.seq_from(value: T.Value) -> Maybe<&2, +List<Node60()>>:
  Node60.seq_from_go(value, [])

def Node74() -> Data: +List<Node60()>
def Node74.to_value(v: Node74()) -> T.Value: T.Sequence{Node60.seq_to(v)}
def Node74.from_value(value: T.Value) -> Maybe<&2, Node74()>:
  match value:
    case T.Sequence{v}: Node60.seq_from(v)
    case _: None{}
def Node74.schema() -> T.Schema: Spec.Schema73()

def WithdrawalValue.seq_to_go(xs: +List<WithdrawalValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: WithdrawalValue.seq_to_go(t, T.Items{WithdrawalValue.to_value(h), acc})

def WithdrawalValue.seq_to(xs: +List<WithdrawalValue()>) -> T.Value:
  WithdrawalValue.seq_to_go(List.reverse(&2, WithdrawalValue(), xs), T.EmptyItems{})

def WithdrawalValue.seq_step(result: Maybe<&2, WithdrawalValue()>, acc: +List<WithdrawalValue()>, next: +List<WithdrawalValue()> -> Maybe<&2, +List<WithdrawalValue()>>) -> Maybe<&2, +List<WithdrawalValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def WithdrawalValue.seq_from_go(value: T.Value, acc: +List<WithdrawalValue()>) -> Maybe<&2, +List<WithdrawalValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, WithdrawalValue(), acc)}
    case T.Items{h, t}: WithdrawalValue.seq_step(WithdrawalValue.from_value(h), acc, next => WithdrawalValue.seq_from_go(t, next))
    case _: None{}

def WithdrawalValue.seq_from(value: T.Value) -> Maybe<&2, +List<WithdrawalValue()>>:
  WithdrawalValue.seq_from_go(value, [])

def Node75() -> Data: +List<WithdrawalValue()>
def Node75.to_value(v: Node75()) -> T.Value: T.Sequence{WithdrawalValue.seq_to(v)}
def Node75.from_value(value: T.Value) -> Maybe<&2, Node75()>:
  match value:
    case T.Sequence{v}: WithdrawalValue.seq_from(v)
    case _: None{}
def Node75.schema() -> T.Schema: Spec.Schema74()

type ExecutionPayload is Data:
  ExecutionPayload{parent_hash: Node7(), fee_recipient: Node11(), state_root: Node7(), receipts_root: Node7(), logs_bloom: Node70(), prev_randao: Node7(), block_number: Node3(), gas_limit: Node3(), gas_used: Node3(), timestamp: Node3(), extra_data: Node71(), base_fee_per_gas: Node4(), block_hash: Node7(), transactions: Node74(), withdrawals: Node75(), blob_gas_used: Node3(), excess_blob_gas: Node3()}
def ExecutionPayloadValue() -> Data: ExecutionPayload
def ExecutionPayloadValue.to_value(v: ExecutionPayloadValue()) -> T.Value:
  ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas} = v
  T.Sequence{T.Items{Node7.to_value(parent_hash), T.Items{Node11.to_value(fee_recipient), T.Items{Node7.to_value(state_root), T.Items{Node7.to_value(receipts_root), T.Items{Node70.to_value(logs_bloom), T.Items{Node7.to_value(prev_randao), T.Items{Node3.to_value(block_number), T.Items{Node3.to_value(gas_limit), T.Items{Node3.to_value(gas_used), T.Items{Node3.to_value(timestamp), T.Items{Node71.to_value(extra_data), T.Items{Node4.to_value(base_fee_per_gas), T.Items{Node7.to_value(block_hash), T.Items{Node74.to_value(transactions), T.Items{Node75.to_value(withdrawals), T.Items{Node3.to_value(blob_gas_used), T.Items{Node3.to_value(excess_blob_gas), T.EmptyItems{}}}}}}}}}}}}}}}}}}}
def ExecutionPayloadValue.assemble(a0: Maybe<&2, Node7()>, a1: Maybe<&2, Node11()>, a2: Maybe<&2, Node7()>, a3: Maybe<&2, Node7()>, a4: Maybe<&2, Node70()>, a5: Maybe<&2, Node7()>, a6: Maybe<&2, Node3()>, a7: Maybe<&2, Node3()>, a8: Maybe<&2, Node3()>, a9: Maybe<&2, Node3()>, a10: Maybe<&2, Node71()>, a11: Maybe<&2, Node4()>, a12: Maybe<&2, Node7()>, a13: Maybe<&2, Node74()>, a14: Maybe<&2, Node75()>, a15: Maybe<&2, Node3()>, a16: Maybe<&2, Node3()>) -> Maybe<&2, ExecutionPayloadValue()>:
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16}: Some{ExecutionPayload{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16}}
    case _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: None{}
def ExecutionPayloadValue.from_value(v: T.Value) -> Maybe<&2, ExecutionPayloadValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.Items{v5, T.Items{v6, T.Items{v7, T.Items{v8, T.Items{v9, T.Items{v10, T.Items{v11, T.Items{v12, T.Items{v13, T.Items{v14, T.Items{v15, T.Items{v16, T.EmptyItems{}}}}}}}}}}}}}}}}}}}: ExecutionPayloadValue.assemble(Node7.from_value(v0), Node11.from_value(v1), Node7.from_value(v2), Node7.from_value(v3), Node70.from_value(v4), Node7.from_value(v5), Node3.from_value(v6), Node3.from_value(v7), Node3.from_value(v8), Node3.from_value(v9), Node71.from_value(v10), Node4.from_value(v11), Node7.from_value(v12), Node74.from_value(v13), Node75.from_value(v14), Node3.from_value(v15), Node3.from_value(v16))
    case _: None{}
def ExecutionPayloadValue.schema() -> T.Schema: Spec.Schema75()

def Node77() -> Data: +List<Node7()>
def Node77.to_value(v: Node77()) -> T.Value: T.Sequence{Node7.seq_to(v)}
def Node77.from_value(value: T.Value) -> Maybe<&2, Node77()>:
  match value:
    case T.Sequence{v}: Node7.seq_from(v)
    case _: None{}
def Node77.schema() -> T.Schema: Spec.Schema76()

def Eth1DataValue.seq_to_go(xs: +List<Eth1DataValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: Eth1DataValue.seq_to_go(t, T.Items{Eth1DataValue.to_value(h), acc})

def Eth1DataValue.seq_to(xs: +List<Eth1DataValue()>) -> T.Value:
  Eth1DataValue.seq_to_go(List.reverse(&2, Eth1DataValue(), xs), T.EmptyItems{})

def Eth1DataValue.seq_step(result: Maybe<&2, Eth1DataValue()>, acc: +List<Eth1DataValue()>, next: +List<Eth1DataValue()> -> Maybe<&2, +List<Eth1DataValue()>>) -> Maybe<&2, +List<Eth1DataValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def Eth1DataValue.seq_from_go(value: T.Value, acc: +List<Eth1DataValue()>) -> Maybe<&2, +List<Eth1DataValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, Eth1DataValue(), acc)}
    case T.Items{h, t}: Eth1DataValue.seq_step(Eth1DataValue.from_value(h), acc, next => Eth1DataValue.seq_from_go(t, next))
    case _: None{}

def Eth1DataValue.seq_from(value: T.Value) -> Maybe<&2, +List<Eth1DataValue()>>:
  Eth1DataValue.seq_from_go(value, [])

def Node78() -> Data: +List<Eth1DataValue()>
def Node78.to_value(v: Node78()) -> T.Value: T.Sequence{Eth1DataValue.seq_to(v)}
def Node78.from_value(value: T.Value) -> Maybe<&2, Node78()>:
  match value:
    case T.Sequence{v}: Eth1DataValue.seq_from(v)
    case _: None{}
def Node78.schema() -> T.Schema: Spec.Schema77()

def ValidatorValue.seq_to_go(xs: +List<ValidatorValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: ValidatorValue.seq_to_go(t, T.Items{ValidatorValue.to_value(h), acc})

def ValidatorValue.seq_to(xs: +List<ValidatorValue()>) -> T.Value:
  ValidatorValue.seq_to_go(List.reverse(&2, ValidatorValue(), xs), T.EmptyItems{})

def ValidatorValue.seq_step(result: Maybe<&2, ValidatorValue()>, acc: +List<ValidatorValue()>, next: +List<ValidatorValue()> -> Maybe<&2, +List<ValidatorValue()>>) -> Maybe<&2, +List<ValidatorValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def ValidatorValue.seq_from_go(value: T.Value, acc: +List<ValidatorValue()>) -> Maybe<&2, +List<ValidatorValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, ValidatorValue(), acc)}
    case T.Items{h, t}: ValidatorValue.seq_step(ValidatorValue.from_value(h), acc, next => ValidatorValue.seq_from_go(t, next))
    case _: None{}

def ValidatorValue.seq_from(value: T.Value) -> Maybe<&2, +List<ValidatorValue()>>:
  ValidatorValue.seq_from_go(value, [])

def Node79() -> Data: +List<ValidatorValue()>
def Node79.to_value(v: Node79()) -> T.Value: T.Sequence{ValidatorValue.seq_to(v)}
def Node79.from_value(value: T.Value) -> Maybe<&2, Node79()>:
  match value:
    case T.Sequence{v}: ValidatorValue.seq_from(v)
    case _: None{}
def Node79.schema() -> T.Schema: Spec.Schema78()

def Node80() -> Data: +List<Node3()>
def Node80.to_value(v: Node80()) -> T.Value: T.Sequence{Node3.seq_to(v)}
def Node80.from_value(value: T.Value) -> Maybe<&2, Node80()>:
  match value:
    case T.Sequence{v}: Node3.seq_from(v)
    case _: None{}
def Node80.schema() -> T.Schema: Spec.Schema79()

def Node81() -> Data: +List<Node7()>
def Node81.to_value(v: Node81()) -> T.Value: T.Sequence{Node7.seq_to(v)}
def Node81.from_value(value: T.Value) -> Maybe<&2, Node81()>:
  match value:
    case T.Sequence{v}: Node7.seq_from(v)
    case _: None{}
def Node81.schema() -> T.Schema: Spec.Schema80()

def Node82() -> Data: +List<Node3()>
def Node82.to_value(v: Node82()) -> T.Value: T.Sequence{Node3.seq_to(v)}
def Node82.from_value(value: T.Value) -> Maybe<&2, Node82()>:
  match value:
    case T.Sequence{v}: Node3.seq_from(v)
    case _: None{}
def Node82.schema() -> T.Schema: Spec.Schema81()

def Node1.seq_to_go(xs: +List<Node1()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: Node1.seq_to_go(t, T.Items{Node1.to_value(h), acc})

def Node1.seq_to(xs: +List<Node1()>) -> T.Value:
  Node1.seq_to_go(List.reverse(&2, Node1(), xs), T.EmptyItems{})

def Node1.seq_step(result: Maybe<&2, Node1()>, acc: +List<Node1()>, next: +List<Node1()> -> Maybe<&2, +List<Node1()>>) -> Maybe<&2, +List<Node1()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def Node1.seq_from_go(value: T.Value, acc: +List<Node1()>) -> Maybe<&2, +List<Node1()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, Node1(), acc)}
    case T.Items{h, t}: Node1.seq_step(Node1.from_value(h), acc, next => Node1.seq_from_go(t, next))
    case _: None{}

def Node1.seq_from(value: T.Value) -> Maybe<&2, +List<Node1()>>:
  Node1.seq_from_go(value, [])

def Node83() -> Data: +List<Node1()>
def Node83.to_value(v: Node83()) -> T.Value: T.Sequence{Node1.seq_to(v)}
def Node83.from_value(value: T.Value) -> Maybe<&2, Node83()>:
  match value:
    case T.Sequence{v}: Node1.seq_from(v)
    case _: None{}
def Node83.schema() -> T.Schema: Spec.Schema82()

def Node84() -> Data: +List<Bool>
def Node84.to_value(v: Node84()) -> T.Value: T.BitsValue{v}
def Node84.from_value(value: T.Value) -> Maybe<&2, Node84()>:
  match value:
    case T.BitsValue{v}: Some{v}
    case _: None{}
def Node84.schema() -> T.Schema: Spec.Schema83()

def HistoricalSummaryValue.seq_to_go(xs: +List<HistoricalSummaryValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: HistoricalSummaryValue.seq_to_go(t, T.Items{HistoricalSummaryValue.to_value(h), acc})

def HistoricalSummaryValue.seq_to(xs: +List<HistoricalSummaryValue()>) -> T.Value:
  HistoricalSummaryValue.seq_to_go(List.reverse(&2, HistoricalSummaryValue(), xs), T.EmptyItems{})

def HistoricalSummaryValue.seq_step(result: Maybe<&2, HistoricalSummaryValue()>, acc: +List<HistoricalSummaryValue()>, next: +List<HistoricalSummaryValue()> -> Maybe<&2, +List<HistoricalSummaryValue()>>) -> Maybe<&2, +List<HistoricalSummaryValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def HistoricalSummaryValue.seq_from_go(value: T.Value, acc: +List<HistoricalSummaryValue()>) -> Maybe<&2, +List<HistoricalSummaryValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, HistoricalSummaryValue(), acc)}
    case T.Items{h, t}: HistoricalSummaryValue.seq_step(HistoricalSummaryValue.from_value(h), acc, next => HistoricalSummaryValue.seq_from_go(t, next))
    case _: None{}

def HistoricalSummaryValue.seq_from(value: T.Value) -> Maybe<&2, +List<HistoricalSummaryValue()>>:
  HistoricalSummaryValue.seq_from_go(value, [])

def Node85() -> Data: +List<HistoricalSummaryValue()>
def Node85.to_value(v: Node85()) -> T.Value: T.Sequence{HistoricalSummaryValue.seq_to(v)}
def Node85.from_value(value: T.Value) -> Maybe<&2, Node85()>:
  match value:
    case T.Sequence{v}: HistoricalSummaryValue.seq_from(v)
    case _: None{}
def Node85.schema() -> T.Schema: Spec.Schema84()

def PendingDepositValue.seq_to_go(xs: +List<PendingDepositValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: PendingDepositValue.seq_to_go(t, T.Items{PendingDepositValue.to_value(h), acc})

def PendingDepositValue.seq_to(xs: +List<PendingDepositValue()>) -> T.Value:
  PendingDepositValue.seq_to_go(List.reverse(&2, PendingDepositValue(), xs), T.EmptyItems{})

def PendingDepositValue.seq_step(result: Maybe<&2, PendingDepositValue()>, acc: +List<PendingDepositValue()>, next: +List<PendingDepositValue()> -> Maybe<&2, +List<PendingDepositValue()>>) -> Maybe<&2, +List<PendingDepositValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def PendingDepositValue.seq_from_go(value: T.Value, acc: +List<PendingDepositValue()>) -> Maybe<&2, +List<PendingDepositValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, PendingDepositValue(), acc)}
    case T.Items{h, t}: PendingDepositValue.seq_step(PendingDepositValue.from_value(h), acc, next => PendingDepositValue.seq_from_go(t, next))
    case _: None{}

def PendingDepositValue.seq_from(value: T.Value) -> Maybe<&2, +List<PendingDepositValue()>>:
  PendingDepositValue.seq_from_go(value, [])

def Node86() -> Data: +List<PendingDepositValue()>
def Node86.to_value(v: Node86()) -> T.Value: T.Sequence{PendingDepositValue.seq_to(v)}
def Node86.from_value(value: T.Value) -> Maybe<&2, Node86()>:
  match value:
    case T.Sequence{v}: PendingDepositValue.seq_from(v)
    case _: None{}
def Node86.schema() -> T.Schema: Spec.Schema85()

def PendingPartialWithdrawalValue.seq_to_go(xs: +List<PendingPartialWithdrawalValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: PendingPartialWithdrawalValue.seq_to_go(t, T.Items{PendingPartialWithdrawalValue.to_value(h), acc})

def PendingPartialWithdrawalValue.seq_to(xs: +List<PendingPartialWithdrawalValue()>) -> T.Value:
  PendingPartialWithdrawalValue.seq_to_go(List.reverse(&2, PendingPartialWithdrawalValue(), xs), T.EmptyItems{})

def PendingPartialWithdrawalValue.seq_step(result: Maybe<&2, PendingPartialWithdrawalValue()>, acc: +List<PendingPartialWithdrawalValue()>, next: +List<PendingPartialWithdrawalValue()> -> Maybe<&2, +List<PendingPartialWithdrawalValue()>>) -> Maybe<&2, +List<PendingPartialWithdrawalValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def PendingPartialWithdrawalValue.seq_from_go(value: T.Value, acc: +List<PendingPartialWithdrawalValue()>) -> Maybe<&2, +List<PendingPartialWithdrawalValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, PendingPartialWithdrawalValue(), acc)}
    case T.Items{h, t}: PendingPartialWithdrawalValue.seq_step(PendingPartialWithdrawalValue.from_value(h), acc, next => PendingPartialWithdrawalValue.seq_from_go(t, next))
    case _: None{}

def PendingPartialWithdrawalValue.seq_from(value: T.Value) -> Maybe<&2, +List<PendingPartialWithdrawalValue()>>:
  PendingPartialWithdrawalValue.seq_from_go(value, [])

def Node87() -> Data: +List<PendingPartialWithdrawalValue()>
def Node87.to_value(v: Node87()) -> T.Value: T.Sequence{PendingPartialWithdrawalValue.seq_to(v)}
def Node87.from_value(value: T.Value) -> Maybe<&2, Node87()>:
  match value:
    case T.Sequence{v}: PendingPartialWithdrawalValue.seq_from(v)
    case _: None{}
def Node87.schema() -> T.Schema: Spec.Schema86()

def PendingConsolidationValue.seq_to_go(xs: +List<PendingConsolidationValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: PendingConsolidationValue.seq_to_go(t, T.Items{PendingConsolidationValue.to_value(h), acc})

def PendingConsolidationValue.seq_to(xs: +List<PendingConsolidationValue()>) -> T.Value:
  PendingConsolidationValue.seq_to_go(List.reverse(&2, PendingConsolidationValue(), xs), T.EmptyItems{})

def PendingConsolidationValue.seq_step(result: Maybe<&2, PendingConsolidationValue()>, acc: +List<PendingConsolidationValue()>, next: +List<PendingConsolidationValue()> -> Maybe<&2, +List<PendingConsolidationValue()>>) -> Maybe<&2, +List<PendingConsolidationValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def PendingConsolidationValue.seq_from_go(value: T.Value, acc: +List<PendingConsolidationValue()>) -> Maybe<&2, +List<PendingConsolidationValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, PendingConsolidationValue(), acc)}
    case T.Items{h, t}: PendingConsolidationValue.seq_step(PendingConsolidationValue.from_value(h), acc, next => PendingConsolidationValue.seq_from_go(t, next))
    case _: None{}

def PendingConsolidationValue.seq_from(value: T.Value) -> Maybe<&2, +List<PendingConsolidationValue()>>:
  PendingConsolidationValue.seq_from_go(value, [])

def Node88() -> Data: +List<PendingConsolidationValue()>
def Node88.to_value(v: Node88()) -> T.Value: T.Sequence{PendingConsolidationValue.seq_to(v)}
def Node88.from_value(value: T.Value) -> Maybe<&2, Node88()>:
  match value:
    case T.Sequence{v}: PendingConsolidationValue.seq_from(v)
    case _: None{}
def Node88.schema() -> T.Schema: Spec.Schema87()

def Node89() -> Data: +List<Node3()>
def Node89.to_value(v: Node89()) -> T.Value: T.Sequence{Node3.seq_to(v)}
def Node89.from_value(value: T.Value) -> Maybe<&2, Node89()>:
  match value:
    case T.Sequence{v}: Node3.seq_from(v)
    case _: None{}
def Node89.schema() -> T.Schema: Spec.Schema88()

type BeaconState is Data:
  BeaconState{genesis_time: Node3(), genesis_validators_root: Node7(), slot: Node3(), fork: ForkValue(), latest_block_header: BeaconBlockHeaderValue(), block_roots: Node33(), state_roots: Node33(), historical_roots: Node77(), eth1_data: Eth1DataValue(), eth1_data_votes: Node78(), eth1_deposit_index: Node3(), validators: Node79(), balances: Node80(), randao_mixes: Node81(), slashings: Node82(), previous_epoch_participation: Node83(), current_epoch_participation: Node83(), justification_bits: Node84(), previous_justified_checkpoint: CheckpointValue(), current_justified_checkpoint: CheckpointValue(), finalized_checkpoint: CheckpointValue(), inactivity_scores: Node80(), current_sync_committee: SyncCommitteeValue(), next_sync_committee: SyncCommitteeValue(), latest_execution_payload_header: ExecutionPayloadHeaderValue(), next_withdrawal_index: Node3(), next_withdrawal_validator_index: Node3(), historical_summaries: Node85(), deposit_requests_start_index: Node3(), deposit_balance_to_consume: Node3(), exit_balance_to_consume: Node3(), earliest_exit_epoch: Node3(), consolidation_balance_to_consume: Node3(), earliest_consolidation_epoch: Node3(), pending_deposits: Node86(), pending_partial_withdrawals: Node87(), pending_consolidations: Node88(), proposer_lookahead: Node89()}
def BeaconStateValue() -> Data: BeaconState
def BeaconStateValue.to_value(v: BeaconStateValue()) -> T.Value:
  BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead} = v
  T.Sequence{T.Items{Node3.to_value(genesis_time), T.Items{Node7.to_value(genesis_validators_root), T.Items{Node3.to_value(slot), T.Items{ForkValue.to_value(fork), T.Items{BeaconBlockHeaderValue.to_value(latest_block_header), T.Items{Node33.to_value(block_roots), T.Items{Node33.to_value(state_roots), T.Items{Node77.to_value(historical_roots), T.Items{Eth1DataValue.to_value(eth1_data), T.Items{Node78.to_value(eth1_data_votes), T.Items{Node3.to_value(eth1_deposit_index), T.Items{Node79.to_value(validators), T.Items{Node80.to_value(balances), T.Items{Node81.to_value(randao_mixes), T.Items{Node82.to_value(slashings), T.Items{Node83.to_value(previous_epoch_participation), T.Items{Node83.to_value(current_epoch_participation), T.Items{Node84.to_value(justification_bits), T.Items{CheckpointValue.to_value(previous_justified_checkpoint), T.Items{CheckpointValue.to_value(current_justified_checkpoint), T.Items{CheckpointValue.to_value(finalized_checkpoint), T.Items{Node80.to_value(inactivity_scores), T.Items{SyncCommitteeValue.to_value(current_sync_committee), T.Items{SyncCommitteeValue.to_value(next_sync_committee), T.Items{ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header), T.Items{Node3.to_value(next_withdrawal_index), T.Items{Node3.to_value(next_withdrawal_validator_index), T.Items{Node85.to_value(historical_summaries), T.Items{Node3.to_value(deposit_requests_start_index), T.Items{Node3.to_value(deposit_balance_to_consume), T.Items{Node3.to_value(exit_balance_to_consume), T.Items{Node3.to_value(earliest_exit_epoch), T.Items{Node3.to_value(consolidation_balance_to_consume), T.Items{Node3.to_value(earliest_consolidation_epoch), T.Items{Node86.to_value(pending_deposits), T.Items{Node87.to_value(pending_partial_withdrawals), T.Items{Node88.to_value(pending_consolidations), T.Items{Node89.to_value(proposer_lookahead), T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
def BeaconStateValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node7()>, a2: Maybe<&2, Node3()>, a3: Maybe<&2, ForkValue()>, a4: Maybe<&2, BeaconBlockHeaderValue()>, a5: Maybe<&2, Node33()>, a6: Maybe<&2, Node33()>, a7: Maybe<&2, Node77()>, a8: Maybe<&2, Eth1DataValue()>, a9: Maybe<&2, Node78()>, a10: Maybe<&2, Node3()>, a11: Maybe<&2, Node79()>, a12: Maybe<&2, Node80()>, a13: Maybe<&2, Node81()>, a14: Maybe<&2, Node82()>, a15: Maybe<&2, Node83()>, a16: Maybe<&2, Node83()>, a17: Maybe<&2, Node84()>, a18: Maybe<&2, CheckpointValue()>, a19: Maybe<&2, CheckpointValue()>, a20: Maybe<&2, CheckpointValue()>, a21: Maybe<&2, Node80()>, a22: Maybe<&2, SyncCommitteeValue()>, a23: Maybe<&2, SyncCommitteeValue()>, a24: Maybe<&2, ExecutionPayloadHeaderValue()>, a25: Maybe<&2, Node3()>, a26: Maybe<&2, Node3()>, a27: Maybe<&2, Node85()>, a28: Maybe<&2, Node3()>, a29: Maybe<&2, Node3()>, a30: Maybe<&2, Node3()>, a31: Maybe<&2, Node3()>, a32: Maybe<&2, Node3()>, a33: Maybe<&2, Node3()>, a34: Maybe<&2, Node86()>, a35: Maybe<&2, Node87()>, a36: Maybe<&2, Node88()>, a37: Maybe<&2, Node89()>) -> Maybe<&2, BeaconStateValue()>:
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 a17 a18 a19 a20 a21 a22 a23 a24 a25 a26 a27 a28 a29 a30 a31 a32 a33 a34 a35 a36 a37:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12} Some{v13} Some{v14} Some{v15} Some{v16} Some{v17} Some{v18} Some{v19} Some{v20} Some{v21} Some{v22} Some{v23} Some{v24} Some{v25} Some{v26} Some{v27} Some{v28} Some{v29} Some{v30} Some{v31} Some{v32} Some{v33} Some{v34} Some{v35} Some{v36} Some{v37}: Some{BeaconState{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37}}
    case _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _: None{}
def BeaconStateValue.from_value(v: T.Value) -> Maybe<&2, BeaconStateValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.Items{v5, T.Items{v6, T.Items{v7, T.Items{v8, T.Items{v9, T.Items{v10, T.Items{v11, T.Items{v12, T.Items{v13, T.Items{v14, T.Items{v15, T.Items{v16, T.Items{v17, T.Items{v18, T.Items{v19, T.Items{v20, T.Items{v21, T.Items{v22, T.Items{v23, T.Items{v24, T.Items{v25, T.Items{v26, T.Items{v27, T.Items{v28, T.Items{v29, T.Items{v30, T.Items{v31, T.Items{v32, T.Items{v33, T.Items{v34, T.Items{v35, T.Items{v36, T.Items{v37, T.EmptyItems{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}: BeaconStateValue.assemble(Node3.from_value(v0), Node7.from_value(v1), Node3.from_value(v2), ForkValue.from_value(v3), BeaconBlockHeaderValue.from_value(v4), Node33.from_value(v5), Node33.from_value(v6), Node77.from_value(v7), Eth1DataValue.from_value(v8), Node78.from_value(v9), Node3.from_value(v10), Node79.from_value(v11), Node80.from_value(v12), Node81.from_value(v13), Node82.from_value(v14), Node83.from_value(v15), Node83.from_value(v16), Node84.from_value(v17), CheckpointValue.from_value(v18), CheckpointValue.from_value(v19), CheckpointValue.from_value(v20), Node80.from_value(v21), SyncCommitteeValue.from_value(v22), SyncCommitteeValue.from_value(v23), ExecutionPayloadHeaderValue.from_value(v24), Node3.from_value(v25), Node3.from_value(v26), Node85.from_value(v27), Node3.from_value(v28), Node3.from_value(v29), Node3.from_value(v30), Node3.from_value(v31), Node3.from_value(v32), Node3.from_value(v33), Node86.from_value(v34), Node87.from_value(v35), Node88.from_value(v36), Node89.from_value(v37))
    case _: None{}
def BeaconStateValue.schema() -> T.Schema: Spec.Schema89()

def Node90() -> Data: +List<Node7()>
def Node90.to_value(v: Node90()) -> T.Value: T.Sequence{Node7.seq_to(v)}
def Node90.from_value(value: T.Value) -> Maybe<&2, Node90()>:
  match value:
    case T.Sequence{v}: Node7.seq_from(v)
    case _: None{}
def Node90.schema() -> T.Schema: Spec.Schema90()

type LightClientHeader is Data:
  LightClientHeader{beacon: BeaconBlockHeaderValue(), execution: ExecutionPayloadHeaderValue(), execution_branch: Node90()}
def LightClientHeaderValue() -> Data: LightClientHeader
def LightClientHeaderValue.to_value(v: LightClientHeaderValue()) -> T.Value:
  LightClientHeader{beacon, execution, execution_branch} = v
  T.Sequence{T.Items{BeaconBlockHeaderValue.to_value(beacon), T.Items{ExecutionPayloadHeaderValue.to_value(execution), T.Items{Node90.to_value(execution_branch), T.EmptyItems{}}}}}
def LightClientHeaderValue.assemble(a0: Maybe<&2, BeaconBlockHeaderValue()>, a1: Maybe<&2, ExecutionPayloadHeaderValue()>, a2: Maybe<&2, Node90()>) -> Maybe<&2, LightClientHeaderValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{LightClientHeader{v0, v1, v2}}
    case _ _ _: None{}
def LightClientHeaderValue.from_value(v: T.Value) -> Maybe<&2, LightClientHeaderValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: LightClientHeaderValue.assemble(BeaconBlockHeaderValue.from_value(v0), ExecutionPayloadHeaderValue.from_value(v1), Node90.from_value(v2))
    case _: None{}
def LightClientHeaderValue.schema() -> T.Schema: Spec.Schema91()

type LightClientOptimisticUpdate is Data:
  LightClientOptimisticUpdate{attested_header: LightClientHeaderValue(), sync_aggregate: SyncAggregateValue(), signature_slot: Node3()}
def LightClientOptimisticUpdateValue() -> Data: LightClientOptimisticUpdate
def LightClientOptimisticUpdateValue.to_value(v: LightClientOptimisticUpdateValue()) -> T.Value:
  LightClientOptimisticUpdate{attested_header, sync_aggregate, signature_slot} = v
  T.Sequence{T.Items{LightClientHeaderValue.to_value(attested_header), T.Items{SyncAggregateValue.to_value(sync_aggregate), T.Items{Node3.to_value(signature_slot), T.EmptyItems{}}}}}
def LightClientOptimisticUpdateValue.assemble(a0: Maybe<&2, LightClientHeaderValue()>, a1: Maybe<&2, SyncAggregateValue()>, a2: Maybe<&2, Node3()>) -> Maybe<&2, LightClientOptimisticUpdateValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{LightClientOptimisticUpdate{v0, v1, v2}}
    case _ _ _: None{}
def LightClientOptimisticUpdateValue.from_value(v: T.Value) -> Maybe<&2, LightClientOptimisticUpdateValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: LightClientOptimisticUpdateValue.assemble(LightClientHeaderValue.from_value(v0), SyncAggregateValue.from_value(v1), Node3.from_value(v2))
    case _: None{}
def LightClientOptimisticUpdateValue.schema() -> T.Schema: Spec.Schema92()

type LightClientFinalityUpdate is Data:
  LightClientFinalityUpdate{attested_header: LightClientHeaderValue(), finalized_header: LightClientHeaderValue(), finality_branch: Node12(), sync_aggregate: SyncAggregateValue(), signature_slot: Node3()}
def LightClientFinalityUpdateValue() -> Data: LightClientFinalityUpdate
def LightClientFinalityUpdateValue.to_value(v: LightClientFinalityUpdateValue()) -> T.Value:
  LightClientFinalityUpdate{attested_header, finalized_header, finality_branch, sync_aggregate, signature_slot} = v
  T.Sequence{T.Items{LightClientHeaderValue.to_value(attested_header), T.Items{LightClientHeaderValue.to_value(finalized_header), T.Items{Node12.to_value(finality_branch), T.Items{SyncAggregateValue.to_value(sync_aggregate), T.Items{Node3.to_value(signature_slot), T.EmptyItems{}}}}}}}
def LightClientFinalityUpdateValue.assemble(a0: Maybe<&2, LightClientHeaderValue()>, a1: Maybe<&2, LightClientHeaderValue()>, a2: Maybe<&2, Node12()>, a3: Maybe<&2, SyncAggregateValue()>, a4: Maybe<&2, Node3()>) -> Maybe<&2, LightClientFinalityUpdateValue()>:
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: Some{LightClientFinalityUpdate{v0, v1, v2, v3, v4}}
    case _ _ _ _ _: None{}
def LightClientFinalityUpdateValue.from_value(v: T.Value) -> Maybe<&2, LightClientFinalityUpdateValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.EmptyItems{}}}}}}}: LightClientFinalityUpdateValue.assemble(LightClientHeaderValue.from_value(v0), LightClientHeaderValue.from_value(v1), Node12.from_value(v2), SyncAggregateValue.from_value(v3), Node3.from_value(v4))
    case _: None{}
def LightClientFinalityUpdateValue.schema() -> T.Schema: Spec.Schema93()

type LightClientUpdate is Data:
  LightClientUpdate{attested_header: LightClientHeaderValue(), next_sync_committee: SyncCommitteeValue(), next_sync_committee_branch: Node59(), finalized_header: LightClientHeaderValue(), finality_branch: Node12(), sync_aggregate: SyncAggregateValue(), signature_slot: Node3()}
def LightClientUpdateValue() -> Data: LightClientUpdate
def LightClientUpdateValue.to_value(v: LightClientUpdateValue()) -> T.Value:
  LightClientUpdate{attested_header, next_sync_committee, next_sync_committee_branch, finalized_header, finality_branch, sync_aggregate, signature_slot} = v
  T.Sequence{T.Items{LightClientHeaderValue.to_value(attested_header), T.Items{SyncCommitteeValue.to_value(next_sync_committee), T.Items{Node59.to_value(next_sync_committee_branch), T.Items{LightClientHeaderValue.to_value(finalized_header), T.Items{Node12.to_value(finality_branch), T.Items{SyncAggregateValue.to_value(sync_aggregate), T.Items{Node3.to_value(signature_slot), T.EmptyItems{}}}}}}}}}
def LightClientUpdateValue.assemble(a0: Maybe<&2, LightClientHeaderValue()>, a1: Maybe<&2, SyncCommitteeValue()>, a2: Maybe<&2, Node59()>, a3: Maybe<&2, LightClientHeaderValue()>, a4: Maybe<&2, Node12()>, a5: Maybe<&2, SyncAggregateValue()>, a6: Maybe<&2, Node3()>) -> Maybe<&2, LightClientUpdateValue()>:
  match a0 a1 a2 a3 a4 a5 a6:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6}: Some{LightClientUpdate{v0, v1, v2, v3, v4, v5, v6}}
    case _ _ _ _ _ _ _: None{}
def LightClientUpdateValue.from_value(v: T.Value) -> Maybe<&2, LightClientUpdateValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.Items{v5, T.Items{v6, T.EmptyItems{}}}}}}}}}: LightClientUpdateValue.assemble(LightClientHeaderValue.from_value(v0), SyncCommitteeValue.from_value(v1), Node59.from_value(v2), LightClientHeaderValue.from_value(v3), Node12.from_value(v4), SyncAggregateValue.from_value(v5), Node3.from_value(v6))
    case _: None{}
def LightClientUpdateValue.schema() -> T.Schema: Spec.Schema94()

type LightClientBootstrap is Data:
  LightClientBootstrap{header: LightClientHeaderValue(), current_sync_committee: SyncCommitteeValue(), current_sync_committee_branch: Node59()}
def LightClientBootstrapValue() -> Data: LightClientBootstrap
def LightClientBootstrapValue.to_value(v: LightClientBootstrapValue()) -> T.Value:
  LightClientBootstrap{header, current_sync_committee, current_sync_committee_branch} = v
  T.Sequence{T.Items{LightClientHeaderValue.to_value(header), T.Items{SyncCommitteeValue.to_value(current_sync_committee), T.Items{Node59.to_value(current_sync_committee_branch), T.EmptyItems{}}}}}
def LightClientBootstrapValue.assemble(a0: Maybe<&2, LightClientHeaderValue()>, a1: Maybe<&2, SyncCommitteeValue()>, a2: Maybe<&2, Node59()>) -> Maybe<&2, LightClientBootstrapValue()>:
  match a0 a1 a2:
    case Some{v0} Some{v1} Some{v2}: Some{LightClientBootstrap{v0, v1, v2}}
    case _ _ _: None{}
def LightClientBootstrapValue.from_value(v: T.Value) -> Maybe<&2, LightClientBootstrapValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.EmptyItems{}}}}}: LightClientBootstrapValue.assemble(LightClientHeaderValue.from_value(v0), SyncCommitteeValue.from_value(v1), Node59.from_value(v2))
    case _: None{}
def LightClientBootstrapValue.schema() -> T.Schema: Spec.Schema95()

type BlobIdentifier is Data:
  BlobIdentifier{block_root: Node7(), index: Node3()}
def BlobIdentifierValue() -> Data: BlobIdentifier
def BlobIdentifierValue.to_value(v: BlobIdentifierValue()) -> T.Value:
  BlobIdentifier{block_root, index} = v
  T.Sequence{T.Items{Node7.to_value(block_root), T.Items{Node3.to_value(index), T.EmptyItems{}}}}
def BlobIdentifierValue.assemble(a0: Maybe<&2, Node7()>, a1: Maybe<&2, Node3()>) -> Maybe<&2, BlobIdentifierValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{BlobIdentifier{v0, v1}}
    case _ _: None{}
def BlobIdentifierValue.from_value(v: T.Value) -> Maybe<&2, BlobIdentifierValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: BlobIdentifierValue.assemble(Node7.from_value(v0), Node3.from_value(v1))
    case _: None{}
def BlobIdentifierValue.schema() -> T.Schema: Spec.Schema96()

def ProposerSlashingValue.seq_to_go(xs: +List<ProposerSlashingValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: ProposerSlashingValue.seq_to_go(t, T.Items{ProposerSlashingValue.to_value(h), acc})

def ProposerSlashingValue.seq_to(xs: +List<ProposerSlashingValue()>) -> T.Value:
  ProposerSlashingValue.seq_to_go(List.reverse(&2, ProposerSlashingValue(), xs), T.EmptyItems{})

def ProposerSlashingValue.seq_step(result: Maybe<&2, ProposerSlashingValue()>, acc: +List<ProposerSlashingValue()>, next: +List<ProposerSlashingValue()> -> Maybe<&2, +List<ProposerSlashingValue()>>) -> Maybe<&2, +List<ProposerSlashingValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def ProposerSlashingValue.seq_from_go(value: T.Value, acc: +List<ProposerSlashingValue()>) -> Maybe<&2, +List<ProposerSlashingValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, ProposerSlashingValue(), acc)}
    case T.Items{h, t}: ProposerSlashingValue.seq_step(ProposerSlashingValue.from_value(h), acc, next => ProposerSlashingValue.seq_from_go(t, next))
    case _: None{}

def ProposerSlashingValue.seq_from(value: T.Value) -> Maybe<&2, +List<ProposerSlashingValue()>>:
  ProposerSlashingValue.seq_from_go(value, [])

def Node98() -> Data: +List<ProposerSlashingValue()>
def Node98.to_value(v: Node98()) -> T.Value: T.Sequence{ProposerSlashingValue.seq_to(v)}
def Node98.from_value(value: T.Value) -> Maybe<&2, Node98()>:
  match value:
    case T.Sequence{v}: ProposerSlashingValue.seq_from(v)
    case _: None{}
def Node98.schema() -> T.Schema: Spec.Schema97()

def AttesterSlashingValue.seq_to_go(xs: +List<AttesterSlashingValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: AttesterSlashingValue.seq_to_go(t, T.Items{AttesterSlashingValue.to_value(h), acc})

def AttesterSlashingValue.seq_to(xs: +List<AttesterSlashingValue()>) -> T.Value:
  AttesterSlashingValue.seq_to_go(List.reverse(&2, AttesterSlashingValue(), xs), T.EmptyItems{})

def AttesterSlashingValue.seq_step(result: Maybe<&2, AttesterSlashingValue()>, acc: +List<AttesterSlashingValue()>, next: +List<AttesterSlashingValue()> -> Maybe<&2, +List<AttesterSlashingValue()>>) -> Maybe<&2, +List<AttesterSlashingValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def AttesterSlashingValue.seq_from_go(value: T.Value, acc: +List<AttesterSlashingValue()>) -> Maybe<&2, +List<AttesterSlashingValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, AttesterSlashingValue(), acc)}
    case T.Items{h, t}: AttesterSlashingValue.seq_step(AttesterSlashingValue.from_value(h), acc, next => AttesterSlashingValue.seq_from_go(t, next))
    case _: None{}

def AttesterSlashingValue.seq_from(value: T.Value) -> Maybe<&2, +List<AttesterSlashingValue()>>:
  AttesterSlashingValue.seq_from_go(value, [])

def Node99() -> Data: +List<AttesterSlashingValue()>
def Node99.to_value(v: Node99()) -> T.Value: T.Sequence{AttesterSlashingValue.seq_to(v)}
def Node99.from_value(value: T.Value) -> Maybe<&2, Node99()>:
  match value:
    case T.Sequence{v}: AttesterSlashingValue.seq_from(v)
    case _: None{}
def Node99.schema() -> T.Schema: Spec.Schema98()

def AttestationValue.seq_to_go(xs: +List<AttestationValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: AttestationValue.seq_to_go(t, T.Items{AttestationValue.to_value(h), acc})

def AttestationValue.seq_to(xs: +List<AttestationValue()>) -> T.Value:
  AttestationValue.seq_to_go(List.reverse(&2, AttestationValue(), xs), T.EmptyItems{})

def AttestationValue.seq_step(result: Maybe<&2, AttestationValue()>, acc: +List<AttestationValue()>, next: +List<AttestationValue()> -> Maybe<&2, +List<AttestationValue()>>) -> Maybe<&2, +List<AttestationValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def AttestationValue.seq_from_go(value: T.Value, acc: +List<AttestationValue()>) -> Maybe<&2, +List<AttestationValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, AttestationValue(), acc)}
    case T.Items{h, t}: AttestationValue.seq_step(AttestationValue.from_value(h), acc, next => AttestationValue.seq_from_go(t, next))
    case _: None{}

def AttestationValue.seq_from(value: T.Value) -> Maybe<&2, +List<AttestationValue()>>:
  AttestationValue.seq_from_go(value, [])

def Node100() -> Data: +List<AttestationValue()>
def Node100.to_value(v: Node100()) -> T.Value: T.Sequence{AttestationValue.seq_to(v)}
def Node100.from_value(value: T.Value) -> Maybe<&2, Node100()>:
  match value:
    case T.Sequence{v}: AttestationValue.seq_from(v)
    case _: None{}
def Node100.schema() -> T.Schema: Spec.Schema99()

def DepositValue.seq_to_go(xs: +List<DepositValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: DepositValue.seq_to_go(t, T.Items{DepositValue.to_value(h), acc})

def DepositValue.seq_to(xs: +List<DepositValue()>) -> T.Value:
  DepositValue.seq_to_go(List.reverse(&2, DepositValue(), xs), T.EmptyItems{})

def DepositValue.seq_step(result: Maybe<&2, DepositValue()>, acc: +List<DepositValue()>, next: +List<DepositValue()> -> Maybe<&2, +List<DepositValue()>>) -> Maybe<&2, +List<DepositValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def DepositValue.seq_from_go(value: T.Value, acc: +List<DepositValue()>) -> Maybe<&2, +List<DepositValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, DepositValue(), acc)}
    case T.Items{h, t}: DepositValue.seq_step(DepositValue.from_value(h), acc, next => DepositValue.seq_from_go(t, next))
    case _: None{}

def DepositValue.seq_from(value: T.Value) -> Maybe<&2, +List<DepositValue()>>:
  DepositValue.seq_from_go(value, [])

def Node101() -> Data: +List<DepositValue()>
def Node101.to_value(v: Node101()) -> T.Value: T.Sequence{DepositValue.seq_to(v)}
def Node101.from_value(value: T.Value) -> Maybe<&2, Node101()>:
  match value:
    case T.Sequence{v}: DepositValue.seq_from(v)
    case _: None{}
def Node101.schema() -> T.Schema: Spec.Schema100()

def SignedVoluntaryExitValue.seq_to_go(xs: +List<SignedVoluntaryExitValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: SignedVoluntaryExitValue.seq_to_go(t, T.Items{SignedVoluntaryExitValue.to_value(h), acc})

def SignedVoluntaryExitValue.seq_to(xs: +List<SignedVoluntaryExitValue()>) -> T.Value:
  SignedVoluntaryExitValue.seq_to_go(List.reverse(&2, SignedVoluntaryExitValue(), xs), T.EmptyItems{})

def SignedVoluntaryExitValue.seq_step(result: Maybe<&2, SignedVoluntaryExitValue()>, acc: +List<SignedVoluntaryExitValue()>, next: +List<SignedVoluntaryExitValue()> -> Maybe<&2, +List<SignedVoluntaryExitValue()>>) -> Maybe<&2, +List<SignedVoluntaryExitValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def SignedVoluntaryExitValue.seq_from_go(value: T.Value, acc: +List<SignedVoluntaryExitValue()>) -> Maybe<&2, +List<SignedVoluntaryExitValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, SignedVoluntaryExitValue(), acc)}
    case T.Items{h, t}: SignedVoluntaryExitValue.seq_step(SignedVoluntaryExitValue.from_value(h), acc, next => SignedVoluntaryExitValue.seq_from_go(t, next))
    case _: None{}

def SignedVoluntaryExitValue.seq_from(value: T.Value) -> Maybe<&2, +List<SignedVoluntaryExitValue()>>:
  SignedVoluntaryExitValue.seq_from_go(value, [])

def Node102() -> Data: +List<SignedVoluntaryExitValue()>
def Node102.to_value(v: Node102()) -> T.Value: T.Sequence{SignedVoluntaryExitValue.seq_to(v)}
def Node102.from_value(value: T.Value) -> Maybe<&2, Node102()>:
  match value:
    case T.Sequence{v}: SignedVoluntaryExitValue.seq_from(v)
    case _: None{}
def Node102.schema() -> T.Schema: Spec.Schema101()

def SignedBLSToExecutionChangeValue.seq_to_go(xs: +List<SignedBLSToExecutionChangeValue()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: SignedBLSToExecutionChangeValue.seq_to_go(t, T.Items{SignedBLSToExecutionChangeValue.to_value(h), acc})

def SignedBLSToExecutionChangeValue.seq_to(xs: +List<SignedBLSToExecutionChangeValue()>) -> T.Value:
  SignedBLSToExecutionChangeValue.seq_to_go(List.reverse(&2, SignedBLSToExecutionChangeValue(), xs), T.EmptyItems{})

def SignedBLSToExecutionChangeValue.seq_step(result: Maybe<&2, SignedBLSToExecutionChangeValue()>, acc: +List<SignedBLSToExecutionChangeValue()>, next: +List<SignedBLSToExecutionChangeValue()> -> Maybe<&2, +List<SignedBLSToExecutionChangeValue()>>) -> Maybe<&2, +List<SignedBLSToExecutionChangeValue()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def SignedBLSToExecutionChangeValue.seq_from_go(value: T.Value, acc: +List<SignedBLSToExecutionChangeValue()>) -> Maybe<&2, +List<SignedBLSToExecutionChangeValue()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, SignedBLSToExecutionChangeValue(), acc)}
    case T.Items{h, t}: SignedBLSToExecutionChangeValue.seq_step(SignedBLSToExecutionChangeValue.from_value(h), acc, next => SignedBLSToExecutionChangeValue.seq_from_go(t, next))
    case _: None{}

def SignedBLSToExecutionChangeValue.seq_from(value: T.Value) -> Maybe<&2, +List<SignedBLSToExecutionChangeValue()>>:
  SignedBLSToExecutionChangeValue.seq_from_go(value, [])

def Node103() -> Data: +List<SignedBLSToExecutionChangeValue()>
def Node103.to_value(v: Node103()) -> T.Value: T.Sequence{SignedBLSToExecutionChangeValue.seq_to(v)}
def Node103.from_value(value: T.Value) -> Maybe<&2, Node103()>:
  match value:
    case T.Sequence{v}: SignedBLSToExecutionChangeValue.seq_from(v)
    case _: None{}
def Node103.schema() -> T.Schema: Spec.Schema102()

def Node104() -> Data: +List<Node8()>
def Node104.to_value(v: Node104()) -> T.Value: T.Sequence{Node8.seq_to(v)}
def Node104.from_value(value: T.Value) -> Maybe<&2, Node104()>:
  match value:
    case T.Sequence{v}: Node8.seq_from(v)
    case _: None{}
def Node104.schema() -> T.Schema: Spec.Schema103()

type BeaconBlockBody is Data:
  BeaconBlockBody{randao_reveal: Node9(), eth1_data: Eth1DataValue(), graffiti: Node7(), proposer_slashings: Node98(), attester_slashings: Node99(), attestations: Node100(), deposits: Node101(), voluntary_exits: Node102(), sync_aggregate: SyncAggregateValue(), execution_payload: ExecutionPayloadValue(), bls_to_execution_changes: Node103(), blob_kzg_commitments: Node104(), execution_requests: ExecutionRequestsValue()}
def BeaconBlockBodyValue() -> Data: BeaconBlockBody
def BeaconBlockBodyValue.to_value(v: BeaconBlockBodyValue()) -> T.Value:
  BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests} = v
  T.Sequence{T.Items{Node9.to_value(randao_reveal), T.Items{Eth1DataValue.to_value(eth1_data), T.Items{Node7.to_value(graffiti), T.Items{Node98.to_value(proposer_slashings), T.Items{Node99.to_value(attester_slashings), T.Items{Node100.to_value(attestations), T.Items{Node101.to_value(deposits), T.Items{Node102.to_value(voluntary_exits), T.Items{SyncAggregateValue.to_value(sync_aggregate), T.Items{ExecutionPayloadValue.to_value(execution_payload), T.Items{Node103.to_value(bls_to_execution_changes), T.Items{Node104.to_value(blob_kzg_commitments), T.Items{ExecutionRequestsValue.to_value(execution_requests), T.EmptyItems{}}}}}}}}}}}}}}}
def BeaconBlockBodyValue.assemble(a0: Maybe<&2, Node9()>, a1: Maybe<&2, Eth1DataValue()>, a2: Maybe<&2, Node7()>, a3: Maybe<&2, Node98()>, a4: Maybe<&2, Node99()>, a5: Maybe<&2, Node100()>, a6: Maybe<&2, Node101()>, a7: Maybe<&2, Node102()>, a8: Maybe<&2, SyncAggregateValue()>, a9: Maybe<&2, ExecutionPayloadValue()>, a10: Maybe<&2, Node103()>, a11: Maybe<&2, Node104()>, a12: Maybe<&2, ExecutionRequestsValue()>) -> Maybe<&2, BeaconBlockBodyValue()>:
  match a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5} Some{v6} Some{v7} Some{v8} Some{v9} Some{v10} Some{v11} Some{v12}: Some{BeaconBlockBody{v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12}}
    case _ _ _ _ _ _ _ _ _ _ _ _ _: None{}
def BeaconBlockBodyValue.from_value(v: T.Value) -> Maybe<&2, BeaconBlockBodyValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.Items{v5, T.Items{v6, T.Items{v7, T.Items{v8, T.Items{v9, T.Items{v10, T.Items{v11, T.Items{v12, T.EmptyItems{}}}}}}}}}}}}}}}: BeaconBlockBodyValue.assemble(Node9.from_value(v0), Eth1DataValue.from_value(v1), Node7.from_value(v2), Node98.from_value(v3), Node99.from_value(v4), Node100.from_value(v5), Node101.from_value(v6), Node102.from_value(v7), SyncAggregateValue.from_value(v8), ExecutionPayloadValue.from_value(v9), Node103.from_value(v10), Node104.from_value(v11), ExecutionRequestsValue.from_value(v12))
    case _: None{}
def BeaconBlockBodyValue.schema() -> T.Schema: Spec.Schema104()

type BeaconBlock is Data:
  BeaconBlock{slot: Node3(), proposer_index: Node3(), parent_root: Node7(), state_root: Node7(), body: BeaconBlockBodyValue()}
def BeaconBlockValue() -> Data: BeaconBlock
def BeaconBlockValue.to_value(v: BeaconBlockValue()) -> T.Value:
  BeaconBlock{slot, proposer_index, parent_root, state_root, body} = v
  T.Sequence{T.Items{Node3.to_value(slot), T.Items{Node3.to_value(proposer_index), T.Items{Node7.to_value(parent_root), T.Items{Node7.to_value(state_root), T.Items{BeaconBlockBodyValue.to_value(body), T.EmptyItems{}}}}}}}
def BeaconBlockValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node3()>, a2: Maybe<&2, Node7()>, a3: Maybe<&2, Node7()>, a4: Maybe<&2, BeaconBlockBodyValue()>) -> Maybe<&2, BeaconBlockValue()>:
  match a0 a1 a2 a3 a4:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4}: Some{BeaconBlock{v0, v1, v2, v3, v4}}
    case _ _ _ _ _: None{}
def BeaconBlockValue.from_value(v: T.Value) -> Maybe<&2, BeaconBlockValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.EmptyItems{}}}}}}}: BeaconBlockValue.assemble(Node3.from_value(v0), Node3.from_value(v1), Node7.from_value(v2), Node7.from_value(v3), BeaconBlockBodyValue.from_value(v4))
    case _: None{}
def BeaconBlockValue.schema() -> T.Schema: Spec.Schema105()

type SignedBeaconBlock is Data:
  SignedBeaconBlock{message: BeaconBlockValue(), signature: Node9()}
def SignedBeaconBlockValue() -> Data: SignedBeaconBlock
def SignedBeaconBlockValue.to_value(v: SignedBeaconBlockValue()) -> T.Value:
  SignedBeaconBlock{message, signature} = v
  T.Sequence{T.Items{BeaconBlockValue.to_value(message), T.Items{Node9.to_value(signature), T.EmptyItems{}}}}
def SignedBeaconBlockValue.assemble(a0: Maybe<&2, BeaconBlockValue()>, a1: Maybe<&2, Node9()>) -> Maybe<&2, SignedBeaconBlockValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{SignedBeaconBlock{v0, v1}}
    case _ _: None{}
def SignedBeaconBlockValue.from_value(v: T.Value) -> Maybe<&2, SignedBeaconBlockValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: SignedBeaconBlockValue.assemble(BeaconBlockValue.from_value(v0), Node9.from_value(v1))
    case _: None{}
def SignedBeaconBlockValue.schema() -> T.Schema: Spec.Schema106()

def Node107() -> Data: +List<U32>
def Node107.to_value(v: Node107()) -> T.Value: T.BytesValue{v}
def Node107.from_value(value: T.Value) -> Maybe<&2, Node107()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node107.schema() -> T.Schema: Spec.Schema107()

def Node109() -> Data: +List<Node7()>
def Node109.to_value(v: Node109()) -> T.Value: T.Sequence{Node7.seq_to(v)}
def Node109.from_value(value: T.Value) -> Maybe<&2, Node109()>:
  match value:
    case T.Sequence{v}: Node7.seq_from(v)
    case _: None{}
def Node109.schema() -> T.Schema: Spec.Schema108()

type BlobSidecar is Data:
  BlobSidecar{index: Node3(), blob: Node107(), kzg_commitment: Node8(), kzg_proof: Node8(), signed_block_header: SignedBeaconBlockHeaderValue(), kzg_commitment_inclusion_proof: Node109()}
def BlobSidecarValue() -> Data: BlobSidecar
def BlobSidecarValue.to_value(v: BlobSidecarValue()) -> T.Value:
  BlobSidecar{index, blob, kzg_commitment, kzg_proof, signed_block_header, kzg_commitment_inclusion_proof} = v
  T.Sequence{T.Items{Node3.to_value(index), T.Items{Node107.to_value(blob), T.Items{Node8.to_value(kzg_commitment), T.Items{Node8.to_value(kzg_proof), T.Items{SignedBeaconBlockHeaderValue.to_value(signed_block_header), T.Items{Node109.to_value(kzg_commitment_inclusion_proof), T.EmptyItems{}}}}}}}}
def BlobSidecarValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node107()>, a2: Maybe<&2, Node8()>, a3: Maybe<&2, Node8()>, a4: Maybe<&2, SignedBeaconBlockHeaderValue()>, a5: Maybe<&2, Node109()>) -> Maybe<&2, BlobSidecarValue()>:
  match a0 a1 a2 a3 a4 a5:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5}: Some{BlobSidecar{v0, v1, v2, v3, v4, v5}}
    case _ _ _ _ _ _: None{}
def BlobSidecarValue.from_value(v: T.Value) -> Maybe<&2, BlobSidecarValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.Items{v5, T.EmptyItems{}}}}}}}}: BlobSidecarValue.assemble(Node3.from_value(v0), Node107.from_value(v1), Node8.from_value(v2), Node8.from_value(v3), SignedBeaconBlockHeaderValue.from_value(v4), Node109.from_value(v5))
    case _: None{}
def BlobSidecarValue.schema() -> T.Schema: Spec.Schema109()

def Node110() -> Data: +List<U32>
def Node110.to_value(v: Node110()) -> T.Value: T.BytesValue{v}
def Node110.from_value(value: T.Value) -> Maybe<&2, Node110()>:
  match value:
    case T.BytesValue{v}: Some{v}
    case _: None{}
def Node110.schema() -> T.Schema: Spec.Schema110()

def Node112() -> Data: +List<Node3()>
def Node112.to_value(v: Node112()) -> T.Value: T.Sequence{Node3.seq_to(v)}
def Node112.from_value(value: T.Value) -> Maybe<&2, Node112()>:
  match value:
    case T.Sequence{v}: Node3.seq_from(v)
    case _: None{}
def Node112.schema() -> T.Schema: Spec.Schema111()

type DataColumnsByRootIdentifier is Data:
  DataColumnsByRootIdentifier{block_root: Node7(), columns: Node112()}
def DataColumnsByRootIdentifierValue() -> Data: DataColumnsByRootIdentifier
def DataColumnsByRootIdentifierValue.to_value(v: DataColumnsByRootIdentifierValue()) -> T.Value:
  DataColumnsByRootIdentifier{block_root, columns} = v
  T.Sequence{T.Items{Node7.to_value(block_root), T.Items{Node112.to_value(columns), T.EmptyItems{}}}}
def DataColumnsByRootIdentifierValue.assemble(a0: Maybe<&2, Node7()>, a1: Maybe<&2, Node112()>) -> Maybe<&2, DataColumnsByRootIdentifierValue()>:
  match a0 a1:
    case Some{v0} Some{v1}: Some{DataColumnsByRootIdentifier{v0, v1}}
    case _ _: None{}
def DataColumnsByRootIdentifierValue.from_value(v: T.Value) -> Maybe<&2, DataColumnsByRootIdentifierValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.EmptyItems{}}}}: DataColumnsByRootIdentifierValue.assemble(Node7.from_value(v0), Node112.from_value(v1))
    case _: None{}
def DataColumnsByRootIdentifierValue.schema() -> T.Schema: Spec.Schema112()

type MatrixEntry is Data:
  MatrixEntry{cell: Node110(), kzg_proof: Node8(), column_index: Node3(), row_index: Node3()}
def MatrixEntryValue() -> Data: MatrixEntry
def MatrixEntryValue.to_value(v: MatrixEntryValue()) -> T.Value:
  MatrixEntry{cell, kzg_proof, column_index, row_index} = v
  T.Sequence{T.Items{Node110.to_value(cell), T.Items{Node8.to_value(kzg_proof), T.Items{Node3.to_value(column_index), T.Items{Node3.to_value(row_index), T.EmptyItems{}}}}}}
def MatrixEntryValue.assemble(a0: Maybe<&2, Node110()>, a1: Maybe<&2, Node8()>, a2: Maybe<&2, Node3()>, a3: Maybe<&2, Node3()>) -> Maybe<&2, MatrixEntryValue()>:
  match a0 a1 a2 a3:
    case Some{v0} Some{v1} Some{v2} Some{v3}: Some{MatrixEntry{v0, v1, v2, v3}}
    case _ _ _ _: None{}
def MatrixEntryValue.from_value(v: T.Value) -> Maybe<&2, MatrixEntryValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.EmptyItems{}}}}}}: MatrixEntryValue.assemble(Node110.from_value(v0), Node8.from_value(v1), Node3.from_value(v2), Node3.from_value(v3))
    case _: None{}
def MatrixEntryValue.schema() -> T.Schema: Spec.Schema113()

def Node110.seq_to_go(xs: +List<Node110()>, acc: T.Value) -> T.Value:
  match xs:
    case Nil{}: acc
    case Con{h, t}: Node110.seq_to_go(t, T.Items{Node110.to_value(h), acc})

def Node110.seq_to(xs: +List<Node110()>) -> T.Value:
  Node110.seq_to_go(List.reverse(&2, Node110(), xs), T.EmptyItems{})

def Node110.seq_step(result: Maybe<&2, Node110()>, acc: +List<Node110()>, next: +List<Node110()> -> Maybe<&2, +List<Node110()>>) -> Maybe<&2, +List<Node110()>>:
  match result:
    case None{}: None{}
    case Some{x}: next(x <> acc)

def Node110.seq_from_go(value: T.Value, acc: +List<Node110()>) -> Maybe<&2, +List<Node110()>>:
  match value:
    case T.EmptyItems{}: Some{List.reverse(&2, Node110(), acc)}
    case T.Items{h, t}: Node110.seq_step(Node110.from_value(h), acc, next => Node110.seq_from_go(t, next))
    case _: None{}

def Node110.seq_from(value: T.Value) -> Maybe<&2, +List<Node110()>>:
  Node110.seq_from_go(value, [])

def Node115() -> Data: +List<Node110()>
def Node115.to_value(v: Node115()) -> T.Value: T.Sequence{Node110.seq_to(v)}
def Node115.from_value(value: T.Value) -> Maybe<&2, Node115()>:
  match value:
    case T.Sequence{v}: Node110.seq_from(v)
    case _: None{}
def Node115.schema() -> T.Schema: Spec.Schema114()

type DataColumnSidecar is Data:
  DataColumnSidecar{index: Node3(), column: Node115(), kzg_commitments: Node104(), kzg_proofs: Node104(), signed_block_header: SignedBeaconBlockHeaderValue(), kzg_commitments_inclusion_proof: Node90()}
def DataColumnSidecarValue() -> Data: DataColumnSidecar
def DataColumnSidecarValue.to_value(v: DataColumnSidecarValue()) -> T.Value:
  DataColumnSidecar{index, column, kzg_commitments, kzg_proofs, signed_block_header, kzg_commitments_inclusion_proof} = v
  T.Sequence{T.Items{Node3.to_value(index), T.Items{Node115.to_value(column), T.Items{Node104.to_value(kzg_commitments), T.Items{Node104.to_value(kzg_proofs), T.Items{SignedBeaconBlockHeaderValue.to_value(signed_block_header), T.Items{Node90.to_value(kzg_commitments_inclusion_proof), T.EmptyItems{}}}}}}}}
def DataColumnSidecarValue.assemble(a0: Maybe<&2, Node3()>, a1: Maybe<&2, Node115()>, a2: Maybe<&2, Node104()>, a3: Maybe<&2, Node104()>, a4: Maybe<&2, SignedBeaconBlockHeaderValue()>, a5: Maybe<&2, Node90()>) -> Maybe<&2, DataColumnSidecarValue()>:
  match a0 a1 a2 a3 a4 a5:
    case Some{v0} Some{v1} Some{v2} Some{v3} Some{v4} Some{v5}: Some{DataColumnSidecar{v0, v1, v2, v3, v4, v5}}
    case _ _ _ _ _ _: None{}
def DataColumnSidecarValue.from_value(v: T.Value) -> Maybe<&2, DataColumnSidecarValue()>:
  match v:
    case T.Sequence{T.Items{v0, T.Items{v1, T.Items{v2, T.Items{v3, T.Items{v4, T.Items{v5, T.EmptyItems{}}}}}}}}: DataColumnSidecarValue.assemble(Node3.from_value(v0), Node115.from_value(v1), Node104.from_value(v2), Node104.from_value(v3), SignedBeaconBlockHeaderValue.from_value(v4), Node90.from_value(v5))
    case _: None{}
def DataColumnSidecarValue.schema() -> T.Schema: Spec.Schema115()

# Closed name index of the frozen mainnet Fulu inventory.
type Name is Data:
  Name_boolean{}
  Name_uint8{}
  Name_uint32{}
  Name_uint64{}
  Name_uint256{}
  Name_Bytes1{}
  Name_Bytes4{}
  Name_Bytes32{}
  Name_Bytes48{}
  Name_Bytes96{}
  Name_Bytes8{}
  Name_Bytes20{}
  Name_Slot{}
  Name_Epoch{}
  Name_Gwei{}
  Name_Hash32{}
  Name_Version{}
  Name_DomainType{}
  Name_BLSSignature{}
  Name_FinalityBranch{}
  Name_VersionedHash{}
  Name_G1Point{}
  Name_G2Point{}
  Name_Fork{}
  Name_SyncAggregate{}
  Name_SyncAggregatorSelectionData{}
  Name_PowBlock{}
  Name_CommitteeIndex{}
  Name_ValidatorIndex{}
  Name_PendingConsolidation{}
  Name_PendingPartialWithdrawal{}
  Name_VoluntaryExit{}
  Name_SignedVoluntaryExit{}
  Name_Root{}
  Name_HistoricalSummary{}
  Name_SyncCommitteeContribution{}
  Name_ContributionAndProof{}
  Name_SignedContributionAndProof{}
  Name_SyncCommitteeMessage{}
  Name_Eth1Block{}
  Name_BeaconBlockHeader{}
  Name_SignedBeaconBlockHeader{}
  Name_ProposerSlashing{}
  Name_HistoricalBatch{}
  Name_Eth1Data{}
  Name_Checkpoint{}
  Name_AttestationData{}
  Name_SingleAttestation{}
  Name_Attestation{}
  Name_AggregateAndProof{}
  Name_SignedAggregateAndProof{}
  Name_PendingAttestation{}
  Name_IndexedAttestation{}
  Name_AttesterSlashing{}
  Name_ForkData{}
  Name_ForkDigest{}
  Name_Domain{}
  Name_SigningData{}
  Name_BLSPubkey{}
  Name_DepositRequest{}
  Name_PendingDeposit{}
  Name_SyncCommittee{}
  Name_DepositData{}
  Name_Deposit{}
  Name_DepositMessage{}
  Name_Validator{}
  Name_NodeID{}
  Name_SubnetID{}
  Name_Ether{}
  Name_ParticipationFlags{}
  Name_CurrentSyncCommitteeBranch{}
  Name_NextSyncCommitteeBranch{}
  Name_Transaction{}
  Name_ExecutionAddress{}
  Name_ConsolidationRequest{}
  Name_WithdrawalRequest{}
  Name_ExecutionRequests{}
  Name_BLSToExecutionChange{}
  Name_SignedBLSToExecutionChange{}
  Name_ExecutionPayloadHeader{}
  Name_PayloadId{}
  Name_WithdrawalIndex{}
  Name_Withdrawal{}
  Name_ExecutionPayload{}
  Name_BeaconState{}
  Name_ExecutionBranch{}
  Name_LightClientHeader{}
  Name_LightClientOptimisticUpdate{}
  Name_LightClientFinalityUpdate{}
  Name_LightClientUpdate{}
  Name_LightClientBootstrap{}
  Name_BlobIndex{}
  Name_BlobIdentifier{}
  Name_KZGCommitment{}
  Name_BeaconBlockBody{}
  Name_BeaconBlock{}
  Name_SignedBeaconBlock{}
  Name_KZGProof{}
  Name_Blob{}
  Name_BlobSidecar{}
  Name_Cell{}
  Name_CellIndex{}
  Name_CommitmentIndex{}
  Name_RowIndex{}
  Name_ColumnIndex{}
  Name_DataColumnsByRootIdentifier{}
  Name_MatrixEntry{}
  Name_DataColumnSidecar{}
  Name_CustodyIndex{}

def Name.Value(name: Name) -> Data:
  match name:
    case Name_boolean{}: Node0()
    case Name_uint8{}: Node1()
    case Name_uint32{}: Node2()
    case Name_uint64{}: Node3()
    case Name_uint256{}: Node4()
    case Name_Bytes1{}: Node5()
    case Name_Bytes4{}: Node6()
    case Name_Bytes32{}: Node7()
    case Name_Bytes48{}: Node8()
    case Name_Bytes96{}: Node9()
    case Name_Bytes8{}: Node10()
    case Name_Bytes20{}: Node11()
    case Name_Slot{}: Node3()
    case Name_Epoch{}: Node3()
    case Name_Gwei{}: Node3()
    case Name_Hash32{}: Node7()
    case Name_Version{}: Node6()
    case Name_DomainType{}: Node6()
    case Name_BLSSignature{}: Node9()
    case Name_FinalityBranch{}: Node12()
    case Name_VersionedHash{}: Node7()
    case Name_G1Point{}: Node8()
    case Name_G2Point{}: Node9()
    case Name_Fork{}: Fork
    case Name_SyncAggregate{}: SyncAggregate
    case Name_SyncAggregatorSelectionData{}: SyncAggregatorSelectionData
    case Name_PowBlock{}: PowBlock
    case Name_CommitteeIndex{}: Node3()
    case Name_ValidatorIndex{}: Node3()
    case Name_PendingConsolidation{}: PendingConsolidation
    case Name_PendingPartialWithdrawal{}: PendingPartialWithdrawal
    case Name_VoluntaryExit{}: VoluntaryExit
    case Name_SignedVoluntaryExit{}: SignedVoluntaryExit
    case Name_Root{}: Node7()
    case Name_HistoricalSummary{}: HistoricalSummary
    case Name_SyncCommitteeContribution{}: SyncCommitteeContribution
    case Name_ContributionAndProof{}: ContributionAndProof
    case Name_SignedContributionAndProof{}: SignedContributionAndProof
    case Name_SyncCommitteeMessage{}: SyncCommitteeMessage
    case Name_Eth1Block{}: Eth1Block
    case Name_BeaconBlockHeader{}: BeaconBlockHeader
    case Name_SignedBeaconBlockHeader{}: SignedBeaconBlockHeader
    case Name_ProposerSlashing{}: ProposerSlashing
    case Name_HistoricalBatch{}: HistoricalBatch
    case Name_Eth1Data{}: Eth1Data
    case Name_Checkpoint{}: Checkpoint
    case Name_AttestationData{}: AttestationData
    case Name_SingleAttestation{}: SingleAttestation
    case Name_Attestation{}: Attestation
    case Name_AggregateAndProof{}: AggregateAndProof
    case Name_SignedAggregateAndProof{}: SignedAggregateAndProof
    case Name_PendingAttestation{}: PendingAttestation
    case Name_IndexedAttestation{}: IndexedAttestation
    case Name_AttesterSlashing{}: AttesterSlashing
    case Name_ForkData{}: ForkData
    case Name_ForkDigest{}: Node6()
    case Name_Domain{}: Node7()
    case Name_SigningData{}: SigningData
    case Name_BLSPubkey{}: Node8()
    case Name_DepositRequest{}: DepositRequest
    case Name_PendingDeposit{}: PendingDeposit
    case Name_SyncCommittee{}: SyncCommittee
    case Name_DepositData{}: DepositData
    case Name_Deposit{}: Deposit
    case Name_DepositMessage{}: DepositMessage
    case Name_Validator{}: Validator
    case Name_NodeID{}: Node4()
    case Name_SubnetID{}: Node3()
    case Name_Ether{}: Node3()
    case Name_ParticipationFlags{}: Node1()
    case Name_CurrentSyncCommitteeBranch{}: Node59()
    case Name_NextSyncCommitteeBranch{}: Node59()
    case Name_Transaction{}: Node60()
    case Name_ExecutionAddress{}: Node11()
    case Name_ConsolidationRequest{}: ConsolidationRequest
    case Name_WithdrawalRequest{}: WithdrawalRequest
    case Name_ExecutionRequests{}: ExecutionRequests
    case Name_BLSToExecutionChange{}: BLSToExecutionChange
    case Name_SignedBLSToExecutionChange{}: SignedBLSToExecutionChange
    case Name_ExecutionPayloadHeader{}: ExecutionPayloadHeader
    case Name_PayloadId{}: Node10()
    case Name_WithdrawalIndex{}: Node3()
    case Name_Withdrawal{}: Withdrawal
    case Name_ExecutionPayload{}: ExecutionPayload
    case Name_BeaconState{}: BeaconState
    case Name_ExecutionBranch{}: Node90()
    case Name_LightClientHeader{}: LightClientHeader
    case Name_LightClientOptimisticUpdate{}: LightClientOptimisticUpdate
    case Name_LightClientFinalityUpdate{}: LightClientFinalityUpdate
    case Name_LightClientUpdate{}: LightClientUpdate
    case Name_LightClientBootstrap{}: LightClientBootstrap
    case Name_BlobIndex{}: Node3()
    case Name_BlobIdentifier{}: BlobIdentifier
    case Name_KZGCommitment{}: Node8()
    case Name_BeaconBlockBody{}: BeaconBlockBody
    case Name_BeaconBlock{}: BeaconBlock
    case Name_SignedBeaconBlock{}: SignedBeaconBlock
    case Name_KZGProof{}: Node8()
    case Name_Blob{}: Node107()
    case Name_BlobSidecar{}: BlobSidecar
    case Name_Cell{}: Node110()
    case Name_CellIndex{}: Node3()
    case Name_CommitmentIndex{}: Node3()
    case Name_RowIndex{}: Node3()
    case Name_ColumnIndex{}: Node3()
    case Name_DataColumnsByRootIdentifier{}: DataColumnsByRootIdentifier
    case Name_MatrixEntry{}: MatrixEntry
    case Name_DataColumnSidecar{}: DataColumnSidecar
    case Name_CustodyIndex{}: Node3()

def Name.schema(name: Name) -> T.Schema:
  match name:
    case Name_boolean{}: Spec.boolean()
    case Name_uint8{}: Spec.uint8()
    case Name_uint32{}: Spec.uint32()
    case Name_uint64{}: Spec.uint64()
    case Name_uint256{}: Spec.uint256()
    case Name_Bytes1{}: Spec.Bytes1()
    case Name_Bytes4{}: Spec.Bytes4()
    case Name_Bytes32{}: Spec.Bytes32()
    case Name_Bytes48{}: Spec.Bytes48()
    case Name_Bytes96{}: Spec.Bytes96()
    case Name_Bytes8{}: Spec.Bytes8()
    case Name_Bytes20{}: Spec.Bytes20()
    case Name_Slot{}: Spec.Slot()
    case Name_Epoch{}: Spec.Epoch()
    case Name_Gwei{}: Spec.Gwei()
    case Name_Hash32{}: Spec.Hash32()
    case Name_Version{}: Spec.Version()
    case Name_DomainType{}: Spec.DomainType()
    case Name_BLSSignature{}: Spec.BLSSignature()
    case Name_FinalityBranch{}: Spec.FinalityBranch()
    case Name_VersionedHash{}: Spec.VersionedHash()
    case Name_G1Point{}: Spec.G1Point()
    case Name_G2Point{}: Spec.G2Point()
    case Name_Fork{}: Spec.Fork()
    case Name_SyncAggregate{}: Spec.SyncAggregate()
    case Name_SyncAggregatorSelectionData{}: Spec.SyncAggregatorSelectionData()
    case Name_PowBlock{}: Spec.PowBlock()
    case Name_CommitteeIndex{}: Spec.CommitteeIndex()
    case Name_ValidatorIndex{}: Spec.ValidatorIndex()
    case Name_PendingConsolidation{}: Spec.PendingConsolidation()
    case Name_PendingPartialWithdrawal{}: Spec.PendingPartialWithdrawal()
    case Name_VoluntaryExit{}: Spec.VoluntaryExit()
    case Name_SignedVoluntaryExit{}: Spec.SignedVoluntaryExit()
    case Name_Root{}: Spec.Root()
    case Name_HistoricalSummary{}: Spec.HistoricalSummary()
    case Name_SyncCommitteeContribution{}: Spec.SyncCommitteeContribution()
    case Name_ContributionAndProof{}: Spec.ContributionAndProof()
    case Name_SignedContributionAndProof{}: Spec.SignedContributionAndProof()
    case Name_SyncCommitteeMessage{}: Spec.SyncCommitteeMessage()
    case Name_Eth1Block{}: Spec.Eth1Block()
    case Name_BeaconBlockHeader{}: Spec.BeaconBlockHeader()
    case Name_SignedBeaconBlockHeader{}: Spec.SignedBeaconBlockHeader()
    case Name_ProposerSlashing{}: Spec.ProposerSlashing()
    case Name_HistoricalBatch{}: Spec.HistoricalBatch()
    case Name_Eth1Data{}: Spec.Eth1Data()
    case Name_Checkpoint{}: Spec.Checkpoint()
    case Name_AttestationData{}: Spec.AttestationData()
    case Name_SingleAttestation{}: Spec.SingleAttestation()
    case Name_Attestation{}: Spec.Attestation()
    case Name_AggregateAndProof{}: Spec.AggregateAndProof()
    case Name_SignedAggregateAndProof{}: Spec.SignedAggregateAndProof()
    case Name_PendingAttestation{}: Spec.PendingAttestation()
    case Name_IndexedAttestation{}: Spec.IndexedAttestation()
    case Name_AttesterSlashing{}: Spec.AttesterSlashing()
    case Name_ForkData{}: Spec.ForkData()
    case Name_ForkDigest{}: Spec.ForkDigest()
    case Name_Domain{}: Spec.Domain()
    case Name_SigningData{}: Spec.SigningData()
    case Name_BLSPubkey{}: Spec.BLSPubkey()
    case Name_DepositRequest{}: Spec.DepositRequest()
    case Name_PendingDeposit{}: Spec.PendingDeposit()
    case Name_SyncCommittee{}: Spec.SyncCommittee()
    case Name_DepositData{}: Spec.DepositData()
    case Name_Deposit{}: Spec.Deposit()
    case Name_DepositMessage{}: Spec.DepositMessage()
    case Name_Validator{}: Spec.Validator()
    case Name_NodeID{}: Spec.NodeID()
    case Name_SubnetID{}: Spec.SubnetID()
    case Name_Ether{}: Spec.Ether()
    case Name_ParticipationFlags{}: Spec.ParticipationFlags()
    case Name_CurrentSyncCommitteeBranch{}: Spec.CurrentSyncCommitteeBranch()
    case Name_NextSyncCommitteeBranch{}: Spec.NextSyncCommitteeBranch()
    case Name_Transaction{}: Spec.Transaction()
    case Name_ExecutionAddress{}: Spec.ExecutionAddress()
    case Name_ConsolidationRequest{}: Spec.ConsolidationRequest()
    case Name_WithdrawalRequest{}: Spec.WithdrawalRequest()
    case Name_ExecutionRequests{}: Spec.ExecutionRequests()
    case Name_BLSToExecutionChange{}: Spec.BLSToExecutionChange()
    case Name_SignedBLSToExecutionChange{}: Spec.SignedBLSToExecutionChange()
    case Name_ExecutionPayloadHeader{}: Spec.ExecutionPayloadHeader()
    case Name_PayloadId{}: Spec.PayloadId()
    case Name_WithdrawalIndex{}: Spec.WithdrawalIndex()
    case Name_Withdrawal{}: Spec.Withdrawal()
    case Name_ExecutionPayload{}: Spec.ExecutionPayload()
    case Name_BeaconState{}: Spec.BeaconState()
    case Name_ExecutionBranch{}: Spec.ExecutionBranch()
    case Name_LightClientHeader{}: Spec.LightClientHeader()
    case Name_LightClientOptimisticUpdate{}: Spec.LightClientOptimisticUpdate()
    case Name_LightClientFinalityUpdate{}: Spec.LightClientFinalityUpdate()
    case Name_LightClientUpdate{}: Spec.LightClientUpdate()
    case Name_LightClientBootstrap{}: Spec.LightClientBootstrap()
    case Name_BlobIndex{}: Spec.BlobIndex()
    case Name_BlobIdentifier{}: Spec.BlobIdentifier()
    case Name_KZGCommitment{}: Spec.KZGCommitment()
    case Name_BeaconBlockBody{}: Spec.BeaconBlockBody()
    case Name_BeaconBlock{}: Spec.BeaconBlock()
    case Name_SignedBeaconBlock{}: Spec.SignedBeaconBlock()
    case Name_KZGProof{}: Spec.KZGProof()
    case Name_Blob{}: Spec.Blob()
    case Name_BlobSidecar{}: Spec.BlobSidecar()
    case Name_Cell{}: Spec.Cell()
    case Name_CellIndex{}: Spec.CellIndex()
    case Name_CommitmentIndex{}: Spec.CommitmentIndex()
    case Name_RowIndex{}: Spec.RowIndex()
    case Name_ColumnIndex{}: Spec.ColumnIndex()
    case Name_DataColumnsByRootIdentifier{}: Spec.DataColumnsByRootIdentifier()
    case Name_MatrixEntry{}: Spec.MatrixEntry()
    case Name_DataColumnSidecar{}: Spec.DataColumnSidecar()
    case Name_CustodyIndex{}: Spec.CustodyIndex()

def Name.to_ssz(name: Name, v: Name.Value(name)) -> T.Value:
  match name:
    case Name_boolean{}: Node0.to_value(v)
    case Name_uint8{}: Node1.to_value(v)
    case Name_uint32{}: Node2.to_value(v)
    case Name_uint64{}: Node3.to_value(v)
    case Name_uint256{}: Node4.to_value(v)
    case Name_Bytes1{}: Node5.to_value(v)
    case Name_Bytes4{}: Node6.to_value(v)
    case Name_Bytes32{}: Node7.to_value(v)
    case Name_Bytes48{}: Node8.to_value(v)
    case Name_Bytes96{}: Node9.to_value(v)
    case Name_Bytes8{}: Node10.to_value(v)
    case Name_Bytes20{}: Node11.to_value(v)
    case Name_Slot{}: Node3.to_value(v)
    case Name_Epoch{}: Node3.to_value(v)
    case Name_Gwei{}: Node3.to_value(v)
    case Name_Hash32{}: Node7.to_value(v)
    case Name_Version{}: Node6.to_value(v)
    case Name_DomainType{}: Node6.to_value(v)
    case Name_BLSSignature{}: Node9.to_value(v)
    case Name_FinalityBranch{}: Node12.to_value(v)
    case Name_VersionedHash{}: Node7.to_value(v)
    case Name_G1Point{}: Node8.to_value(v)
    case Name_G2Point{}: Node9.to_value(v)
    case Name_Fork{}: ForkValue.to_value(v)
    case Name_SyncAggregate{}: SyncAggregateValue.to_value(v)
    case Name_SyncAggregatorSelectionData{}: SyncAggregatorSelectionDataValue.to_value(v)
    case Name_PowBlock{}: PowBlockValue.to_value(v)
    case Name_CommitteeIndex{}: Node3.to_value(v)
    case Name_ValidatorIndex{}: Node3.to_value(v)
    case Name_PendingConsolidation{}: PendingConsolidationValue.to_value(v)
    case Name_PendingPartialWithdrawal{}: PendingPartialWithdrawalValue.to_value(v)
    case Name_VoluntaryExit{}: VoluntaryExitValue.to_value(v)
    case Name_SignedVoluntaryExit{}: SignedVoluntaryExitValue.to_value(v)
    case Name_Root{}: Node7.to_value(v)
    case Name_HistoricalSummary{}: HistoricalSummaryValue.to_value(v)
    case Name_SyncCommitteeContribution{}: SyncCommitteeContributionValue.to_value(v)
    case Name_ContributionAndProof{}: ContributionAndProofValue.to_value(v)
    case Name_SignedContributionAndProof{}: SignedContributionAndProofValue.to_value(v)
    case Name_SyncCommitteeMessage{}: SyncCommitteeMessageValue.to_value(v)
    case Name_Eth1Block{}: Eth1BlockValue.to_value(v)
    case Name_BeaconBlockHeader{}: BeaconBlockHeaderValue.to_value(v)
    case Name_SignedBeaconBlockHeader{}: SignedBeaconBlockHeaderValue.to_value(v)
    case Name_ProposerSlashing{}: ProposerSlashingValue.to_value(v)
    case Name_HistoricalBatch{}: HistoricalBatchValue.to_value(v)
    case Name_Eth1Data{}: Eth1DataValue.to_value(v)
    case Name_Checkpoint{}: CheckpointValue.to_value(v)
    case Name_AttestationData{}: AttestationDataValue.to_value(v)
    case Name_SingleAttestation{}: SingleAttestationValue.to_value(v)
    case Name_Attestation{}: AttestationValue.to_value(v)
    case Name_AggregateAndProof{}: AggregateAndProofValue.to_value(v)
    case Name_SignedAggregateAndProof{}: SignedAggregateAndProofValue.to_value(v)
    case Name_PendingAttestation{}: PendingAttestationValue.to_value(v)
    case Name_IndexedAttestation{}: IndexedAttestationValue.to_value(v)
    case Name_AttesterSlashing{}: AttesterSlashingValue.to_value(v)
    case Name_ForkData{}: ForkDataValue.to_value(v)
    case Name_ForkDigest{}: Node6.to_value(v)
    case Name_Domain{}: Node7.to_value(v)
    case Name_SigningData{}: SigningDataValue.to_value(v)
    case Name_BLSPubkey{}: Node8.to_value(v)
    case Name_DepositRequest{}: DepositRequestValue.to_value(v)
    case Name_PendingDeposit{}: PendingDepositValue.to_value(v)
    case Name_SyncCommittee{}: SyncCommitteeValue.to_value(v)
    case Name_DepositData{}: DepositDataValue.to_value(v)
    case Name_Deposit{}: DepositValue.to_value(v)
    case Name_DepositMessage{}: DepositMessageValue.to_value(v)
    case Name_Validator{}: ValidatorValue.to_value(v)
    case Name_NodeID{}: Node4.to_value(v)
    case Name_SubnetID{}: Node3.to_value(v)
    case Name_Ether{}: Node3.to_value(v)
    case Name_ParticipationFlags{}: Node1.to_value(v)
    case Name_CurrentSyncCommitteeBranch{}: Node59.to_value(v)
    case Name_NextSyncCommitteeBranch{}: Node59.to_value(v)
    case Name_Transaction{}: Node60.to_value(v)
    case Name_ExecutionAddress{}: Node11.to_value(v)
    case Name_ConsolidationRequest{}: ConsolidationRequestValue.to_value(v)
    case Name_WithdrawalRequest{}: WithdrawalRequestValue.to_value(v)
    case Name_ExecutionRequests{}: ExecutionRequestsValue.to_value(v)
    case Name_BLSToExecutionChange{}: BLSToExecutionChangeValue.to_value(v)
    case Name_SignedBLSToExecutionChange{}: SignedBLSToExecutionChangeValue.to_value(v)
    case Name_ExecutionPayloadHeader{}: ExecutionPayloadHeaderValue.to_value(v)
    case Name_PayloadId{}: Node10.to_value(v)
    case Name_WithdrawalIndex{}: Node3.to_value(v)
    case Name_Withdrawal{}: WithdrawalValue.to_value(v)
    case Name_ExecutionPayload{}: ExecutionPayloadValue.to_value(v)
    case Name_BeaconState{}: BeaconStateValue.to_value(v)
    case Name_ExecutionBranch{}: Node90.to_value(v)
    case Name_LightClientHeader{}: LightClientHeaderValue.to_value(v)
    case Name_LightClientOptimisticUpdate{}: LightClientOptimisticUpdateValue.to_value(v)
    case Name_LightClientFinalityUpdate{}: LightClientFinalityUpdateValue.to_value(v)
    case Name_LightClientUpdate{}: LightClientUpdateValue.to_value(v)
    case Name_LightClientBootstrap{}: LightClientBootstrapValue.to_value(v)
    case Name_BlobIndex{}: Node3.to_value(v)
    case Name_BlobIdentifier{}: BlobIdentifierValue.to_value(v)
    case Name_KZGCommitment{}: Node8.to_value(v)
    case Name_BeaconBlockBody{}: BeaconBlockBodyValue.to_value(v)
    case Name_BeaconBlock{}: BeaconBlockValue.to_value(v)
    case Name_SignedBeaconBlock{}: SignedBeaconBlockValue.to_value(v)
    case Name_KZGProof{}: Node8.to_value(v)
    case Name_Blob{}: Node107.to_value(v)
    case Name_BlobSidecar{}: BlobSidecarValue.to_value(v)
    case Name_Cell{}: Node110.to_value(v)
    case Name_CellIndex{}: Node3.to_value(v)
    case Name_CommitmentIndex{}: Node3.to_value(v)
    case Name_RowIndex{}: Node3.to_value(v)
    case Name_ColumnIndex{}: Node3.to_value(v)
    case Name_DataColumnsByRootIdentifier{}: DataColumnsByRootIdentifierValue.to_value(v)
    case Name_MatrixEntry{}: MatrixEntryValue.to_value(v)
    case Name_DataColumnSidecar{}: DataColumnSidecarValue.to_value(v)
    case Name_CustodyIndex{}: Node3.to_value(v)

def Name.from_ssz(name: Name, value: T.Value) -> Maybe<&2, Name.Value(name)>:
  match name:
    case Name_boolean{}: Node0.from_value(value)
    case Name_uint8{}: Node1.from_value(value)
    case Name_uint32{}: Node2.from_value(value)
    case Name_uint64{}: Node3.from_value(value)
    case Name_uint256{}: Node4.from_value(value)
    case Name_Bytes1{}: Node5.from_value(value)
    case Name_Bytes4{}: Node6.from_value(value)
    case Name_Bytes32{}: Node7.from_value(value)
    case Name_Bytes48{}: Node8.from_value(value)
    case Name_Bytes96{}: Node9.from_value(value)
    case Name_Bytes8{}: Node10.from_value(value)
    case Name_Bytes20{}: Node11.from_value(value)
    case Name_Slot{}: Node3.from_value(value)
    case Name_Epoch{}: Node3.from_value(value)
    case Name_Gwei{}: Node3.from_value(value)
    case Name_Hash32{}: Node7.from_value(value)
    case Name_Version{}: Node6.from_value(value)
    case Name_DomainType{}: Node6.from_value(value)
    case Name_BLSSignature{}: Node9.from_value(value)
    case Name_FinalityBranch{}: Node12.from_value(value)
    case Name_VersionedHash{}: Node7.from_value(value)
    case Name_G1Point{}: Node8.from_value(value)
    case Name_G2Point{}: Node9.from_value(value)
    case Name_Fork{}: ForkValue.from_value(value)
    case Name_SyncAggregate{}: SyncAggregateValue.from_value(value)
    case Name_SyncAggregatorSelectionData{}: SyncAggregatorSelectionDataValue.from_value(value)
    case Name_PowBlock{}: PowBlockValue.from_value(value)
    case Name_CommitteeIndex{}: Node3.from_value(value)
    case Name_ValidatorIndex{}: Node3.from_value(value)
    case Name_PendingConsolidation{}: PendingConsolidationValue.from_value(value)
    case Name_PendingPartialWithdrawal{}: PendingPartialWithdrawalValue.from_value(value)
    case Name_VoluntaryExit{}: VoluntaryExitValue.from_value(value)
    case Name_SignedVoluntaryExit{}: SignedVoluntaryExitValue.from_value(value)
    case Name_Root{}: Node7.from_value(value)
    case Name_HistoricalSummary{}: HistoricalSummaryValue.from_value(value)
    case Name_SyncCommitteeContribution{}: SyncCommitteeContributionValue.from_value(value)
    case Name_ContributionAndProof{}: ContributionAndProofValue.from_value(value)
    case Name_SignedContributionAndProof{}: SignedContributionAndProofValue.from_value(value)
    case Name_SyncCommitteeMessage{}: SyncCommitteeMessageValue.from_value(value)
    case Name_Eth1Block{}: Eth1BlockValue.from_value(value)
    case Name_BeaconBlockHeader{}: BeaconBlockHeaderValue.from_value(value)
    case Name_SignedBeaconBlockHeader{}: SignedBeaconBlockHeaderValue.from_value(value)
    case Name_ProposerSlashing{}: ProposerSlashingValue.from_value(value)
    case Name_HistoricalBatch{}: HistoricalBatchValue.from_value(value)
    case Name_Eth1Data{}: Eth1DataValue.from_value(value)
    case Name_Checkpoint{}: CheckpointValue.from_value(value)
    case Name_AttestationData{}: AttestationDataValue.from_value(value)
    case Name_SingleAttestation{}: SingleAttestationValue.from_value(value)
    case Name_Attestation{}: AttestationValue.from_value(value)
    case Name_AggregateAndProof{}: AggregateAndProofValue.from_value(value)
    case Name_SignedAggregateAndProof{}: SignedAggregateAndProofValue.from_value(value)
    case Name_PendingAttestation{}: PendingAttestationValue.from_value(value)
    case Name_IndexedAttestation{}: IndexedAttestationValue.from_value(value)
    case Name_AttesterSlashing{}: AttesterSlashingValue.from_value(value)
    case Name_ForkData{}: ForkDataValue.from_value(value)
    case Name_ForkDigest{}: Node6.from_value(value)
    case Name_Domain{}: Node7.from_value(value)
    case Name_SigningData{}: SigningDataValue.from_value(value)
    case Name_BLSPubkey{}: Node8.from_value(value)
    case Name_DepositRequest{}: DepositRequestValue.from_value(value)
    case Name_PendingDeposit{}: PendingDepositValue.from_value(value)
    case Name_SyncCommittee{}: SyncCommitteeValue.from_value(value)
    case Name_DepositData{}: DepositDataValue.from_value(value)
    case Name_Deposit{}: DepositValue.from_value(value)
    case Name_DepositMessage{}: DepositMessageValue.from_value(value)
    case Name_Validator{}: ValidatorValue.from_value(value)
    case Name_NodeID{}: Node4.from_value(value)
    case Name_SubnetID{}: Node3.from_value(value)
    case Name_Ether{}: Node3.from_value(value)
    case Name_ParticipationFlags{}: Node1.from_value(value)
    case Name_CurrentSyncCommitteeBranch{}: Node59.from_value(value)
    case Name_NextSyncCommitteeBranch{}: Node59.from_value(value)
    case Name_Transaction{}: Node60.from_value(value)
    case Name_ExecutionAddress{}: Node11.from_value(value)
    case Name_ConsolidationRequest{}: ConsolidationRequestValue.from_value(value)
    case Name_WithdrawalRequest{}: WithdrawalRequestValue.from_value(value)
    case Name_ExecutionRequests{}: ExecutionRequestsValue.from_value(value)
    case Name_BLSToExecutionChange{}: BLSToExecutionChangeValue.from_value(value)
    case Name_SignedBLSToExecutionChange{}: SignedBLSToExecutionChangeValue.from_value(value)
    case Name_ExecutionPayloadHeader{}: ExecutionPayloadHeaderValue.from_value(value)
    case Name_PayloadId{}: Node10.from_value(value)
    case Name_WithdrawalIndex{}: Node3.from_value(value)
    case Name_Withdrawal{}: WithdrawalValue.from_value(value)
    case Name_ExecutionPayload{}: ExecutionPayloadValue.from_value(value)
    case Name_BeaconState{}: BeaconStateValue.from_value(value)
    case Name_ExecutionBranch{}: Node90.from_value(value)
    case Name_LightClientHeader{}: LightClientHeaderValue.from_value(value)
    case Name_LightClientOptimisticUpdate{}: LightClientOptimisticUpdateValue.from_value(value)
    case Name_LightClientFinalityUpdate{}: LightClientFinalityUpdateValue.from_value(value)
    case Name_LightClientUpdate{}: LightClientUpdateValue.from_value(value)
    case Name_LightClientBootstrap{}: LightClientBootstrapValue.from_value(value)
    case Name_BlobIndex{}: Node3.from_value(value)
    case Name_BlobIdentifier{}: BlobIdentifierValue.from_value(value)
    case Name_KZGCommitment{}: Node8.from_value(value)
    case Name_BeaconBlockBody{}: BeaconBlockBodyValue.from_value(value)
    case Name_BeaconBlock{}: BeaconBlockValue.from_value(value)
    case Name_SignedBeaconBlock{}: SignedBeaconBlockValue.from_value(value)
    case Name_KZGProof{}: Node8.from_value(value)
    case Name_Blob{}: Node107.from_value(value)
    case Name_BlobSidecar{}: BlobSidecarValue.from_value(value)
    case Name_Cell{}: Node110.from_value(value)
    case Name_CellIndex{}: Node3.from_value(value)
    case Name_CommitmentIndex{}: Node3.from_value(value)
    case Name_RowIndex{}: Node3.from_value(value)
    case Name_ColumnIndex{}: Node3.from_value(value)
    case Name_DataColumnsByRootIdentifier{}: DataColumnsByRootIdentifierValue.from_value(value)
    case Name_MatrixEntry{}: MatrixEntryValue.from_value(value)
    case Name_DataColumnSidecar{}: DataColumnSidecarValue.from_value(value)
    case Name_CustodyIndex{}: Node3.from_value(value)

def Name.valid(+name: Name, v: Name.Value(name)) -> Bool: API.valid(Name.schema(name), Name.to_ssz(name, v))
def Name.serialize(+name: Name, v: Name.Value(name)) -> Maybe<&2, +List<U32>>: API.serialize(Name.schema(name), Name.to_ssz(name, v))
def Name.decode_result(name: Name, result: Maybe<&2, T.Value>) -> Maybe<&2, Name.Value(name)>:
  match result:
    case None{}: None{}
    case Some{v}: Name.from_ssz(name, v)
def Name.deserialize(+name: Name, xs: +List<U32>) -> Maybe<&2, Name.Value(name)>: Name.decode_result(name, API.deserialize(Name.schema(name), xs))
def Name.hash_tree_root(+name: Name, v: Name.Value(name)) -> Maybe<&2, +List<U32>>: API.hash_tree_root(Name.schema(name), Name.to_ssz(name, v))

def boolean() -> Data: Node0()
def boolean.schema() -> T.Schema: Name.schema(Name_boolean{})
def boolean.to_ssz(v: boolean()) -> T.Value: Name.to_ssz(Name_boolean{}, v)
def boolean.from_ssz(v: T.Value) -> Maybe<&2, boolean()>: Name.from_ssz(Name_boolean{}, v)
def boolean.valid(v: boolean()) -> Bool: Name.valid(Name_boolean{}, v)
def boolean.serialize(v: boolean()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_boolean{}, v)
def boolean.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, boolean()>: Name.decode_result(Name_boolean{}, result)
def boolean.deserialize(xs: +List<U32>) -> Maybe<&2, boolean()>: Name.deserialize(Name_boolean{}, xs)
def boolean.hash_tree_root(v: boolean()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_boolean{}, v)
# boolean, primary compact API: packed buffer in, view / packed bytes / digest out.
def boolean.compact() -> CS.CS: Compact.boolean()
def boolean.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.boolean(), size, buf)
def boolean.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def boolean.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.boolean(), v, buf)

def uint8() -> Data: Node1()
def uint8.schema() -> T.Schema: Name.schema(Name_uint8{})
def uint8.to_ssz(v: uint8()) -> T.Value: Name.to_ssz(Name_uint8{}, v)
def uint8.from_ssz(v: T.Value) -> Maybe<&2, uint8()>: Name.from_ssz(Name_uint8{}, v)
def uint8.valid(v: uint8()) -> Bool: Name.valid(Name_uint8{}, v)
def uint8.serialize(v: uint8()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_uint8{}, v)
def uint8.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, uint8()>: Name.decode_result(Name_uint8{}, result)
def uint8.deserialize(xs: +List<U32>) -> Maybe<&2, uint8()>: Name.deserialize(Name_uint8{}, xs)
def uint8.hash_tree_root(v: uint8()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_uint8{}, v)
# uint8, primary compact API: packed buffer in, view / packed bytes / digest out.
def uint8.compact() -> CS.CS: Compact.uint8()
def uint8.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.uint8(), size, buf)
def uint8.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def uint8.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.uint8(), v, buf)

def uint32() -> Data: Node2()
def uint32.schema() -> T.Schema: Name.schema(Name_uint32{})
def uint32.to_ssz(v: uint32()) -> T.Value: Name.to_ssz(Name_uint32{}, v)
def uint32.from_ssz(v: T.Value) -> Maybe<&2, uint32()>: Name.from_ssz(Name_uint32{}, v)
def uint32.valid(v: uint32()) -> Bool: Name.valid(Name_uint32{}, v)
def uint32.serialize(v: uint32()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_uint32{}, v)
def uint32.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, uint32()>: Name.decode_result(Name_uint32{}, result)
def uint32.deserialize(xs: +List<U32>) -> Maybe<&2, uint32()>: Name.deserialize(Name_uint32{}, xs)
def uint32.hash_tree_root(v: uint32()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_uint32{}, v)
# uint32, primary compact API: packed buffer in, view / packed bytes / digest out.
def uint32.compact() -> CS.CS: Compact.uint32()
def uint32.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.uint32(), size, buf)
def uint32.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def uint32.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.uint32(), v, buf)

def uint64() -> Data: Node3()
def uint64.schema() -> T.Schema: Name.schema(Name_uint64{})
def uint64.to_ssz(v: uint64()) -> T.Value: Name.to_ssz(Name_uint64{}, v)
def uint64.from_ssz(v: T.Value) -> Maybe<&2, uint64()>: Name.from_ssz(Name_uint64{}, v)
def uint64.valid(v: uint64()) -> Bool: Name.valid(Name_uint64{}, v)
def uint64.serialize(v: uint64()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_uint64{}, v)
def uint64.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, uint64()>: Name.decode_result(Name_uint64{}, result)
def uint64.deserialize(xs: +List<U32>) -> Maybe<&2, uint64()>: Name.deserialize(Name_uint64{}, xs)
def uint64.hash_tree_root(v: uint64()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_uint64{}, v)
# uint64, primary compact API: packed buffer in, view / packed bytes / digest out.
def uint64.compact() -> CS.CS: Compact.uint64()
def uint64.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.uint64(), size, buf)
def uint64.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def uint64.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.uint64(), v, buf)

def uint256() -> Data: Node4()
def uint256.schema() -> T.Schema: Name.schema(Name_uint256{})
def uint256.to_ssz(v: uint256()) -> T.Value: Name.to_ssz(Name_uint256{}, v)
def uint256.from_ssz(v: T.Value) -> Maybe<&2, uint256()>: Name.from_ssz(Name_uint256{}, v)
def uint256.valid(v: uint256()) -> Bool: Name.valid(Name_uint256{}, v)
def uint256.serialize(v: uint256()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_uint256{}, v)
def uint256.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, uint256()>: Name.decode_result(Name_uint256{}, result)
def uint256.deserialize(xs: +List<U32>) -> Maybe<&2, uint256()>: Name.deserialize(Name_uint256{}, xs)
def uint256.hash_tree_root(v: uint256()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_uint256{}, v)
# uint256, primary compact API: packed buffer in, view / packed bytes / digest out.
def uint256.compact() -> CS.CS: Compact.uint256()
def uint256.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.uint256(), size, buf)
def uint256.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def uint256.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.uint256(), v, buf)

def Bytes1() -> Data: Node5()
def Bytes1.schema() -> T.Schema: Name.schema(Name_Bytes1{})
def Bytes1.to_ssz(v: Bytes1()) -> T.Value: Name.to_ssz(Name_Bytes1{}, v)
def Bytes1.from_ssz(v: T.Value) -> Maybe<&2, Bytes1()>: Name.from_ssz(Name_Bytes1{}, v)
def Bytes1.valid(v: Bytes1()) -> Bool: Name.valid(Name_Bytes1{}, v)
def Bytes1.serialize(v: Bytes1()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Bytes1{}, v)
def Bytes1.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Bytes1()>: Name.decode_result(Name_Bytes1{}, result)
def Bytes1.deserialize(xs: +List<U32>) -> Maybe<&2, Bytes1()>: Name.deserialize(Name_Bytes1{}, xs)
def Bytes1.hash_tree_root(v: Bytes1()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Bytes1{}, v)
# Bytes1, primary compact API: packed buffer in, view / packed bytes / digest out.
def Bytes1.compact() -> CS.CS: Compact.Bytes1()
def Bytes1.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Bytes1(), size, buf)
def Bytes1.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Bytes1.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Bytes1(), v, buf)

def Bytes4() -> Data: Node6()
def Bytes4.schema() -> T.Schema: Name.schema(Name_Bytes4{})
def Bytes4.to_ssz(v: Bytes4()) -> T.Value: Name.to_ssz(Name_Bytes4{}, v)
def Bytes4.from_ssz(v: T.Value) -> Maybe<&2, Bytes4()>: Name.from_ssz(Name_Bytes4{}, v)
def Bytes4.valid(v: Bytes4()) -> Bool: Name.valid(Name_Bytes4{}, v)
def Bytes4.serialize(v: Bytes4()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Bytes4{}, v)
def Bytes4.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Bytes4()>: Name.decode_result(Name_Bytes4{}, result)
def Bytes4.deserialize(xs: +List<U32>) -> Maybe<&2, Bytes4()>: Name.deserialize(Name_Bytes4{}, xs)
def Bytes4.hash_tree_root(v: Bytes4()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Bytes4{}, v)
# Bytes4, primary compact API: packed buffer in, view / packed bytes / digest out.
def Bytes4.compact() -> CS.CS: Compact.Bytes4()
def Bytes4.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Bytes4(), size, buf)
def Bytes4.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Bytes4.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Bytes4(), v, buf)

def Bytes32() -> Data: Node7()
def Bytes32.schema() -> T.Schema: Name.schema(Name_Bytes32{})
def Bytes32.to_ssz(v: Bytes32()) -> T.Value: Name.to_ssz(Name_Bytes32{}, v)
def Bytes32.from_ssz(v: T.Value) -> Maybe<&2, Bytes32()>: Name.from_ssz(Name_Bytes32{}, v)
def Bytes32.valid(v: Bytes32()) -> Bool: Name.valid(Name_Bytes32{}, v)
def Bytes32.serialize(v: Bytes32()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Bytes32{}, v)
def Bytes32.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Bytes32()>: Name.decode_result(Name_Bytes32{}, result)
def Bytes32.deserialize(xs: +List<U32>) -> Maybe<&2, Bytes32()>: Name.deserialize(Name_Bytes32{}, xs)
def Bytes32.hash_tree_root(v: Bytes32()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Bytes32{}, v)
# Bytes32, primary compact API: packed buffer in, view / packed bytes / digest out.
def Bytes32.compact() -> CS.CS: Compact.Bytes32()
def Bytes32.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Bytes32(), size, buf)
def Bytes32.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Bytes32.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Bytes32(), v, buf)

def Bytes48() -> Data: Node8()
def Bytes48.schema() -> T.Schema: Name.schema(Name_Bytes48{})
def Bytes48.to_ssz(v: Bytes48()) -> T.Value: Name.to_ssz(Name_Bytes48{}, v)
def Bytes48.from_ssz(v: T.Value) -> Maybe<&2, Bytes48()>: Name.from_ssz(Name_Bytes48{}, v)
def Bytes48.valid(v: Bytes48()) -> Bool: Name.valid(Name_Bytes48{}, v)
def Bytes48.serialize(v: Bytes48()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Bytes48{}, v)
def Bytes48.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Bytes48()>: Name.decode_result(Name_Bytes48{}, result)
def Bytes48.deserialize(xs: +List<U32>) -> Maybe<&2, Bytes48()>: Name.deserialize(Name_Bytes48{}, xs)
def Bytes48.hash_tree_root(v: Bytes48()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Bytes48{}, v)
# Bytes48, primary compact API: packed buffer in, view / packed bytes / digest out.
def Bytes48.compact() -> CS.CS: Compact.Bytes48()
def Bytes48.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Bytes48(), size, buf)
def Bytes48.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Bytes48.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Bytes48(), v, buf)

def Bytes96() -> Data: Node9()
def Bytes96.schema() -> T.Schema: Name.schema(Name_Bytes96{})
def Bytes96.to_ssz(v: Bytes96()) -> T.Value: Name.to_ssz(Name_Bytes96{}, v)
def Bytes96.from_ssz(v: T.Value) -> Maybe<&2, Bytes96()>: Name.from_ssz(Name_Bytes96{}, v)
def Bytes96.valid(v: Bytes96()) -> Bool: Name.valid(Name_Bytes96{}, v)
def Bytes96.serialize(v: Bytes96()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Bytes96{}, v)
def Bytes96.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Bytes96()>: Name.decode_result(Name_Bytes96{}, result)
def Bytes96.deserialize(xs: +List<U32>) -> Maybe<&2, Bytes96()>: Name.deserialize(Name_Bytes96{}, xs)
def Bytes96.hash_tree_root(v: Bytes96()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Bytes96{}, v)
# Bytes96, primary compact API: packed buffer in, view / packed bytes / digest out.
def Bytes96.compact() -> CS.CS: Compact.Bytes96()
def Bytes96.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Bytes96(), size, buf)
def Bytes96.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Bytes96.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Bytes96(), v, buf)

def Bytes8() -> Data: Node10()
def Bytes8.schema() -> T.Schema: Name.schema(Name_Bytes8{})
def Bytes8.to_ssz(v: Bytes8()) -> T.Value: Name.to_ssz(Name_Bytes8{}, v)
def Bytes8.from_ssz(v: T.Value) -> Maybe<&2, Bytes8()>: Name.from_ssz(Name_Bytes8{}, v)
def Bytes8.valid(v: Bytes8()) -> Bool: Name.valid(Name_Bytes8{}, v)
def Bytes8.serialize(v: Bytes8()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Bytes8{}, v)
def Bytes8.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Bytes8()>: Name.decode_result(Name_Bytes8{}, result)
def Bytes8.deserialize(xs: +List<U32>) -> Maybe<&2, Bytes8()>: Name.deserialize(Name_Bytes8{}, xs)
def Bytes8.hash_tree_root(v: Bytes8()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Bytes8{}, v)
# Bytes8, primary compact API: packed buffer in, view / packed bytes / digest out.
def Bytes8.compact() -> CS.CS: Compact.Bytes8()
def Bytes8.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Bytes8(), size, buf)
def Bytes8.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Bytes8.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Bytes8(), v, buf)

def Bytes20() -> Data: Node11()
def Bytes20.schema() -> T.Schema: Name.schema(Name_Bytes20{})
def Bytes20.to_ssz(v: Bytes20()) -> T.Value: Name.to_ssz(Name_Bytes20{}, v)
def Bytes20.from_ssz(v: T.Value) -> Maybe<&2, Bytes20()>: Name.from_ssz(Name_Bytes20{}, v)
def Bytes20.valid(v: Bytes20()) -> Bool: Name.valid(Name_Bytes20{}, v)
def Bytes20.serialize(v: Bytes20()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Bytes20{}, v)
def Bytes20.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Bytes20()>: Name.decode_result(Name_Bytes20{}, result)
def Bytes20.deserialize(xs: +List<U32>) -> Maybe<&2, Bytes20()>: Name.deserialize(Name_Bytes20{}, xs)
def Bytes20.hash_tree_root(v: Bytes20()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Bytes20{}, v)
# Bytes20, primary compact API: packed buffer in, view / packed bytes / digest out.
def Bytes20.compact() -> CS.CS: Compact.Bytes20()
def Bytes20.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Bytes20(), size, buf)
def Bytes20.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Bytes20.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Bytes20(), v, buf)

def Slot() -> Data: Node3()
def Slot.schema() -> T.Schema: Name.schema(Name_Slot{})
def Slot.to_ssz(v: Slot()) -> T.Value: Name.to_ssz(Name_Slot{}, v)
def Slot.from_ssz(v: T.Value) -> Maybe<&2, Slot()>: Name.from_ssz(Name_Slot{}, v)
def Slot.valid(v: Slot()) -> Bool: Name.valid(Name_Slot{}, v)
def Slot.serialize(v: Slot()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Slot{}, v)
def Slot.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Slot()>: Name.decode_result(Name_Slot{}, result)
def Slot.deserialize(xs: +List<U32>) -> Maybe<&2, Slot()>: Name.deserialize(Name_Slot{}, xs)
def Slot.hash_tree_root(v: Slot()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Slot{}, v)
# Slot, primary compact API: packed buffer in, view / packed bytes / digest out.
def Slot.compact() -> CS.CS: Compact.Slot()
def Slot.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Slot(), size, buf)
def Slot.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Slot.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Slot(), v, buf)

def Epoch() -> Data: Node3()
def Epoch.schema() -> T.Schema: Name.schema(Name_Epoch{})
def Epoch.to_ssz(v: Epoch()) -> T.Value: Name.to_ssz(Name_Epoch{}, v)
def Epoch.from_ssz(v: T.Value) -> Maybe<&2, Epoch()>: Name.from_ssz(Name_Epoch{}, v)
def Epoch.valid(v: Epoch()) -> Bool: Name.valid(Name_Epoch{}, v)
def Epoch.serialize(v: Epoch()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Epoch{}, v)
def Epoch.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Epoch()>: Name.decode_result(Name_Epoch{}, result)
def Epoch.deserialize(xs: +List<U32>) -> Maybe<&2, Epoch()>: Name.deserialize(Name_Epoch{}, xs)
def Epoch.hash_tree_root(v: Epoch()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Epoch{}, v)
# Epoch, primary compact API: packed buffer in, view / packed bytes / digest out.
def Epoch.compact() -> CS.CS: Compact.Epoch()
def Epoch.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Epoch(), size, buf)
def Epoch.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Epoch.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Epoch(), v, buf)

def Gwei() -> Data: Node3()
def Gwei.schema() -> T.Schema: Name.schema(Name_Gwei{})
def Gwei.to_ssz(v: Gwei()) -> T.Value: Name.to_ssz(Name_Gwei{}, v)
def Gwei.from_ssz(v: T.Value) -> Maybe<&2, Gwei()>: Name.from_ssz(Name_Gwei{}, v)
def Gwei.valid(v: Gwei()) -> Bool: Name.valid(Name_Gwei{}, v)
def Gwei.serialize(v: Gwei()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Gwei{}, v)
def Gwei.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Gwei()>: Name.decode_result(Name_Gwei{}, result)
def Gwei.deserialize(xs: +List<U32>) -> Maybe<&2, Gwei()>: Name.deserialize(Name_Gwei{}, xs)
def Gwei.hash_tree_root(v: Gwei()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Gwei{}, v)
# Gwei, primary compact API: packed buffer in, view / packed bytes / digest out.
def Gwei.compact() -> CS.CS: Compact.Gwei()
def Gwei.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Gwei(), size, buf)
def Gwei.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Gwei.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Gwei(), v, buf)

def Hash32() -> Data: Node7()
def Hash32.schema() -> T.Schema: Name.schema(Name_Hash32{})
def Hash32.to_ssz(v: Hash32()) -> T.Value: Name.to_ssz(Name_Hash32{}, v)
def Hash32.from_ssz(v: T.Value) -> Maybe<&2, Hash32()>: Name.from_ssz(Name_Hash32{}, v)
def Hash32.valid(v: Hash32()) -> Bool: Name.valid(Name_Hash32{}, v)
def Hash32.serialize(v: Hash32()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Hash32{}, v)
def Hash32.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Hash32()>: Name.decode_result(Name_Hash32{}, result)
def Hash32.deserialize(xs: +List<U32>) -> Maybe<&2, Hash32()>: Name.deserialize(Name_Hash32{}, xs)
def Hash32.hash_tree_root(v: Hash32()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Hash32{}, v)
# Hash32, primary compact API: packed buffer in, view / packed bytes / digest out.
def Hash32.compact() -> CS.CS: Compact.Hash32()
def Hash32.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Hash32(), size, buf)
def Hash32.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Hash32.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Hash32(), v, buf)

def Version() -> Data: Node6()
def Version.schema() -> T.Schema: Name.schema(Name_Version{})
def Version.to_ssz(v: Version()) -> T.Value: Name.to_ssz(Name_Version{}, v)
def Version.from_ssz(v: T.Value) -> Maybe<&2, Version()>: Name.from_ssz(Name_Version{}, v)
def Version.valid(v: Version()) -> Bool: Name.valid(Name_Version{}, v)
def Version.serialize(v: Version()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Version{}, v)
def Version.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Version()>: Name.decode_result(Name_Version{}, result)
def Version.deserialize(xs: +List<U32>) -> Maybe<&2, Version()>: Name.deserialize(Name_Version{}, xs)
def Version.hash_tree_root(v: Version()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Version{}, v)
# Version, primary compact API: packed buffer in, view / packed bytes / digest out.
def Version.compact() -> CS.CS: Compact.Version()
def Version.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Version(), size, buf)
def Version.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Version.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Version(), v, buf)

def DomainType() -> Data: Node6()
def DomainType.schema() -> T.Schema: Name.schema(Name_DomainType{})
def DomainType.to_ssz(v: DomainType()) -> T.Value: Name.to_ssz(Name_DomainType{}, v)
def DomainType.from_ssz(v: T.Value) -> Maybe<&2, DomainType()>: Name.from_ssz(Name_DomainType{}, v)
def DomainType.valid(v: DomainType()) -> Bool: Name.valid(Name_DomainType{}, v)
def DomainType.serialize(v: DomainType()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_DomainType{}, v)
def DomainType.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, DomainType()>: Name.decode_result(Name_DomainType{}, result)
def DomainType.deserialize(xs: +List<U32>) -> Maybe<&2, DomainType()>: Name.deserialize(Name_DomainType{}, xs)
def DomainType.hash_tree_root(v: DomainType()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_DomainType{}, v)
# DomainType, primary compact API: packed buffer in, view / packed bytes / digest out.
def DomainType.compact() -> CS.CS: Compact.DomainType()
def DomainType.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.DomainType(), size, buf)
def DomainType.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def DomainType.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.DomainType(), v, buf)

def BLSSignature() -> Data: Node9()
def BLSSignature.schema() -> T.Schema: Name.schema(Name_BLSSignature{})
def BLSSignature.to_ssz(v: BLSSignature()) -> T.Value: Name.to_ssz(Name_BLSSignature{}, v)
def BLSSignature.from_ssz(v: T.Value) -> Maybe<&2, BLSSignature()>: Name.from_ssz(Name_BLSSignature{}, v)
def BLSSignature.valid(v: BLSSignature()) -> Bool: Name.valid(Name_BLSSignature{}, v)
def BLSSignature.serialize(v: BLSSignature()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_BLSSignature{}, v)
def BLSSignature.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, BLSSignature()>: Name.decode_result(Name_BLSSignature{}, result)
def BLSSignature.deserialize(xs: +List<U32>) -> Maybe<&2, BLSSignature()>: Name.deserialize(Name_BLSSignature{}, xs)
def BLSSignature.hash_tree_root(v: BLSSignature()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_BLSSignature{}, v)
# BLSSignature, primary compact API: packed buffer in, view / packed bytes / digest out.
def BLSSignature.compact() -> CS.CS: Compact.BLSSignature()
def BLSSignature.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.BLSSignature(), size, buf)
def BLSSignature.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def BLSSignature.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.BLSSignature(), v, buf)

def FinalityBranch() -> Data: Node12()
def FinalityBranch.schema() -> T.Schema: Name.schema(Name_FinalityBranch{})
def FinalityBranch.to_ssz(v: FinalityBranch()) -> T.Value: Name.to_ssz(Name_FinalityBranch{}, v)
def FinalityBranch.from_ssz(v: T.Value) -> Maybe<&2, FinalityBranch()>: Name.from_ssz(Name_FinalityBranch{}, v)
def FinalityBranch.valid(v: FinalityBranch()) -> Bool: Name.valid(Name_FinalityBranch{}, v)
def FinalityBranch.serialize(v: FinalityBranch()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_FinalityBranch{}, v)
def FinalityBranch.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, FinalityBranch()>: Name.decode_result(Name_FinalityBranch{}, result)
def FinalityBranch.deserialize(xs: +List<U32>) -> Maybe<&2, FinalityBranch()>: Name.deserialize(Name_FinalityBranch{}, xs)
def FinalityBranch.hash_tree_root(v: FinalityBranch()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_FinalityBranch{}, v)
# FinalityBranch, primary compact API: packed buffer in, view / packed bytes / digest out.
def FinalityBranch.compact() -> CS.CS: Compact.FinalityBranch()
def FinalityBranch.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.FinalityBranch(), size, buf)
def FinalityBranch.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def FinalityBranch.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.FinalityBranch(), v, buf)

def VersionedHash() -> Data: Node7()
def VersionedHash.schema() -> T.Schema: Name.schema(Name_VersionedHash{})
def VersionedHash.to_ssz(v: VersionedHash()) -> T.Value: Name.to_ssz(Name_VersionedHash{}, v)
def VersionedHash.from_ssz(v: T.Value) -> Maybe<&2, VersionedHash()>: Name.from_ssz(Name_VersionedHash{}, v)
def VersionedHash.valid(v: VersionedHash()) -> Bool: Name.valid(Name_VersionedHash{}, v)
def VersionedHash.serialize(v: VersionedHash()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_VersionedHash{}, v)
def VersionedHash.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, VersionedHash()>: Name.decode_result(Name_VersionedHash{}, result)
def VersionedHash.deserialize(xs: +List<U32>) -> Maybe<&2, VersionedHash()>: Name.deserialize(Name_VersionedHash{}, xs)
def VersionedHash.hash_tree_root(v: VersionedHash()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_VersionedHash{}, v)
# VersionedHash, primary compact API: packed buffer in, view / packed bytes / digest out.
def VersionedHash.compact() -> CS.CS: Compact.VersionedHash()
def VersionedHash.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.VersionedHash(), size, buf)
def VersionedHash.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def VersionedHash.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.VersionedHash(), v, buf)

def G1Point() -> Data: Node8()
def G1Point.schema() -> T.Schema: Name.schema(Name_G1Point{})
def G1Point.to_ssz(v: G1Point()) -> T.Value: Name.to_ssz(Name_G1Point{}, v)
def G1Point.from_ssz(v: T.Value) -> Maybe<&2, G1Point()>: Name.from_ssz(Name_G1Point{}, v)
def G1Point.valid(v: G1Point()) -> Bool: Name.valid(Name_G1Point{}, v)
def G1Point.serialize(v: G1Point()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_G1Point{}, v)
def G1Point.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, G1Point()>: Name.decode_result(Name_G1Point{}, result)
def G1Point.deserialize(xs: +List<U32>) -> Maybe<&2, G1Point()>: Name.deserialize(Name_G1Point{}, xs)
def G1Point.hash_tree_root(v: G1Point()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_G1Point{}, v)
# G1Point, primary compact API: packed buffer in, view / packed bytes / digest out.
def G1Point.compact() -> CS.CS: Compact.G1Point()
def G1Point.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.G1Point(), size, buf)
def G1Point.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def G1Point.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.G1Point(), v, buf)

def G2Point() -> Data: Node9()
def G2Point.schema() -> T.Schema: Name.schema(Name_G2Point{})
def G2Point.to_ssz(v: G2Point()) -> T.Value: Name.to_ssz(Name_G2Point{}, v)
def G2Point.from_ssz(v: T.Value) -> Maybe<&2, G2Point()>: Name.from_ssz(Name_G2Point{}, v)
def G2Point.valid(v: G2Point()) -> Bool: Name.valid(Name_G2Point{}, v)
def G2Point.serialize(v: G2Point()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_G2Point{}, v)
def G2Point.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, G2Point()>: Name.decode_result(Name_G2Point{}, result)
def G2Point.deserialize(xs: +List<U32>) -> Maybe<&2, G2Point()>: Name.deserialize(Name_G2Point{}, xs)
def G2Point.hash_tree_root(v: G2Point()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_G2Point{}, v)
# G2Point, primary compact API: packed buffer in, view / packed bytes / digest out.
def G2Point.compact() -> CS.CS: Compact.G2Point()
def G2Point.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.G2Point(), size, buf)
def G2Point.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def G2Point.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.G2Point(), v, buf)

def Fork.schema() -> T.Schema: Name.schema(Name_Fork{})
def Fork.to_ssz(v: Fork) -> T.Value: Name.to_ssz(Name_Fork{}, v)
def Fork.from_ssz(v: T.Value) -> Maybe<&2, Fork>: Name.from_ssz(Name_Fork{}, v)
def Fork.valid(v: Fork) -> Bool: Name.valid(Name_Fork{}, v)
def Fork.serialize(v: Fork) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Fork{}, v)
def Fork.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Fork>: Name.decode_result(Name_Fork{}, result)
def Fork.deserialize(xs: +List<U32>) -> Maybe<&2, Fork>: Name.deserialize(Name_Fork{}, xs)
def Fork.hash_tree_root(v: Fork) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Fork{}, v)
# Fork, primary compact API: packed buffer in, view / packed bytes / digest out.
def Fork.compact() -> CS.CS: Compact.Fork()
def Fork.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Fork(), size, buf)
def Fork.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Fork.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Fork(), v, buf)

def SyncAggregate.schema() -> T.Schema: Name.schema(Name_SyncAggregate{})
def SyncAggregate.to_ssz(v: SyncAggregate) -> T.Value: Name.to_ssz(Name_SyncAggregate{}, v)
def SyncAggregate.from_ssz(v: T.Value) -> Maybe<&2, SyncAggregate>: Name.from_ssz(Name_SyncAggregate{}, v)
def SyncAggregate.valid(v: SyncAggregate) -> Bool: Name.valid(Name_SyncAggregate{}, v)
def SyncAggregate.serialize(v: SyncAggregate) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SyncAggregate{}, v)
def SyncAggregate.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SyncAggregate>: Name.decode_result(Name_SyncAggregate{}, result)
def SyncAggregate.deserialize(xs: +List<U32>) -> Maybe<&2, SyncAggregate>: Name.deserialize(Name_SyncAggregate{}, xs)
def SyncAggregate.hash_tree_root(v: SyncAggregate) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SyncAggregate{}, v)
# SyncAggregate, primary compact API: packed buffer in, view / packed bytes / digest out.
def SyncAggregate.compact() -> CS.CS: Compact.SyncAggregate()
def SyncAggregate.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SyncAggregate(), size, buf)
def SyncAggregate.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SyncAggregate.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SyncAggregate(), v, buf)

def SyncAggregatorSelectionData.schema() -> T.Schema: Name.schema(Name_SyncAggregatorSelectionData{})
def SyncAggregatorSelectionData.to_ssz(v: SyncAggregatorSelectionData) -> T.Value: Name.to_ssz(Name_SyncAggregatorSelectionData{}, v)
def SyncAggregatorSelectionData.from_ssz(v: T.Value) -> Maybe<&2, SyncAggregatorSelectionData>: Name.from_ssz(Name_SyncAggregatorSelectionData{}, v)
def SyncAggregatorSelectionData.valid(v: SyncAggregatorSelectionData) -> Bool: Name.valid(Name_SyncAggregatorSelectionData{}, v)
def SyncAggregatorSelectionData.serialize(v: SyncAggregatorSelectionData) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SyncAggregatorSelectionData{}, v)
def SyncAggregatorSelectionData.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SyncAggregatorSelectionData>: Name.decode_result(Name_SyncAggregatorSelectionData{}, result)
def SyncAggregatorSelectionData.deserialize(xs: +List<U32>) -> Maybe<&2, SyncAggregatorSelectionData>: Name.deserialize(Name_SyncAggregatorSelectionData{}, xs)
def SyncAggregatorSelectionData.hash_tree_root(v: SyncAggregatorSelectionData) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SyncAggregatorSelectionData{}, v)
# SyncAggregatorSelectionData, primary compact API: packed buffer in, view / packed bytes / digest out.
def SyncAggregatorSelectionData.compact() -> CS.CS: Compact.SyncAggregatorSelectionData()
def SyncAggregatorSelectionData.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SyncAggregatorSelectionData(), size, buf)
def SyncAggregatorSelectionData.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SyncAggregatorSelectionData.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SyncAggregatorSelectionData(), v, buf)

def PowBlock.schema() -> T.Schema: Name.schema(Name_PowBlock{})
def PowBlock.to_ssz(v: PowBlock) -> T.Value: Name.to_ssz(Name_PowBlock{}, v)
def PowBlock.from_ssz(v: T.Value) -> Maybe<&2, PowBlock>: Name.from_ssz(Name_PowBlock{}, v)
def PowBlock.valid(v: PowBlock) -> Bool: Name.valid(Name_PowBlock{}, v)
def PowBlock.serialize(v: PowBlock) -> Maybe<&2, +List<U32>>: Name.serialize(Name_PowBlock{}, v)
def PowBlock.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, PowBlock>: Name.decode_result(Name_PowBlock{}, result)
def PowBlock.deserialize(xs: +List<U32>) -> Maybe<&2, PowBlock>: Name.deserialize(Name_PowBlock{}, xs)
def PowBlock.hash_tree_root(v: PowBlock) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_PowBlock{}, v)
# PowBlock, primary compact API: packed buffer in, view / packed bytes / digest out.
def PowBlock.compact() -> CS.CS: Compact.PowBlock()
def PowBlock.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.PowBlock(), size, buf)
def PowBlock.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def PowBlock.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.PowBlock(), v, buf)

def CommitteeIndex() -> Data: Node3()
def CommitteeIndex.schema() -> T.Schema: Name.schema(Name_CommitteeIndex{})
def CommitteeIndex.to_ssz(v: CommitteeIndex()) -> T.Value: Name.to_ssz(Name_CommitteeIndex{}, v)
def CommitteeIndex.from_ssz(v: T.Value) -> Maybe<&2, CommitteeIndex()>: Name.from_ssz(Name_CommitteeIndex{}, v)
def CommitteeIndex.valid(v: CommitteeIndex()) -> Bool: Name.valid(Name_CommitteeIndex{}, v)
def CommitteeIndex.serialize(v: CommitteeIndex()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_CommitteeIndex{}, v)
def CommitteeIndex.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, CommitteeIndex()>: Name.decode_result(Name_CommitteeIndex{}, result)
def CommitteeIndex.deserialize(xs: +List<U32>) -> Maybe<&2, CommitteeIndex()>: Name.deserialize(Name_CommitteeIndex{}, xs)
def CommitteeIndex.hash_tree_root(v: CommitteeIndex()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_CommitteeIndex{}, v)
# CommitteeIndex, primary compact API: packed buffer in, view / packed bytes / digest out.
def CommitteeIndex.compact() -> CS.CS: Compact.CommitteeIndex()
def CommitteeIndex.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.CommitteeIndex(), size, buf)
def CommitteeIndex.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def CommitteeIndex.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.CommitteeIndex(), v, buf)

def ValidatorIndex() -> Data: Node3()
def ValidatorIndex.schema() -> T.Schema: Name.schema(Name_ValidatorIndex{})
def ValidatorIndex.to_ssz(v: ValidatorIndex()) -> T.Value: Name.to_ssz(Name_ValidatorIndex{}, v)
def ValidatorIndex.from_ssz(v: T.Value) -> Maybe<&2, ValidatorIndex()>: Name.from_ssz(Name_ValidatorIndex{}, v)
def ValidatorIndex.valid(v: ValidatorIndex()) -> Bool: Name.valid(Name_ValidatorIndex{}, v)
def ValidatorIndex.serialize(v: ValidatorIndex()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ValidatorIndex{}, v)
def ValidatorIndex.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ValidatorIndex()>: Name.decode_result(Name_ValidatorIndex{}, result)
def ValidatorIndex.deserialize(xs: +List<U32>) -> Maybe<&2, ValidatorIndex()>: Name.deserialize(Name_ValidatorIndex{}, xs)
def ValidatorIndex.hash_tree_root(v: ValidatorIndex()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ValidatorIndex{}, v)
# ValidatorIndex, primary compact API: packed buffer in, view / packed bytes / digest out.
def ValidatorIndex.compact() -> CS.CS: Compact.ValidatorIndex()
def ValidatorIndex.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ValidatorIndex(), size, buf)
def ValidatorIndex.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ValidatorIndex.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ValidatorIndex(), v, buf)

def PendingConsolidation.schema() -> T.Schema: Name.schema(Name_PendingConsolidation{})
def PendingConsolidation.to_ssz(v: PendingConsolidation) -> T.Value: Name.to_ssz(Name_PendingConsolidation{}, v)
def PendingConsolidation.from_ssz(v: T.Value) -> Maybe<&2, PendingConsolidation>: Name.from_ssz(Name_PendingConsolidation{}, v)
def PendingConsolidation.valid(v: PendingConsolidation) -> Bool: Name.valid(Name_PendingConsolidation{}, v)
def PendingConsolidation.serialize(v: PendingConsolidation) -> Maybe<&2, +List<U32>>: Name.serialize(Name_PendingConsolidation{}, v)
def PendingConsolidation.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, PendingConsolidation>: Name.decode_result(Name_PendingConsolidation{}, result)
def PendingConsolidation.deserialize(xs: +List<U32>) -> Maybe<&2, PendingConsolidation>: Name.deserialize(Name_PendingConsolidation{}, xs)
def PendingConsolidation.hash_tree_root(v: PendingConsolidation) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_PendingConsolidation{}, v)
# PendingConsolidation, primary compact API: packed buffer in, view / packed bytes / digest out.
def PendingConsolidation.compact() -> CS.CS: Compact.PendingConsolidation()
def PendingConsolidation.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.PendingConsolidation(), size, buf)
def PendingConsolidation.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def PendingConsolidation.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.PendingConsolidation(), v, buf)

def PendingPartialWithdrawal.schema() -> T.Schema: Name.schema(Name_PendingPartialWithdrawal{})
def PendingPartialWithdrawal.to_ssz(v: PendingPartialWithdrawal) -> T.Value: Name.to_ssz(Name_PendingPartialWithdrawal{}, v)
def PendingPartialWithdrawal.from_ssz(v: T.Value) -> Maybe<&2, PendingPartialWithdrawal>: Name.from_ssz(Name_PendingPartialWithdrawal{}, v)
def PendingPartialWithdrawal.valid(v: PendingPartialWithdrawal) -> Bool: Name.valid(Name_PendingPartialWithdrawal{}, v)
def PendingPartialWithdrawal.serialize(v: PendingPartialWithdrawal) -> Maybe<&2, +List<U32>>: Name.serialize(Name_PendingPartialWithdrawal{}, v)
def PendingPartialWithdrawal.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, PendingPartialWithdrawal>: Name.decode_result(Name_PendingPartialWithdrawal{}, result)
def PendingPartialWithdrawal.deserialize(xs: +List<U32>) -> Maybe<&2, PendingPartialWithdrawal>: Name.deserialize(Name_PendingPartialWithdrawal{}, xs)
def PendingPartialWithdrawal.hash_tree_root(v: PendingPartialWithdrawal) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_PendingPartialWithdrawal{}, v)
# PendingPartialWithdrawal, primary compact API: packed buffer in, view / packed bytes / digest out.
def PendingPartialWithdrawal.compact() -> CS.CS: Compact.PendingPartialWithdrawal()
def PendingPartialWithdrawal.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.PendingPartialWithdrawal(), size, buf)
def PendingPartialWithdrawal.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def PendingPartialWithdrawal.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.PendingPartialWithdrawal(), v, buf)

def VoluntaryExit.schema() -> T.Schema: Name.schema(Name_VoluntaryExit{})
def VoluntaryExit.to_ssz(v: VoluntaryExit) -> T.Value: Name.to_ssz(Name_VoluntaryExit{}, v)
def VoluntaryExit.from_ssz(v: T.Value) -> Maybe<&2, VoluntaryExit>: Name.from_ssz(Name_VoluntaryExit{}, v)
def VoluntaryExit.valid(v: VoluntaryExit) -> Bool: Name.valid(Name_VoluntaryExit{}, v)
def VoluntaryExit.serialize(v: VoluntaryExit) -> Maybe<&2, +List<U32>>: Name.serialize(Name_VoluntaryExit{}, v)
def VoluntaryExit.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, VoluntaryExit>: Name.decode_result(Name_VoluntaryExit{}, result)
def VoluntaryExit.deserialize(xs: +List<U32>) -> Maybe<&2, VoluntaryExit>: Name.deserialize(Name_VoluntaryExit{}, xs)
def VoluntaryExit.hash_tree_root(v: VoluntaryExit) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_VoluntaryExit{}, v)
# VoluntaryExit, primary compact API: packed buffer in, view / packed bytes / digest out.
def VoluntaryExit.compact() -> CS.CS: Compact.VoluntaryExit()
def VoluntaryExit.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.VoluntaryExit(), size, buf)
def VoluntaryExit.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def VoluntaryExit.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.VoluntaryExit(), v, buf)

def SignedVoluntaryExit.schema() -> T.Schema: Name.schema(Name_SignedVoluntaryExit{})
def SignedVoluntaryExit.to_ssz(v: SignedVoluntaryExit) -> T.Value: Name.to_ssz(Name_SignedVoluntaryExit{}, v)
def SignedVoluntaryExit.from_ssz(v: T.Value) -> Maybe<&2, SignedVoluntaryExit>: Name.from_ssz(Name_SignedVoluntaryExit{}, v)
def SignedVoluntaryExit.valid(v: SignedVoluntaryExit) -> Bool: Name.valid(Name_SignedVoluntaryExit{}, v)
def SignedVoluntaryExit.serialize(v: SignedVoluntaryExit) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SignedVoluntaryExit{}, v)
def SignedVoluntaryExit.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SignedVoluntaryExit>: Name.decode_result(Name_SignedVoluntaryExit{}, result)
def SignedVoluntaryExit.deserialize(xs: +List<U32>) -> Maybe<&2, SignedVoluntaryExit>: Name.deserialize(Name_SignedVoluntaryExit{}, xs)
def SignedVoluntaryExit.hash_tree_root(v: SignedVoluntaryExit) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SignedVoluntaryExit{}, v)
# SignedVoluntaryExit, primary compact API: packed buffer in, view / packed bytes / digest out.
def SignedVoluntaryExit.compact() -> CS.CS: Compact.SignedVoluntaryExit()
def SignedVoluntaryExit.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SignedVoluntaryExit(), size, buf)
def SignedVoluntaryExit.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SignedVoluntaryExit.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SignedVoluntaryExit(), v, buf)

def Root() -> Data: Node7()
def Root.schema() -> T.Schema: Name.schema(Name_Root{})
def Root.to_ssz(v: Root()) -> T.Value: Name.to_ssz(Name_Root{}, v)
def Root.from_ssz(v: T.Value) -> Maybe<&2, Root()>: Name.from_ssz(Name_Root{}, v)
def Root.valid(v: Root()) -> Bool: Name.valid(Name_Root{}, v)
def Root.serialize(v: Root()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Root{}, v)
def Root.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Root()>: Name.decode_result(Name_Root{}, result)
def Root.deserialize(xs: +List<U32>) -> Maybe<&2, Root()>: Name.deserialize(Name_Root{}, xs)
def Root.hash_tree_root(v: Root()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Root{}, v)
# Root, primary compact API: packed buffer in, view / packed bytes / digest out.
def Root.compact() -> CS.CS: Compact.Root()
def Root.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Root(), size, buf)
def Root.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Root.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Root(), v, buf)

def HistoricalSummary.schema() -> T.Schema: Name.schema(Name_HistoricalSummary{})
def HistoricalSummary.to_ssz(v: HistoricalSummary) -> T.Value: Name.to_ssz(Name_HistoricalSummary{}, v)
def HistoricalSummary.from_ssz(v: T.Value) -> Maybe<&2, HistoricalSummary>: Name.from_ssz(Name_HistoricalSummary{}, v)
def HistoricalSummary.valid(v: HistoricalSummary) -> Bool: Name.valid(Name_HistoricalSummary{}, v)
def HistoricalSummary.serialize(v: HistoricalSummary) -> Maybe<&2, +List<U32>>: Name.serialize(Name_HistoricalSummary{}, v)
def HistoricalSummary.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, HistoricalSummary>: Name.decode_result(Name_HistoricalSummary{}, result)
def HistoricalSummary.deserialize(xs: +List<U32>) -> Maybe<&2, HistoricalSummary>: Name.deserialize(Name_HistoricalSummary{}, xs)
def HistoricalSummary.hash_tree_root(v: HistoricalSummary) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_HistoricalSummary{}, v)
# HistoricalSummary, primary compact API: packed buffer in, view / packed bytes / digest out.
def HistoricalSummary.compact() -> CS.CS: Compact.HistoricalSummary()
def HistoricalSummary.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.HistoricalSummary(), size, buf)
def HistoricalSummary.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def HistoricalSummary.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.HistoricalSummary(), v, buf)

def SyncCommitteeContribution.schema() -> T.Schema: Name.schema(Name_SyncCommitteeContribution{})
def SyncCommitteeContribution.to_ssz(v: SyncCommitteeContribution) -> T.Value: Name.to_ssz(Name_SyncCommitteeContribution{}, v)
def SyncCommitteeContribution.from_ssz(v: T.Value) -> Maybe<&2, SyncCommitteeContribution>: Name.from_ssz(Name_SyncCommitteeContribution{}, v)
def SyncCommitteeContribution.valid(v: SyncCommitteeContribution) -> Bool: Name.valid(Name_SyncCommitteeContribution{}, v)
def SyncCommitteeContribution.serialize(v: SyncCommitteeContribution) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SyncCommitteeContribution{}, v)
def SyncCommitteeContribution.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SyncCommitteeContribution>: Name.decode_result(Name_SyncCommitteeContribution{}, result)
def SyncCommitteeContribution.deserialize(xs: +List<U32>) -> Maybe<&2, SyncCommitteeContribution>: Name.deserialize(Name_SyncCommitteeContribution{}, xs)
def SyncCommitteeContribution.hash_tree_root(v: SyncCommitteeContribution) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SyncCommitteeContribution{}, v)
# SyncCommitteeContribution, primary compact API: packed buffer in, view / packed bytes / digest out.
def SyncCommitteeContribution.compact() -> CS.CS: Compact.SyncCommitteeContribution()
def SyncCommitteeContribution.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SyncCommitteeContribution(), size, buf)
def SyncCommitteeContribution.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SyncCommitteeContribution.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SyncCommitteeContribution(), v, buf)

def ContributionAndProof.schema() -> T.Schema: Name.schema(Name_ContributionAndProof{})
def ContributionAndProof.to_ssz(v: ContributionAndProof) -> T.Value: Name.to_ssz(Name_ContributionAndProof{}, v)
def ContributionAndProof.from_ssz(v: T.Value) -> Maybe<&2, ContributionAndProof>: Name.from_ssz(Name_ContributionAndProof{}, v)
def ContributionAndProof.valid(v: ContributionAndProof) -> Bool: Name.valid(Name_ContributionAndProof{}, v)
def ContributionAndProof.serialize(v: ContributionAndProof) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ContributionAndProof{}, v)
def ContributionAndProof.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ContributionAndProof>: Name.decode_result(Name_ContributionAndProof{}, result)
def ContributionAndProof.deserialize(xs: +List<U32>) -> Maybe<&2, ContributionAndProof>: Name.deserialize(Name_ContributionAndProof{}, xs)
def ContributionAndProof.hash_tree_root(v: ContributionAndProof) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ContributionAndProof{}, v)
# ContributionAndProof, primary compact API: packed buffer in, view / packed bytes / digest out.
def ContributionAndProof.compact() -> CS.CS: Compact.ContributionAndProof()
def ContributionAndProof.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ContributionAndProof(), size, buf)
def ContributionAndProof.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ContributionAndProof.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ContributionAndProof(), v, buf)

def SignedContributionAndProof.schema() -> T.Schema: Name.schema(Name_SignedContributionAndProof{})
def SignedContributionAndProof.to_ssz(v: SignedContributionAndProof) -> T.Value: Name.to_ssz(Name_SignedContributionAndProof{}, v)
def SignedContributionAndProof.from_ssz(v: T.Value) -> Maybe<&2, SignedContributionAndProof>: Name.from_ssz(Name_SignedContributionAndProof{}, v)
def SignedContributionAndProof.valid(v: SignedContributionAndProof) -> Bool: Name.valid(Name_SignedContributionAndProof{}, v)
def SignedContributionAndProof.serialize(v: SignedContributionAndProof) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SignedContributionAndProof{}, v)
def SignedContributionAndProof.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SignedContributionAndProof>: Name.decode_result(Name_SignedContributionAndProof{}, result)
def SignedContributionAndProof.deserialize(xs: +List<U32>) -> Maybe<&2, SignedContributionAndProof>: Name.deserialize(Name_SignedContributionAndProof{}, xs)
def SignedContributionAndProof.hash_tree_root(v: SignedContributionAndProof) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SignedContributionAndProof{}, v)
# SignedContributionAndProof, primary compact API: packed buffer in, view / packed bytes / digest out.
def SignedContributionAndProof.compact() -> CS.CS: Compact.SignedContributionAndProof()
def SignedContributionAndProof.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SignedContributionAndProof(), size, buf)
def SignedContributionAndProof.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SignedContributionAndProof.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SignedContributionAndProof(), v, buf)

def SyncCommitteeMessage.schema() -> T.Schema: Name.schema(Name_SyncCommitteeMessage{})
def SyncCommitteeMessage.to_ssz(v: SyncCommitteeMessage) -> T.Value: Name.to_ssz(Name_SyncCommitteeMessage{}, v)
def SyncCommitteeMessage.from_ssz(v: T.Value) -> Maybe<&2, SyncCommitteeMessage>: Name.from_ssz(Name_SyncCommitteeMessage{}, v)
def SyncCommitteeMessage.valid(v: SyncCommitteeMessage) -> Bool: Name.valid(Name_SyncCommitteeMessage{}, v)
def SyncCommitteeMessage.serialize(v: SyncCommitteeMessage) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SyncCommitteeMessage{}, v)
def SyncCommitteeMessage.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SyncCommitteeMessage>: Name.decode_result(Name_SyncCommitteeMessage{}, result)
def SyncCommitteeMessage.deserialize(xs: +List<U32>) -> Maybe<&2, SyncCommitteeMessage>: Name.deserialize(Name_SyncCommitteeMessage{}, xs)
def SyncCommitteeMessage.hash_tree_root(v: SyncCommitteeMessage) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SyncCommitteeMessage{}, v)
# SyncCommitteeMessage, primary compact API: packed buffer in, view / packed bytes / digest out.
def SyncCommitteeMessage.compact() -> CS.CS: Compact.SyncCommitteeMessage()
def SyncCommitteeMessage.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SyncCommitteeMessage(), size, buf)
def SyncCommitteeMessage.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SyncCommitteeMessage.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SyncCommitteeMessage(), v, buf)

def Eth1Block.schema() -> T.Schema: Name.schema(Name_Eth1Block{})
def Eth1Block.to_ssz(v: Eth1Block) -> T.Value: Name.to_ssz(Name_Eth1Block{}, v)
def Eth1Block.from_ssz(v: T.Value) -> Maybe<&2, Eth1Block>: Name.from_ssz(Name_Eth1Block{}, v)
def Eth1Block.valid(v: Eth1Block) -> Bool: Name.valid(Name_Eth1Block{}, v)
def Eth1Block.serialize(v: Eth1Block) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Eth1Block{}, v)
def Eth1Block.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Eth1Block>: Name.decode_result(Name_Eth1Block{}, result)
def Eth1Block.deserialize(xs: +List<U32>) -> Maybe<&2, Eth1Block>: Name.deserialize(Name_Eth1Block{}, xs)
def Eth1Block.hash_tree_root(v: Eth1Block) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Eth1Block{}, v)
# Eth1Block, primary compact API: packed buffer in, view / packed bytes / digest out.
def Eth1Block.compact() -> CS.CS: Compact.Eth1Block()
def Eth1Block.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Eth1Block(), size, buf)
def Eth1Block.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Eth1Block.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Eth1Block(), v, buf)

def BeaconBlockHeader.schema() -> T.Schema: Name.schema(Name_BeaconBlockHeader{})
def BeaconBlockHeader.to_ssz(v: BeaconBlockHeader) -> T.Value: Name.to_ssz(Name_BeaconBlockHeader{}, v)
def BeaconBlockHeader.from_ssz(v: T.Value) -> Maybe<&2, BeaconBlockHeader>: Name.from_ssz(Name_BeaconBlockHeader{}, v)
def BeaconBlockHeader.valid(v: BeaconBlockHeader) -> Bool: Name.valid(Name_BeaconBlockHeader{}, v)
def BeaconBlockHeader.serialize(v: BeaconBlockHeader) -> Maybe<&2, +List<U32>>: Name.serialize(Name_BeaconBlockHeader{}, v)
def BeaconBlockHeader.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, BeaconBlockHeader>: Name.decode_result(Name_BeaconBlockHeader{}, result)
def BeaconBlockHeader.deserialize(xs: +List<U32>) -> Maybe<&2, BeaconBlockHeader>: Name.deserialize(Name_BeaconBlockHeader{}, xs)
def BeaconBlockHeader.hash_tree_root(v: BeaconBlockHeader) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_BeaconBlockHeader{}, v)
# BeaconBlockHeader, primary compact API: packed buffer in, view / packed bytes / digest out.
def BeaconBlockHeader.compact() -> CS.CS: Compact.BeaconBlockHeader()
def BeaconBlockHeader.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.BeaconBlockHeader(), size, buf)
def BeaconBlockHeader.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def BeaconBlockHeader.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.BeaconBlockHeader(), v, buf)

def SignedBeaconBlockHeader.schema() -> T.Schema: Name.schema(Name_SignedBeaconBlockHeader{})
def SignedBeaconBlockHeader.to_ssz(v: SignedBeaconBlockHeader) -> T.Value: Name.to_ssz(Name_SignedBeaconBlockHeader{}, v)
def SignedBeaconBlockHeader.from_ssz(v: T.Value) -> Maybe<&2, SignedBeaconBlockHeader>: Name.from_ssz(Name_SignedBeaconBlockHeader{}, v)
def SignedBeaconBlockHeader.valid(v: SignedBeaconBlockHeader) -> Bool: Name.valid(Name_SignedBeaconBlockHeader{}, v)
def SignedBeaconBlockHeader.serialize(v: SignedBeaconBlockHeader) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SignedBeaconBlockHeader{}, v)
def SignedBeaconBlockHeader.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SignedBeaconBlockHeader>: Name.decode_result(Name_SignedBeaconBlockHeader{}, result)
def SignedBeaconBlockHeader.deserialize(xs: +List<U32>) -> Maybe<&2, SignedBeaconBlockHeader>: Name.deserialize(Name_SignedBeaconBlockHeader{}, xs)
def SignedBeaconBlockHeader.hash_tree_root(v: SignedBeaconBlockHeader) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SignedBeaconBlockHeader{}, v)
# SignedBeaconBlockHeader, primary compact API: packed buffer in, view / packed bytes / digest out.
def SignedBeaconBlockHeader.compact() -> CS.CS: Compact.SignedBeaconBlockHeader()
def SignedBeaconBlockHeader.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SignedBeaconBlockHeader(), size, buf)
def SignedBeaconBlockHeader.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SignedBeaconBlockHeader.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SignedBeaconBlockHeader(), v, buf)

def ProposerSlashing.schema() -> T.Schema: Name.schema(Name_ProposerSlashing{})
def ProposerSlashing.to_ssz(v: ProposerSlashing) -> T.Value: Name.to_ssz(Name_ProposerSlashing{}, v)
def ProposerSlashing.from_ssz(v: T.Value) -> Maybe<&2, ProposerSlashing>: Name.from_ssz(Name_ProposerSlashing{}, v)
def ProposerSlashing.valid(v: ProposerSlashing) -> Bool: Name.valid(Name_ProposerSlashing{}, v)
def ProposerSlashing.serialize(v: ProposerSlashing) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ProposerSlashing{}, v)
def ProposerSlashing.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ProposerSlashing>: Name.decode_result(Name_ProposerSlashing{}, result)
def ProposerSlashing.deserialize(xs: +List<U32>) -> Maybe<&2, ProposerSlashing>: Name.deserialize(Name_ProposerSlashing{}, xs)
def ProposerSlashing.hash_tree_root(v: ProposerSlashing) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ProposerSlashing{}, v)
# ProposerSlashing, primary compact API: packed buffer in, view / packed bytes / digest out.
def ProposerSlashing.compact() -> CS.CS: Compact.ProposerSlashing()
def ProposerSlashing.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ProposerSlashing(), size, buf)
def ProposerSlashing.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ProposerSlashing.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ProposerSlashing(), v, buf)

def HistoricalBatch.schema() -> T.Schema: Name.schema(Name_HistoricalBatch{})
def HistoricalBatch.to_ssz(v: HistoricalBatch) -> T.Value: Name.to_ssz(Name_HistoricalBatch{}, v)
def HistoricalBatch.from_ssz(v: T.Value) -> Maybe<&2, HistoricalBatch>: Name.from_ssz(Name_HistoricalBatch{}, v)
def HistoricalBatch.valid(v: HistoricalBatch) -> Bool: Name.valid(Name_HistoricalBatch{}, v)
def HistoricalBatch.serialize(v: HistoricalBatch) -> Maybe<&2, +List<U32>>: Name.serialize(Name_HistoricalBatch{}, v)
def HistoricalBatch.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, HistoricalBatch>: Name.decode_result(Name_HistoricalBatch{}, result)
def HistoricalBatch.deserialize(xs: +List<U32>) -> Maybe<&2, HistoricalBatch>: Name.deserialize(Name_HistoricalBatch{}, xs)
def HistoricalBatch.hash_tree_root(v: HistoricalBatch) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_HistoricalBatch{}, v)
# HistoricalBatch, primary compact API: packed buffer in, view / packed bytes / digest out.
def HistoricalBatch.compact() -> CS.CS: Compact.HistoricalBatch()
def HistoricalBatch.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.HistoricalBatch(), size, buf)
def HistoricalBatch.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def HistoricalBatch.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.HistoricalBatch(), v, buf)

def Eth1Data.schema() -> T.Schema: Name.schema(Name_Eth1Data{})
def Eth1Data.to_ssz(v: Eth1Data) -> T.Value: Name.to_ssz(Name_Eth1Data{}, v)
def Eth1Data.from_ssz(v: T.Value) -> Maybe<&2, Eth1Data>: Name.from_ssz(Name_Eth1Data{}, v)
def Eth1Data.valid(v: Eth1Data) -> Bool: Name.valid(Name_Eth1Data{}, v)
def Eth1Data.serialize(v: Eth1Data) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Eth1Data{}, v)
def Eth1Data.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Eth1Data>: Name.decode_result(Name_Eth1Data{}, result)
def Eth1Data.deserialize(xs: +List<U32>) -> Maybe<&2, Eth1Data>: Name.deserialize(Name_Eth1Data{}, xs)
def Eth1Data.hash_tree_root(v: Eth1Data) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Eth1Data{}, v)
# Eth1Data, primary compact API: packed buffer in, view / packed bytes / digest out.
def Eth1Data.compact() -> CS.CS: Compact.Eth1Data()
def Eth1Data.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Eth1Data(), size, buf)
def Eth1Data.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Eth1Data.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Eth1Data(), v, buf)

def Checkpoint.schema() -> T.Schema: Name.schema(Name_Checkpoint{})
def Checkpoint.to_ssz(v: Checkpoint) -> T.Value: Name.to_ssz(Name_Checkpoint{}, v)
def Checkpoint.from_ssz(v: T.Value) -> Maybe<&2, Checkpoint>: Name.from_ssz(Name_Checkpoint{}, v)
def Checkpoint.valid(v: Checkpoint) -> Bool: Name.valid(Name_Checkpoint{}, v)
def Checkpoint.serialize(v: Checkpoint) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Checkpoint{}, v)
def Checkpoint.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Checkpoint>: Name.decode_result(Name_Checkpoint{}, result)
def Checkpoint.deserialize(xs: +List<U32>) -> Maybe<&2, Checkpoint>: Name.deserialize(Name_Checkpoint{}, xs)
def Checkpoint.hash_tree_root(v: Checkpoint) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Checkpoint{}, v)
# Checkpoint, primary compact API: packed buffer in, view / packed bytes / digest out.
def Checkpoint.compact() -> CS.CS: Compact.Checkpoint()
def Checkpoint.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Checkpoint(), size, buf)
def Checkpoint.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Checkpoint.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Checkpoint(), v, buf)

def AttestationData.schema() -> T.Schema: Name.schema(Name_AttestationData{})
def AttestationData.to_ssz(v: AttestationData) -> T.Value: Name.to_ssz(Name_AttestationData{}, v)
def AttestationData.from_ssz(v: T.Value) -> Maybe<&2, AttestationData>: Name.from_ssz(Name_AttestationData{}, v)
def AttestationData.valid(v: AttestationData) -> Bool: Name.valid(Name_AttestationData{}, v)
def AttestationData.serialize(v: AttestationData) -> Maybe<&2, +List<U32>>: Name.serialize(Name_AttestationData{}, v)
def AttestationData.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, AttestationData>: Name.decode_result(Name_AttestationData{}, result)
def AttestationData.deserialize(xs: +List<U32>) -> Maybe<&2, AttestationData>: Name.deserialize(Name_AttestationData{}, xs)
def AttestationData.hash_tree_root(v: AttestationData) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_AttestationData{}, v)
# AttestationData, primary compact API: packed buffer in, view / packed bytes / digest out.
def AttestationData.compact() -> CS.CS: Compact.AttestationData()
def AttestationData.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.AttestationData(), size, buf)
def AttestationData.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def AttestationData.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.AttestationData(), v, buf)

def SingleAttestation.schema() -> T.Schema: Name.schema(Name_SingleAttestation{})
def SingleAttestation.to_ssz(v: SingleAttestation) -> T.Value: Name.to_ssz(Name_SingleAttestation{}, v)
def SingleAttestation.from_ssz(v: T.Value) -> Maybe<&2, SingleAttestation>: Name.from_ssz(Name_SingleAttestation{}, v)
def SingleAttestation.valid(v: SingleAttestation) -> Bool: Name.valid(Name_SingleAttestation{}, v)
def SingleAttestation.serialize(v: SingleAttestation) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SingleAttestation{}, v)
def SingleAttestation.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SingleAttestation>: Name.decode_result(Name_SingleAttestation{}, result)
def SingleAttestation.deserialize(xs: +List<U32>) -> Maybe<&2, SingleAttestation>: Name.deserialize(Name_SingleAttestation{}, xs)
def SingleAttestation.hash_tree_root(v: SingleAttestation) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SingleAttestation{}, v)
# SingleAttestation, primary compact API: packed buffer in, view / packed bytes / digest out.
def SingleAttestation.compact() -> CS.CS: Compact.SingleAttestation()
def SingleAttestation.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SingleAttestation(), size, buf)
def SingleAttestation.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SingleAttestation.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SingleAttestation(), v, buf)

def Attestation.schema() -> T.Schema: Name.schema(Name_Attestation{})
def Attestation.to_ssz(v: Attestation) -> T.Value: Name.to_ssz(Name_Attestation{}, v)
def Attestation.from_ssz(v: T.Value) -> Maybe<&2, Attestation>: Name.from_ssz(Name_Attestation{}, v)
def Attestation.valid(v: Attestation) -> Bool: Name.valid(Name_Attestation{}, v)
def Attestation.serialize(v: Attestation) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Attestation{}, v)
def Attestation.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Attestation>: Name.decode_result(Name_Attestation{}, result)
def Attestation.deserialize(xs: +List<U32>) -> Maybe<&2, Attestation>: Name.deserialize(Name_Attestation{}, xs)
def Attestation.hash_tree_root(v: Attestation) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Attestation{}, v)
# Attestation, primary compact API: packed buffer in, view / packed bytes / digest out.
def Attestation.compact() -> CS.CS: Compact.Attestation()
def Attestation.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Attestation(), size, buf)
def Attestation.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Attestation.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Attestation(), v, buf)

def AggregateAndProof.schema() -> T.Schema: Name.schema(Name_AggregateAndProof{})
def AggregateAndProof.to_ssz(v: AggregateAndProof) -> T.Value: Name.to_ssz(Name_AggregateAndProof{}, v)
def AggregateAndProof.from_ssz(v: T.Value) -> Maybe<&2, AggregateAndProof>: Name.from_ssz(Name_AggregateAndProof{}, v)
def AggregateAndProof.valid(v: AggregateAndProof) -> Bool: Name.valid(Name_AggregateAndProof{}, v)
def AggregateAndProof.serialize(v: AggregateAndProof) -> Maybe<&2, +List<U32>>: Name.serialize(Name_AggregateAndProof{}, v)
def AggregateAndProof.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, AggregateAndProof>: Name.decode_result(Name_AggregateAndProof{}, result)
def AggregateAndProof.deserialize(xs: +List<U32>) -> Maybe<&2, AggregateAndProof>: Name.deserialize(Name_AggregateAndProof{}, xs)
def AggregateAndProof.hash_tree_root(v: AggregateAndProof) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_AggregateAndProof{}, v)
# AggregateAndProof, primary compact API: packed buffer in, view / packed bytes / digest out.
def AggregateAndProof.compact() -> CS.CS: Compact.AggregateAndProof()
def AggregateAndProof.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.AggregateAndProof(), size, buf)
def AggregateAndProof.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def AggregateAndProof.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.AggregateAndProof(), v, buf)

def SignedAggregateAndProof.schema() -> T.Schema: Name.schema(Name_SignedAggregateAndProof{})
def SignedAggregateAndProof.to_ssz(v: SignedAggregateAndProof) -> T.Value: Name.to_ssz(Name_SignedAggregateAndProof{}, v)
def SignedAggregateAndProof.from_ssz(v: T.Value) -> Maybe<&2, SignedAggregateAndProof>: Name.from_ssz(Name_SignedAggregateAndProof{}, v)
def SignedAggregateAndProof.valid(v: SignedAggregateAndProof) -> Bool: Name.valid(Name_SignedAggregateAndProof{}, v)
def SignedAggregateAndProof.serialize(v: SignedAggregateAndProof) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SignedAggregateAndProof{}, v)
def SignedAggregateAndProof.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SignedAggregateAndProof>: Name.decode_result(Name_SignedAggregateAndProof{}, result)
def SignedAggregateAndProof.deserialize(xs: +List<U32>) -> Maybe<&2, SignedAggregateAndProof>: Name.deserialize(Name_SignedAggregateAndProof{}, xs)
def SignedAggregateAndProof.hash_tree_root(v: SignedAggregateAndProof) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SignedAggregateAndProof{}, v)
# SignedAggregateAndProof, primary compact API: packed buffer in, view / packed bytes / digest out.
def SignedAggregateAndProof.compact() -> CS.CS: Compact.SignedAggregateAndProof()
def SignedAggregateAndProof.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SignedAggregateAndProof(), size, buf)
def SignedAggregateAndProof.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SignedAggregateAndProof.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SignedAggregateAndProof(), v, buf)

def PendingAttestation.schema() -> T.Schema: Name.schema(Name_PendingAttestation{})
def PendingAttestation.to_ssz(v: PendingAttestation) -> T.Value: Name.to_ssz(Name_PendingAttestation{}, v)
def PendingAttestation.from_ssz(v: T.Value) -> Maybe<&2, PendingAttestation>: Name.from_ssz(Name_PendingAttestation{}, v)
def PendingAttestation.valid(v: PendingAttestation) -> Bool: Name.valid(Name_PendingAttestation{}, v)
def PendingAttestation.serialize(v: PendingAttestation) -> Maybe<&2, +List<U32>>: Name.serialize(Name_PendingAttestation{}, v)
def PendingAttestation.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, PendingAttestation>: Name.decode_result(Name_PendingAttestation{}, result)
def PendingAttestation.deserialize(xs: +List<U32>) -> Maybe<&2, PendingAttestation>: Name.deserialize(Name_PendingAttestation{}, xs)
def PendingAttestation.hash_tree_root(v: PendingAttestation) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_PendingAttestation{}, v)
# PendingAttestation, primary compact API: packed buffer in, view / packed bytes / digest out.
def PendingAttestation.compact() -> CS.CS: Compact.PendingAttestation()
def PendingAttestation.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.PendingAttestation(), size, buf)
def PendingAttestation.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def PendingAttestation.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.PendingAttestation(), v, buf)

def IndexedAttestation.schema() -> T.Schema: Name.schema(Name_IndexedAttestation{})
def IndexedAttestation.to_ssz(v: IndexedAttestation) -> T.Value: Name.to_ssz(Name_IndexedAttestation{}, v)
def IndexedAttestation.from_ssz(v: T.Value) -> Maybe<&2, IndexedAttestation>: Name.from_ssz(Name_IndexedAttestation{}, v)
def IndexedAttestation.valid(v: IndexedAttestation) -> Bool: Name.valid(Name_IndexedAttestation{}, v)
def IndexedAttestation.serialize(v: IndexedAttestation) -> Maybe<&2, +List<U32>>: Name.serialize(Name_IndexedAttestation{}, v)
def IndexedAttestation.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, IndexedAttestation>: Name.decode_result(Name_IndexedAttestation{}, result)
def IndexedAttestation.deserialize(xs: +List<U32>) -> Maybe<&2, IndexedAttestation>: Name.deserialize(Name_IndexedAttestation{}, xs)
def IndexedAttestation.hash_tree_root(v: IndexedAttestation) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_IndexedAttestation{}, v)
# IndexedAttestation, primary compact API: packed buffer in, view / packed bytes / digest out.
def IndexedAttestation.compact() -> CS.CS: Compact.IndexedAttestation()
def IndexedAttestation.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.IndexedAttestation(), size, buf)
def IndexedAttestation.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def IndexedAttestation.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.IndexedAttestation(), v, buf)

def AttesterSlashing.schema() -> T.Schema: Name.schema(Name_AttesterSlashing{})
def AttesterSlashing.to_ssz(v: AttesterSlashing) -> T.Value: Name.to_ssz(Name_AttesterSlashing{}, v)
def AttesterSlashing.from_ssz(v: T.Value) -> Maybe<&2, AttesterSlashing>: Name.from_ssz(Name_AttesterSlashing{}, v)
def AttesterSlashing.valid(v: AttesterSlashing) -> Bool: Name.valid(Name_AttesterSlashing{}, v)
def AttesterSlashing.serialize(v: AttesterSlashing) -> Maybe<&2, +List<U32>>: Name.serialize(Name_AttesterSlashing{}, v)
def AttesterSlashing.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, AttesterSlashing>: Name.decode_result(Name_AttesterSlashing{}, result)
def AttesterSlashing.deserialize(xs: +List<U32>) -> Maybe<&2, AttesterSlashing>: Name.deserialize(Name_AttesterSlashing{}, xs)
def AttesterSlashing.hash_tree_root(v: AttesterSlashing) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_AttesterSlashing{}, v)
# AttesterSlashing, primary compact API: packed buffer in, view / packed bytes / digest out.
def AttesterSlashing.compact() -> CS.CS: Compact.AttesterSlashing()
def AttesterSlashing.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.AttesterSlashing(), size, buf)
def AttesterSlashing.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def AttesterSlashing.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.AttesterSlashing(), v, buf)

def ForkData.schema() -> T.Schema: Name.schema(Name_ForkData{})
def ForkData.to_ssz(v: ForkData) -> T.Value: Name.to_ssz(Name_ForkData{}, v)
def ForkData.from_ssz(v: T.Value) -> Maybe<&2, ForkData>: Name.from_ssz(Name_ForkData{}, v)
def ForkData.valid(v: ForkData) -> Bool: Name.valid(Name_ForkData{}, v)
def ForkData.serialize(v: ForkData) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ForkData{}, v)
def ForkData.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ForkData>: Name.decode_result(Name_ForkData{}, result)
def ForkData.deserialize(xs: +List<U32>) -> Maybe<&2, ForkData>: Name.deserialize(Name_ForkData{}, xs)
def ForkData.hash_tree_root(v: ForkData) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ForkData{}, v)
# ForkData, primary compact API: packed buffer in, view / packed bytes / digest out.
def ForkData.compact() -> CS.CS: Compact.ForkData()
def ForkData.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ForkData(), size, buf)
def ForkData.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ForkData.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ForkData(), v, buf)

def ForkDigest() -> Data: Node6()
def ForkDigest.schema() -> T.Schema: Name.schema(Name_ForkDigest{})
def ForkDigest.to_ssz(v: ForkDigest()) -> T.Value: Name.to_ssz(Name_ForkDigest{}, v)
def ForkDigest.from_ssz(v: T.Value) -> Maybe<&2, ForkDigest()>: Name.from_ssz(Name_ForkDigest{}, v)
def ForkDigest.valid(v: ForkDigest()) -> Bool: Name.valid(Name_ForkDigest{}, v)
def ForkDigest.serialize(v: ForkDigest()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ForkDigest{}, v)
def ForkDigest.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ForkDigest()>: Name.decode_result(Name_ForkDigest{}, result)
def ForkDigest.deserialize(xs: +List<U32>) -> Maybe<&2, ForkDigest()>: Name.deserialize(Name_ForkDigest{}, xs)
def ForkDigest.hash_tree_root(v: ForkDigest()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ForkDigest{}, v)
# ForkDigest, primary compact API: packed buffer in, view / packed bytes / digest out.
def ForkDigest.compact() -> CS.CS: Compact.ForkDigest()
def ForkDigest.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ForkDigest(), size, buf)
def ForkDigest.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ForkDigest.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ForkDigest(), v, buf)

def Domain() -> Data: Node7()
def Domain.schema() -> T.Schema: Name.schema(Name_Domain{})
def Domain.to_ssz(v: Domain()) -> T.Value: Name.to_ssz(Name_Domain{}, v)
def Domain.from_ssz(v: T.Value) -> Maybe<&2, Domain()>: Name.from_ssz(Name_Domain{}, v)
def Domain.valid(v: Domain()) -> Bool: Name.valid(Name_Domain{}, v)
def Domain.serialize(v: Domain()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Domain{}, v)
def Domain.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Domain()>: Name.decode_result(Name_Domain{}, result)
def Domain.deserialize(xs: +List<U32>) -> Maybe<&2, Domain()>: Name.deserialize(Name_Domain{}, xs)
def Domain.hash_tree_root(v: Domain()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Domain{}, v)
# Domain, primary compact API: packed buffer in, view / packed bytes / digest out.
def Domain.compact() -> CS.CS: Compact.Domain()
def Domain.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Domain(), size, buf)
def Domain.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Domain.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Domain(), v, buf)

def SigningData.schema() -> T.Schema: Name.schema(Name_SigningData{})
def SigningData.to_ssz(v: SigningData) -> T.Value: Name.to_ssz(Name_SigningData{}, v)
def SigningData.from_ssz(v: T.Value) -> Maybe<&2, SigningData>: Name.from_ssz(Name_SigningData{}, v)
def SigningData.valid(v: SigningData) -> Bool: Name.valid(Name_SigningData{}, v)
def SigningData.serialize(v: SigningData) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SigningData{}, v)
def SigningData.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SigningData>: Name.decode_result(Name_SigningData{}, result)
def SigningData.deserialize(xs: +List<U32>) -> Maybe<&2, SigningData>: Name.deserialize(Name_SigningData{}, xs)
def SigningData.hash_tree_root(v: SigningData) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SigningData{}, v)
# SigningData, primary compact API: packed buffer in, view / packed bytes / digest out.
def SigningData.compact() -> CS.CS: Compact.SigningData()
def SigningData.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SigningData(), size, buf)
def SigningData.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SigningData.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SigningData(), v, buf)

def BLSPubkey() -> Data: Node8()
def BLSPubkey.schema() -> T.Schema: Name.schema(Name_BLSPubkey{})
def BLSPubkey.to_ssz(v: BLSPubkey()) -> T.Value: Name.to_ssz(Name_BLSPubkey{}, v)
def BLSPubkey.from_ssz(v: T.Value) -> Maybe<&2, BLSPubkey()>: Name.from_ssz(Name_BLSPubkey{}, v)
def BLSPubkey.valid(v: BLSPubkey()) -> Bool: Name.valid(Name_BLSPubkey{}, v)
def BLSPubkey.serialize(v: BLSPubkey()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_BLSPubkey{}, v)
def BLSPubkey.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, BLSPubkey()>: Name.decode_result(Name_BLSPubkey{}, result)
def BLSPubkey.deserialize(xs: +List<U32>) -> Maybe<&2, BLSPubkey()>: Name.deserialize(Name_BLSPubkey{}, xs)
def BLSPubkey.hash_tree_root(v: BLSPubkey()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_BLSPubkey{}, v)
# BLSPubkey, primary compact API: packed buffer in, view / packed bytes / digest out.
def BLSPubkey.compact() -> CS.CS: Compact.BLSPubkey()
def BLSPubkey.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.BLSPubkey(), size, buf)
def BLSPubkey.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def BLSPubkey.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.BLSPubkey(), v, buf)

def DepositRequest.schema() -> T.Schema: Name.schema(Name_DepositRequest{})
def DepositRequest.to_ssz(v: DepositRequest) -> T.Value: Name.to_ssz(Name_DepositRequest{}, v)
def DepositRequest.from_ssz(v: T.Value) -> Maybe<&2, DepositRequest>: Name.from_ssz(Name_DepositRequest{}, v)
def DepositRequest.valid(v: DepositRequest) -> Bool: Name.valid(Name_DepositRequest{}, v)
def DepositRequest.serialize(v: DepositRequest) -> Maybe<&2, +List<U32>>: Name.serialize(Name_DepositRequest{}, v)
def DepositRequest.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, DepositRequest>: Name.decode_result(Name_DepositRequest{}, result)
def DepositRequest.deserialize(xs: +List<U32>) -> Maybe<&2, DepositRequest>: Name.deserialize(Name_DepositRequest{}, xs)
def DepositRequest.hash_tree_root(v: DepositRequest) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_DepositRequest{}, v)
# DepositRequest, primary compact API: packed buffer in, view / packed bytes / digest out.
def DepositRequest.compact() -> CS.CS: Compact.DepositRequest()
def DepositRequest.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.DepositRequest(), size, buf)
def DepositRequest.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def DepositRequest.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.DepositRequest(), v, buf)

def PendingDeposit.schema() -> T.Schema: Name.schema(Name_PendingDeposit{})
def PendingDeposit.to_ssz(v: PendingDeposit) -> T.Value: Name.to_ssz(Name_PendingDeposit{}, v)
def PendingDeposit.from_ssz(v: T.Value) -> Maybe<&2, PendingDeposit>: Name.from_ssz(Name_PendingDeposit{}, v)
def PendingDeposit.valid(v: PendingDeposit) -> Bool: Name.valid(Name_PendingDeposit{}, v)
def PendingDeposit.serialize(v: PendingDeposit) -> Maybe<&2, +List<U32>>: Name.serialize(Name_PendingDeposit{}, v)
def PendingDeposit.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, PendingDeposit>: Name.decode_result(Name_PendingDeposit{}, result)
def PendingDeposit.deserialize(xs: +List<U32>) -> Maybe<&2, PendingDeposit>: Name.deserialize(Name_PendingDeposit{}, xs)
def PendingDeposit.hash_tree_root(v: PendingDeposit) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_PendingDeposit{}, v)
# PendingDeposit, primary compact API: packed buffer in, view / packed bytes / digest out.
def PendingDeposit.compact() -> CS.CS: Compact.PendingDeposit()
def PendingDeposit.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.PendingDeposit(), size, buf)
def PendingDeposit.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def PendingDeposit.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.PendingDeposit(), v, buf)

def SyncCommittee.schema() -> T.Schema: Name.schema(Name_SyncCommittee{})
def SyncCommittee.to_ssz(v: SyncCommittee) -> T.Value: Name.to_ssz(Name_SyncCommittee{}, v)
def SyncCommittee.from_ssz(v: T.Value) -> Maybe<&2, SyncCommittee>: Name.from_ssz(Name_SyncCommittee{}, v)
def SyncCommittee.valid(v: SyncCommittee) -> Bool: Name.valid(Name_SyncCommittee{}, v)
def SyncCommittee.serialize(v: SyncCommittee) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SyncCommittee{}, v)
def SyncCommittee.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SyncCommittee>: Name.decode_result(Name_SyncCommittee{}, result)
def SyncCommittee.deserialize(xs: +List<U32>) -> Maybe<&2, SyncCommittee>: Name.deserialize(Name_SyncCommittee{}, xs)
def SyncCommittee.hash_tree_root(v: SyncCommittee) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SyncCommittee{}, v)
# SyncCommittee, primary compact API: packed buffer in, view / packed bytes / digest out.
def SyncCommittee.compact() -> CS.CS: Compact.SyncCommittee()
def SyncCommittee.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SyncCommittee(), size, buf)
def SyncCommittee.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SyncCommittee.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SyncCommittee(), v, buf)

def DepositData.schema() -> T.Schema: Name.schema(Name_DepositData{})
def DepositData.to_ssz(v: DepositData) -> T.Value: Name.to_ssz(Name_DepositData{}, v)
def DepositData.from_ssz(v: T.Value) -> Maybe<&2, DepositData>: Name.from_ssz(Name_DepositData{}, v)
def DepositData.valid(v: DepositData) -> Bool: Name.valid(Name_DepositData{}, v)
def DepositData.serialize(v: DepositData) -> Maybe<&2, +List<U32>>: Name.serialize(Name_DepositData{}, v)
def DepositData.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, DepositData>: Name.decode_result(Name_DepositData{}, result)
def DepositData.deserialize(xs: +List<U32>) -> Maybe<&2, DepositData>: Name.deserialize(Name_DepositData{}, xs)
def DepositData.hash_tree_root(v: DepositData) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_DepositData{}, v)
# DepositData, primary compact API: packed buffer in, view / packed bytes / digest out.
def DepositData.compact() -> CS.CS: Compact.DepositData()
def DepositData.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.DepositData(), size, buf)
def DepositData.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def DepositData.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.DepositData(), v, buf)

def Deposit.schema() -> T.Schema: Name.schema(Name_Deposit{})
def Deposit.to_ssz(v: Deposit) -> T.Value: Name.to_ssz(Name_Deposit{}, v)
def Deposit.from_ssz(v: T.Value) -> Maybe<&2, Deposit>: Name.from_ssz(Name_Deposit{}, v)
def Deposit.valid(v: Deposit) -> Bool: Name.valid(Name_Deposit{}, v)
def Deposit.serialize(v: Deposit) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Deposit{}, v)
def Deposit.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Deposit>: Name.decode_result(Name_Deposit{}, result)
def Deposit.deserialize(xs: +List<U32>) -> Maybe<&2, Deposit>: Name.deserialize(Name_Deposit{}, xs)
def Deposit.hash_tree_root(v: Deposit) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Deposit{}, v)
# Deposit, primary compact API: packed buffer in, view / packed bytes / digest out.
def Deposit.compact() -> CS.CS: Compact.Deposit()
def Deposit.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Deposit(), size, buf)
def Deposit.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Deposit.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Deposit(), v, buf)

def DepositMessage.schema() -> T.Schema: Name.schema(Name_DepositMessage{})
def DepositMessage.to_ssz(v: DepositMessage) -> T.Value: Name.to_ssz(Name_DepositMessage{}, v)
def DepositMessage.from_ssz(v: T.Value) -> Maybe<&2, DepositMessage>: Name.from_ssz(Name_DepositMessage{}, v)
def DepositMessage.valid(v: DepositMessage) -> Bool: Name.valid(Name_DepositMessage{}, v)
def DepositMessage.serialize(v: DepositMessage) -> Maybe<&2, +List<U32>>: Name.serialize(Name_DepositMessage{}, v)
def DepositMessage.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, DepositMessage>: Name.decode_result(Name_DepositMessage{}, result)
def DepositMessage.deserialize(xs: +List<U32>) -> Maybe<&2, DepositMessage>: Name.deserialize(Name_DepositMessage{}, xs)
def DepositMessage.hash_tree_root(v: DepositMessage) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_DepositMessage{}, v)
# DepositMessage, primary compact API: packed buffer in, view / packed bytes / digest out.
def DepositMessage.compact() -> CS.CS: Compact.DepositMessage()
def DepositMessage.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.DepositMessage(), size, buf)
def DepositMessage.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def DepositMessage.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.DepositMessage(), v, buf)

def Validator.schema() -> T.Schema: Name.schema(Name_Validator{})
def Validator.to_ssz(v: Validator) -> T.Value: Name.to_ssz(Name_Validator{}, v)
def Validator.from_ssz(v: T.Value) -> Maybe<&2, Validator>: Name.from_ssz(Name_Validator{}, v)
def Validator.valid(v: Validator) -> Bool: Name.valid(Name_Validator{}, v)
def Validator.serialize(v: Validator) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Validator{}, v)
def Validator.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Validator>: Name.decode_result(Name_Validator{}, result)
def Validator.deserialize(xs: +List<U32>) -> Maybe<&2, Validator>: Name.deserialize(Name_Validator{}, xs)
def Validator.hash_tree_root(v: Validator) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Validator{}, v)
# Validator, primary compact API: packed buffer in, view / packed bytes / digest out.
def Validator.compact() -> CS.CS: Compact.Validator()
def Validator.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Validator(), size, buf)
def Validator.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Validator.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Validator(), v, buf)

def NodeID() -> Data: Node4()
def NodeID.schema() -> T.Schema: Name.schema(Name_NodeID{})
def NodeID.to_ssz(v: NodeID()) -> T.Value: Name.to_ssz(Name_NodeID{}, v)
def NodeID.from_ssz(v: T.Value) -> Maybe<&2, NodeID()>: Name.from_ssz(Name_NodeID{}, v)
def NodeID.valid(v: NodeID()) -> Bool: Name.valid(Name_NodeID{}, v)
def NodeID.serialize(v: NodeID()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_NodeID{}, v)
def NodeID.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, NodeID()>: Name.decode_result(Name_NodeID{}, result)
def NodeID.deserialize(xs: +List<U32>) -> Maybe<&2, NodeID()>: Name.deserialize(Name_NodeID{}, xs)
def NodeID.hash_tree_root(v: NodeID()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_NodeID{}, v)
# NodeID, primary compact API: packed buffer in, view / packed bytes / digest out.
def NodeID.compact() -> CS.CS: Compact.NodeID()
def NodeID.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.NodeID(), size, buf)
def NodeID.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def NodeID.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.NodeID(), v, buf)

def SubnetID() -> Data: Node3()
def SubnetID.schema() -> T.Schema: Name.schema(Name_SubnetID{})
def SubnetID.to_ssz(v: SubnetID()) -> T.Value: Name.to_ssz(Name_SubnetID{}, v)
def SubnetID.from_ssz(v: T.Value) -> Maybe<&2, SubnetID()>: Name.from_ssz(Name_SubnetID{}, v)
def SubnetID.valid(v: SubnetID()) -> Bool: Name.valid(Name_SubnetID{}, v)
def SubnetID.serialize(v: SubnetID()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SubnetID{}, v)
def SubnetID.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SubnetID()>: Name.decode_result(Name_SubnetID{}, result)
def SubnetID.deserialize(xs: +List<U32>) -> Maybe<&2, SubnetID()>: Name.deserialize(Name_SubnetID{}, xs)
def SubnetID.hash_tree_root(v: SubnetID()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SubnetID{}, v)
# SubnetID, primary compact API: packed buffer in, view / packed bytes / digest out.
def SubnetID.compact() -> CS.CS: Compact.SubnetID()
def SubnetID.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SubnetID(), size, buf)
def SubnetID.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SubnetID.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SubnetID(), v, buf)

def Ether() -> Data: Node3()
def Ether.schema() -> T.Schema: Name.schema(Name_Ether{})
def Ether.to_ssz(v: Ether()) -> T.Value: Name.to_ssz(Name_Ether{}, v)
def Ether.from_ssz(v: T.Value) -> Maybe<&2, Ether()>: Name.from_ssz(Name_Ether{}, v)
def Ether.valid(v: Ether()) -> Bool: Name.valid(Name_Ether{}, v)
def Ether.serialize(v: Ether()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Ether{}, v)
def Ether.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Ether()>: Name.decode_result(Name_Ether{}, result)
def Ether.deserialize(xs: +List<U32>) -> Maybe<&2, Ether()>: Name.deserialize(Name_Ether{}, xs)
def Ether.hash_tree_root(v: Ether()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Ether{}, v)
# Ether, primary compact API: packed buffer in, view / packed bytes / digest out.
def Ether.compact() -> CS.CS: Compact.Ether()
def Ether.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Ether(), size, buf)
def Ether.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Ether.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Ether(), v, buf)

def ParticipationFlags() -> Data: Node1()
def ParticipationFlags.schema() -> T.Schema: Name.schema(Name_ParticipationFlags{})
def ParticipationFlags.to_ssz(v: ParticipationFlags()) -> T.Value: Name.to_ssz(Name_ParticipationFlags{}, v)
def ParticipationFlags.from_ssz(v: T.Value) -> Maybe<&2, ParticipationFlags()>: Name.from_ssz(Name_ParticipationFlags{}, v)
def ParticipationFlags.valid(v: ParticipationFlags()) -> Bool: Name.valid(Name_ParticipationFlags{}, v)
def ParticipationFlags.serialize(v: ParticipationFlags()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ParticipationFlags{}, v)
def ParticipationFlags.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ParticipationFlags()>: Name.decode_result(Name_ParticipationFlags{}, result)
def ParticipationFlags.deserialize(xs: +List<U32>) -> Maybe<&2, ParticipationFlags()>: Name.deserialize(Name_ParticipationFlags{}, xs)
def ParticipationFlags.hash_tree_root(v: ParticipationFlags()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ParticipationFlags{}, v)
# ParticipationFlags, primary compact API: packed buffer in, view / packed bytes / digest out.
def ParticipationFlags.compact() -> CS.CS: Compact.ParticipationFlags()
def ParticipationFlags.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ParticipationFlags(), size, buf)
def ParticipationFlags.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ParticipationFlags.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ParticipationFlags(), v, buf)

def CurrentSyncCommitteeBranch() -> Data: Node59()
def CurrentSyncCommitteeBranch.schema() -> T.Schema: Name.schema(Name_CurrentSyncCommitteeBranch{})
def CurrentSyncCommitteeBranch.to_ssz(v: CurrentSyncCommitteeBranch()) -> T.Value: Name.to_ssz(Name_CurrentSyncCommitteeBranch{}, v)
def CurrentSyncCommitteeBranch.from_ssz(v: T.Value) -> Maybe<&2, CurrentSyncCommitteeBranch()>: Name.from_ssz(Name_CurrentSyncCommitteeBranch{}, v)
def CurrentSyncCommitteeBranch.valid(v: CurrentSyncCommitteeBranch()) -> Bool: Name.valid(Name_CurrentSyncCommitteeBranch{}, v)
def CurrentSyncCommitteeBranch.serialize(v: CurrentSyncCommitteeBranch()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_CurrentSyncCommitteeBranch{}, v)
def CurrentSyncCommitteeBranch.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, CurrentSyncCommitteeBranch()>: Name.decode_result(Name_CurrentSyncCommitteeBranch{}, result)
def CurrentSyncCommitteeBranch.deserialize(xs: +List<U32>) -> Maybe<&2, CurrentSyncCommitteeBranch()>: Name.deserialize(Name_CurrentSyncCommitteeBranch{}, xs)
def CurrentSyncCommitteeBranch.hash_tree_root(v: CurrentSyncCommitteeBranch()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_CurrentSyncCommitteeBranch{}, v)
# CurrentSyncCommitteeBranch, primary compact API: packed buffer in, view / packed bytes / digest out.
def CurrentSyncCommitteeBranch.compact() -> CS.CS: Compact.CurrentSyncCommitteeBranch()
def CurrentSyncCommitteeBranch.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.CurrentSyncCommitteeBranch(), size, buf)
def CurrentSyncCommitteeBranch.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def CurrentSyncCommitteeBranch.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.CurrentSyncCommitteeBranch(), v, buf)

def NextSyncCommitteeBranch() -> Data: Node59()
def NextSyncCommitteeBranch.schema() -> T.Schema: Name.schema(Name_NextSyncCommitteeBranch{})
def NextSyncCommitteeBranch.to_ssz(v: NextSyncCommitteeBranch()) -> T.Value: Name.to_ssz(Name_NextSyncCommitteeBranch{}, v)
def NextSyncCommitteeBranch.from_ssz(v: T.Value) -> Maybe<&2, NextSyncCommitteeBranch()>: Name.from_ssz(Name_NextSyncCommitteeBranch{}, v)
def NextSyncCommitteeBranch.valid(v: NextSyncCommitteeBranch()) -> Bool: Name.valid(Name_NextSyncCommitteeBranch{}, v)
def NextSyncCommitteeBranch.serialize(v: NextSyncCommitteeBranch()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_NextSyncCommitteeBranch{}, v)
def NextSyncCommitteeBranch.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, NextSyncCommitteeBranch()>: Name.decode_result(Name_NextSyncCommitteeBranch{}, result)
def NextSyncCommitteeBranch.deserialize(xs: +List<U32>) -> Maybe<&2, NextSyncCommitteeBranch()>: Name.deserialize(Name_NextSyncCommitteeBranch{}, xs)
def NextSyncCommitteeBranch.hash_tree_root(v: NextSyncCommitteeBranch()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_NextSyncCommitteeBranch{}, v)
# NextSyncCommitteeBranch, primary compact API: packed buffer in, view / packed bytes / digest out.
def NextSyncCommitteeBranch.compact() -> CS.CS: Compact.NextSyncCommitteeBranch()
def NextSyncCommitteeBranch.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.NextSyncCommitteeBranch(), size, buf)
def NextSyncCommitteeBranch.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def NextSyncCommitteeBranch.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.NextSyncCommitteeBranch(), v, buf)

def Transaction() -> Data: Node60()
def Transaction.schema() -> T.Schema: Name.schema(Name_Transaction{})
def Transaction.to_ssz(v: Transaction()) -> T.Value: Name.to_ssz(Name_Transaction{}, v)
def Transaction.from_ssz(v: T.Value) -> Maybe<&2, Transaction()>: Name.from_ssz(Name_Transaction{}, v)
def Transaction.valid(v: Transaction()) -> Bool: Name.valid(Name_Transaction{}, v)
def Transaction.serialize(v: Transaction()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Transaction{}, v)
def Transaction.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Transaction()>: Name.decode_result(Name_Transaction{}, result)
def Transaction.deserialize(xs: +List<U32>) -> Maybe<&2, Transaction()>: Name.deserialize(Name_Transaction{}, xs)
def Transaction.hash_tree_root(v: Transaction()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Transaction{}, v)
# Transaction, primary compact API: packed buffer in, view / packed bytes / digest out.
def Transaction.compact() -> CS.CS: Compact.Transaction()
def Transaction.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Transaction(), size, buf)
def Transaction.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Transaction.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Transaction(), v, buf)

def ExecutionAddress() -> Data: Node11()
def ExecutionAddress.schema() -> T.Schema: Name.schema(Name_ExecutionAddress{})
def ExecutionAddress.to_ssz(v: ExecutionAddress()) -> T.Value: Name.to_ssz(Name_ExecutionAddress{}, v)
def ExecutionAddress.from_ssz(v: T.Value) -> Maybe<&2, ExecutionAddress()>: Name.from_ssz(Name_ExecutionAddress{}, v)
def ExecutionAddress.valid(v: ExecutionAddress()) -> Bool: Name.valid(Name_ExecutionAddress{}, v)
def ExecutionAddress.serialize(v: ExecutionAddress()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ExecutionAddress{}, v)
def ExecutionAddress.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ExecutionAddress()>: Name.decode_result(Name_ExecutionAddress{}, result)
def ExecutionAddress.deserialize(xs: +List<U32>) -> Maybe<&2, ExecutionAddress()>: Name.deserialize(Name_ExecutionAddress{}, xs)
def ExecutionAddress.hash_tree_root(v: ExecutionAddress()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ExecutionAddress{}, v)
# ExecutionAddress, primary compact API: packed buffer in, view / packed bytes / digest out.
def ExecutionAddress.compact() -> CS.CS: Compact.ExecutionAddress()
def ExecutionAddress.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ExecutionAddress(), size, buf)
def ExecutionAddress.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ExecutionAddress.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ExecutionAddress(), v, buf)

def ConsolidationRequest.schema() -> T.Schema: Name.schema(Name_ConsolidationRequest{})
def ConsolidationRequest.to_ssz(v: ConsolidationRequest) -> T.Value: Name.to_ssz(Name_ConsolidationRequest{}, v)
def ConsolidationRequest.from_ssz(v: T.Value) -> Maybe<&2, ConsolidationRequest>: Name.from_ssz(Name_ConsolidationRequest{}, v)
def ConsolidationRequest.valid(v: ConsolidationRequest) -> Bool: Name.valid(Name_ConsolidationRequest{}, v)
def ConsolidationRequest.serialize(v: ConsolidationRequest) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ConsolidationRequest{}, v)
def ConsolidationRequest.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ConsolidationRequest>: Name.decode_result(Name_ConsolidationRequest{}, result)
def ConsolidationRequest.deserialize(xs: +List<U32>) -> Maybe<&2, ConsolidationRequest>: Name.deserialize(Name_ConsolidationRequest{}, xs)
def ConsolidationRequest.hash_tree_root(v: ConsolidationRequest) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ConsolidationRequest{}, v)
# ConsolidationRequest, primary compact API: packed buffer in, view / packed bytes / digest out.
def ConsolidationRequest.compact() -> CS.CS: Compact.ConsolidationRequest()
def ConsolidationRequest.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ConsolidationRequest(), size, buf)
def ConsolidationRequest.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ConsolidationRequest.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ConsolidationRequest(), v, buf)

def WithdrawalRequest.schema() -> T.Schema: Name.schema(Name_WithdrawalRequest{})
def WithdrawalRequest.to_ssz(v: WithdrawalRequest) -> T.Value: Name.to_ssz(Name_WithdrawalRequest{}, v)
def WithdrawalRequest.from_ssz(v: T.Value) -> Maybe<&2, WithdrawalRequest>: Name.from_ssz(Name_WithdrawalRequest{}, v)
def WithdrawalRequest.valid(v: WithdrawalRequest) -> Bool: Name.valid(Name_WithdrawalRequest{}, v)
def WithdrawalRequest.serialize(v: WithdrawalRequest) -> Maybe<&2, +List<U32>>: Name.serialize(Name_WithdrawalRequest{}, v)
def WithdrawalRequest.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, WithdrawalRequest>: Name.decode_result(Name_WithdrawalRequest{}, result)
def WithdrawalRequest.deserialize(xs: +List<U32>) -> Maybe<&2, WithdrawalRequest>: Name.deserialize(Name_WithdrawalRequest{}, xs)
def WithdrawalRequest.hash_tree_root(v: WithdrawalRequest) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_WithdrawalRequest{}, v)
# WithdrawalRequest, primary compact API: packed buffer in, view / packed bytes / digest out.
def WithdrawalRequest.compact() -> CS.CS: Compact.WithdrawalRequest()
def WithdrawalRequest.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.WithdrawalRequest(), size, buf)
def WithdrawalRequest.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def WithdrawalRequest.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.WithdrawalRequest(), v, buf)

def ExecutionRequests.schema() -> T.Schema: Name.schema(Name_ExecutionRequests{})
def ExecutionRequests.to_ssz(v: ExecutionRequests) -> T.Value: Name.to_ssz(Name_ExecutionRequests{}, v)
def ExecutionRequests.from_ssz(v: T.Value) -> Maybe<&2, ExecutionRequests>: Name.from_ssz(Name_ExecutionRequests{}, v)
def ExecutionRequests.valid(v: ExecutionRequests) -> Bool: Name.valid(Name_ExecutionRequests{}, v)
def ExecutionRequests.serialize(v: ExecutionRequests) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ExecutionRequests{}, v)
def ExecutionRequests.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ExecutionRequests>: Name.decode_result(Name_ExecutionRequests{}, result)
def ExecutionRequests.deserialize(xs: +List<U32>) -> Maybe<&2, ExecutionRequests>: Name.deserialize(Name_ExecutionRequests{}, xs)
def ExecutionRequests.hash_tree_root(v: ExecutionRequests) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ExecutionRequests{}, v)
# ExecutionRequests, primary compact API: packed buffer in, view / packed bytes / digest out.
def ExecutionRequests.compact() -> CS.CS: Compact.ExecutionRequests()
def ExecutionRequests.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ExecutionRequests(), size, buf)
def ExecutionRequests.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ExecutionRequests.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ExecutionRequests(), v, buf)

def BLSToExecutionChange.schema() -> T.Schema: Name.schema(Name_BLSToExecutionChange{})
def BLSToExecutionChange.to_ssz(v: BLSToExecutionChange) -> T.Value: Name.to_ssz(Name_BLSToExecutionChange{}, v)
def BLSToExecutionChange.from_ssz(v: T.Value) -> Maybe<&2, BLSToExecutionChange>: Name.from_ssz(Name_BLSToExecutionChange{}, v)
def BLSToExecutionChange.valid(v: BLSToExecutionChange) -> Bool: Name.valid(Name_BLSToExecutionChange{}, v)
def BLSToExecutionChange.serialize(v: BLSToExecutionChange) -> Maybe<&2, +List<U32>>: Name.serialize(Name_BLSToExecutionChange{}, v)
def BLSToExecutionChange.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, BLSToExecutionChange>: Name.decode_result(Name_BLSToExecutionChange{}, result)
def BLSToExecutionChange.deserialize(xs: +List<U32>) -> Maybe<&2, BLSToExecutionChange>: Name.deserialize(Name_BLSToExecutionChange{}, xs)
def BLSToExecutionChange.hash_tree_root(v: BLSToExecutionChange) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_BLSToExecutionChange{}, v)
# BLSToExecutionChange, primary compact API: packed buffer in, view / packed bytes / digest out.
def BLSToExecutionChange.compact() -> CS.CS: Compact.BLSToExecutionChange()
def BLSToExecutionChange.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.BLSToExecutionChange(), size, buf)
def BLSToExecutionChange.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def BLSToExecutionChange.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.BLSToExecutionChange(), v, buf)

def SignedBLSToExecutionChange.schema() -> T.Schema: Name.schema(Name_SignedBLSToExecutionChange{})
def SignedBLSToExecutionChange.to_ssz(v: SignedBLSToExecutionChange) -> T.Value: Name.to_ssz(Name_SignedBLSToExecutionChange{}, v)
def SignedBLSToExecutionChange.from_ssz(v: T.Value) -> Maybe<&2, SignedBLSToExecutionChange>: Name.from_ssz(Name_SignedBLSToExecutionChange{}, v)
def SignedBLSToExecutionChange.valid(v: SignedBLSToExecutionChange) -> Bool: Name.valid(Name_SignedBLSToExecutionChange{}, v)
def SignedBLSToExecutionChange.serialize(v: SignedBLSToExecutionChange) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SignedBLSToExecutionChange{}, v)
def SignedBLSToExecutionChange.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SignedBLSToExecutionChange>: Name.decode_result(Name_SignedBLSToExecutionChange{}, result)
def SignedBLSToExecutionChange.deserialize(xs: +List<U32>) -> Maybe<&2, SignedBLSToExecutionChange>: Name.deserialize(Name_SignedBLSToExecutionChange{}, xs)
def SignedBLSToExecutionChange.hash_tree_root(v: SignedBLSToExecutionChange) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SignedBLSToExecutionChange{}, v)
# SignedBLSToExecutionChange, primary compact API: packed buffer in, view / packed bytes / digest out.
def SignedBLSToExecutionChange.compact() -> CS.CS: Compact.SignedBLSToExecutionChange()
def SignedBLSToExecutionChange.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SignedBLSToExecutionChange(), size, buf)
def SignedBLSToExecutionChange.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SignedBLSToExecutionChange.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SignedBLSToExecutionChange(), v, buf)

def ExecutionPayloadHeader.schema() -> T.Schema: Name.schema(Name_ExecutionPayloadHeader{})
def ExecutionPayloadHeader.to_ssz(v: ExecutionPayloadHeader) -> T.Value: Name.to_ssz(Name_ExecutionPayloadHeader{}, v)
def ExecutionPayloadHeader.from_ssz(v: T.Value) -> Maybe<&2, ExecutionPayloadHeader>: Name.from_ssz(Name_ExecutionPayloadHeader{}, v)
def ExecutionPayloadHeader.valid(v: ExecutionPayloadHeader) -> Bool: Name.valid(Name_ExecutionPayloadHeader{}, v)
def ExecutionPayloadHeader.serialize(v: ExecutionPayloadHeader) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ExecutionPayloadHeader{}, v)
def ExecutionPayloadHeader.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ExecutionPayloadHeader>: Name.decode_result(Name_ExecutionPayloadHeader{}, result)
def ExecutionPayloadHeader.deserialize(xs: +List<U32>) -> Maybe<&2, ExecutionPayloadHeader>: Name.deserialize(Name_ExecutionPayloadHeader{}, xs)
def ExecutionPayloadHeader.hash_tree_root(v: ExecutionPayloadHeader) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ExecutionPayloadHeader{}, v)
# ExecutionPayloadHeader, primary compact API: packed buffer in, view / packed bytes / digest out.
def ExecutionPayloadHeader.compact() -> CS.CS: Compact.ExecutionPayloadHeader()
def ExecutionPayloadHeader.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ExecutionPayloadHeader(), size, buf)
def ExecutionPayloadHeader.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ExecutionPayloadHeader.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ExecutionPayloadHeader(), v, buf)

def PayloadId() -> Data: Node10()
def PayloadId.schema() -> T.Schema: Name.schema(Name_PayloadId{})
def PayloadId.to_ssz(v: PayloadId()) -> T.Value: Name.to_ssz(Name_PayloadId{}, v)
def PayloadId.from_ssz(v: T.Value) -> Maybe<&2, PayloadId()>: Name.from_ssz(Name_PayloadId{}, v)
def PayloadId.valid(v: PayloadId()) -> Bool: Name.valid(Name_PayloadId{}, v)
def PayloadId.serialize(v: PayloadId()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_PayloadId{}, v)
def PayloadId.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, PayloadId()>: Name.decode_result(Name_PayloadId{}, result)
def PayloadId.deserialize(xs: +List<U32>) -> Maybe<&2, PayloadId()>: Name.deserialize(Name_PayloadId{}, xs)
def PayloadId.hash_tree_root(v: PayloadId()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_PayloadId{}, v)
# PayloadId, primary compact API: packed buffer in, view / packed bytes / digest out.
def PayloadId.compact() -> CS.CS: Compact.PayloadId()
def PayloadId.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.PayloadId(), size, buf)
def PayloadId.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def PayloadId.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.PayloadId(), v, buf)

def WithdrawalIndex() -> Data: Node3()
def WithdrawalIndex.schema() -> T.Schema: Name.schema(Name_WithdrawalIndex{})
def WithdrawalIndex.to_ssz(v: WithdrawalIndex()) -> T.Value: Name.to_ssz(Name_WithdrawalIndex{}, v)
def WithdrawalIndex.from_ssz(v: T.Value) -> Maybe<&2, WithdrawalIndex()>: Name.from_ssz(Name_WithdrawalIndex{}, v)
def WithdrawalIndex.valid(v: WithdrawalIndex()) -> Bool: Name.valid(Name_WithdrawalIndex{}, v)
def WithdrawalIndex.serialize(v: WithdrawalIndex()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_WithdrawalIndex{}, v)
def WithdrawalIndex.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, WithdrawalIndex()>: Name.decode_result(Name_WithdrawalIndex{}, result)
def WithdrawalIndex.deserialize(xs: +List<U32>) -> Maybe<&2, WithdrawalIndex()>: Name.deserialize(Name_WithdrawalIndex{}, xs)
def WithdrawalIndex.hash_tree_root(v: WithdrawalIndex()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_WithdrawalIndex{}, v)
# WithdrawalIndex, primary compact API: packed buffer in, view / packed bytes / digest out.
def WithdrawalIndex.compact() -> CS.CS: Compact.WithdrawalIndex()
def WithdrawalIndex.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.WithdrawalIndex(), size, buf)
def WithdrawalIndex.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def WithdrawalIndex.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.WithdrawalIndex(), v, buf)

def Withdrawal.schema() -> T.Schema: Name.schema(Name_Withdrawal{})
def Withdrawal.to_ssz(v: Withdrawal) -> T.Value: Name.to_ssz(Name_Withdrawal{}, v)
def Withdrawal.from_ssz(v: T.Value) -> Maybe<&2, Withdrawal>: Name.from_ssz(Name_Withdrawal{}, v)
def Withdrawal.valid(v: Withdrawal) -> Bool: Name.valid(Name_Withdrawal{}, v)
def Withdrawal.serialize(v: Withdrawal) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Withdrawal{}, v)
def Withdrawal.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Withdrawal>: Name.decode_result(Name_Withdrawal{}, result)
def Withdrawal.deserialize(xs: +List<U32>) -> Maybe<&2, Withdrawal>: Name.deserialize(Name_Withdrawal{}, xs)
def Withdrawal.hash_tree_root(v: Withdrawal) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Withdrawal{}, v)
# Withdrawal, primary compact API: packed buffer in, view / packed bytes / digest out.
def Withdrawal.compact() -> CS.CS: Compact.Withdrawal()
def Withdrawal.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Withdrawal(), size, buf)
def Withdrawal.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Withdrawal.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Withdrawal(), v, buf)

def ExecutionPayload.schema() -> T.Schema: Name.schema(Name_ExecutionPayload{})
def ExecutionPayload.to_ssz(v: ExecutionPayload) -> T.Value: Name.to_ssz(Name_ExecutionPayload{}, v)
def ExecutionPayload.from_ssz(v: T.Value) -> Maybe<&2, ExecutionPayload>: Name.from_ssz(Name_ExecutionPayload{}, v)
def ExecutionPayload.valid(v: ExecutionPayload) -> Bool: Name.valid(Name_ExecutionPayload{}, v)
def ExecutionPayload.serialize(v: ExecutionPayload) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ExecutionPayload{}, v)
def ExecutionPayload.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ExecutionPayload>: Name.decode_result(Name_ExecutionPayload{}, result)
def ExecutionPayload.deserialize(xs: +List<U32>) -> Maybe<&2, ExecutionPayload>: Name.deserialize(Name_ExecutionPayload{}, xs)
def ExecutionPayload.hash_tree_root(v: ExecutionPayload) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ExecutionPayload{}, v)
# ExecutionPayload, primary compact API: packed buffer in, view / packed bytes / digest out.
def ExecutionPayload.compact() -> CS.CS: Compact.ExecutionPayload()
def ExecutionPayload.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ExecutionPayload(), size, buf)
def ExecutionPayload.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ExecutionPayload.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ExecutionPayload(), v, buf)

def BeaconState.schema() -> T.Schema: Name.schema(Name_BeaconState{})
def BeaconState.to_ssz(v: BeaconState) -> T.Value: Name.to_ssz(Name_BeaconState{}, v)
def BeaconState.from_ssz(v: T.Value) -> Maybe<&2, BeaconState>: Name.from_ssz(Name_BeaconState{}, v)
def BeaconState.valid(v: BeaconState) -> Bool: Name.valid(Name_BeaconState{}, v)
def BeaconState.serialize(v: BeaconState) -> Maybe<&2, +List<U32>>: Name.serialize(Name_BeaconState{}, v)
def BeaconState.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, BeaconState>: Name.decode_result(Name_BeaconState{}, result)
def BeaconState.deserialize(xs: +List<U32>) -> Maybe<&2, BeaconState>: Name.deserialize(Name_BeaconState{}, xs)
def BeaconState.hash_tree_root(v: BeaconState) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_BeaconState{}, v)
# BeaconState, primary compact API: packed buffer in, view / packed bytes / digest out.
def BeaconState.compact() -> CS.CS: Compact.BeaconState()
def BeaconState.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.BeaconState(), size, buf)
def BeaconState.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def BeaconState.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.BeaconState(), v, buf)

def ExecutionBranch() -> Data: Node90()
def ExecutionBranch.schema() -> T.Schema: Name.schema(Name_ExecutionBranch{})
def ExecutionBranch.to_ssz(v: ExecutionBranch()) -> T.Value: Name.to_ssz(Name_ExecutionBranch{}, v)
def ExecutionBranch.from_ssz(v: T.Value) -> Maybe<&2, ExecutionBranch()>: Name.from_ssz(Name_ExecutionBranch{}, v)
def ExecutionBranch.valid(v: ExecutionBranch()) -> Bool: Name.valid(Name_ExecutionBranch{}, v)
def ExecutionBranch.serialize(v: ExecutionBranch()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ExecutionBranch{}, v)
def ExecutionBranch.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ExecutionBranch()>: Name.decode_result(Name_ExecutionBranch{}, result)
def ExecutionBranch.deserialize(xs: +List<U32>) -> Maybe<&2, ExecutionBranch()>: Name.deserialize(Name_ExecutionBranch{}, xs)
def ExecutionBranch.hash_tree_root(v: ExecutionBranch()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ExecutionBranch{}, v)
# ExecutionBranch, primary compact API: packed buffer in, view / packed bytes / digest out.
def ExecutionBranch.compact() -> CS.CS: Compact.ExecutionBranch()
def ExecutionBranch.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ExecutionBranch(), size, buf)
def ExecutionBranch.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ExecutionBranch.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ExecutionBranch(), v, buf)

def LightClientHeader.schema() -> T.Schema: Name.schema(Name_LightClientHeader{})
def LightClientHeader.to_ssz(v: LightClientHeader) -> T.Value: Name.to_ssz(Name_LightClientHeader{}, v)
def LightClientHeader.from_ssz(v: T.Value) -> Maybe<&2, LightClientHeader>: Name.from_ssz(Name_LightClientHeader{}, v)
def LightClientHeader.valid(v: LightClientHeader) -> Bool: Name.valid(Name_LightClientHeader{}, v)
def LightClientHeader.serialize(v: LightClientHeader) -> Maybe<&2, +List<U32>>: Name.serialize(Name_LightClientHeader{}, v)
def LightClientHeader.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, LightClientHeader>: Name.decode_result(Name_LightClientHeader{}, result)
def LightClientHeader.deserialize(xs: +List<U32>) -> Maybe<&2, LightClientHeader>: Name.deserialize(Name_LightClientHeader{}, xs)
def LightClientHeader.hash_tree_root(v: LightClientHeader) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_LightClientHeader{}, v)
# LightClientHeader, primary compact API: packed buffer in, view / packed bytes / digest out.
def LightClientHeader.compact() -> CS.CS: Compact.LightClientHeader()
def LightClientHeader.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.LightClientHeader(), size, buf)
def LightClientHeader.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def LightClientHeader.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.LightClientHeader(), v, buf)

def LightClientOptimisticUpdate.schema() -> T.Schema: Name.schema(Name_LightClientOptimisticUpdate{})
def LightClientOptimisticUpdate.to_ssz(v: LightClientOptimisticUpdate) -> T.Value: Name.to_ssz(Name_LightClientOptimisticUpdate{}, v)
def LightClientOptimisticUpdate.from_ssz(v: T.Value) -> Maybe<&2, LightClientOptimisticUpdate>: Name.from_ssz(Name_LightClientOptimisticUpdate{}, v)
def LightClientOptimisticUpdate.valid(v: LightClientOptimisticUpdate) -> Bool: Name.valid(Name_LightClientOptimisticUpdate{}, v)
def LightClientOptimisticUpdate.serialize(v: LightClientOptimisticUpdate) -> Maybe<&2, +List<U32>>: Name.serialize(Name_LightClientOptimisticUpdate{}, v)
def LightClientOptimisticUpdate.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, LightClientOptimisticUpdate>: Name.decode_result(Name_LightClientOptimisticUpdate{}, result)
def LightClientOptimisticUpdate.deserialize(xs: +List<U32>) -> Maybe<&2, LightClientOptimisticUpdate>: Name.deserialize(Name_LightClientOptimisticUpdate{}, xs)
def LightClientOptimisticUpdate.hash_tree_root(v: LightClientOptimisticUpdate) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_LightClientOptimisticUpdate{}, v)
# LightClientOptimisticUpdate, primary compact API: packed buffer in, view / packed bytes / digest out.
def LightClientOptimisticUpdate.compact() -> CS.CS: Compact.LightClientOptimisticUpdate()
def LightClientOptimisticUpdate.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.LightClientOptimisticUpdate(), size, buf)
def LightClientOptimisticUpdate.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def LightClientOptimisticUpdate.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.LightClientOptimisticUpdate(), v, buf)

def LightClientFinalityUpdate.schema() -> T.Schema: Name.schema(Name_LightClientFinalityUpdate{})
def LightClientFinalityUpdate.to_ssz(v: LightClientFinalityUpdate) -> T.Value: Name.to_ssz(Name_LightClientFinalityUpdate{}, v)
def LightClientFinalityUpdate.from_ssz(v: T.Value) -> Maybe<&2, LightClientFinalityUpdate>: Name.from_ssz(Name_LightClientFinalityUpdate{}, v)
def LightClientFinalityUpdate.valid(v: LightClientFinalityUpdate) -> Bool: Name.valid(Name_LightClientFinalityUpdate{}, v)
def LightClientFinalityUpdate.serialize(v: LightClientFinalityUpdate) -> Maybe<&2, +List<U32>>: Name.serialize(Name_LightClientFinalityUpdate{}, v)
def LightClientFinalityUpdate.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, LightClientFinalityUpdate>: Name.decode_result(Name_LightClientFinalityUpdate{}, result)
def LightClientFinalityUpdate.deserialize(xs: +List<U32>) -> Maybe<&2, LightClientFinalityUpdate>: Name.deserialize(Name_LightClientFinalityUpdate{}, xs)
def LightClientFinalityUpdate.hash_tree_root(v: LightClientFinalityUpdate) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_LightClientFinalityUpdate{}, v)
# LightClientFinalityUpdate, primary compact API: packed buffer in, view / packed bytes / digest out.
def LightClientFinalityUpdate.compact() -> CS.CS: Compact.LightClientFinalityUpdate()
def LightClientFinalityUpdate.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.LightClientFinalityUpdate(), size, buf)
def LightClientFinalityUpdate.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def LightClientFinalityUpdate.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.LightClientFinalityUpdate(), v, buf)

def LightClientUpdate.schema() -> T.Schema: Name.schema(Name_LightClientUpdate{})
def LightClientUpdate.to_ssz(v: LightClientUpdate) -> T.Value: Name.to_ssz(Name_LightClientUpdate{}, v)
def LightClientUpdate.from_ssz(v: T.Value) -> Maybe<&2, LightClientUpdate>: Name.from_ssz(Name_LightClientUpdate{}, v)
def LightClientUpdate.valid(v: LightClientUpdate) -> Bool: Name.valid(Name_LightClientUpdate{}, v)
def LightClientUpdate.serialize(v: LightClientUpdate) -> Maybe<&2, +List<U32>>: Name.serialize(Name_LightClientUpdate{}, v)
def LightClientUpdate.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, LightClientUpdate>: Name.decode_result(Name_LightClientUpdate{}, result)
def LightClientUpdate.deserialize(xs: +List<U32>) -> Maybe<&2, LightClientUpdate>: Name.deserialize(Name_LightClientUpdate{}, xs)
def LightClientUpdate.hash_tree_root(v: LightClientUpdate) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_LightClientUpdate{}, v)
# LightClientUpdate, primary compact API: packed buffer in, view / packed bytes / digest out.
def LightClientUpdate.compact() -> CS.CS: Compact.LightClientUpdate()
def LightClientUpdate.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.LightClientUpdate(), size, buf)
def LightClientUpdate.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def LightClientUpdate.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.LightClientUpdate(), v, buf)

def LightClientBootstrap.schema() -> T.Schema: Name.schema(Name_LightClientBootstrap{})
def LightClientBootstrap.to_ssz(v: LightClientBootstrap) -> T.Value: Name.to_ssz(Name_LightClientBootstrap{}, v)
def LightClientBootstrap.from_ssz(v: T.Value) -> Maybe<&2, LightClientBootstrap>: Name.from_ssz(Name_LightClientBootstrap{}, v)
def LightClientBootstrap.valid(v: LightClientBootstrap) -> Bool: Name.valid(Name_LightClientBootstrap{}, v)
def LightClientBootstrap.serialize(v: LightClientBootstrap) -> Maybe<&2, +List<U32>>: Name.serialize(Name_LightClientBootstrap{}, v)
def LightClientBootstrap.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, LightClientBootstrap>: Name.decode_result(Name_LightClientBootstrap{}, result)
def LightClientBootstrap.deserialize(xs: +List<U32>) -> Maybe<&2, LightClientBootstrap>: Name.deserialize(Name_LightClientBootstrap{}, xs)
def LightClientBootstrap.hash_tree_root(v: LightClientBootstrap) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_LightClientBootstrap{}, v)
# LightClientBootstrap, primary compact API: packed buffer in, view / packed bytes / digest out.
def LightClientBootstrap.compact() -> CS.CS: Compact.LightClientBootstrap()
def LightClientBootstrap.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.LightClientBootstrap(), size, buf)
def LightClientBootstrap.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def LightClientBootstrap.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.LightClientBootstrap(), v, buf)

def BlobIndex() -> Data: Node3()
def BlobIndex.schema() -> T.Schema: Name.schema(Name_BlobIndex{})
def BlobIndex.to_ssz(v: BlobIndex()) -> T.Value: Name.to_ssz(Name_BlobIndex{}, v)
def BlobIndex.from_ssz(v: T.Value) -> Maybe<&2, BlobIndex()>: Name.from_ssz(Name_BlobIndex{}, v)
def BlobIndex.valid(v: BlobIndex()) -> Bool: Name.valid(Name_BlobIndex{}, v)
def BlobIndex.serialize(v: BlobIndex()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_BlobIndex{}, v)
def BlobIndex.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, BlobIndex()>: Name.decode_result(Name_BlobIndex{}, result)
def BlobIndex.deserialize(xs: +List<U32>) -> Maybe<&2, BlobIndex()>: Name.deserialize(Name_BlobIndex{}, xs)
def BlobIndex.hash_tree_root(v: BlobIndex()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_BlobIndex{}, v)
# BlobIndex, primary compact API: packed buffer in, view / packed bytes / digest out.
def BlobIndex.compact() -> CS.CS: Compact.BlobIndex()
def BlobIndex.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.BlobIndex(), size, buf)
def BlobIndex.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def BlobIndex.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.BlobIndex(), v, buf)

def BlobIdentifier.schema() -> T.Schema: Name.schema(Name_BlobIdentifier{})
def BlobIdentifier.to_ssz(v: BlobIdentifier) -> T.Value: Name.to_ssz(Name_BlobIdentifier{}, v)
def BlobIdentifier.from_ssz(v: T.Value) -> Maybe<&2, BlobIdentifier>: Name.from_ssz(Name_BlobIdentifier{}, v)
def BlobIdentifier.valid(v: BlobIdentifier) -> Bool: Name.valid(Name_BlobIdentifier{}, v)
def BlobIdentifier.serialize(v: BlobIdentifier) -> Maybe<&2, +List<U32>>: Name.serialize(Name_BlobIdentifier{}, v)
def BlobIdentifier.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, BlobIdentifier>: Name.decode_result(Name_BlobIdentifier{}, result)
def BlobIdentifier.deserialize(xs: +List<U32>) -> Maybe<&2, BlobIdentifier>: Name.deserialize(Name_BlobIdentifier{}, xs)
def BlobIdentifier.hash_tree_root(v: BlobIdentifier) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_BlobIdentifier{}, v)
# BlobIdentifier, primary compact API: packed buffer in, view / packed bytes / digest out.
def BlobIdentifier.compact() -> CS.CS: Compact.BlobIdentifier()
def BlobIdentifier.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.BlobIdentifier(), size, buf)
def BlobIdentifier.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def BlobIdentifier.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.BlobIdentifier(), v, buf)

def KZGCommitment() -> Data: Node8()
def KZGCommitment.schema() -> T.Schema: Name.schema(Name_KZGCommitment{})
def KZGCommitment.to_ssz(v: KZGCommitment()) -> T.Value: Name.to_ssz(Name_KZGCommitment{}, v)
def KZGCommitment.from_ssz(v: T.Value) -> Maybe<&2, KZGCommitment()>: Name.from_ssz(Name_KZGCommitment{}, v)
def KZGCommitment.valid(v: KZGCommitment()) -> Bool: Name.valid(Name_KZGCommitment{}, v)
def KZGCommitment.serialize(v: KZGCommitment()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_KZGCommitment{}, v)
def KZGCommitment.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, KZGCommitment()>: Name.decode_result(Name_KZGCommitment{}, result)
def KZGCommitment.deserialize(xs: +List<U32>) -> Maybe<&2, KZGCommitment()>: Name.deserialize(Name_KZGCommitment{}, xs)
def KZGCommitment.hash_tree_root(v: KZGCommitment()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_KZGCommitment{}, v)
# KZGCommitment, primary compact API: packed buffer in, view / packed bytes / digest out.
def KZGCommitment.compact() -> CS.CS: Compact.KZGCommitment()
def KZGCommitment.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.KZGCommitment(), size, buf)
def KZGCommitment.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def KZGCommitment.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.KZGCommitment(), v, buf)

def BeaconBlockBody.schema() -> T.Schema: Name.schema(Name_BeaconBlockBody{})
def BeaconBlockBody.to_ssz(v: BeaconBlockBody) -> T.Value: Name.to_ssz(Name_BeaconBlockBody{}, v)
def BeaconBlockBody.from_ssz(v: T.Value) -> Maybe<&2, BeaconBlockBody>: Name.from_ssz(Name_BeaconBlockBody{}, v)
def BeaconBlockBody.valid(v: BeaconBlockBody) -> Bool: Name.valid(Name_BeaconBlockBody{}, v)
def BeaconBlockBody.serialize(v: BeaconBlockBody) -> Maybe<&2, +List<U32>>: Name.serialize(Name_BeaconBlockBody{}, v)
def BeaconBlockBody.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, BeaconBlockBody>: Name.decode_result(Name_BeaconBlockBody{}, result)
def BeaconBlockBody.deserialize(xs: +List<U32>) -> Maybe<&2, BeaconBlockBody>: Name.deserialize(Name_BeaconBlockBody{}, xs)
def BeaconBlockBody.hash_tree_root(v: BeaconBlockBody) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_BeaconBlockBody{}, v)
# BeaconBlockBody, primary compact API: packed buffer in, view / packed bytes / digest out.
def BeaconBlockBody.compact() -> CS.CS: Compact.BeaconBlockBody()
def BeaconBlockBody.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.BeaconBlockBody(), size, buf)
def BeaconBlockBody.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def BeaconBlockBody.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.BeaconBlockBody(), v, buf)

def BeaconBlock.schema() -> T.Schema: Name.schema(Name_BeaconBlock{})
def BeaconBlock.to_ssz(v: BeaconBlock) -> T.Value: Name.to_ssz(Name_BeaconBlock{}, v)
def BeaconBlock.from_ssz(v: T.Value) -> Maybe<&2, BeaconBlock>: Name.from_ssz(Name_BeaconBlock{}, v)
def BeaconBlock.valid(v: BeaconBlock) -> Bool: Name.valid(Name_BeaconBlock{}, v)
def BeaconBlock.serialize(v: BeaconBlock) -> Maybe<&2, +List<U32>>: Name.serialize(Name_BeaconBlock{}, v)
def BeaconBlock.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, BeaconBlock>: Name.decode_result(Name_BeaconBlock{}, result)
def BeaconBlock.deserialize(xs: +List<U32>) -> Maybe<&2, BeaconBlock>: Name.deserialize(Name_BeaconBlock{}, xs)
def BeaconBlock.hash_tree_root(v: BeaconBlock) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_BeaconBlock{}, v)
# BeaconBlock, primary compact API: packed buffer in, view / packed bytes / digest out.
def BeaconBlock.compact() -> CS.CS: Compact.BeaconBlock()
def BeaconBlock.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.BeaconBlock(), size, buf)
def BeaconBlock.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def BeaconBlock.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.BeaconBlock(), v, buf)

def SignedBeaconBlock.schema() -> T.Schema: Name.schema(Name_SignedBeaconBlock{})
def SignedBeaconBlock.to_ssz(v: SignedBeaconBlock) -> T.Value: Name.to_ssz(Name_SignedBeaconBlock{}, v)
def SignedBeaconBlock.from_ssz(v: T.Value) -> Maybe<&2, SignedBeaconBlock>: Name.from_ssz(Name_SignedBeaconBlock{}, v)
def SignedBeaconBlock.valid(v: SignedBeaconBlock) -> Bool: Name.valid(Name_SignedBeaconBlock{}, v)
def SignedBeaconBlock.serialize(v: SignedBeaconBlock) -> Maybe<&2, +List<U32>>: Name.serialize(Name_SignedBeaconBlock{}, v)
def SignedBeaconBlock.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, SignedBeaconBlock>: Name.decode_result(Name_SignedBeaconBlock{}, result)
def SignedBeaconBlock.deserialize(xs: +List<U32>) -> Maybe<&2, SignedBeaconBlock>: Name.deserialize(Name_SignedBeaconBlock{}, xs)
def SignedBeaconBlock.hash_tree_root(v: SignedBeaconBlock) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_SignedBeaconBlock{}, v)
# SignedBeaconBlock, primary compact API: packed buffer in, view / packed bytes / digest out.
def SignedBeaconBlock.compact() -> CS.CS: Compact.SignedBeaconBlock()
def SignedBeaconBlock.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.SignedBeaconBlock(), size, buf)
def SignedBeaconBlock.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def SignedBeaconBlock.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.SignedBeaconBlock(), v, buf)

def KZGProof() -> Data: Node8()
def KZGProof.schema() -> T.Schema: Name.schema(Name_KZGProof{})
def KZGProof.to_ssz(v: KZGProof()) -> T.Value: Name.to_ssz(Name_KZGProof{}, v)
def KZGProof.from_ssz(v: T.Value) -> Maybe<&2, KZGProof()>: Name.from_ssz(Name_KZGProof{}, v)
def KZGProof.valid(v: KZGProof()) -> Bool: Name.valid(Name_KZGProof{}, v)
def KZGProof.serialize(v: KZGProof()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_KZGProof{}, v)
def KZGProof.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, KZGProof()>: Name.decode_result(Name_KZGProof{}, result)
def KZGProof.deserialize(xs: +List<U32>) -> Maybe<&2, KZGProof()>: Name.deserialize(Name_KZGProof{}, xs)
def KZGProof.hash_tree_root(v: KZGProof()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_KZGProof{}, v)
# KZGProof, primary compact API: packed buffer in, view / packed bytes / digest out.
def KZGProof.compact() -> CS.CS: Compact.KZGProof()
def KZGProof.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.KZGProof(), size, buf)
def KZGProof.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def KZGProof.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.KZGProof(), v, buf)

def Blob() -> Data: Node107()
def Blob.schema() -> T.Schema: Name.schema(Name_Blob{})
def Blob.to_ssz(v: Blob()) -> T.Value: Name.to_ssz(Name_Blob{}, v)
def Blob.from_ssz(v: T.Value) -> Maybe<&2, Blob()>: Name.from_ssz(Name_Blob{}, v)
def Blob.valid(v: Blob()) -> Bool: Name.valid(Name_Blob{}, v)
def Blob.serialize(v: Blob()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Blob{}, v)
def Blob.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Blob()>: Name.decode_result(Name_Blob{}, result)
def Blob.deserialize(xs: +List<U32>) -> Maybe<&2, Blob()>: Name.deserialize(Name_Blob{}, xs)
def Blob.hash_tree_root(v: Blob()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Blob{}, v)
# Blob, primary compact API: packed buffer in, view / packed bytes / digest out.
def Blob.compact() -> CS.CS: Compact.Blob()
def Blob.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Blob(), size, buf)
def Blob.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Blob.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Blob(), v, buf)

def BlobSidecar.schema() -> T.Schema: Name.schema(Name_BlobSidecar{})
def BlobSidecar.to_ssz(v: BlobSidecar) -> T.Value: Name.to_ssz(Name_BlobSidecar{}, v)
def BlobSidecar.from_ssz(v: T.Value) -> Maybe<&2, BlobSidecar>: Name.from_ssz(Name_BlobSidecar{}, v)
def BlobSidecar.valid(v: BlobSidecar) -> Bool: Name.valid(Name_BlobSidecar{}, v)
def BlobSidecar.serialize(v: BlobSidecar) -> Maybe<&2, +List<U32>>: Name.serialize(Name_BlobSidecar{}, v)
def BlobSidecar.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, BlobSidecar>: Name.decode_result(Name_BlobSidecar{}, result)
def BlobSidecar.deserialize(xs: +List<U32>) -> Maybe<&2, BlobSidecar>: Name.deserialize(Name_BlobSidecar{}, xs)
def BlobSidecar.hash_tree_root(v: BlobSidecar) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_BlobSidecar{}, v)
# BlobSidecar, primary compact API: packed buffer in, view / packed bytes / digest out.
def BlobSidecar.compact() -> CS.CS: Compact.BlobSidecar()
def BlobSidecar.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.BlobSidecar(), size, buf)
def BlobSidecar.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def BlobSidecar.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.BlobSidecar(), v, buf)

def Cell() -> Data: Node110()
def Cell.schema() -> T.Schema: Name.schema(Name_Cell{})
def Cell.to_ssz(v: Cell()) -> T.Value: Name.to_ssz(Name_Cell{}, v)
def Cell.from_ssz(v: T.Value) -> Maybe<&2, Cell()>: Name.from_ssz(Name_Cell{}, v)
def Cell.valid(v: Cell()) -> Bool: Name.valid(Name_Cell{}, v)
def Cell.serialize(v: Cell()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_Cell{}, v)
def Cell.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, Cell()>: Name.decode_result(Name_Cell{}, result)
def Cell.deserialize(xs: +List<U32>) -> Maybe<&2, Cell()>: Name.deserialize(Name_Cell{}, xs)
def Cell.hash_tree_root(v: Cell()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_Cell{}, v)
# Cell, primary compact API: packed buffer in, view / packed bytes / digest out.
def Cell.compact() -> CS.CS: Compact.Cell()
def Cell.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.Cell(), size, buf)
def Cell.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def Cell.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.Cell(), v, buf)

def CellIndex() -> Data: Node3()
def CellIndex.schema() -> T.Schema: Name.schema(Name_CellIndex{})
def CellIndex.to_ssz(v: CellIndex()) -> T.Value: Name.to_ssz(Name_CellIndex{}, v)
def CellIndex.from_ssz(v: T.Value) -> Maybe<&2, CellIndex()>: Name.from_ssz(Name_CellIndex{}, v)
def CellIndex.valid(v: CellIndex()) -> Bool: Name.valid(Name_CellIndex{}, v)
def CellIndex.serialize(v: CellIndex()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_CellIndex{}, v)
def CellIndex.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, CellIndex()>: Name.decode_result(Name_CellIndex{}, result)
def CellIndex.deserialize(xs: +List<U32>) -> Maybe<&2, CellIndex()>: Name.deserialize(Name_CellIndex{}, xs)
def CellIndex.hash_tree_root(v: CellIndex()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_CellIndex{}, v)
# CellIndex, primary compact API: packed buffer in, view / packed bytes / digest out.
def CellIndex.compact() -> CS.CS: Compact.CellIndex()
def CellIndex.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.CellIndex(), size, buf)
def CellIndex.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def CellIndex.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.CellIndex(), v, buf)

def CommitmentIndex() -> Data: Node3()
def CommitmentIndex.schema() -> T.Schema: Name.schema(Name_CommitmentIndex{})
def CommitmentIndex.to_ssz(v: CommitmentIndex()) -> T.Value: Name.to_ssz(Name_CommitmentIndex{}, v)
def CommitmentIndex.from_ssz(v: T.Value) -> Maybe<&2, CommitmentIndex()>: Name.from_ssz(Name_CommitmentIndex{}, v)
def CommitmentIndex.valid(v: CommitmentIndex()) -> Bool: Name.valid(Name_CommitmentIndex{}, v)
def CommitmentIndex.serialize(v: CommitmentIndex()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_CommitmentIndex{}, v)
def CommitmentIndex.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, CommitmentIndex()>: Name.decode_result(Name_CommitmentIndex{}, result)
def CommitmentIndex.deserialize(xs: +List<U32>) -> Maybe<&2, CommitmentIndex()>: Name.deserialize(Name_CommitmentIndex{}, xs)
def CommitmentIndex.hash_tree_root(v: CommitmentIndex()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_CommitmentIndex{}, v)
# CommitmentIndex, primary compact API: packed buffer in, view / packed bytes / digest out.
def CommitmentIndex.compact() -> CS.CS: Compact.CommitmentIndex()
def CommitmentIndex.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.CommitmentIndex(), size, buf)
def CommitmentIndex.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def CommitmentIndex.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.CommitmentIndex(), v, buf)

def RowIndex() -> Data: Node3()
def RowIndex.schema() -> T.Schema: Name.schema(Name_RowIndex{})
def RowIndex.to_ssz(v: RowIndex()) -> T.Value: Name.to_ssz(Name_RowIndex{}, v)
def RowIndex.from_ssz(v: T.Value) -> Maybe<&2, RowIndex()>: Name.from_ssz(Name_RowIndex{}, v)
def RowIndex.valid(v: RowIndex()) -> Bool: Name.valid(Name_RowIndex{}, v)
def RowIndex.serialize(v: RowIndex()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_RowIndex{}, v)
def RowIndex.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, RowIndex()>: Name.decode_result(Name_RowIndex{}, result)
def RowIndex.deserialize(xs: +List<U32>) -> Maybe<&2, RowIndex()>: Name.deserialize(Name_RowIndex{}, xs)
def RowIndex.hash_tree_root(v: RowIndex()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_RowIndex{}, v)
# RowIndex, primary compact API: packed buffer in, view / packed bytes / digest out.
def RowIndex.compact() -> CS.CS: Compact.RowIndex()
def RowIndex.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.RowIndex(), size, buf)
def RowIndex.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def RowIndex.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.RowIndex(), v, buf)

def ColumnIndex() -> Data: Node3()
def ColumnIndex.schema() -> T.Schema: Name.schema(Name_ColumnIndex{})
def ColumnIndex.to_ssz(v: ColumnIndex()) -> T.Value: Name.to_ssz(Name_ColumnIndex{}, v)
def ColumnIndex.from_ssz(v: T.Value) -> Maybe<&2, ColumnIndex()>: Name.from_ssz(Name_ColumnIndex{}, v)
def ColumnIndex.valid(v: ColumnIndex()) -> Bool: Name.valid(Name_ColumnIndex{}, v)
def ColumnIndex.serialize(v: ColumnIndex()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_ColumnIndex{}, v)
def ColumnIndex.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, ColumnIndex()>: Name.decode_result(Name_ColumnIndex{}, result)
def ColumnIndex.deserialize(xs: +List<U32>) -> Maybe<&2, ColumnIndex()>: Name.deserialize(Name_ColumnIndex{}, xs)
def ColumnIndex.hash_tree_root(v: ColumnIndex()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_ColumnIndex{}, v)
# ColumnIndex, primary compact API: packed buffer in, view / packed bytes / digest out.
def ColumnIndex.compact() -> CS.CS: Compact.ColumnIndex()
def ColumnIndex.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.ColumnIndex(), size, buf)
def ColumnIndex.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def ColumnIndex.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.ColumnIndex(), v, buf)

def DataColumnsByRootIdentifier.schema() -> T.Schema: Name.schema(Name_DataColumnsByRootIdentifier{})
def DataColumnsByRootIdentifier.to_ssz(v: DataColumnsByRootIdentifier) -> T.Value: Name.to_ssz(Name_DataColumnsByRootIdentifier{}, v)
def DataColumnsByRootIdentifier.from_ssz(v: T.Value) -> Maybe<&2, DataColumnsByRootIdentifier>: Name.from_ssz(Name_DataColumnsByRootIdentifier{}, v)
def DataColumnsByRootIdentifier.valid(v: DataColumnsByRootIdentifier) -> Bool: Name.valid(Name_DataColumnsByRootIdentifier{}, v)
def DataColumnsByRootIdentifier.serialize(v: DataColumnsByRootIdentifier) -> Maybe<&2, +List<U32>>: Name.serialize(Name_DataColumnsByRootIdentifier{}, v)
def DataColumnsByRootIdentifier.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, DataColumnsByRootIdentifier>: Name.decode_result(Name_DataColumnsByRootIdentifier{}, result)
def DataColumnsByRootIdentifier.deserialize(xs: +List<U32>) -> Maybe<&2, DataColumnsByRootIdentifier>: Name.deserialize(Name_DataColumnsByRootIdentifier{}, xs)
def DataColumnsByRootIdentifier.hash_tree_root(v: DataColumnsByRootIdentifier) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_DataColumnsByRootIdentifier{}, v)
# DataColumnsByRootIdentifier, primary compact API: packed buffer in, view / packed bytes / digest out.
def DataColumnsByRootIdentifier.compact() -> CS.CS: Compact.DataColumnsByRootIdentifier()
def DataColumnsByRootIdentifier.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.DataColumnsByRootIdentifier(), size, buf)
def DataColumnsByRootIdentifier.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def DataColumnsByRootIdentifier.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.DataColumnsByRootIdentifier(), v, buf)

def MatrixEntry.schema() -> T.Schema: Name.schema(Name_MatrixEntry{})
def MatrixEntry.to_ssz(v: MatrixEntry) -> T.Value: Name.to_ssz(Name_MatrixEntry{}, v)
def MatrixEntry.from_ssz(v: T.Value) -> Maybe<&2, MatrixEntry>: Name.from_ssz(Name_MatrixEntry{}, v)
def MatrixEntry.valid(v: MatrixEntry) -> Bool: Name.valid(Name_MatrixEntry{}, v)
def MatrixEntry.serialize(v: MatrixEntry) -> Maybe<&2, +List<U32>>: Name.serialize(Name_MatrixEntry{}, v)
def MatrixEntry.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, MatrixEntry>: Name.decode_result(Name_MatrixEntry{}, result)
def MatrixEntry.deserialize(xs: +List<U32>) -> Maybe<&2, MatrixEntry>: Name.deserialize(Name_MatrixEntry{}, xs)
def MatrixEntry.hash_tree_root(v: MatrixEntry) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_MatrixEntry{}, v)
# MatrixEntry, primary compact API: packed buffer in, view / packed bytes / digest out.
def MatrixEntry.compact() -> CS.CS: Compact.MatrixEntry()
def MatrixEntry.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.MatrixEntry(), size, buf)
def MatrixEntry.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def MatrixEntry.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.MatrixEntry(), v, buf)

def DataColumnSidecar.schema() -> T.Schema: Name.schema(Name_DataColumnSidecar{})
def DataColumnSidecar.to_ssz(v: DataColumnSidecar) -> T.Value: Name.to_ssz(Name_DataColumnSidecar{}, v)
def DataColumnSidecar.from_ssz(v: T.Value) -> Maybe<&2, DataColumnSidecar>: Name.from_ssz(Name_DataColumnSidecar{}, v)
def DataColumnSidecar.valid(v: DataColumnSidecar) -> Bool: Name.valid(Name_DataColumnSidecar{}, v)
def DataColumnSidecar.serialize(v: DataColumnSidecar) -> Maybe<&2, +List<U32>>: Name.serialize(Name_DataColumnSidecar{}, v)
def DataColumnSidecar.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, DataColumnSidecar>: Name.decode_result(Name_DataColumnSidecar{}, result)
def DataColumnSidecar.deserialize(xs: +List<U32>) -> Maybe<&2, DataColumnSidecar>: Name.deserialize(Name_DataColumnSidecar{}, xs)
def DataColumnSidecar.hash_tree_root(v: DataColumnSidecar) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_DataColumnSidecar{}, v)
# DataColumnSidecar, primary compact API: packed buffer in, view / packed bytes / digest out.
def DataColumnSidecar.compact() -> CS.CS: Compact.DataColumnSidecar()
def DataColumnSidecar.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.DataColumnSidecar(), size, buf)
def DataColumnSidecar.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def DataColumnSidecar.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.DataColumnSidecar(), v, buf)

def CustodyIndex() -> Data: Node3()
def CustodyIndex.schema() -> T.Schema: Name.schema(Name_CustodyIndex{})
def CustodyIndex.to_ssz(v: CustodyIndex()) -> T.Value: Name.to_ssz(Name_CustodyIndex{}, v)
def CustodyIndex.from_ssz(v: T.Value) -> Maybe<&2, CustodyIndex()>: Name.from_ssz(Name_CustodyIndex{}, v)
def CustodyIndex.valid(v: CustodyIndex()) -> Bool: Name.valid(Name_CustodyIndex{}, v)
def CustodyIndex.serialize(v: CustodyIndex()) -> Maybe<&2, +List<U32>>: Name.serialize(Name_CustodyIndex{}, v)
def CustodyIndex.decode_result(result: Maybe<&2, T.Value>) -> Maybe<&2, CustodyIndex()>: Name.decode_result(Name_CustodyIndex{}, result)
def CustodyIndex.deserialize(xs: +List<U32>) -> Maybe<&2, CustodyIndex()>: Name.deserialize(Name_CustodyIndex{}, xs)
def CustodyIndex.hash_tree_root(v: CustodyIndex()) -> Maybe<&2, +List<U32>>: Name.hash_tree_root(Name_CustodyIndex{}, v)
# CustodyIndex, primary compact API: packed buffer in, view / packed bytes / digest out.
def CustodyIndex.compact() -> CS.CS: Compact.CustodyIndex()
def CustodyIndex.decode(+size: U32, buf: Buf.Buf) -> Buf.Buf & Maybe<&2, Access.View>: API.decode(Compact.CustodyIndex(), size, buf)
def CustodyIndex.encode(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Buf.Buf: API.encode(v, buf)
def CustodyIndex.root(+v: Access.View, buf: Buf.Buf) -> Buf.Buf & Digest.Digest: API.root(Compact.CustodyIndex(), v, buf)

