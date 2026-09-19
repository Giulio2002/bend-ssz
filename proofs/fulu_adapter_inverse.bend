import Base
import ../types/fulu.bend as F
import ../types/schema.bend as T
import ./lists.bend as L

law Node0_inverse:
  for +value: F.Node0()
  {F.Node0.from_value(F.Node0.to_value(value)) == Some{value} : Maybe<&2, F.Node0()>}
def Node0_inverse(value):
  {==}

law Node1_inverse:
  for +value: F.Node1()
  {F.Node1.from_value(F.Node1.to_value(value)) == Some{value} : Maybe<&2, F.Node1()>}
def Node1_inverse(value):
  {==}

law Node2_inverse:
  for +value: F.Node2()
  {F.Node2.from_value(F.Node2.to_value(value)) == Some{value} : Maybe<&2, F.Node2()>}
def Node2_inverse(value):
  {==}

law Node3_inverse:
  for +value: F.Node3()
  {F.Node3.from_value(F.Node3.to_value(value)) == Some{value} : Maybe<&2, F.Node3()>}
def Node3_inverse(value):
  {==}

law Node4_inverse:
  for +value: F.Node4()
  {F.Node4.from_value(F.Node4.to_value(value)) == Some{value} : Maybe<&2, F.Node4()>}
def Node4_inverse(value):
  {==}

law Node5_inverse:
  for +value: F.Node5()
  {F.Node5.from_value(F.Node5.to_value(value)) == Some{value} : Maybe<&2, F.Node5()>}
def Node5_inverse(value):
  {==}

law Node6_inverse:
  for +value: F.Node6()
  {F.Node6.from_value(F.Node6.to_value(value)) == Some{value} : Maybe<&2, F.Node6()>}
def Node6_inverse(value):
  {==}

law Node7_inverse:
  for +value: F.Node7()
  {F.Node7.from_value(F.Node7.to_value(value)) == Some{value} : Maybe<&2, F.Node7()>}
def Node7_inverse(value):
  {==}

law Node8_inverse:
  for +value: F.Node8()
  {F.Node8.from_value(F.Node8.to_value(value)) == Some{value} : Maybe<&2, F.Node8()>}
def Node8_inverse(value):
  {==}

law Node9_inverse:
  for +value: F.Node9()
  {F.Node9.from_value(F.Node9.to_value(value)) == Some{value} : Maybe<&2, F.Node9()>}
def Node9_inverse(value):
  {==}

law Node10_inverse:
  for +value: F.Node10()
  {F.Node10.from_value(F.Node10.to_value(value)) == Some{value} : Maybe<&2, F.Node10()>}
def Node10_inverse(value):
  {==}

law Node11_inverse:
  for +value: F.Node11()
  {F.Node11.from_value(F.Node11.to_value(value)) == Some{value} : Maybe<&2, F.Node11()>}
def Node11_inverse(value):
  {==}

law Node12_append:
  for +xs: +List<F.Node7()>
  for +ys: +List<F.Node7()>
  for +acc: T.Value
  {F.Node7.seq_to_go(List.append(&2, F.Node7(), xs, ys), acc) == F.Node7.seq_to_go(ys, F.Node7.seq_to_go(xs, acc)) : T.Value}
def Node12_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node12_append(t, ys, T.Items{F.Node7.to_value(h), acc})

law Node12_cons:
  for +h: F.Node7()
  for +t: +List<F.Node7()>
  {F.Node7.seq_to(h <> t) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
def Node12_cons(h, t):
  %Equal.sym(+List<F.Node7()>, List.reverse.go(&2, F.Node7(), t, [h]), List.append(&2, F.Node7(), List.reverse(&2, F.Node7(), t), [h]), L.reverse_acc_append(F.Node7(), t, [], [h])) : {F.Node7.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
  Node12_append(List.reverse(&2, F.Node7(), t), [h], T.EmptyItems{})

law Node12_inverse_go:
  for +xs: +List<F.Node7()>
  for +acc: +List<F.Node7()>
  {F.Node7.seq_from_go(F.Node7.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node7(), acc, xs)} : Maybe<&2, +List<F.Node7()>>}
def Node12_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node7.seq_to(h <> t), T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)}, Node12_cons(h, t)) : {F.Node7.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(h)), Some{h}, Node7_inverse(h)) : {F.Node7.seq_step(_, acc, next => F.Node7.seq_from_go(F.Node7.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      Node12_inverse_go(t, h <> acc)

law Node12_inverse:
  for +value: F.Node12()
  {F.Node12.from_value(F.Node12.to_value(value)) == Some{value} : Maybe<&2, F.Node12()>}
def Node12_inverse(value):
  Node12_inverse_go(value, [])

law ForkValue_inverse:
  for +value: F.ForkValue()
  {F.ForkValue.from_value(F.ForkValue.to_value(value)) == Some{value} : Maybe<&2, F.ForkValue()>}
def ForkValue_inverse(value):
  F.Fork{previous_version, current_version, epoch} = value
  %Equal.sym(Maybe<&2, F.Node6()>, F.Node6.from_value(F.Node6.to_value(previous_version)), Some{previous_version}, Node6_inverse(previous_version)) : {F.ForkValue.assemble(_, F.Node6.from_value(F.Node6.to_value(current_version)), F.Node3.from_value(F.Node3.to_value(epoch))) == Some{F.Fork{previous_version, current_version, epoch}} : Maybe<&2, F.ForkValue()>}
  %Equal.sym(Maybe<&2, F.Node6()>, F.Node6.from_value(F.Node6.to_value(current_version)), Some{current_version}, Node6_inverse(current_version)) : {F.ForkValue.assemble(Some{previous_version}, _, F.Node3.from_value(F.Node3.to_value(epoch))) == Some{F.Fork{previous_version, current_version, epoch}} : Maybe<&2, F.ForkValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(epoch)), Some{epoch}, Node3_inverse(epoch)) : {F.ForkValue.assemble(Some{previous_version}, Some{current_version}, _) == Some{F.Fork{previous_version, current_version, epoch}} : Maybe<&2, F.ForkValue()>}
  {==}

law Node15_inverse:
  for +value: F.Node15()
  {F.Node15.from_value(F.Node15.to_value(value)) == Some{value} : Maybe<&2, F.Node15()>}
def Node15_inverse(value):
  {==}

law SyncAggregateValue_inverse:
  for +value: F.SyncAggregateValue()
  {F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(value)) == Some{value} : Maybe<&2, F.SyncAggregateValue()>}
def SyncAggregateValue_inverse(value):
  F.SyncAggregate{sync_committee_bits, sync_committee_signature} = value
  %Equal.sym(Maybe<&2, F.Node15()>, F.Node15.from_value(F.Node15.to_value(sync_committee_bits)), Some{sync_committee_bits}, Node15_inverse(sync_committee_bits)) : {F.SyncAggregateValue.assemble(_, F.Node9.from_value(F.Node9.to_value(sync_committee_signature))) == Some{F.SyncAggregate{sync_committee_bits, sync_committee_signature}} : Maybe<&2, F.SyncAggregateValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(sync_committee_signature)), Some{sync_committee_signature}, Node9_inverse(sync_committee_signature)) : {F.SyncAggregateValue.assemble(Some{sync_committee_bits}, _) == Some{F.SyncAggregate{sync_committee_bits, sync_committee_signature}} : Maybe<&2, F.SyncAggregateValue()>}
  {==}

law SyncAggregatorSelectionDataValue_inverse:
  for +value: F.SyncAggregatorSelectionDataValue()
  {F.SyncAggregatorSelectionDataValue.from_value(F.SyncAggregatorSelectionDataValue.to_value(value)) == Some{value} : Maybe<&2, F.SyncAggregatorSelectionDataValue()>}
def SyncAggregatorSelectionDataValue_inverse(value):
  F.SyncAggregatorSelectionData{slot, subcommittee_index} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(slot)), Some{slot}, Node3_inverse(slot)) : {F.SyncAggregatorSelectionDataValue.assemble(_, F.Node3.from_value(F.Node3.to_value(subcommittee_index))) == Some{F.SyncAggregatorSelectionData{slot, subcommittee_index}} : Maybe<&2, F.SyncAggregatorSelectionDataValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(subcommittee_index)), Some{subcommittee_index}, Node3_inverse(subcommittee_index)) : {F.SyncAggregatorSelectionDataValue.assemble(Some{slot}, _) == Some{F.SyncAggregatorSelectionData{slot, subcommittee_index}} : Maybe<&2, F.SyncAggregatorSelectionDataValue()>}
  {==}

law PowBlockValue_inverse:
  for +value: F.PowBlockValue()
  {F.PowBlockValue.from_value(F.PowBlockValue.to_value(value)) == Some{value} : Maybe<&2, F.PowBlockValue()>}
def PowBlockValue_inverse(value):
  F.PowBlock{block_hash, parent_hash, total_difficulty} = value
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(block_hash)), Some{block_hash}, Node7_inverse(block_hash)) : {F.PowBlockValue.assemble(_, F.Node7.from_value(F.Node7.to_value(parent_hash)), F.Node4.from_value(F.Node4.to_value(total_difficulty))) == Some{F.PowBlock{block_hash, parent_hash, total_difficulty}} : Maybe<&2, F.PowBlockValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(parent_hash)), Some{parent_hash}, Node7_inverse(parent_hash)) : {F.PowBlockValue.assemble(Some{block_hash}, _, F.Node4.from_value(F.Node4.to_value(total_difficulty))) == Some{F.PowBlock{block_hash, parent_hash, total_difficulty}} : Maybe<&2, F.PowBlockValue()>}
  %Equal.sym(Maybe<&2, F.Node4()>, F.Node4.from_value(F.Node4.to_value(total_difficulty)), Some{total_difficulty}, Node4_inverse(total_difficulty)) : {F.PowBlockValue.assemble(Some{block_hash}, Some{parent_hash}, _) == Some{F.PowBlock{block_hash, parent_hash, total_difficulty}} : Maybe<&2, F.PowBlockValue()>}
  {==}

law PendingConsolidationValue_inverse:
  for +value: F.PendingConsolidationValue()
  {F.PendingConsolidationValue.from_value(F.PendingConsolidationValue.to_value(value)) == Some{value} : Maybe<&2, F.PendingConsolidationValue()>}
def PendingConsolidationValue_inverse(value):
  F.PendingConsolidation{source_index, target_index} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(source_index)), Some{source_index}, Node3_inverse(source_index)) : {F.PendingConsolidationValue.assemble(_, F.Node3.from_value(F.Node3.to_value(target_index))) == Some{F.PendingConsolidation{source_index, target_index}} : Maybe<&2, F.PendingConsolidationValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(target_index)), Some{target_index}, Node3_inverse(target_index)) : {F.PendingConsolidationValue.assemble(Some{source_index}, _) == Some{F.PendingConsolidation{source_index, target_index}} : Maybe<&2, F.PendingConsolidationValue()>}
  {==}

law PendingPartialWithdrawalValue_inverse:
  for +value: F.PendingPartialWithdrawalValue()
  {F.PendingPartialWithdrawalValue.from_value(F.PendingPartialWithdrawalValue.to_value(value)) == Some{value} : Maybe<&2, F.PendingPartialWithdrawalValue()>}
def PendingPartialWithdrawalValue_inverse(value):
  F.PendingPartialWithdrawal{validator_index, amount, withdrawable_epoch} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(validator_index)), Some{validator_index}, Node3_inverse(validator_index)) : {F.PendingPartialWithdrawalValue.assemble(_, F.Node3.from_value(F.Node3.to_value(amount)), F.Node3.from_value(F.Node3.to_value(withdrawable_epoch))) == Some{F.PendingPartialWithdrawal{validator_index, amount, withdrawable_epoch}} : Maybe<&2, F.PendingPartialWithdrawalValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(amount)), Some{amount}, Node3_inverse(amount)) : {F.PendingPartialWithdrawalValue.assemble(Some{validator_index}, _, F.Node3.from_value(F.Node3.to_value(withdrawable_epoch))) == Some{F.PendingPartialWithdrawal{validator_index, amount, withdrawable_epoch}} : Maybe<&2, F.PendingPartialWithdrawalValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(withdrawable_epoch)), Some{withdrawable_epoch}, Node3_inverse(withdrawable_epoch)) : {F.PendingPartialWithdrawalValue.assemble(Some{validator_index}, Some{amount}, _) == Some{F.PendingPartialWithdrawal{validator_index, amount, withdrawable_epoch}} : Maybe<&2, F.PendingPartialWithdrawalValue()>}
  {==}

law VoluntaryExitValue_inverse:
  for +value: F.VoluntaryExitValue()
  {F.VoluntaryExitValue.from_value(F.VoluntaryExitValue.to_value(value)) == Some{value} : Maybe<&2, F.VoluntaryExitValue()>}
def VoluntaryExitValue_inverse(value):
  F.VoluntaryExit{epoch, validator_index} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(epoch)), Some{epoch}, Node3_inverse(epoch)) : {F.VoluntaryExitValue.assemble(_, F.Node3.from_value(F.Node3.to_value(validator_index))) == Some{F.VoluntaryExit{epoch, validator_index}} : Maybe<&2, F.VoluntaryExitValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(validator_index)), Some{validator_index}, Node3_inverse(validator_index)) : {F.VoluntaryExitValue.assemble(Some{epoch}, _) == Some{F.VoluntaryExit{epoch, validator_index}} : Maybe<&2, F.VoluntaryExitValue()>}
  {==}

law SignedVoluntaryExitValue_inverse:
  for +value: F.SignedVoluntaryExitValue()
  {F.SignedVoluntaryExitValue.from_value(F.SignedVoluntaryExitValue.to_value(value)) == Some{value} : Maybe<&2, F.SignedVoluntaryExitValue()>}
def SignedVoluntaryExitValue_inverse(value):
  F.SignedVoluntaryExit{message, signature} = value
  %Equal.sym(Maybe<&2, F.VoluntaryExitValue()>, F.VoluntaryExitValue.from_value(F.VoluntaryExitValue.to_value(message)), Some{message}, VoluntaryExitValue_inverse(message)) : {F.SignedVoluntaryExitValue.assemble(_, F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SignedVoluntaryExit{message, signature}} : Maybe<&2, F.SignedVoluntaryExitValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.SignedVoluntaryExitValue.assemble(Some{message}, _) == Some{F.SignedVoluntaryExit{message, signature}} : Maybe<&2, F.SignedVoluntaryExitValue()>}
  {==}

law HistoricalSummaryValue_inverse:
  for +value: F.HistoricalSummaryValue()
  {F.HistoricalSummaryValue.from_value(F.HistoricalSummaryValue.to_value(value)) == Some{value} : Maybe<&2, F.HistoricalSummaryValue()>}
def HistoricalSummaryValue_inverse(value):
  F.HistoricalSummary{block_summary_root, state_summary_root} = value
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(block_summary_root)), Some{block_summary_root}, Node7_inverse(block_summary_root)) : {F.HistoricalSummaryValue.assemble(_, F.Node7.from_value(F.Node7.to_value(state_summary_root))) == Some{F.HistoricalSummary{block_summary_root, state_summary_root}} : Maybe<&2, F.HistoricalSummaryValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(state_summary_root)), Some{state_summary_root}, Node7_inverse(state_summary_root)) : {F.HistoricalSummaryValue.assemble(Some{block_summary_root}, _) == Some{F.HistoricalSummary{block_summary_root, state_summary_root}} : Maybe<&2, F.HistoricalSummaryValue()>}
  {==}

law Node24_inverse:
  for +value: F.Node24()
  {F.Node24.from_value(F.Node24.to_value(value)) == Some{value} : Maybe<&2, F.Node24()>}
def Node24_inverse(value):
  {==}

law SyncCommitteeContributionValue_inverse:
  for +value: F.SyncCommitteeContributionValue()
  {F.SyncCommitteeContributionValue.from_value(F.SyncCommitteeContributionValue.to_value(value)) == Some{value} : Maybe<&2, F.SyncCommitteeContributionValue()>}
def SyncCommitteeContributionValue_inverse(value):
  F.SyncCommitteeContribution{slot, beacon_block_root, subcommittee_index, aggregation_bits, signature} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(slot)), Some{slot}, Node3_inverse(slot)) : {F.SyncCommitteeContributionValue.assemble(_, F.Node7.from_value(F.Node7.to_value(beacon_block_root)), F.Node3.from_value(F.Node3.to_value(subcommittee_index)), F.Node24.from_value(F.Node24.to_value(aggregation_bits)), F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SyncCommitteeContribution{slot, beacon_block_root, subcommittee_index, aggregation_bits, signature}} : Maybe<&2, F.SyncCommitteeContributionValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(beacon_block_root)), Some{beacon_block_root}, Node7_inverse(beacon_block_root)) : {F.SyncCommitteeContributionValue.assemble(Some{slot}, _, F.Node3.from_value(F.Node3.to_value(subcommittee_index)), F.Node24.from_value(F.Node24.to_value(aggregation_bits)), F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SyncCommitteeContribution{slot, beacon_block_root, subcommittee_index, aggregation_bits, signature}} : Maybe<&2, F.SyncCommitteeContributionValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(subcommittee_index)), Some{subcommittee_index}, Node3_inverse(subcommittee_index)) : {F.SyncCommitteeContributionValue.assemble(Some{slot}, Some{beacon_block_root}, _, F.Node24.from_value(F.Node24.to_value(aggregation_bits)), F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SyncCommitteeContribution{slot, beacon_block_root, subcommittee_index, aggregation_bits, signature}} : Maybe<&2, F.SyncCommitteeContributionValue()>}
  %Equal.sym(Maybe<&2, F.Node24()>, F.Node24.from_value(F.Node24.to_value(aggregation_bits)), Some{aggregation_bits}, Node24_inverse(aggregation_bits)) : {F.SyncCommitteeContributionValue.assemble(Some{slot}, Some{beacon_block_root}, Some{subcommittee_index}, _, F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SyncCommitteeContribution{slot, beacon_block_root, subcommittee_index, aggregation_bits, signature}} : Maybe<&2, F.SyncCommitteeContributionValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.SyncCommitteeContributionValue.assemble(Some{slot}, Some{beacon_block_root}, Some{subcommittee_index}, Some{aggregation_bits}, _) == Some{F.SyncCommitteeContribution{slot, beacon_block_root, subcommittee_index, aggregation_bits, signature}} : Maybe<&2, F.SyncCommitteeContributionValue()>}
  {==}

law ContributionAndProofValue_inverse:
  for +value: F.ContributionAndProofValue()
  {F.ContributionAndProofValue.from_value(F.ContributionAndProofValue.to_value(value)) == Some{value} : Maybe<&2, F.ContributionAndProofValue()>}
def ContributionAndProofValue_inverse(value):
  F.ContributionAndProof{aggregator_index, contribution, selection_proof} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(aggregator_index)), Some{aggregator_index}, Node3_inverse(aggregator_index)) : {F.ContributionAndProofValue.assemble(_, F.SyncCommitteeContributionValue.from_value(F.SyncCommitteeContributionValue.to_value(contribution)), F.Node9.from_value(F.Node9.to_value(selection_proof))) == Some{F.ContributionAndProof{aggregator_index, contribution, selection_proof}} : Maybe<&2, F.ContributionAndProofValue()>}
  %Equal.sym(Maybe<&2, F.SyncCommitteeContributionValue()>, F.SyncCommitteeContributionValue.from_value(F.SyncCommitteeContributionValue.to_value(contribution)), Some{contribution}, SyncCommitteeContributionValue_inverse(contribution)) : {F.ContributionAndProofValue.assemble(Some{aggregator_index}, _, F.Node9.from_value(F.Node9.to_value(selection_proof))) == Some{F.ContributionAndProof{aggregator_index, contribution, selection_proof}} : Maybe<&2, F.ContributionAndProofValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(selection_proof)), Some{selection_proof}, Node9_inverse(selection_proof)) : {F.ContributionAndProofValue.assemble(Some{aggregator_index}, Some{contribution}, _) == Some{F.ContributionAndProof{aggregator_index, contribution, selection_proof}} : Maybe<&2, F.ContributionAndProofValue()>}
  {==}

law SignedContributionAndProofValue_inverse:
  for +value: F.SignedContributionAndProofValue()
  {F.SignedContributionAndProofValue.from_value(F.SignedContributionAndProofValue.to_value(value)) == Some{value} : Maybe<&2, F.SignedContributionAndProofValue()>}
def SignedContributionAndProofValue_inverse(value):
  F.SignedContributionAndProof{message, signature} = value
  %Equal.sym(Maybe<&2, F.ContributionAndProofValue()>, F.ContributionAndProofValue.from_value(F.ContributionAndProofValue.to_value(message)), Some{message}, ContributionAndProofValue_inverse(message)) : {F.SignedContributionAndProofValue.assemble(_, F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SignedContributionAndProof{message, signature}} : Maybe<&2, F.SignedContributionAndProofValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.SignedContributionAndProofValue.assemble(Some{message}, _) == Some{F.SignedContributionAndProof{message, signature}} : Maybe<&2, F.SignedContributionAndProofValue()>}
  {==}

law SyncCommitteeMessageValue_inverse:
  for +value: F.SyncCommitteeMessageValue()
  {F.SyncCommitteeMessageValue.from_value(F.SyncCommitteeMessageValue.to_value(value)) == Some{value} : Maybe<&2, F.SyncCommitteeMessageValue()>}
def SyncCommitteeMessageValue_inverse(value):
  F.SyncCommitteeMessage{slot, beacon_block_root, validator_index, signature} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(slot)), Some{slot}, Node3_inverse(slot)) : {F.SyncCommitteeMessageValue.assemble(_, F.Node7.from_value(F.Node7.to_value(beacon_block_root)), F.Node3.from_value(F.Node3.to_value(validator_index)), F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SyncCommitteeMessage{slot, beacon_block_root, validator_index, signature}} : Maybe<&2, F.SyncCommitteeMessageValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(beacon_block_root)), Some{beacon_block_root}, Node7_inverse(beacon_block_root)) : {F.SyncCommitteeMessageValue.assemble(Some{slot}, _, F.Node3.from_value(F.Node3.to_value(validator_index)), F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SyncCommitteeMessage{slot, beacon_block_root, validator_index, signature}} : Maybe<&2, F.SyncCommitteeMessageValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(validator_index)), Some{validator_index}, Node3_inverse(validator_index)) : {F.SyncCommitteeMessageValue.assemble(Some{slot}, Some{beacon_block_root}, _, F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SyncCommitteeMessage{slot, beacon_block_root, validator_index, signature}} : Maybe<&2, F.SyncCommitteeMessageValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.SyncCommitteeMessageValue.assemble(Some{slot}, Some{beacon_block_root}, Some{validator_index}, _) == Some{F.SyncCommitteeMessage{slot, beacon_block_root, validator_index, signature}} : Maybe<&2, F.SyncCommitteeMessageValue()>}
  {==}

law Eth1BlockValue_inverse:
  for +value: F.Eth1BlockValue()
  {F.Eth1BlockValue.from_value(F.Eth1BlockValue.to_value(value)) == Some{value} : Maybe<&2, F.Eth1BlockValue()>}
def Eth1BlockValue_inverse(value):
  F.Eth1Block{timestamp, deposit_root, deposit_count} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(timestamp)), Some{timestamp}, Node3_inverse(timestamp)) : {F.Eth1BlockValue.assemble(_, F.Node7.from_value(F.Node7.to_value(deposit_root)), F.Node3.from_value(F.Node3.to_value(deposit_count))) == Some{F.Eth1Block{timestamp, deposit_root, deposit_count}} : Maybe<&2, F.Eth1BlockValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(deposit_root)), Some{deposit_root}, Node7_inverse(deposit_root)) : {F.Eth1BlockValue.assemble(Some{timestamp}, _, F.Node3.from_value(F.Node3.to_value(deposit_count))) == Some{F.Eth1Block{timestamp, deposit_root, deposit_count}} : Maybe<&2, F.Eth1BlockValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(deposit_count)), Some{deposit_count}, Node3_inverse(deposit_count)) : {F.Eth1BlockValue.assemble(Some{timestamp}, Some{deposit_root}, _) == Some{F.Eth1Block{timestamp, deposit_root, deposit_count}} : Maybe<&2, F.Eth1BlockValue()>}
  {==}

law BeaconBlockHeaderValue_inverse:
  for +value: F.BeaconBlockHeaderValue()
  {F.BeaconBlockHeaderValue.from_value(F.BeaconBlockHeaderValue.to_value(value)) == Some{value} : Maybe<&2, F.BeaconBlockHeaderValue()>}
def BeaconBlockHeaderValue_inverse(value):
  F.BeaconBlockHeader{slot, proposer_index, parent_root, state_root, body_root} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(slot)), Some{slot}, Node3_inverse(slot)) : {F.BeaconBlockHeaderValue.assemble(_, F.Node3.from_value(F.Node3.to_value(proposer_index)), F.Node7.from_value(F.Node7.to_value(parent_root)), F.Node7.from_value(F.Node7.to_value(state_root)), F.Node7.from_value(F.Node7.to_value(body_root))) == Some{F.BeaconBlockHeader{slot, proposer_index, parent_root, state_root, body_root}} : Maybe<&2, F.BeaconBlockHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(proposer_index)), Some{proposer_index}, Node3_inverse(proposer_index)) : {F.BeaconBlockHeaderValue.assemble(Some{slot}, _, F.Node7.from_value(F.Node7.to_value(parent_root)), F.Node7.from_value(F.Node7.to_value(state_root)), F.Node7.from_value(F.Node7.to_value(body_root))) == Some{F.BeaconBlockHeader{slot, proposer_index, parent_root, state_root, body_root}} : Maybe<&2, F.BeaconBlockHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(parent_root)), Some{parent_root}, Node7_inverse(parent_root)) : {F.BeaconBlockHeaderValue.assemble(Some{slot}, Some{proposer_index}, _, F.Node7.from_value(F.Node7.to_value(state_root)), F.Node7.from_value(F.Node7.to_value(body_root))) == Some{F.BeaconBlockHeader{slot, proposer_index, parent_root, state_root, body_root}} : Maybe<&2, F.BeaconBlockHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(state_root)), Some{state_root}, Node7_inverse(state_root)) : {F.BeaconBlockHeaderValue.assemble(Some{slot}, Some{proposer_index}, Some{parent_root}, _, F.Node7.from_value(F.Node7.to_value(body_root))) == Some{F.BeaconBlockHeader{slot, proposer_index, parent_root, state_root, body_root}} : Maybe<&2, F.BeaconBlockHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(body_root)), Some{body_root}, Node7_inverse(body_root)) : {F.BeaconBlockHeaderValue.assemble(Some{slot}, Some{proposer_index}, Some{parent_root}, Some{state_root}, _) == Some{F.BeaconBlockHeader{slot, proposer_index, parent_root, state_root, body_root}} : Maybe<&2, F.BeaconBlockHeaderValue()>}
  {==}

law SignedBeaconBlockHeaderValue_inverse:
  for +value: F.SignedBeaconBlockHeaderValue()
  {F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(value)) == Some{value} : Maybe<&2, F.SignedBeaconBlockHeaderValue()>}
def SignedBeaconBlockHeaderValue_inverse(value):
  F.SignedBeaconBlockHeader{message, signature} = value
  %Equal.sym(Maybe<&2, F.BeaconBlockHeaderValue()>, F.BeaconBlockHeaderValue.from_value(F.BeaconBlockHeaderValue.to_value(message)), Some{message}, BeaconBlockHeaderValue_inverse(message)) : {F.SignedBeaconBlockHeaderValue.assemble(_, F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SignedBeaconBlockHeader{message, signature}} : Maybe<&2, F.SignedBeaconBlockHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.SignedBeaconBlockHeaderValue.assemble(Some{message}, _) == Some{F.SignedBeaconBlockHeader{message, signature}} : Maybe<&2, F.SignedBeaconBlockHeaderValue()>}
  {==}

law ProposerSlashingValue_inverse:
  for +value: F.ProposerSlashingValue()
  {F.ProposerSlashingValue.from_value(F.ProposerSlashingValue.to_value(value)) == Some{value} : Maybe<&2, F.ProposerSlashingValue()>}
def ProposerSlashingValue_inverse(value):
  F.ProposerSlashing{signed_header_1, signed_header_2} = value
  %Equal.sym(Maybe<&2, F.SignedBeaconBlockHeaderValue()>, F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_header_1)), Some{signed_header_1}, SignedBeaconBlockHeaderValue_inverse(signed_header_1)) : {F.ProposerSlashingValue.assemble(_, F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_header_2))) == Some{F.ProposerSlashing{signed_header_1, signed_header_2}} : Maybe<&2, F.ProposerSlashingValue()>}
  %Equal.sym(Maybe<&2, F.SignedBeaconBlockHeaderValue()>, F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_header_2)), Some{signed_header_2}, SignedBeaconBlockHeaderValue_inverse(signed_header_2)) : {F.ProposerSlashingValue.assemble(Some{signed_header_1}, _) == Some{F.ProposerSlashing{signed_header_1, signed_header_2}} : Maybe<&2, F.ProposerSlashingValue()>}
  {==}

law Node33_append:
  for +xs: +List<F.Node7()>
  for +ys: +List<F.Node7()>
  for +acc: T.Value
  {F.Node7.seq_to_go(List.append(&2, F.Node7(), xs, ys), acc) == F.Node7.seq_to_go(ys, F.Node7.seq_to_go(xs, acc)) : T.Value}
def Node33_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node33_append(t, ys, T.Items{F.Node7.to_value(h), acc})

law Node33_cons:
  for +h: F.Node7()
  for +t: +List<F.Node7()>
  {F.Node7.seq_to(h <> t) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
def Node33_cons(h, t):
  %Equal.sym(+List<F.Node7()>, List.reverse.go(&2, F.Node7(), t, [h]), List.append(&2, F.Node7(), List.reverse(&2, F.Node7(), t), [h]), L.reverse_acc_append(F.Node7(), t, [], [h])) : {F.Node7.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
  Node33_append(List.reverse(&2, F.Node7(), t), [h], T.EmptyItems{})

law Node33_inverse_go:
  for +xs: +List<F.Node7()>
  for +acc: +List<F.Node7()>
  {F.Node7.seq_from_go(F.Node7.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node7(), acc, xs)} : Maybe<&2, +List<F.Node7()>>}
def Node33_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node7.seq_to(h <> t), T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)}, Node33_cons(h, t)) : {F.Node7.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(h)), Some{h}, Node7_inverse(h)) : {F.Node7.seq_step(_, acc, next => F.Node7.seq_from_go(F.Node7.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      Node33_inverse_go(t, h <> acc)

law Node33_inverse:
  for +value: F.Node33()
  {F.Node33.from_value(F.Node33.to_value(value)) == Some{value} : Maybe<&2, F.Node33()>}
def Node33_inverse(value):
  Node33_inverse_go(value, [])

law HistoricalBatchValue_inverse:
  for +value: F.HistoricalBatchValue()
  {F.HistoricalBatchValue.from_value(F.HistoricalBatchValue.to_value(value)) == Some{value} : Maybe<&2, F.HistoricalBatchValue()>}
def HistoricalBatchValue_inverse(value):
  F.HistoricalBatch{block_roots, state_roots} = value
  %Equal.sym(Maybe<&2, F.Node33()>, F.Node33.from_value(F.Node33.to_value(block_roots)), Some{block_roots}, Node33_inverse(block_roots)) : {F.HistoricalBatchValue.assemble(_, F.Node33.from_value(F.Node33.to_value(state_roots))) == Some{F.HistoricalBatch{block_roots, state_roots}} : Maybe<&2, F.HistoricalBatchValue()>}
  %Equal.sym(Maybe<&2, F.Node33()>, F.Node33.from_value(F.Node33.to_value(state_roots)), Some{state_roots}, Node33_inverse(state_roots)) : {F.HistoricalBatchValue.assemble(Some{block_roots}, _) == Some{F.HistoricalBatch{block_roots, state_roots}} : Maybe<&2, F.HistoricalBatchValue()>}
  {==}

law Eth1DataValue_inverse:
  for +value: F.Eth1DataValue()
  {F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(value)) == Some{value} : Maybe<&2, F.Eth1DataValue()>}
def Eth1DataValue_inverse(value):
  F.Eth1Data{deposit_root, deposit_count, block_hash} = value
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(deposit_root)), Some{deposit_root}, Node7_inverse(deposit_root)) : {F.Eth1DataValue.assemble(_, F.Node3.from_value(F.Node3.to_value(deposit_count)), F.Node7.from_value(F.Node7.to_value(block_hash))) == Some{F.Eth1Data{deposit_root, deposit_count, block_hash}} : Maybe<&2, F.Eth1DataValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(deposit_count)), Some{deposit_count}, Node3_inverse(deposit_count)) : {F.Eth1DataValue.assemble(Some{deposit_root}, _, F.Node7.from_value(F.Node7.to_value(block_hash))) == Some{F.Eth1Data{deposit_root, deposit_count, block_hash}} : Maybe<&2, F.Eth1DataValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(block_hash)), Some{block_hash}, Node7_inverse(block_hash)) : {F.Eth1DataValue.assemble(Some{deposit_root}, Some{deposit_count}, _) == Some{F.Eth1Data{deposit_root, deposit_count, block_hash}} : Maybe<&2, F.Eth1DataValue()>}
  {==}

law CheckpointValue_inverse:
  for +value: F.CheckpointValue()
  {F.CheckpointValue.from_value(F.CheckpointValue.to_value(value)) == Some{value} : Maybe<&2, F.CheckpointValue()>}
def CheckpointValue_inverse(value):
  F.Checkpoint{epoch, root} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(epoch)), Some{epoch}, Node3_inverse(epoch)) : {F.CheckpointValue.assemble(_, F.Node7.from_value(F.Node7.to_value(root))) == Some{F.Checkpoint{epoch, root}} : Maybe<&2, F.CheckpointValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(root)), Some{root}, Node7_inverse(root)) : {F.CheckpointValue.assemble(Some{epoch}, _) == Some{F.Checkpoint{epoch, root}} : Maybe<&2, F.CheckpointValue()>}
  {==}

law AttestationDataValue_inverse:
  for +value: F.AttestationDataValue()
  {F.AttestationDataValue.from_value(F.AttestationDataValue.to_value(value)) == Some{value} : Maybe<&2, F.AttestationDataValue()>}
def AttestationDataValue_inverse(value):
  F.AttestationData{slot, index, beacon_block_root, source, target} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(slot)), Some{slot}, Node3_inverse(slot)) : {F.AttestationDataValue.assemble(_, F.Node3.from_value(F.Node3.to_value(index)), F.Node7.from_value(F.Node7.to_value(beacon_block_root)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(source)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(target))) == Some{F.AttestationData{slot, index, beacon_block_root, source, target}} : Maybe<&2, F.AttestationDataValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(index)), Some{index}, Node3_inverse(index)) : {F.AttestationDataValue.assemble(Some{slot}, _, F.Node7.from_value(F.Node7.to_value(beacon_block_root)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(source)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(target))) == Some{F.AttestationData{slot, index, beacon_block_root, source, target}} : Maybe<&2, F.AttestationDataValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(beacon_block_root)), Some{beacon_block_root}, Node7_inverse(beacon_block_root)) : {F.AttestationDataValue.assemble(Some{slot}, Some{index}, _, F.CheckpointValue.from_value(F.CheckpointValue.to_value(source)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(target))) == Some{F.AttestationData{slot, index, beacon_block_root, source, target}} : Maybe<&2, F.AttestationDataValue()>}
  %Equal.sym(Maybe<&2, F.CheckpointValue()>, F.CheckpointValue.from_value(F.CheckpointValue.to_value(source)), Some{source}, CheckpointValue_inverse(source)) : {F.AttestationDataValue.assemble(Some{slot}, Some{index}, Some{beacon_block_root}, _, F.CheckpointValue.from_value(F.CheckpointValue.to_value(target))) == Some{F.AttestationData{slot, index, beacon_block_root, source, target}} : Maybe<&2, F.AttestationDataValue()>}
  %Equal.sym(Maybe<&2, F.CheckpointValue()>, F.CheckpointValue.from_value(F.CheckpointValue.to_value(target)), Some{target}, CheckpointValue_inverse(target)) : {F.AttestationDataValue.assemble(Some{slot}, Some{index}, Some{beacon_block_root}, Some{source}, _) == Some{F.AttestationData{slot, index, beacon_block_root, source, target}} : Maybe<&2, F.AttestationDataValue()>}
  {==}

law SingleAttestationValue_inverse:
  for +value: F.SingleAttestationValue()
  {F.SingleAttestationValue.from_value(F.SingleAttestationValue.to_value(value)) == Some{value} : Maybe<&2, F.SingleAttestationValue()>}
def SingleAttestationValue_inverse(value):
  F.SingleAttestation{committee_index, attester_index, data, signature} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(committee_index)), Some{committee_index}, Node3_inverse(committee_index)) : {F.SingleAttestationValue.assemble(_, F.Node3.from_value(F.Node3.to_value(attester_index)), F.AttestationDataValue.from_value(F.AttestationDataValue.to_value(data)), F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SingleAttestation{committee_index, attester_index, data, signature}} : Maybe<&2, F.SingleAttestationValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(attester_index)), Some{attester_index}, Node3_inverse(attester_index)) : {F.SingleAttestationValue.assemble(Some{committee_index}, _, F.AttestationDataValue.from_value(F.AttestationDataValue.to_value(data)), F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SingleAttestation{committee_index, attester_index, data, signature}} : Maybe<&2, F.SingleAttestationValue()>}
  %Equal.sym(Maybe<&2, F.AttestationDataValue()>, F.AttestationDataValue.from_value(F.AttestationDataValue.to_value(data)), Some{data}, AttestationDataValue_inverse(data)) : {F.SingleAttestationValue.assemble(Some{committee_index}, Some{attester_index}, _, F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SingleAttestation{committee_index, attester_index, data, signature}} : Maybe<&2, F.SingleAttestationValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.SingleAttestationValue.assemble(Some{committee_index}, Some{attester_index}, Some{data}, _) == Some{F.SingleAttestation{committee_index, attester_index, data, signature}} : Maybe<&2, F.SingleAttestationValue()>}
  {==}

law Node39_inverse:
  for +value: F.Node39()
  {F.Node39.from_value(F.Node39.to_value(value)) == Some{value} : Maybe<&2, F.Node39()>}
def Node39_inverse(value):
  {==}

law Node40_inverse:
  for +value: F.Node40()
  {F.Node40.from_value(F.Node40.to_value(value)) == Some{value} : Maybe<&2, F.Node40()>}
def Node40_inverse(value):
  {==}

law AttestationValue_inverse:
  for +value: F.AttestationValue()
  {F.AttestationValue.from_value(F.AttestationValue.to_value(value)) == Some{value} : Maybe<&2, F.AttestationValue()>}
def AttestationValue_inverse(value):
  F.Attestation{aggregation_bits, data, signature, committee_bits} = value
  %Equal.sym(Maybe<&2, F.Node39()>, F.Node39.from_value(F.Node39.to_value(aggregation_bits)), Some{aggregation_bits}, Node39_inverse(aggregation_bits)) : {F.AttestationValue.assemble(_, F.AttestationDataValue.from_value(F.AttestationDataValue.to_value(data)), F.Node9.from_value(F.Node9.to_value(signature)), F.Node40.from_value(F.Node40.to_value(committee_bits))) == Some{F.Attestation{aggregation_bits, data, signature, committee_bits}} : Maybe<&2, F.AttestationValue()>}
  %Equal.sym(Maybe<&2, F.AttestationDataValue()>, F.AttestationDataValue.from_value(F.AttestationDataValue.to_value(data)), Some{data}, AttestationDataValue_inverse(data)) : {F.AttestationValue.assemble(Some{aggregation_bits}, _, F.Node9.from_value(F.Node9.to_value(signature)), F.Node40.from_value(F.Node40.to_value(committee_bits))) == Some{F.Attestation{aggregation_bits, data, signature, committee_bits}} : Maybe<&2, F.AttestationValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.AttestationValue.assemble(Some{aggregation_bits}, Some{data}, _, F.Node40.from_value(F.Node40.to_value(committee_bits))) == Some{F.Attestation{aggregation_bits, data, signature, committee_bits}} : Maybe<&2, F.AttestationValue()>}
  %Equal.sym(Maybe<&2, F.Node40()>, F.Node40.from_value(F.Node40.to_value(committee_bits)), Some{committee_bits}, Node40_inverse(committee_bits)) : {F.AttestationValue.assemble(Some{aggregation_bits}, Some{data}, Some{signature}, _) == Some{F.Attestation{aggregation_bits, data, signature, committee_bits}} : Maybe<&2, F.AttestationValue()>}
  {==}

law AggregateAndProofValue_inverse:
  for +value: F.AggregateAndProofValue()
  {F.AggregateAndProofValue.from_value(F.AggregateAndProofValue.to_value(value)) == Some{value} : Maybe<&2, F.AggregateAndProofValue()>}
def AggregateAndProofValue_inverse(value):
  F.AggregateAndProof{aggregator_index, aggregate, selection_proof} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(aggregator_index)), Some{aggregator_index}, Node3_inverse(aggregator_index)) : {F.AggregateAndProofValue.assemble(_, F.AttestationValue.from_value(F.AttestationValue.to_value(aggregate)), F.Node9.from_value(F.Node9.to_value(selection_proof))) == Some{F.AggregateAndProof{aggregator_index, aggregate, selection_proof}} : Maybe<&2, F.AggregateAndProofValue()>}
  %Equal.sym(Maybe<&2, F.AttestationValue()>, F.AttestationValue.from_value(F.AttestationValue.to_value(aggregate)), Some{aggregate}, AttestationValue_inverse(aggregate)) : {F.AggregateAndProofValue.assemble(Some{aggregator_index}, _, F.Node9.from_value(F.Node9.to_value(selection_proof))) == Some{F.AggregateAndProof{aggregator_index, aggregate, selection_proof}} : Maybe<&2, F.AggregateAndProofValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(selection_proof)), Some{selection_proof}, Node9_inverse(selection_proof)) : {F.AggregateAndProofValue.assemble(Some{aggregator_index}, Some{aggregate}, _) == Some{F.AggregateAndProof{aggregator_index, aggregate, selection_proof}} : Maybe<&2, F.AggregateAndProofValue()>}
  {==}

law SignedAggregateAndProofValue_inverse:
  for +value: F.SignedAggregateAndProofValue()
  {F.SignedAggregateAndProofValue.from_value(F.SignedAggregateAndProofValue.to_value(value)) == Some{value} : Maybe<&2, F.SignedAggregateAndProofValue()>}
def SignedAggregateAndProofValue_inverse(value):
  F.SignedAggregateAndProof{message, signature} = value
  %Equal.sym(Maybe<&2, F.AggregateAndProofValue()>, F.AggregateAndProofValue.from_value(F.AggregateAndProofValue.to_value(message)), Some{message}, AggregateAndProofValue_inverse(message)) : {F.SignedAggregateAndProofValue.assemble(_, F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SignedAggregateAndProof{message, signature}} : Maybe<&2, F.SignedAggregateAndProofValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.SignedAggregateAndProofValue.assemble(Some{message}, _) == Some{F.SignedAggregateAndProof{message, signature}} : Maybe<&2, F.SignedAggregateAndProofValue()>}
  {==}

law Node44_inverse:
  for +value: F.Node44()
  {F.Node44.from_value(F.Node44.to_value(value)) == Some{value} : Maybe<&2, F.Node44()>}
def Node44_inverse(value):
  {==}

law PendingAttestationValue_inverse:
  for +value: F.PendingAttestationValue()
  {F.PendingAttestationValue.from_value(F.PendingAttestationValue.to_value(value)) == Some{value} : Maybe<&2, F.PendingAttestationValue()>}
def PendingAttestationValue_inverse(value):
  F.PendingAttestation{aggregation_bits, data, inclusion_delay, proposer_index} = value
  %Equal.sym(Maybe<&2, F.Node44()>, F.Node44.from_value(F.Node44.to_value(aggregation_bits)), Some{aggregation_bits}, Node44_inverse(aggregation_bits)) : {F.PendingAttestationValue.assemble(_, F.AttestationDataValue.from_value(F.AttestationDataValue.to_value(data)), F.Node3.from_value(F.Node3.to_value(inclusion_delay)), F.Node3.from_value(F.Node3.to_value(proposer_index))) == Some{F.PendingAttestation{aggregation_bits, data, inclusion_delay, proposer_index}} : Maybe<&2, F.PendingAttestationValue()>}
  %Equal.sym(Maybe<&2, F.AttestationDataValue()>, F.AttestationDataValue.from_value(F.AttestationDataValue.to_value(data)), Some{data}, AttestationDataValue_inverse(data)) : {F.PendingAttestationValue.assemble(Some{aggregation_bits}, _, F.Node3.from_value(F.Node3.to_value(inclusion_delay)), F.Node3.from_value(F.Node3.to_value(proposer_index))) == Some{F.PendingAttestation{aggregation_bits, data, inclusion_delay, proposer_index}} : Maybe<&2, F.PendingAttestationValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(inclusion_delay)), Some{inclusion_delay}, Node3_inverse(inclusion_delay)) : {F.PendingAttestationValue.assemble(Some{aggregation_bits}, Some{data}, _, F.Node3.from_value(F.Node3.to_value(proposer_index))) == Some{F.PendingAttestation{aggregation_bits, data, inclusion_delay, proposer_index}} : Maybe<&2, F.PendingAttestationValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(proposer_index)), Some{proposer_index}, Node3_inverse(proposer_index)) : {F.PendingAttestationValue.assemble(Some{aggregation_bits}, Some{data}, Some{inclusion_delay}, _) == Some{F.PendingAttestation{aggregation_bits, data, inclusion_delay, proposer_index}} : Maybe<&2, F.PendingAttestationValue()>}
  {==}

law Node46_append:
  for +xs: +List<F.Node3()>
  for +ys: +List<F.Node3()>
  for +acc: T.Value
  {F.Node3.seq_to_go(List.append(&2, F.Node3(), xs, ys), acc) == F.Node3.seq_to_go(ys, F.Node3.seq_to_go(xs, acc)) : T.Value}
def Node46_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node46_append(t, ys, T.Items{F.Node3.to_value(h), acc})

law Node46_cons:
  for +h: F.Node3()
  for +t: +List<F.Node3()>
  {F.Node3.seq_to(h <> t) == T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)} : T.Value}
def Node46_cons(h, t):
  %Equal.sym(+List<F.Node3()>, List.reverse.go(&2, F.Node3(), t, [h]), List.append(&2, F.Node3(), List.reverse(&2, F.Node3(), t), [h]), L.reverse_acc_append(F.Node3(), t, [], [h])) : {F.Node3.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)} : T.Value}
  Node46_append(List.reverse(&2, F.Node3(), t), [h], T.EmptyItems{})

law Node46_inverse_go:
  for +xs: +List<F.Node3()>
  for +acc: +List<F.Node3()>
  {F.Node3.seq_from_go(F.Node3.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node3(), acc, xs)} : Maybe<&2, +List<F.Node3()>>}
def Node46_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node3.seq_to(h <> t), T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)}, Node46_cons(h, t)) : {F.Node3.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node3(), acc, h <> t)} : Maybe<&2, +List<F.Node3()>>}
      %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(h)), Some{h}, Node3_inverse(h)) : {F.Node3.seq_step(_, acc, next => F.Node3.seq_from_go(F.Node3.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node3(), acc, h <> t)} : Maybe<&2, +List<F.Node3()>>}
      Node46_inverse_go(t, h <> acc)

law Node46_inverse:
  for +value: F.Node46()
  {F.Node46.from_value(F.Node46.to_value(value)) == Some{value} : Maybe<&2, F.Node46()>}
def Node46_inverse(value):
  Node46_inverse_go(value, [])

law IndexedAttestationValue_inverse:
  for +value: F.IndexedAttestationValue()
  {F.IndexedAttestationValue.from_value(F.IndexedAttestationValue.to_value(value)) == Some{value} : Maybe<&2, F.IndexedAttestationValue()>}
def IndexedAttestationValue_inverse(value):
  F.IndexedAttestation{attesting_indices, data, signature} = value
  %Equal.sym(Maybe<&2, F.Node46()>, F.Node46.from_value(F.Node46.to_value(attesting_indices)), Some{attesting_indices}, Node46_inverse(attesting_indices)) : {F.IndexedAttestationValue.assemble(_, F.AttestationDataValue.from_value(F.AttestationDataValue.to_value(data)), F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.IndexedAttestation{attesting_indices, data, signature}} : Maybe<&2, F.IndexedAttestationValue()>}
  %Equal.sym(Maybe<&2, F.AttestationDataValue()>, F.AttestationDataValue.from_value(F.AttestationDataValue.to_value(data)), Some{data}, AttestationDataValue_inverse(data)) : {F.IndexedAttestationValue.assemble(Some{attesting_indices}, _, F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.IndexedAttestation{attesting_indices, data, signature}} : Maybe<&2, F.IndexedAttestationValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.IndexedAttestationValue.assemble(Some{attesting_indices}, Some{data}, _) == Some{F.IndexedAttestation{attesting_indices, data, signature}} : Maybe<&2, F.IndexedAttestationValue()>}
  {==}

law AttesterSlashingValue_inverse:
  for +value: F.AttesterSlashingValue()
  {F.AttesterSlashingValue.from_value(F.AttesterSlashingValue.to_value(value)) == Some{value} : Maybe<&2, F.AttesterSlashingValue()>}
def AttesterSlashingValue_inverse(value):
  F.AttesterSlashing{attestation_1, attestation_2} = value
  %Equal.sym(Maybe<&2, F.IndexedAttestationValue()>, F.IndexedAttestationValue.from_value(F.IndexedAttestationValue.to_value(attestation_1)), Some{attestation_1}, IndexedAttestationValue_inverse(attestation_1)) : {F.AttesterSlashingValue.assemble(_, F.IndexedAttestationValue.from_value(F.IndexedAttestationValue.to_value(attestation_2))) == Some{F.AttesterSlashing{attestation_1, attestation_2}} : Maybe<&2, F.AttesterSlashingValue()>}
  %Equal.sym(Maybe<&2, F.IndexedAttestationValue()>, F.IndexedAttestationValue.from_value(F.IndexedAttestationValue.to_value(attestation_2)), Some{attestation_2}, IndexedAttestationValue_inverse(attestation_2)) : {F.AttesterSlashingValue.assemble(Some{attestation_1}, _) == Some{F.AttesterSlashing{attestation_1, attestation_2}} : Maybe<&2, F.AttesterSlashingValue()>}
  {==}

law ForkDataValue_inverse:
  for +value: F.ForkDataValue()
  {F.ForkDataValue.from_value(F.ForkDataValue.to_value(value)) == Some{value} : Maybe<&2, F.ForkDataValue()>}
def ForkDataValue_inverse(value):
  F.ForkData{current_version, genesis_validators_root} = value
  %Equal.sym(Maybe<&2, F.Node6()>, F.Node6.from_value(F.Node6.to_value(current_version)), Some{current_version}, Node6_inverse(current_version)) : {F.ForkDataValue.assemble(_, F.Node7.from_value(F.Node7.to_value(genesis_validators_root))) == Some{F.ForkData{current_version, genesis_validators_root}} : Maybe<&2, F.ForkDataValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(genesis_validators_root)), Some{genesis_validators_root}, Node7_inverse(genesis_validators_root)) : {F.ForkDataValue.assemble(Some{current_version}, _) == Some{F.ForkData{current_version, genesis_validators_root}} : Maybe<&2, F.ForkDataValue()>}
  {==}

law SigningDataValue_inverse:
  for +value: F.SigningDataValue()
  {F.SigningDataValue.from_value(F.SigningDataValue.to_value(value)) == Some{value} : Maybe<&2, F.SigningDataValue()>}
def SigningDataValue_inverse(value):
  F.SigningData{object_root, domain} = value
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(object_root)), Some{object_root}, Node7_inverse(object_root)) : {F.SigningDataValue.assemble(_, F.Node7.from_value(F.Node7.to_value(domain))) == Some{F.SigningData{object_root, domain}} : Maybe<&2, F.SigningDataValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(domain)), Some{domain}, Node7_inverse(domain)) : {F.SigningDataValue.assemble(Some{object_root}, _) == Some{F.SigningData{object_root, domain}} : Maybe<&2, F.SigningDataValue()>}
  {==}

law DepositRequestValue_inverse:
  for +value: F.DepositRequestValue()
  {F.DepositRequestValue.from_value(F.DepositRequestValue.to_value(value)) == Some{value} : Maybe<&2, F.DepositRequestValue()>}
def DepositRequestValue_inverse(value):
  F.DepositRequest{pubkey, withdrawal_credentials, amount, signature, index} = value
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(pubkey)), Some{pubkey}, Node8_inverse(pubkey)) : {F.DepositRequestValue.assemble(_, F.Node7.from_value(F.Node7.to_value(withdrawal_credentials)), F.Node3.from_value(F.Node3.to_value(amount)), F.Node9.from_value(F.Node9.to_value(signature)), F.Node3.from_value(F.Node3.to_value(index))) == Some{F.DepositRequest{pubkey, withdrawal_credentials, amount, signature, index}} : Maybe<&2, F.DepositRequestValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(withdrawal_credentials)), Some{withdrawal_credentials}, Node7_inverse(withdrawal_credentials)) : {F.DepositRequestValue.assemble(Some{pubkey}, _, F.Node3.from_value(F.Node3.to_value(amount)), F.Node9.from_value(F.Node9.to_value(signature)), F.Node3.from_value(F.Node3.to_value(index))) == Some{F.DepositRequest{pubkey, withdrawal_credentials, amount, signature, index}} : Maybe<&2, F.DepositRequestValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(amount)), Some{amount}, Node3_inverse(amount)) : {F.DepositRequestValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, _, F.Node9.from_value(F.Node9.to_value(signature)), F.Node3.from_value(F.Node3.to_value(index))) == Some{F.DepositRequest{pubkey, withdrawal_credentials, amount, signature, index}} : Maybe<&2, F.DepositRequestValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.DepositRequestValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, Some{amount}, _, F.Node3.from_value(F.Node3.to_value(index))) == Some{F.DepositRequest{pubkey, withdrawal_credentials, amount, signature, index}} : Maybe<&2, F.DepositRequestValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(index)), Some{index}, Node3_inverse(index)) : {F.DepositRequestValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, Some{amount}, Some{signature}, _) == Some{F.DepositRequest{pubkey, withdrawal_credentials, amount, signature, index}} : Maybe<&2, F.DepositRequestValue()>}
  {==}

law PendingDepositValue_inverse:
  for +value: F.PendingDepositValue()
  {F.PendingDepositValue.from_value(F.PendingDepositValue.to_value(value)) == Some{value} : Maybe<&2, F.PendingDepositValue()>}
def PendingDepositValue_inverse(value):
  F.PendingDeposit{pubkey, withdrawal_credentials, amount, signature, slot} = value
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(pubkey)), Some{pubkey}, Node8_inverse(pubkey)) : {F.PendingDepositValue.assemble(_, F.Node7.from_value(F.Node7.to_value(withdrawal_credentials)), F.Node3.from_value(F.Node3.to_value(amount)), F.Node9.from_value(F.Node9.to_value(signature)), F.Node3.from_value(F.Node3.to_value(slot))) == Some{F.PendingDeposit{pubkey, withdrawal_credentials, amount, signature, slot}} : Maybe<&2, F.PendingDepositValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(withdrawal_credentials)), Some{withdrawal_credentials}, Node7_inverse(withdrawal_credentials)) : {F.PendingDepositValue.assemble(Some{pubkey}, _, F.Node3.from_value(F.Node3.to_value(amount)), F.Node9.from_value(F.Node9.to_value(signature)), F.Node3.from_value(F.Node3.to_value(slot))) == Some{F.PendingDeposit{pubkey, withdrawal_credentials, amount, signature, slot}} : Maybe<&2, F.PendingDepositValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(amount)), Some{amount}, Node3_inverse(amount)) : {F.PendingDepositValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, _, F.Node9.from_value(F.Node9.to_value(signature)), F.Node3.from_value(F.Node3.to_value(slot))) == Some{F.PendingDeposit{pubkey, withdrawal_credentials, amount, signature, slot}} : Maybe<&2, F.PendingDepositValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.PendingDepositValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, Some{amount}, _, F.Node3.from_value(F.Node3.to_value(slot))) == Some{F.PendingDeposit{pubkey, withdrawal_credentials, amount, signature, slot}} : Maybe<&2, F.PendingDepositValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(slot)), Some{slot}, Node3_inverse(slot)) : {F.PendingDepositValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, Some{amount}, Some{signature}, _) == Some{F.PendingDeposit{pubkey, withdrawal_credentials, amount, signature, slot}} : Maybe<&2, F.PendingDepositValue()>}
  {==}

law Node53_append:
  for +xs: +List<F.Node8()>
  for +ys: +List<F.Node8()>
  for +acc: T.Value
  {F.Node8.seq_to_go(List.append(&2, F.Node8(), xs, ys), acc) == F.Node8.seq_to_go(ys, F.Node8.seq_to_go(xs, acc)) : T.Value}
def Node53_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node53_append(t, ys, T.Items{F.Node8.to_value(h), acc})

law Node53_cons:
  for +h: F.Node8()
  for +t: +List<F.Node8()>
  {F.Node8.seq_to(h <> t) == T.Items{F.Node8.to_value(h), F.Node8.seq_to(t)} : T.Value}
def Node53_cons(h, t):
  %Equal.sym(+List<F.Node8()>, List.reverse.go(&2, F.Node8(), t, [h]), List.append(&2, F.Node8(), List.reverse(&2, F.Node8(), t), [h]), L.reverse_acc_append(F.Node8(), t, [], [h])) : {F.Node8.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node8.to_value(h), F.Node8.seq_to(t)} : T.Value}
  Node53_append(List.reverse(&2, F.Node8(), t), [h], T.EmptyItems{})

law Node53_inverse_go:
  for +xs: +List<F.Node8()>
  for +acc: +List<F.Node8()>
  {F.Node8.seq_from_go(F.Node8.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node8(), acc, xs)} : Maybe<&2, +List<F.Node8()>>}
def Node53_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node8.seq_to(h <> t), T.Items{F.Node8.to_value(h), F.Node8.seq_to(t)}, Node53_cons(h, t)) : {F.Node8.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node8(), acc, h <> t)} : Maybe<&2, +List<F.Node8()>>}
      %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(h)), Some{h}, Node8_inverse(h)) : {F.Node8.seq_step(_, acc, next => F.Node8.seq_from_go(F.Node8.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node8(), acc, h <> t)} : Maybe<&2, +List<F.Node8()>>}
      Node53_inverse_go(t, h <> acc)

law Node53_inverse:
  for +value: F.Node53()
  {F.Node53.from_value(F.Node53.to_value(value)) == Some{value} : Maybe<&2, F.Node53()>}
def Node53_inverse(value):
  Node53_inverse_go(value, [])

law SyncCommitteeValue_inverse:
  for +value: F.SyncCommitteeValue()
  {F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(value)) == Some{value} : Maybe<&2, F.SyncCommitteeValue()>}
def SyncCommitteeValue_inverse(value):
  F.SyncCommittee{pubkeys, aggregate_pubkey} = value
  %Equal.sym(Maybe<&2, F.Node53()>, F.Node53.from_value(F.Node53.to_value(pubkeys)), Some{pubkeys}, Node53_inverse(pubkeys)) : {F.SyncCommitteeValue.assemble(_, F.Node8.from_value(F.Node8.to_value(aggregate_pubkey))) == Some{F.SyncCommittee{pubkeys, aggregate_pubkey}} : Maybe<&2, F.SyncCommitteeValue()>}
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(aggregate_pubkey)), Some{aggregate_pubkey}, Node8_inverse(aggregate_pubkey)) : {F.SyncCommitteeValue.assemble(Some{pubkeys}, _) == Some{F.SyncCommittee{pubkeys, aggregate_pubkey}} : Maybe<&2, F.SyncCommitteeValue()>}
  {==}

law DepositDataValue_inverse:
  for +value: F.DepositDataValue()
  {F.DepositDataValue.from_value(F.DepositDataValue.to_value(value)) == Some{value} : Maybe<&2, F.DepositDataValue()>}
def DepositDataValue_inverse(value):
  F.DepositData{pubkey, withdrawal_credentials, amount, signature} = value
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(pubkey)), Some{pubkey}, Node8_inverse(pubkey)) : {F.DepositDataValue.assemble(_, F.Node7.from_value(F.Node7.to_value(withdrawal_credentials)), F.Node3.from_value(F.Node3.to_value(amount)), F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.DepositData{pubkey, withdrawal_credentials, amount, signature}} : Maybe<&2, F.DepositDataValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(withdrawal_credentials)), Some{withdrawal_credentials}, Node7_inverse(withdrawal_credentials)) : {F.DepositDataValue.assemble(Some{pubkey}, _, F.Node3.from_value(F.Node3.to_value(amount)), F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.DepositData{pubkey, withdrawal_credentials, amount, signature}} : Maybe<&2, F.DepositDataValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(amount)), Some{amount}, Node3_inverse(amount)) : {F.DepositDataValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, _, F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.DepositData{pubkey, withdrawal_credentials, amount, signature}} : Maybe<&2, F.DepositDataValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.DepositDataValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, Some{amount}, _) == Some{F.DepositData{pubkey, withdrawal_credentials, amount, signature}} : Maybe<&2, F.DepositDataValue()>}
  {==}

law Node56_append:
  for +xs: +List<F.Node7()>
  for +ys: +List<F.Node7()>
  for +acc: T.Value
  {F.Node7.seq_to_go(List.append(&2, F.Node7(), xs, ys), acc) == F.Node7.seq_to_go(ys, F.Node7.seq_to_go(xs, acc)) : T.Value}
def Node56_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node56_append(t, ys, T.Items{F.Node7.to_value(h), acc})

law Node56_cons:
  for +h: F.Node7()
  for +t: +List<F.Node7()>
  {F.Node7.seq_to(h <> t) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
def Node56_cons(h, t):
  %Equal.sym(+List<F.Node7()>, List.reverse.go(&2, F.Node7(), t, [h]), List.append(&2, F.Node7(), List.reverse(&2, F.Node7(), t), [h]), L.reverse_acc_append(F.Node7(), t, [], [h])) : {F.Node7.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
  Node56_append(List.reverse(&2, F.Node7(), t), [h], T.EmptyItems{})

law Node56_inverse_go:
  for +xs: +List<F.Node7()>
  for +acc: +List<F.Node7()>
  {F.Node7.seq_from_go(F.Node7.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node7(), acc, xs)} : Maybe<&2, +List<F.Node7()>>}
def Node56_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node7.seq_to(h <> t), T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)}, Node56_cons(h, t)) : {F.Node7.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(h)), Some{h}, Node7_inverse(h)) : {F.Node7.seq_step(_, acc, next => F.Node7.seq_from_go(F.Node7.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      Node56_inverse_go(t, h <> acc)

law Node56_inverse:
  for +value: F.Node56()
  {F.Node56.from_value(F.Node56.to_value(value)) == Some{value} : Maybe<&2, F.Node56()>}
def Node56_inverse(value):
  Node56_inverse_go(value, [])

law DepositValue_inverse:
  for +value: F.DepositValue()
  {F.DepositValue.from_value(F.DepositValue.to_value(value)) == Some{value} : Maybe<&2, F.DepositValue()>}
def DepositValue_inverse(value):
  F.Deposit{proof, data} = value
  %Equal.sym(Maybe<&2, F.Node56()>, F.Node56.from_value(F.Node56.to_value(proof)), Some{proof}, Node56_inverse(proof)) : {F.DepositValue.assemble(_, F.DepositDataValue.from_value(F.DepositDataValue.to_value(data))) == Some{F.Deposit{proof, data}} : Maybe<&2, F.DepositValue()>}
  %Equal.sym(Maybe<&2, F.DepositDataValue()>, F.DepositDataValue.from_value(F.DepositDataValue.to_value(data)), Some{data}, DepositDataValue_inverse(data)) : {F.DepositValue.assemble(Some{proof}, _) == Some{F.Deposit{proof, data}} : Maybe<&2, F.DepositValue()>}
  {==}

law DepositMessageValue_inverse:
  for +value: F.DepositMessageValue()
  {F.DepositMessageValue.from_value(F.DepositMessageValue.to_value(value)) == Some{value} : Maybe<&2, F.DepositMessageValue()>}
def DepositMessageValue_inverse(value):
  F.DepositMessage{pubkey, withdrawal_credentials, amount} = value
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(pubkey)), Some{pubkey}, Node8_inverse(pubkey)) : {F.DepositMessageValue.assemble(_, F.Node7.from_value(F.Node7.to_value(withdrawal_credentials)), F.Node3.from_value(F.Node3.to_value(amount))) == Some{F.DepositMessage{pubkey, withdrawal_credentials, amount}} : Maybe<&2, F.DepositMessageValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(withdrawal_credentials)), Some{withdrawal_credentials}, Node7_inverse(withdrawal_credentials)) : {F.DepositMessageValue.assemble(Some{pubkey}, _, F.Node3.from_value(F.Node3.to_value(amount))) == Some{F.DepositMessage{pubkey, withdrawal_credentials, amount}} : Maybe<&2, F.DepositMessageValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(amount)), Some{amount}, Node3_inverse(amount)) : {F.DepositMessageValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, _) == Some{F.DepositMessage{pubkey, withdrawal_credentials, amount}} : Maybe<&2, F.DepositMessageValue()>}
  {==}

law ValidatorValue_inverse:
  for +value: F.ValidatorValue()
  {F.ValidatorValue.from_value(F.ValidatorValue.to_value(value)) == Some{value} : Maybe<&2, F.ValidatorValue()>}
def ValidatorValue_inverse(value):
  F.Validator{pubkey, withdrawal_credentials, effective_balance, slashed, activation_eligibility_epoch, activation_epoch, exit_epoch, withdrawable_epoch} = value
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(pubkey)), Some{pubkey}, Node8_inverse(pubkey)) : {F.ValidatorValue.assemble(_, F.Node7.from_value(F.Node7.to_value(withdrawal_credentials)), F.Node3.from_value(F.Node3.to_value(effective_balance)), F.Node0.from_value(F.Node0.to_value(slashed)), F.Node3.from_value(F.Node3.to_value(activation_eligibility_epoch)), F.Node3.from_value(F.Node3.to_value(activation_epoch)), F.Node3.from_value(F.Node3.to_value(exit_epoch)), F.Node3.from_value(F.Node3.to_value(withdrawable_epoch))) == Some{F.Validator{pubkey, withdrawal_credentials, effective_balance, slashed, activation_eligibility_epoch, activation_epoch, exit_epoch, withdrawable_epoch}} : Maybe<&2, F.ValidatorValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(withdrawal_credentials)), Some{withdrawal_credentials}, Node7_inverse(withdrawal_credentials)) : {F.ValidatorValue.assemble(Some{pubkey}, _, F.Node3.from_value(F.Node3.to_value(effective_balance)), F.Node0.from_value(F.Node0.to_value(slashed)), F.Node3.from_value(F.Node3.to_value(activation_eligibility_epoch)), F.Node3.from_value(F.Node3.to_value(activation_epoch)), F.Node3.from_value(F.Node3.to_value(exit_epoch)), F.Node3.from_value(F.Node3.to_value(withdrawable_epoch))) == Some{F.Validator{pubkey, withdrawal_credentials, effective_balance, slashed, activation_eligibility_epoch, activation_epoch, exit_epoch, withdrawable_epoch}} : Maybe<&2, F.ValidatorValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(effective_balance)), Some{effective_balance}, Node3_inverse(effective_balance)) : {F.ValidatorValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, _, F.Node0.from_value(F.Node0.to_value(slashed)), F.Node3.from_value(F.Node3.to_value(activation_eligibility_epoch)), F.Node3.from_value(F.Node3.to_value(activation_epoch)), F.Node3.from_value(F.Node3.to_value(exit_epoch)), F.Node3.from_value(F.Node3.to_value(withdrawable_epoch))) == Some{F.Validator{pubkey, withdrawal_credentials, effective_balance, slashed, activation_eligibility_epoch, activation_epoch, exit_epoch, withdrawable_epoch}} : Maybe<&2, F.ValidatorValue()>}
  %Equal.sym(Maybe<&2, F.Node0()>, F.Node0.from_value(F.Node0.to_value(slashed)), Some{slashed}, Node0_inverse(slashed)) : {F.ValidatorValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, Some{effective_balance}, _, F.Node3.from_value(F.Node3.to_value(activation_eligibility_epoch)), F.Node3.from_value(F.Node3.to_value(activation_epoch)), F.Node3.from_value(F.Node3.to_value(exit_epoch)), F.Node3.from_value(F.Node3.to_value(withdrawable_epoch))) == Some{F.Validator{pubkey, withdrawal_credentials, effective_balance, slashed, activation_eligibility_epoch, activation_epoch, exit_epoch, withdrawable_epoch}} : Maybe<&2, F.ValidatorValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(activation_eligibility_epoch)), Some{activation_eligibility_epoch}, Node3_inverse(activation_eligibility_epoch)) : {F.ValidatorValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, Some{effective_balance}, Some{slashed}, _, F.Node3.from_value(F.Node3.to_value(activation_epoch)), F.Node3.from_value(F.Node3.to_value(exit_epoch)), F.Node3.from_value(F.Node3.to_value(withdrawable_epoch))) == Some{F.Validator{pubkey, withdrawal_credentials, effective_balance, slashed, activation_eligibility_epoch, activation_epoch, exit_epoch, withdrawable_epoch}} : Maybe<&2, F.ValidatorValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(activation_epoch)), Some{activation_epoch}, Node3_inverse(activation_epoch)) : {F.ValidatorValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, Some{effective_balance}, Some{slashed}, Some{activation_eligibility_epoch}, _, F.Node3.from_value(F.Node3.to_value(exit_epoch)), F.Node3.from_value(F.Node3.to_value(withdrawable_epoch))) == Some{F.Validator{pubkey, withdrawal_credentials, effective_balance, slashed, activation_eligibility_epoch, activation_epoch, exit_epoch, withdrawable_epoch}} : Maybe<&2, F.ValidatorValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(exit_epoch)), Some{exit_epoch}, Node3_inverse(exit_epoch)) : {F.ValidatorValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, Some{effective_balance}, Some{slashed}, Some{activation_eligibility_epoch}, Some{activation_epoch}, _, F.Node3.from_value(F.Node3.to_value(withdrawable_epoch))) == Some{F.Validator{pubkey, withdrawal_credentials, effective_balance, slashed, activation_eligibility_epoch, activation_epoch, exit_epoch, withdrawable_epoch}} : Maybe<&2, F.ValidatorValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(withdrawable_epoch)), Some{withdrawable_epoch}, Node3_inverse(withdrawable_epoch)) : {F.ValidatorValue.assemble(Some{pubkey}, Some{withdrawal_credentials}, Some{effective_balance}, Some{slashed}, Some{activation_eligibility_epoch}, Some{activation_epoch}, Some{exit_epoch}, _) == Some{F.Validator{pubkey, withdrawal_credentials, effective_balance, slashed, activation_eligibility_epoch, activation_epoch, exit_epoch, withdrawable_epoch}} : Maybe<&2, F.ValidatorValue()>}
  {==}

law Node59_append:
  for +xs: +List<F.Node7()>
  for +ys: +List<F.Node7()>
  for +acc: T.Value
  {F.Node7.seq_to_go(List.append(&2, F.Node7(), xs, ys), acc) == F.Node7.seq_to_go(ys, F.Node7.seq_to_go(xs, acc)) : T.Value}
def Node59_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node59_append(t, ys, T.Items{F.Node7.to_value(h), acc})

law Node59_cons:
  for +h: F.Node7()
  for +t: +List<F.Node7()>
  {F.Node7.seq_to(h <> t) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
def Node59_cons(h, t):
  %Equal.sym(+List<F.Node7()>, List.reverse.go(&2, F.Node7(), t, [h]), List.append(&2, F.Node7(), List.reverse(&2, F.Node7(), t), [h]), L.reverse_acc_append(F.Node7(), t, [], [h])) : {F.Node7.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
  Node59_append(List.reverse(&2, F.Node7(), t), [h], T.EmptyItems{})

law Node59_inverse_go:
  for +xs: +List<F.Node7()>
  for +acc: +List<F.Node7()>
  {F.Node7.seq_from_go(F.Node7.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node7(), acc, xs)} : Maybe<&2, +List<F.Node7()>>}
def Node59_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node7.seq_to(h <> t), T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)}, Node59_cons(h, t)) : {F.Node7.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(h)), Some{h}, Node7_inverse(h)) : {F.Node7.seq_step(_, acc, next => F.Node7.seq_from_go(F.Node7.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      Node59_inverse_go(t, h <> acc)

law Node59_inverse:
  for +value: F.Node59()
  {F.Node59.from_value(F.Node59.to_value(value)) == Some{value} : Maybe<&2, F.Node59()>}
def Node59_inverse(value):
  Node59_inverse_go(value, [])

law Node60_inverse:
  for +value: F.Node60()
  {F.Node60.from_value(F.Node60.to_value(value)) == Some{value} : Maybe<&2, F.Node60()>}
def Node60_inverse(value):
  {==}

law ConsolidationRequestValue_inverse:
  for +value: F.ConsolidationRequestValue()
  {F.ConsolidationRequestValue.from_value(F.ConsolidationRequestValue.to_value(value)) == Some{value} : Maybe<&2, F.ConsolidationRequestValue()>}
def ConsolidationRequestValue_inverse(value):
  F.ConsolidationRequest{source_address, source_pubkey, target_pubkey} = value
  %Equal.sym(Maybe<&2, F.Node11()>, F.Node11.from_value(F.Node11.to_value(source_address)), Some{source_address}, Node11_inverse(source_address)) : {F.ConsolidationRequestValue.assemble(_, F.Node8.from_value(F.Node8.to_value(source_pubkey)), F.Node8.from_value(F.Node8.to_value(target_pubkey))) == Some{F.ConsolidationRequest{source_address, source_pubkey, target_pubkey}} : Maybe<&2, F.ConsolidationRequestValue()>}
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(source_pubkey)), Some{source_pubkey}, Node8_inverse(source_pubkey)) : {F.ConsolidationRequestValue.assemble(Some{source_address}, _, F.Node8.from_value(F.Node8.to_value(target_pubkey))) == Some{F.ConsolidationRequest{source_address, source_pubkey, target_pubkey}} : Maybe<&2, F.ConsolidationRequestValue()>}
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(target_pubkey)), Some{target_pubkey}, Node8_inverse(target_pubkey)) : {F.ConsolidationRequestValue.assemble(Some{source_address}, Some{source_pubkey}, _) == Some{F.ConsolidationRequest{source_address, source_pubkey, target_pubkey}} : Maybe<&2, F.ConsolidationRequestValue()>}
  {==}

law WithdrawalRequestValue_inverse:
  for +value: F.WithdrawalRequestValue()
  {F.WithdrawalRequestValue.from_value(F.WithdrawalRequestValue.to_value(value)) == Some{value} : Maybe<&2, F.WithdrawalRequestValue()>}
def WithdrawalRequestValue_inverse(value):
  F.WithdrawalRequest{source_address, validator_pubkey, amount} = value
  %Equal.sym(Maybe<&2, F.Node11()>, F.Node11.from_value(F.Node11.to_value(source_address)), Some{source_address}, Node11_inverse(source_address)) : {F.WithdrawalRequestValue.assemble(_, F.Node8.from_value(F.Node8.to_value(validator_pubkey)), F.Node3.from_value(F.Node3.to_value(amount))) == Some{F.WithdrawalRequest{source_address, validator_pubkey, amount}} : Maybe<&2, F.WithdrawalRequestValue()>}
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(validator_pubkey)), Some{validator_pubkey}, Node8_inverse(validator_pubkey)) : {F.WithdrawalRequestValue.assemble(Some{source_address}, _, F.Node3.from_value(F.Node3.to_value(amount))) == Some{F.WithdrawalRequest{source_address, validator_pubkey, amount}} : Maybe<&2, F.WithdrawalRequestValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(amount)), Some{amount}, Node3_inverse(amount)) : {F.WithdrawalRequestValue.assemble(Some{source_address}, Some{validator_pubkey}, _) == Some{F.WithdrawalRequest{source_address, validator_pubkey, amount}} : Maybe<&2, F.WithdrawalRequestValue()>}
  {==}

law Node64_append:
  for +xs: +List<F.DepositRequestValue()>
  for +ys: +List<F.DepositRequestValue()>
  for +acc: T.Value
  {F.DepositRequestValue.seq_to_go(List.append(&2, F.DepositRequestValue(), xs, ys), acc) == F.DepositRequestValue.seq_to_go(ys, F.DepositRequestValue.seq_to_go(xs, acc)) : T.Value}
def Node64_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node64_append(t, ys, T.Items{F.DepositRequestValue.to_value(h), acc})

law Node64_cons:
  for +h: F.DepositRequestValue()
  for +t: +List<F.DepositRequestValue()>
  {F.DepositRequestValue.seq_to(h <> t) == T.Items{F.DepositRequestValue.to_value(h), F.DepositRequestValue.seq_to(t)} : T.Value}
def Node64_cons(h, t):
  %Equal.sym(+List<F.DepositRequestValue()>, List.reverse.go(&2, F.DepositRequestValue(), t, [h]), List.append(&2, F.DepositRequestValue(), List.reverse(&2, F.DepositRequestValue(), t), [h]), L.reverse_acc_append(F.DepositRequestValue(), t, [], [h])) : {F.DepositRequestValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.DepositRequestValue.to_value(h), F.DepositRequestValue.seq_to(t)} : T.Value}
  Node64_append(List.reverse(&2, F.DepositRequestValue(), t), [h], T.EmptyItems{})

law Node64_inverse_go:
  for +xs: +List<F.DepositRequestValue()>
  for +acc: +List<F.DepositRequestValue()>
  {F.DepositRequestValue.seq_from_go(F.DepositRequestValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.DepositRequestValue(), acc, xs)} : Maybe<&2, +List<F.DepositRequestValue()>>}
def Node64_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.DepositRequestValue.seq_to(h <> t), T.Items{F.DepositRequestValue.to_value(h), F.DepositRequestValue.seq_to(t)}, Node64_cons(h, t)) : {F.DepositRequestValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.DepositRequestValue(), acc, h <> t)} : Maybe<&2, +List<F.DepositRequestValue()>>}
      %Equal.sym(Maybe<&2, F.DepositRequestValue()>, F.DepositRequestValue.from_value(F.DepositRequestValue.to_value(h)), Some{h}, DepositRequestValue_inverse(h)) : {F.DepositRequestValue.seq_step(_, acc, next => F.DepositRequestValue.seq_from_go(F.DepositRequestValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.DepositRequestValue(), acc, h <> t)} : Maybe<&2, +List<F.DepositRequestValue()>>}
      Node64_inverse_go(t, h <> acc)

law Node64_inverse:
  for +value: F.Node64()
  {F.Node64.from_value(F.Node64.to_value(value)) == Some{value} : Maybe<&2, F.Node64()>}
def Node64_inverse(value):
  Node64_inverse_go(value, [])

law Node65_append:
  for +xs: +List<F.WithdrawalRequestValue()>
  for +ys: +List<F.WithdrawalRequestValue()>
  for +acc: T.Value
  {F.WithdrawalRequestValue.seq_to_go(List.append(&2, F.WithdrawalRequestValue(), xs, ys), acc) == F.WithdrawalRequestValue.seq_to_go(ys, F.WithdrawalRequestValue.seq_to_go(xs, acc)) : T.Value}
def Node65_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node65_append(t, ys, T.Items{F.WithdrawalRequestValue.to_value(h), acc})

law Node65_cons:
  for +h: F.WithdrawalRequestValue()
  for +t: +List<F.WithdrawalRequestValue()>
  {F.WithdrawalRequestValue.seq_to(h <> t) == T.Items{F.WithdrawalRequestValue.to_value(h), F.WithdrawalRequestValue.seq_to(t)} : T.Value}
def Node65_cons(h, t):
  %Equal.sym(+List<F.WithdrawalRequestValue()>, List.reverse.go(&2, F.WithdrawalRequestValue(), t, [h]), List.append(&2, F.WithdrawalRequestValue(), List.reverse(&2, F.WithdrawalRequestValue(), t), [h]), L.reverse_acc_append(F.WithdrawalRequestValue(), t, [], [h])) : {F.WithdrawalRequestValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.WithdrawalRequestValue.to_value(h), F.WithdrawalRequestValue.seq_to(t)} : T.Value}
  Node65_append(List.reverse(&2, F.WithdrawalRequestValue(), t), [h], T.EmptyItems{})

law Node65_inverse_go:
  for +xs: +List<F.WithdrawalRequestValue()>
  for +acc: +List<F.WithdrawalRequestValue()>
  {F.WithdrawalRequestValue.seq_from_go(F.WithdrawalRequestValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.WithdrawalRequestValue(), acc, xs)} : Maybe<&2, +List<F.WithdrawalRequestValue()>>}
def Node65_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.WithdrawalRequestValue.seq_to(h <> t), T.Items{F.WithdrawalRequestValue.to_value(h), F.WithdrawalRequestValue.seq_to(t)}, Node65_cons(h, t)) : {F.WithdrawalRequestValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.WithdrawalRequestValue(), acc, h <> t)} : Maybe<&2, +List<F.WithdrawalRequestValue()>>}
      %Equal.sym(Maybe<&2, F.WithdrawalRequestValue()>, F.WithdrawalRequestValue.from_value(F.WithdrawalRequestValue.to_value(h)), Some{h}, WithdrawalRequestValue_inverse(h)) : {F.WithdrawalRequestValue.seq_step(_, acc, next => F.WithdrawalRequestValue.seq_from_go(F.WithdrawalRequestValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.WithdrawalRequestValue(), acc, h <> t)} : Maybe<&2, +List<F.WithdrawalRequestValue()>>}
      Node65_inverse_go(t, h <> acc)

law Node65_inverse:
  for +value: F.Node65()
  {F.Node65.from_value(F.Node65.to_value(value)) == Some{value} : Maybe<&2, F.Node65()>}
def Node65_inverse(value):
  Node65_inverse_go(value, [])

law Node66_append:
  for +xs: +List<F.ConsolidationRequestValue()>
  for +ys: +List<F.ConsolidationRequestValue()>
  for +acc: T.Value
  {F.ConsolidationRequestValue.seq_to_go(List.append(&2, F.ConsolidationRequestValue(), xs, ys), acc) == F.ConsolidationRequestValue.seq_to_go(ys, F.ConsolidationRequestValue.seq_to_go(xs, acc)) : T.Value}
def Node66_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node66_append(t, ys, T.Items{F.ConsolidationRequestValue.to_value(h), acc})

law Node66_cons:
  for +h: F.ConsolidationRequestValue()
  for +t: +List<F.ConsolidationRequestValue()>
  {F.ConsolidationRequestValue.seq_to(h <> t) == T.Items{F.ConsolidationRequestValue.to_value(h), F.ConsolidationRequestValue.seq_to(t)} : T.Value}
def Node66_cons(h, t):
  %Equal.sym(+List<F.ConsolidationRequestValue()>, List.reverse.go(&2, F.ConsolidationRequestValue(), t, [h]), List.append(&2, F.ConsolidationRequestValue(), List.reverse(&2, F.ConsolidationRequestValue(), t), [h]), L.reverse_acc_append(F.ConsolidationRequestValue(), t, [], [h])) : {F.ConsolidationRequestValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.ConsolidationRequestValue.to_value(h), F.ConsolidationRequestValue.seq_to(t)} : T.Value}
  Node66_append(List.reverse(&2, F.ConsolidationRequestValue(), t), [h], T.EmptyItems{})

law Node66_inverse_go:
  for +xs: +List<F.ConsolidationRequestValue()>
  for +acc: +List<F.ConsolidationRequestValue()>
  {F.ConsolidationRequestValue.seq_from_go(F.ConsolidationRequestValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.ConsolidationRequestValue(), acc, xs)} : Maybe<&2, +List<F.ConsolidationRequestValue()>>}
def Node66_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.ConsolidationRequestValue.seq_to(h <> t), T.Items{F.ConsolidationRequestValue.to_value(h), F.ConsolidationRequestValue.seq_to(t)}, Node66_cons(h, t)) : {F.ConsolidationRequestValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.ConsolidationRequestValue(), acc, h <> t)} : Maybe<&2, +List<F.ConsolidationRequestValue()>>}
      %Equal.sym(Maybe<&2, F.ConsolidationRequestValue()>, F.ConsolidationRequestValue.from_value(F.ConsolidationRequestValue.to_value(h)), Some{h}, ConsolidationRequestValue_inverse(h)) : {F.ConsolidationRequestValue.seq_step(_, acc, next => F.ConsolidationRequestValue.seq_from_go(F.ConsolidationRequestValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.ConsolidationRequestValue(), acc, h <> t)} : Maybe<&2, +List<F.ConsolidationRequestValue()>>}
      Node66_inverse_go(t, h <> acc)

law Node66_inverse:
  for +value: F.Node66()
  {F.Node66.from_value(F.Node66.to_value(value)) == Some{value} : Maybe<&2, F.Node66()>}
def Node66_inverse(value):
  Node66_inverse_go(value, [])

law ExecutionRequestsValue_inverse:
  for +value: F.ExecutionRequestsValue()
  {F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(value)) == Some{value} : Maybe<&2, F.ExecutionRequestsValue()>}
def ExecutionRequestsValue_inverse(value):
  F.ExecutionRequests{deposits, withdrawals, consolidations} = value
  %Equal.sym(Maybe<&2, F.Node64()>, F.Node64.from_value(F.Node64.to_value(deposits)), Some{deposits}, Node64_inverse(deposits)) : {F.ExecutionRequestsValue.assemble(_, F.Node65.from_value(F.Node65.to_value(withdrawals)), F.Node66.from_value(F.Node66.to_value(consolidations))) == Some{F.ExecutionRequests{deposits, withdrawals, consolidations}} : Maybe<&2, F.ExecutionRequestsValue()>}
  %Equal.sym(Maybe<&2, F.Node65()>, F.Node65.from_value(F.Node65.to_value(withdrawals)), Some{withdrawals}, Node65_inverse(withdrawals)) : {F.ExecutionRequestsValue.assemble(Some{deposits}, _, F.Node66.from_value(F.Node66.to_value(consolidations))) == Some{F.ExecutionRequests{deposits, withdrawals, consolidations}} : Maybe<&2, F.ExecutionRequestsValue()>}
  %Equal.sym(Maybe<&2, F.Node66()>, F.Node66.from_value(F.Node66.to_value(consolidations)), Some{consolidations}, Node66_inverse(consolidations)) : {F.ExecutionRequestsValue.assemble(Some{deposits}, Some{withdrawals}, _) == Some{F.ExecutionRequests{deposits, withdrawals, consolidations}} : Maybe<&2, F.ExecutionRequestsValue()>}
  {==}

law BLSToExecutionChangeValue_inverse:
  for +value: F.BLSToExecutionChangeValue()
  {F.BLSToExecutionChangeValue.from_value(F.BLSToExecutionChangeValue.to_value(value)) == Some{value} : Maybe<&2, F.BLSToExecutionChangeValue()>}
def BLSToExecutionChangeValue_inverse(value):
  F.BLSToExecutionChange{validator_index, from_bls_pubkey, to_execution_address} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(validator_index)), Some{validator_index}, Node3_inverse(validator_index)) : {F.BLSToExecutionChangeValue.assemble(_, F.Node8.from_value(F.Node8.to_value(from_bls_pubkey)), F.Node11.from_value(F.Node11.to_value(to_execution_address))) == Some{F.BLSToExecutionChange{validator_index, from_bls_pubkey, to_execution_address}} : Maybe<&2, F.BLSToExecutionChangeValue()>}
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(from_bls_pubkey)), Some{from_bls_pubkey}, Node8_inverse(from_bls_pubkey)) : {F.BLSToExecutionChangeValue.assemble(Some{validator_index}, _, F.Node11.from_value(F.Node11.to_value(to_execution_address))) == Some{F.BLSToExecutionChange{validator_index, from_bls_pubkey, to_execution_address}} : Maybe<&2, F.BLSToExecutionChangeValue()>}
  %Equal.sym(Maybe<&2, F.Node11()>, F.Node11.from_value(F.Node11.to_value(to_execution_address)), Some{to_execution_address}, Node11_inverse(to_execution_address)) : {F.BLSToExecutionChangeValue.assemble(Some{validator_index}, Some{from_bls_pubkey}, _) == Some{F.BLSToExecutionChange{validator_index, from_bls_pubkey, to_execution_address}} : Maybe<&2, F.BLSToExecutionChangeValue()>}
  {==}

law SignedBLSToExecutionChangeValue_inverse:
  for +value: F.SignedBLSToExecutionChangeValue()
  {F.SignedBLSToExecutionChangeValue.from_value(F.SignedBLSToExecutionChangeValue.to_value(value)) == Some{value} : Maybe<&2, F.SignedBLSToExecutionChangeValue()>}
def SignedBLSToExecutionChangeValue_inverse(value):
  F.SignedBLSToExecutionChange{message, signature} = value
  %Equal.sym(Maybe<&2, F.BLSToExecutionChangeValue()>, F.BLSToExecutionChangeValue.from_value(F.BLSToExecutionChangeValue.to_value(message)), Some{message}, BLSToExecutionChangeValue_inverse(message)) : {F.SignedBLSToExecutionChangeValue.assemble(_, F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SignedBLSToExecutionChange{message, signature}} : Maybe<&2, F.SignedBLSToExecutionChangeValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.SignedBLSToExecutionChangeValue.assemble(Some{message}, _) == Some{F.SignedBLSToExecutionChange{message, signature}} : Maybe<&2, F.SignedBLSToExecutionChangeValue()>}
  {==}

law Node70_inverse:
  for +value: F.Node70()
  {F.Node70.from_value(F.Node70.to_value(value)) == Some{value} : Maybe<&2, F.Node70()>}
def Node70_inverse(value):
  {==}

law Node71_inverse:
  for +value: F.Node71()
  {F.Node71.from_value(F.Node71.to_value(value)) == Some{value} : Maybe<&2, F.Node71()>}
def Node71_inverse(value):
  {==}

law ExecutionPayloadHeaderValue_inverse:
  for +value: F.ExecutionPayloadHeaderValue()
  {F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(value)) == Some{value} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
def ExecutionPayloadHeaderValue_inverse(value):
  F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas} = value
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(parent_hash)), Some{parent_hash}, Node7_inverse(parent_hash)) : {F.ExecutionPayloadHeaderValue.assemble(_, F.Node11.from_value(F.Node11.to_value(fee_recipient)), F.Node7.from_value(F.Node7.to_value(state_root)), F.Node7.from_value(F.Node7.to_value(receipts_root)), F.Node70.from_value(F.Node70.to_value(logs_bloom)), F.Node7.from_value(F.Node7.to_value(prev_randao)), F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node11()>, F.Node11.from_value(F.Node11.to_value(fee_recipient)), Some{fee_recipient}, Node11_inverse(fee_recipient)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, _, F.Node7.from_value(F.Node7.to_value(state_root)), F.Node7.from_value(F.Node7.to_value(receipts_root)), F.Node70.from_value(F.Node70.to_value(logs_bloom)), F.Node7.from_value(F.Node7.to_value(prev_randao)), F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(state_root)), Some{state_root}, Node7_inverse(state_root)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, _, F.Node7.from_value(F.Node7.to_value(receipts_root)), F.Node70.from_value(F.Node70.to_value(logs_bloom)), F.Node7.from_value(F.Node7.to_value(prev_randao)), F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(receipts_root)), Some{receipts_root}, Node7_inverse(receipts_root)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, _, F.Node70.from_value(F.Node70.to_value(logs_bloom)), F.Node7.from_value(F.Node7.to_value(prev_randao)), F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node70()>, F.Node70.from_value(F.Node70.to_value(logs_bloom)), Some{logs_bloom}, Node70_inverse(logs_bloom)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, _, F.Node7.from_value(F.Node7.to_value(prev_randao)), F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(prev_randao)), Some{prev_randao}, Node7_inverse(prev_randao)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, _, F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(block_number)), Some{block_number}, Node3_inverse(block_number)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, _, F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(gas_limit)), Some{gas_limit}, Node3_inverse(gas_limit)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, _, F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(gas_used)), Some{gas_used}, Node3_inverse(gas_used)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, _, F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(timestamp)), Some{timestamp}, Node3_inverse(timestamp)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, _, F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node71()>, F.Node71.from_value(F.Node71.to_value(extra_data)), Some{extra_data}, Node71_inverse(extra_data)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, _, F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node4()>, F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), Some{base_fee_per_gas}, Node4_inverse(base_fee_per_gas)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, _, F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(block_hash)), Some{block_hash}, Node7_inverse(block_hash)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, Some{base_fee_per_gas}, _, F.Node7.from_value(F.Node7.to_value(transactions_root)), F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(transactions_root)), Some{transactions_root}, Node7_inverse(transactions_root)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, Some{base_fee_per_gas}, Some{block_hash}, _, F.Node7.from_value(F.Node7.to_value(withdrawals_root)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(withdrawals_root)), Some{withdrawals_root}, Node7_inverse(withdrawals_root)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, Some{base_fee_per_gas}, Some{block_hash}, Some{transactions_root}, _, F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(blob_gas_used)), Some{blob_gas_used}, Node3_inverse(blob_gas_used)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, Some{base_fee_per_gas}, Some{block_hash}, Some{transactions_root}, Some{withdrawals_root}, _, F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(excess_blob_gas)), Some{excess_blob_gas}, Node3_inverse(excess_blob_gas)) : {F.ExecutionPayloadHeaderValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, Some{base_fee_per_gas}, Some{block_hash}, Some{transactions_root}, Some{withdrawals_root}, Some{blob_gas_used}, _) == Some{F.ExecutionPayloadHeader{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions_root, withdrawals_root, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadHeaderValue()>}
  {==}

law WithdrawalValue_inverse:
  for +value: F.WithdrawalValue()
  {F.WithdrawalValue.from_value(F.WithdrawalValue.to_value(value)) == Some{value} : Maybe<&2, F.WithdrawalValue()>}
def WithdrawalValue_inverse(value):
  F.Withdrawal{index, validator_index, address, amount} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(index)), Some{index}, Node3_inverse(index)) : {F.WithdrawalValue.assemble(_, F.Node3.from_value(F.Node3.to_value(validator_index)), F.Node11.from_value(F.Node11.to_value(address)), F.Node3.from_value(F.Node3.to_value(amount))) == Some{F.Withdrawal{index, validator_index, address, amount}} : Maybe<&2, F.WithdrawalValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(validator_index)), Some{validator_index}, Node3_inverse(validator_index)) : {F.WithdrawalValue.assemble(Some{index}, _, F.Node11.from_value(F.Node11.to_value(address)), F.Node3.from_value(F.Node3.to_value(amount))) == Some{F.Withdrawal{index, validator_index, address, amount}} : Maybe<&2, F.WithdrawalValue()>}
  %Equal.sym(Maybe<&2, F.Node11()>, F.Node11.from_value(F.Node11.to_value(address)), Some{address}, Node11_inverse(address)) : {F.WithdrawalValue.assemble(Some{index}, Some{validator_index}, _, F.Node3.from_value(F.Node3.to_value(amount))) == Some{F.Withdrawal{index, validator_index, address, amount}} : Maybe<&2, F.WithdrawalValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(amount)), Some{amount}, Node3_inverse(amount)) : {F.WithdrawalValue.assemble(Some{index}, Some{validator_index}, Some{address}, _) == Some{F.Withdrawal{index, validator_index, address, amount}} : Maybe<&2, F.WithdrawalValue()>}
  {==}

law Node74_append:
  for +xs: +List<F.Node60()>
  for +ys: +List<F.Node60()>
  for +acc: T.Value
  {F.Node60.seq_to_go(List.append(&2, F.Node60(), xs, ys), acc) == F.Node60.seq_to_go(ys, F.Node60.seq_to_go(xs, acc)) : T.Value}
def Node74_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node74_append(t, ys, T.Items{F.Node60.to_value(h), acc})

law Node74_cons:
  for +h: F.Node60()
  for +t: +List<F.Node60()>
  {F.Node60.seq_to(h <> t) == T.Items{F.Node60.to_value(h), F.Node60.seq_to(t)} : T.Value}
def Node74_cons(h, t):
  %Equal.sym(+List<F.Node60()>, List.reverse.go(&2, F.Node60(), t, [h]), List.append(&2, F.Node60(), List.reverse(&2, F.Node60(), t), [h]), L.reverse_acc_append(F.Node60(), t, [], [h])) : {F.Node60.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node60.to_value(h), F.Node60.seq_to(t)} : T.Value}
  Node74_append(List.reverse(&2, F.Node60(), t), [h], T.EmptyItems{})

law Node74_inverse_go:
  for +xs: +List<F.Node60()>
  for +acc: +List<F.Node60()>
  {F.Node60.seq_from_go(F.Node60.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node60(), acc, xs)} : Maybe<&2, +List<F.Node60()>>}
def Node74_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node60.seq_to(h <> t), T.Items{F.Node60.to_value(h), F.Node60.seq_to(t)}, Node74_cons(h, t)) : {F.Node60.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node60(), acc, h <> t)} : Maybe<&2, +List<F.Node60()>>}
      %Equal.sym(Maybe<&2, F.Node60()>, F.Node60.from_value(F.Node60.to_value(h)), Some{h}, Node60_inverse(h)) : {F.Node60.seq_step(_, acc, next => F.Node60.seq_from_go(F.Node60.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node60(), acc, h <> t)} : Maybe<&2, +List<F.Node60()>>}
      Node74_inverse_go(t, h <> acc)

law Node74_inverse:
  for +value: F.Node74()
  {F.Node74.from_value(F.Node74.to_value(value)) == Some{value} : Maybe<&2, F.Node74()>}
def Node74_inverse(value):
  Node74_inverse_go(value, [])

law Node75_append:
  for +xs: +List<F.WithdrawalValue()>
  for +ys: +List<F.WithdrawalValue()>
  for +acc: T.Value
  {F.WithdrawalValue.seq_to_go(List.append(&2, F.WithdrawalValue(), xs, ys), acc) == F.WithdrawalValue.seq_to_go(ys, F.WithdrawalValue.seq_to_go(xs, acc)) : T.Value}
def Node75_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node75_append(t, ys, T.Items{F.WithdrawalValue.to_value(h), acc})

law Node75_cons:
  for +h: F.WithdrawalValue()
  for +t: +List<F.WithdrawalValue()>
  {F.WithdrawalValue.seq_to(h <> t) == T.Items{F.WithdrawalValue.to_value(h), F.WithdrawalValue.seq_to(t)} : T.Value}
def Node75_cons(h, t):
  %Equal.sym(+List<F.WithdrawalValue()>, List.reverse.go(&2, F.WithdrawalValue(), t, [h]), List.append(&2, F.WithdrawalValue(), List.reverse(&2, F.WithdrawalValue(), t), [h]), L.reverse_acc_append(F.WithdrawalValue(), t, [], [h])) : {F.WithdrawalValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.WithdrawalValue.to_value(h), F.WithdrawalValue.seq_to(t)} : T.Value}
  Node75_append(List.reverse(&2, F.WithdrawalValue(), t), [h], T.EmptyItems{})

law Node75_inverse_go:
  for +xs: +List<F.WithdrawalValue()>
  for +acc: +List<F.WithdrawalValue()>
  {F.WithdrawalValue.seq_from_go(F.WithdrawalValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.WithdrawalValue(), acc, xs)} : Maybe<&2, +List<F.WithdrawalValue()>>}
def Node75_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.WithdrawalValue.seq_to(h <> t), T.Items{F.WithdrawalValue.to_value(h), F.WithdrawalValue.seq_to(t)}, Node75_cons(h, t)) : {F.WithdrawalValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.WithdrawalValue(), acc, h <> t)} : Maybe<&2, +List<F.WithdrawalValue()>>}
      %Equal.sym(Maybe<&2, F.WithdrawalValue()>, F.WithdrawalValue.from_value(F.WithdrawalValue.to_value(h)), Some{h}, WithdrawalValue_inverse(h)) : {F.WithdrawalValue.seq_step(_, acc, next => F.WithdrawalValue.seq_from_go(F.WithdrawalValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.WithdrawalValue(), acc, h <> t)} : Maybe<&2, +List<F.WithdrawalValue()>>}
      Node75_inverse_go(t, h <> acc)

law Node75_inverse:
  for +value: F.Node75()
  {F.Node75.from_value(F.Node75.to_value(value)) == Some{value} : Maybe<&2, F.Node75()>}
def Node75_inverse(value):
  Node75_inverse_go(value, [])

law ExecutionPayloadValue_inverse:
  for +value: F.ExecutionPayloadValue()
  {F.ExecutionPayloadValue.from_value(F.ExecutionPayloadValue.to_value(value)) == Some{value} : Maybe<&2, F.ExecutionPayloadValue()>}
def ExecutionPayloadValue_inverse(value):
  F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas} = value
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(parent_hash)), Some{parent_hash}, Node7_inverse(parent_hash)) : {F.ExecutionPayloadValue.assemble(_, F.Node11.from_value(F.Node11.to_value(fee_recipient)), F.Node7.from_value(F.Node7.to_value(state_root)), F.Node7.from_value(F.Node7.to_value(receipts_root)), F.Node70.from_value(F.Node70.to_value(logs_bloom)), F.Node7.from_value(F.Node7.to_value(prev_randao)), F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node11()>, F.Node11.from_value(F.Node11.to_value(fee_recipient)), Some{fee_recipient}, Node11_inverse(fee_recipient)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, _, F.Node7.from_value(F.Node7.to_value(state_root)), F.Node7.from_value(F.Node7.to_value(receipts_root)), F.Node70.from_value(F.Node70.to_value(logs_bloom)), F.Node7.from_value(F.Node7.to_value(prev_randao)), F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(state_root)), Some{state_root}, Node7_inverse(state_root)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, _, F.Node7.from_value(F.Node7.to_value(receipts_root)), F.Node70.from_value(F.Node70.to_value(logs_bloom)), F.Node7.from_value(F.Node7.to_value(prev_randao)), F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(receipts_root)), Some{receipts_root}, Node7_inverse(receipts_root)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, _, F.Node70.from_value(F.Node70.to_value(logs_bloom)), F.Node7.from_value(F.Node7.to_value(prev_randao)), F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node70()>, F.Node70.from_value(F.Node70.to_value(logs_bloom)), Some{logs_bloom}, Node70_inverse(logs_bloom)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, _, F.Node7.from_value(F.Node7.to_value(prev_randao)), F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(prev_randao)), Some{prev_randao}, Node7_inverse(prev_randao)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, _, F.Node3.from_value(F.Node3.to_value(block_number)), F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(block_number)), Some{block_number}, Node3_inverse(block_number)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, _, F.Node3.from_value(F.Node3.to_value(gas_limit)), F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(gas_limit)), Some{gas_limit}, Node3_inverse(gas_limit)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, _, F.Node3.from_value(F.Node3.to_value(gas_used)), F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(gas_used)), Some{gas_used}, Node3_inverse(gas_used)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, _, F.Node3.from_value(F.Node3.to_value(timestamp)), F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(timestamp)), Some{timestamp}, Node3_inverse(timestamp)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, _, F.Node71.from_value(F.Node71.to_value(extra_data)), F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node71()>, F.Node71.from_value(F.Node71.to_value(extra_data)), Some{extra_data}, Node71_inverse(extra_data)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, _, F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node4()>, F.Node4.from_value(F.Node4.to_value(base_fee_per_gas)), Some{base_fee_per_gas}, Node4_inverse(base_fee_per_gas)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, _, F.Node7.from_value(F.Node7.to_value(block_hash)), F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(block_hash)), Some{block_hash}, Node7_inverse(block_hash)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, Some{base_fee_per_gas}, _, F.Node74.from_value(F.Node74.to_value(transactions)), F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node74()>, F.Node74.from_value(F.Node74.to_value(transactions)), Some{transactions}, Node74_inverse(transactions)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, Some{base_fee_per_gas}, Some{block_hash}, _, F.Node75.from_value(F.Node75.to_value(withdrawals)), F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node75()>, F.Node75.from_value(F.Node75.to_value(withdrawals)), Some{withdrawals}, Node75_inverse(withdrawals)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, Some{base_fee_per_gas}, Some{block_hash}, Some{transactions}, _, F.Node3.from_value(F.Node3.to_value(blob_gas_used)), F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(blob_gas_used)), Some{blob_gas_used}, Node3_inverse(blob_gas_used)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, Some{base_fee_per_gas}, Some{block_hash}, Some{transactions}, Some{withdrawals}, _, F.Node3.from_value(F.Node3.to_value(excess_blob_gas))) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(excess_blob_gas)), Some{excess_blob_gas}, Node3_inverse(excess_blob_gas)) : {F.ExecutionPayloadValue.assemble(Some{parent_hash}, Some{fee_recipient}, Some{state_root}, Some{receipts_root}, Some{logs_bloom}, Some{prev_randao}, Some{block_number}, Some{gas_limit}, Some{gas_used}, Some{timestamp}, Some{extra_data}, Some{base_fee_per_gas}, Some{block_hash}, Some{transactions}, Some{withdrawals}, Some{blob_gas_used}, _) == Some{F.ExecutionPayload{parent_hash, fee_recipient, state_root, receipts_root, logs_bloom, prev_randao, block_number, gas_limit, gas_used, timestamp, extra_data, base_fee_per_gas, block_hash, transactions, withdrawals, blob_gas_used, excess_blob_gas}} : Maybe<&2, F.ExecutionPayloadValue()>}
  {==}

law Node77_append:
  for +xs: +List<F.Node7()>
  for +ys: +List<F.Node7()>
  for +acc: T.Value
  {F.Node7.seq_to_go(List.append(&2, F.Node7(), xs, ys), acc) == F.Node7.seq_to_go(ys, F.Node7.seq_to_go(xs, acc)) : T.Value}
def Node77_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node77_append(t, ys, T.Items{F.Node7.to_value(h), acc})

law Node77_cons:
  for +h: F.Node7()
  for +t: +List<F.Node7()>
  {F.Node7.seq_to(h <> t) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
def Node77_cons(h, t):
  %Equal.sym(+List<F.Node7()>, List.reverse.go(&2, F.Node7(), t, [h]), List.append(&2, F.Node7(), List.reverse(&2, F.Node7(), t), [h]), L.reverse_acc_append(F.Node7(), t, [], [h])) : {F.Node7.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
  Node77_append(List.reverse(&2, F.Node7(), t), [h], T.EmptyItems{})

law Node77_inverse_go:
  for +xs: +List<F.Node7()>
  for +acc: +List<F.Node7()>
  {F.Node7.seq_from_go(F.Node7.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node7(), acc, xs)} : Maybe<&2, +List<F.Node7()>>}
def Node77_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node7.seq_to(h <> t), T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)}, Node77_cons(h, t)) : {F.Node7.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(h)), Some{h}, Node7_inverse(h)) : {F.Node7.seq_step(_, acc, next => F.Node7.seq_from_go(F.Node7.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      Node77_inverse_go(t, h <> acc)

law Node77_inverse:
  for +value: F.Node77()
  {F.Node77.from_value(F.Node77.to_value(value)) == Some{value} : Maybe<&2, F.Node77()>}
def Node77_inverse(value):
  Node77_inverse_go(value, [])

law Node78_append:
  for +xs: +List<F.Eth1DataValue()>
  for +ys: +List<F.Eth1DataValue()>
  for +acc: T.Value
  {F.Eth1DataValue.seq_to_go(List.append(&2, F.Eth1DataValue(), xs, ys), acc) == F.Eth1DataValue.seq_to_go(ys, F.Eth1DataValue.seq_to_go(xs, acc)) : T.Value}
def Node78_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node78_append(t, ys, T.Items{F.Eth1DataValue.to_value(h), acc})

law Node78_cons:
  for +h: F.Eth1DataValue()
  for +t: +List<F.Eth1DataValue()>
  {F.Eth1DataValue.seq_to(h <> t) == T.Items{F.Eth1DataValue.to_value(h), F.Eth1DataValue.seq_to(t)} : T.Value}
def Node78_cons(h, t):
  %Equal.sym(+List<F.Eth1DataValue()>, List.reverse.go(&2, F.Eth1DataValue(), t, [h]), List.append(&2, F.Eth1DataValue(), List.reverse(&2, F.Eth1DataValue(), t), [h]), L.reverse_acc_append(F.Eth1DataValue(), t, [], [h])) : {F.Eth1DataValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Eth1DataValue.to_value(h), F.Eth1DataValue.seq_to(t)} : T.Value}
  Node78_append(List.reverse(&2, F.Eth1DataValue(), t), [h], T.EmptyItems{})

law Node78_inverse_go:
  for +xs: +List<F.Eth1DataValue()>
  for +acc: +List<F.Eth1DataValue()>
  {F.Eth1DataValue.seq_from_go(F.Eth1DataValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Eth1DataValue(), acc, xs)} : Maybe<&2, +List<F.Eth1DataValue()>>}
def Node78_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Eth1DataValue.seq_to(h <> t), T.Items{F.Eth1DataValue.to_value(h), F.Eth1DataValue.seq_to(t)}, Node78_cons(h, t)) : {F.Eth1DataValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Eth1DataValue(), acc, h <> t)} : Maybe<&2, +List<F.Eth1DataValue()>>}
      %Equal.sym(Maybe<&2, F.Eth1DataValue()>, F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(h)), Some{h}, Eth1DataValue_inverse(h)) : {F.Eth1DataValue.seq_step(_, acc, next => F.Eth1DataValue.seq_from_go(F.Eth1DataValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.Eth1DataValue(), acc, h <> t)} : Maybe<&2, +List<F.Eth1DataValue()>>}
      Node78_inverse_go(t, h <> acc)

law Node78_inverse:
  for +value: F.Node78()
  {F.Node78.from_value(F.Node78.to_value(value)) == Some{value} : Maybe<&2, F.Node78()>}
def Node78_inverse(value):
  Node78_inverse_go(value, [])

law Node79_append:
  for +xs: +List<F.ValidatorValue()>
  for +ys: +List<F.ValidatorValue()>
  for +acc: T.Value
  {F.ValidatorValue.seq_to_go(List.append(&2, F.ValidatorValue(), xs, ys), acc) == F.ValidatorValue.seq_to_go(ys, F.ValidatorValue.seq_to_go(xs, acc)) : T.Value}
def Node79_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node79_append(t, ys, T.Items{F.ValidatorValue.to_value(h), acc})

law Node79_cons:
  for +h: F.ValidatorValue()
  for +t: +List<F.ValidatorValue()>
  {F.ValidatorValue.seq_to(h <> t) == T.Items{F.ValidatorValue.to_value(h), F.ValidatorValue.seq_to(t)} : T.Value}
def Node79_cons(h, t):
  %Equal.sym(+List<F.ValidatorValue()>, List.reverse.go(&2, F.ValidatorValue(), t, [h]), List.append(&2, F.ValidatorValue(), List.reverse(&2, F.ValidatorValue(), t), [h]), L.reverse_acc_append(F.ValidatorValue(), t, [], [h])) : {F.ValidatorValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.ValidatorValue.to_value(h), F.ValidatorValue.seq_to(t)} : T.Value}
  Node79_append(List.reverse(&2, F.ValidatorValue(), t), [h], T.EmptyItems{})

law Node79_inverse_go:
  for +xs: +List<F.ValidatorValue()>
  for +acc: +List<F.ValidatorValue()>
  {F.ValidatorValue.seq_from_go(F.ValidatorValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.ValidatorValue(), acc, xs)} : Maybe<&2, +List<F.ValidatorValue()>>}
def Node79_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.ValidatorValue.seq_to(h <> t), T.Items{F.ValidatorValue.to_value(h), F.ValidatorValue.seq_to(t)}, Node79_cons(h, t)) : {F.ValidatorValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.ValidatorValue(), acc, h <> t)} : Maybe<&2, +List<F.ValidatorValue()>>}
      %Equal.sym(Maybe<&2, F.ValidatorValue()>, F.ValidatorValue.from_value(F.ValidatorValue.to_value(h)), Some{h}, ValidatorValue_inverse(h)) : {F.ValidatorValue.seq_step(_, acc, next => F.ValidatorValue.seq_from_go(F.ValidatorValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.ValidatorValue(), acc, h <> t)} : Maybe<&2, +List<F.ValidatorValue()>>}
      Node79_inverse_go(t, h <> acc)

law Node79_inverse:
  for +value: F.Node79()
  {F.Node79.from_value(F.Node79.to_value(value)) == Some{value} : Maybe<&2, F.Node79()>}
def Node79_inverse(value):
  Node79_inverse_go(value, [])

law Node80_append:
  for +xs: +List<F.Node3()>
  for +ys: +List<F.Node3()>
  for +acc: T.Value
  {F.Node3.seq_to_go(List.append(&2, F.Node3(), xs, ys), acc) == F.Node3.seq_to_go(ys, F.Node3.seq_to_go(xs, acc)) : T.Value}
def Node80_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node80_append(t, ys, T.Items{F.Node3.to_value(h), acc})

law Node80_cons:
  for +h: F.Node3()
  for +t: +List<F.Node3()>
  {F.Node3.seq_to(h <> t) == T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)} : T.Value}
def Node80_cons(h, t):
  %Equal.sym(+List<F.Node3()>, List.reverse.go(&2, F.Node3(), t, [h]), List.append(&2, F.Node3(), List.reverse(&2, F.Node3(), t), [h]), L.reverse_acc_append(F.Node3(), t, [], [h])) : {F.Node3.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)} : T.Value}
  Node80_append(List.reverse(&2, F.Node3(), t), [h], T.EmptyItems{})

law Node80_inverse_go:
  for +xs: +List<F.Node3()>
  for +acc: +List<F.Node3()>
  {F.Node3.seq_from_go(F.Node3.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node3(), acc, xs)} : Maybe<&2, +List<F.Node3()>>}
def Node80_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node3.seq_to(h <> t), T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)}, Node80_cons(h, t)) : {F.Node3.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node3(), acc, h <> t)} : Maybe<&2, +List<F.Node3()>>}
      %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(h)), Some{h}, Node3_inverse(h)) : {F.Node3.seq_step(_, acc, next => F.Node3.seq_from_go(F.Node3.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node3(), acc, h <> t)} : Maybe<&2, +List<F.Node3()>>}
      Node80_inverse_go(t, h <> acc)

law Node80_inverse:
  for +value: F.Node80()
  {F.Node80.from_value(F.Node80.to_value(value)) == Some{value} : Maybe<&2, F.Node80()>}
def Node80_inverse(value):
  Node80_inverse_go(value, [])

law Node81_append:
  for +xs: +List<F.Node7()>
  for +ys: +List<F.Node7()>
  for +acc: T.Value
  {F.Node7.seq_to_go(List.append(&2, F.Node7(), xs, ys), acc) == F.Node7.seq_to_go(ys, F.Node7.seq_to_go(xs, acc)) : T.Value}
def Node81_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node81_append(t, ys, T.Items{F.Node7.to_value(h), acc})

law Node81_cons:
  for +h: F.Node7()
  for +t: +List<F.Node7()>
  {F.Node7.seq_to(h <> t) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
def Node81_cons(h, t):
  %Equal.sym(+List<F.Node7()>, List.reverse.go(&2, F.Node7(), t, [h]), List.append(&2, F.Node7(), List.reverse(&2, F.Node7(), t), [h]), L.reverse_acc_append(F.Node7(), t, [], [h])) : {F.Node7.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
  Node81_append(List.reverse(&2, F.Node7(), t), [h], T.EmptyItems{})

law Node81_inverse_go:
  for +xs: +List<F.Node7()>
  for +acc: +List<F.Node7()>
  {F.Node7.seq_from_go(F.Node7.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node7(), acc, xs)} : Maybe<&2, +List<F.Node7()>>}
def Node81_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node7.seq_to(h <> t), T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)}, Node81_cons(h, t)) : {F.Node7.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(h)), Some{h}, Node7_inverse(h)) : {F.Node7.seq_step(_, acc, next => F.Node7.seq_from_go(F.Node7.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      Node81_inverse_go(t, h <> acc)

law Node81_inverse:
  for +value: F.Node81()
  {F.Node81.from_value(F.Node81.to_value(value)) == Some{value} : Maybe<&2, F.Node81()>}
def Node81_inverse(value):
  Node81_inverse_go(value, [])

law Node82_append:
  for +xs: +List<F.Node3()>
  for +ys: +List<F.Node3()>
  for +acc: T.Value
  {F.Node3.seq_to_go(List.append(&2, F.Node3(), xs, ys), acc) == F.Node3.seq_to_go(ys, F.Node3.seq_to_go(xs, acc)) : T.Value}
def Node82_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node82_append(t, ys, T.Items{F.Node3.to_value(h), acc})

law Node82_cons:
  for +h: F.Node3()
  for +t: +List<F.Node3()>
  {F.Node3.seq_to(h <> t) == T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)} : T.Value}
def Node82_cons(h, t):
  %Equal.sym(+List<F.Node3()>, List.reverse.go(&2, F.Node3(), t, [h]), List.append(&2, F.Node3(), List.reverse(&2, F.Node3(), t), [h]), L.reverse_acc_append(F.Node3(), t, [], [h])) : {F.Node3.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)} : T.Value}
  Node82_append(List.reverse(&2, F.Node3(), t), [h], T.EmptyItems{})

law Node82_inverse_go:
  for +xs: +List<F.Node3()>
  for +acc: +List<F.Node3()>
  {F.Node3.seq_from_go(F.Node3.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node3(), acc, xs)} : Maybe<&2, +List<F.Node3()>>}
def Node82_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node3.seq_to(h <> t), T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)}, Node82_cons(h, t)) : {F.Node3.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node3(), acc, h <> t)} : Maybe<&2, +List<F.Node3()>>}
      %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(h)), Some{h}, Node3_inverse(h)) : {F.Node3.seq_step(_, acc, next => F.Node3.seq_from_go(F.Node3.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node3(), acc, h <> t)} : Maybe<&2, +List<F.Node3()>>}
      Node82_inverse_go(t, h <> acc)

law Node82_inverse:
  for +value: F.Node82()
  {F.Node82.from_value(F.Node82.to_value(value)) == Some{value} : Maybe<&2, F.Node82()>}
def Node82_inverse(value):
  Node82_inverse_go(value, [])

law Node83_append:
  for +xs: +List<F.Node1()>
  for +ys: +List<F.Node1()>
  for +acc: T.Value
  {F.Node1.seq_to_go(List.append(&2, F.Node1(), xs, ys), acc) == F.Node1.seq_to_go(ys, F.Node1.seq_to_go(xs, acc)) : T.Value}
def Node83_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node83_append(t, ys, T.Items{F.Node1.to_value(h), acc})

law Node83_cons:
  for +h: F.Node1()
  for +t: +List<F.Node1()>
  {F.Node1.seq_to(h <> t) == T.Items{F.Node1.to_value(h), F.Node1.seq_to(t)} : T.Value}
def Node83_cons(h, t):
  %Equal.sym(+List<F.Node1()>, List.reverse.go(&2, F.Node1(), t, [h]), List.append(&2, F.Node1(), List.reverse(&2, F.Node1(), t), [h]), L.reverse_acc_append(F.Node1(), t, [], [h])) : {F.Node1.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node1.to_value(h), F.Node1.seq_to(t)} : T.Value}
  Node83_append(List.reverse(&2, F.Node1(), t), [h], T.EmptyItems{})

law Node83_inverse_go:
  for +xs: +List<F.Node1()>
  for +acc: +List<F.Node1()>
  {F.Node1.seq_from_go(F.Node1.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node1(), acc, xs)} : Maybe<&2, +List<F.Node1()>>}
def Node83_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node1.seq_to(h <> t), T.Items{F.Node1.to_value(h), F.Node1.seq_to(t)}, Node83_cons(h, t)) : {F.Node1.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node1(), acc, h <> t)} : Maybe<&2, +List<F.Node1()>>}
      %Equal.sym(Maybe<&2, F.Node1()>, F.Node1.from_value(F.Node1.to_value(h)), Some{h}, Node1_inverse(h)) : {F.Node1.seq_step(_, acc, next => F.Node1.seq_from_go(F.Node1.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node1(), acc, h <> t)} : Maybe<&2, +List<F.Node1()>>}
      Node83_inverse_go(t, h <> acc)

law Node83_inverse:
  for +value: F.Node83()
  {F.Node83.from_value(F.Node83.to_value(value)) == Some{value} : Maybe<&2, F.Node83()>}
def Node83_inverse(value):
  Node83_inverse_go(value, [])

law Node84_inverse:
  for +value: F.Node84()
  {F.Node84.from_value(F.Node84.to_value(value)) == Some{value} : Maybe<&2, F.Node84()>}
def Node84_inverse(value):
  {==}

law Node85_append:
  for +xs: +List<F.HistoricalSummaryValue()>
  for +ys: +List<F.HistoricalSummaryValue()>
  for +acc: T.Value
  {F.HistoricalSummaryValue.seq_to_go(List.append(&2, F.HistoricalSummaryValue(), xs, ys), acc) == F.HistoricalSummaryValue.seq_to_go(ys, F.HistoricalSummaryValue.seq_to_go(xs, acc)) : T.Value}
def Node85_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node85_append(t, ys, T.Items{F.HistoricalSummaryValue.to_value(h), acc})

law Node85_cons:
  for +h: F.HistoricalSummaryValue()
  for +t: +List<F.HistoricalSummaryValue()>
  {F.HistoricalSummaryValue.seq_to(h <> t) == T.Items{F.HistoricalSummaryValue.to_value(h), F.HistoricalSummaryValue.seq_to(t)} : T.Value}
def Node85_cons(h, t):
  %Equal.sym(+List<F.HistoricalSummaryValue()>, List.reverse.go(&2, F.HistoricalSummaryValue(), t, [h]), List.append(&2, F.HistoricalSummaryValue(), List.reverse(&2, F.HistoricalSummaryValue(), t), [h]), L.reverse_acc_append(F.HistoricalSummaryValue(), t, [], [h])) : {F.HistoricalSummaryValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.HistoricalSummaryValue.to_value(h), F.HistoricalSummaryValue.seq_to(t)} : T.Value}
  Node85_append(List.reverse(&2, F.HistoricalSummaryValue(), t), [h], T.EmptyItems{})

law Node85_inverse_go:
  for +xs: +List<F.HistoricalSummaryValue()>
  for +acc: +List<F.HistoricalSummaryValue()>
  {F.HistoricalSummaryValue.seq_from_go(F.HistoricalSummaryValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.HistoricalSummaryValue(), acc, xs)} : Maybe<&2, +List<F.HistoricalSummaryValue()>>}
def Node85_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.HistoricalSummaryValue.seq_to(h <> t), T.Items{F.HistoricalSummaryValue.to_value(h), F.HistoricalSummaryValue.seq_to(t)}, Node85_cons(h, t)) : {F.HistoricalSummaryValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.HistoricalSummaryValue(), acc, h <> t)} : Maybe<&2, +List<F.HistoricalSummaryValue()>>}
      %Equal.sym(Maybe<&2, F.HistoricalSummaryValue()>, F.HistoricalSummaryValue.from_value(F.HistoricalSummaryValue.to_value(h)), Some{h}, HistoricalSummaryValue_inverse(h)) : {F.HistoricalSummaryValue.seq_step(_, acc, next => F.HistoricalSummaryValue.seq_from_go(F.HistoricalSummaryValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.HistoricalSummaryValue(), acc, h <> t)} : Maybe<&2, +List<F.HistoricalSummaryValue()>>}
      Node85_inverse_go(t, h <> acc)

law Node85_inverse:
  for +value: F.Node85()
  {F.Node85.from_value(F.Node85.to_value(value)) == Some{value} : Maybe<&2, F.Node85()>}
def Node85_inverse(value):
  Node85_inverse_go(value, [])

law Node86_append:
  for +xs: +List<F.PendingDepositValue()>
  for +ys: +List<F.PendingDepositValue()>
  for +acc: T.Value
  {F.PendingDepositValue.seq_to_go(List.append(&2, F.PendingDepositValue(), xs, ys), acc) == F.PendingDepositValue.seq_to_go(ys, F.PendingDepositValue.seq_to_go(xs, acc)) : T.Value}
def Node86_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node86_append(t, ys, T.Items{F.PendingDepositValue.to_value(h), acc})

law Node86_cons:
  for +h: F.PendingDepositValue()
  for +t: +List<F.PendingDepositValue()>
  {F.PendingDepositValue.seq_to(h <> t) == T.Items{F.PendingDepositValue.to_value(h), F.PendingDepositValue.seq_to(t)} : T.Value}
def Node86_cons(h, t):
  %Equal.sym(+List<F.PendingDepositValue()>, List.reverse.go(&2, F.PendingDepositValue(), t, [h]), List.append(&2, F.PendingDepositValue(), List.reverse(&2, F.PendingDepositValue(), t), [h]), L.reverse_acc_append(F.PendingDepositValue(), t, [], [h])) : {F.PendingDepositValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.PendingDepositValue.to_value(h), F.PendingDepositValue.seq_to(t)} : T.Value}
  Node86_append(List.reverse(&2, F.PendingDepositValue(), t), [h], T.EmptyItems{})

law Node86_inverse_go:
  for +xs: +List<F.PendingDepositValue()>
  for +acc: +List<F.PendingDepositValue()>
  {F.PendingDepositValue.seq_from_go(F.PendingDepositValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.PendingDepositValue(), acc, xs)} : Maybe<&2, +List<F.PendingDepositValue()>>}
def Node86_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.PendingDepositValue.seq_to(h <> t), T.Items{F.PendingDepositValue.to_value(h), F.PendingDepositValue.seq_to(t)}, Node86_cons(h, t)) : {F.PendingDepositValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.PendingDepositValue(), acc, h <> t)} : Maybe<&2, +List<F.PendingDepositValue()>>}
      %Equal.sym(Maybe<&2, F.PendingDepositValue()>, F.PendingDepositValue.from_value(F.PendingDepositValue.to_value(h)), Some{h}, PendingDepositValue_inverse(h)) : {F.PendingDepositValue.seq_step(_, acc, next => F.PendingDepositValue.seq_from_go(F.PendingDepositValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.PendingDepositValue(), acc, h <> t)} : Maybe<&2, +List<F.PendingDepositValue()>>}
      Node86_inverse_go(t, h <> acc)

law Node86_inverse:
  for +value: F.Node86()
  {F.Node86.from_value(F.Node86.to_value(value)) == Some{value} : Maybe<&2, F.Node86()>}
def Node86_inverse(value):
  Node86_inverse_go(value, [])

law Node87_append:
  for +xs: +List<F.PendingPartialWithdrawalValue()>
  for +ys: +List<F.PendingPartialWithdrawalValue()>
  for +acc: T.Value
  {F.PendingPartialWithdrawalValue.seq_to_go(List.append(&2, F.PendingPartialWithdrawalValue(), xs, ys), acc) == F.PendingPartialWithdrawalValue.seq_to_go(ys, F.PendingPartialWithdrawalValue.seq_to_go(xs, acc)) : T.Value}
def Node87_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node87_append(t, ys, T.Items{F.PendingPartialWithdrawalValue.to_value(h), acc})

law Node87_cons:
  for +h: F.PendingPartialWithdrawalValue()
  for +t: +List<F.PendingPartialWithdrawalValue()>
  {F.PendingPartialWithdrawalValue.seq_to(h <> t) == T.Items{F.PendingPartialWithdrawalValue.to_value(h), F.PendingPartialWithdrawalValue.seq_to(t)} : T.Value}
def Node87_cons(h, t):
  %Equal.sym(+List<F.PendingPartialWithdrawalValue()>, List.reverse.go(&2, F.PendingPartialWithdrawalValue(), t, [h]), List.append(&2, F.PendingPartialWithdrawalValue(), List.reverse(&2, F.PendingPartialWithdrawalValue(), t), [h]), L.reverse_acc_append(F.PendingPartialWithdrawalValue(), t, [], [h])) : {F.PendingPartialWithdrawalValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.PendingPartialWithdrawalValue.to_value(h), F.PendingPartialWithdrawalValue.seq_to(t)} : T.Value}
  Node87_append(List.reverse(&2, F.PendingPartialWithdrawalValue(), t), [h], T.EmptyItems{})

law Node87_inverse_go:
  for +xs: +List<F.PendingPartialWithdrawalValue()>
  for +acc: +List<F.PendingPartialWithdrawalValue()>
  {F.PendingPartialWithdrawalValue.seq_from_go(F.PendingPartialWithdrawalValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.PendingPartialWithdrawalValue(), acc, xs)} : Maybe<&2, +List<F.PendingPartialWithdrawalValue()>>}
def Node87_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.PendingPartialWithdrawalValue.seq_to(h <> t), T.Items{F.PendingPartialWithdrawalValue.to_value(h), F.PendingPartialWithdrawalValue.seq_to(t)}, Node87_cons(h, t)) : {F.PendingPartialWithdrawalValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.PendingPartialWithdrawalValue(), acc, h <> t)} : Maybe<&2, +List<F.PendingPartialWithdrawalValue()>>}
      %Equal.sym(Maybe<&2, F.PendingPartialWithdrawalValue()>, F.PendingPartialWithdrawalValue.from_value(F.PendingPartialWithdrawalValue.to_value(h)), Some{h}, PendingPartialWithdrawalValue_inverse(h)) : {F.PendingPartialWithdrawalValue.seq_step(_, acc, next => F.PendingPartialWithdrawalValue.seq_from_go(F.PendingPartialWithdrawalValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.PendingPartialWithdrawalValue(), acc, h <> t)} : Maybe<&2, +List<F.PendingPartialWithdrawalValue()>>}
      Node87_inverse_go(t, h <> acc)

law Node87_inverse:
  for +value: F.Node87()
  {F.Node87.from_value(F.Node87.to_value(value)) == Some{value} : Maybe<&2, F.Node87()>}
def Node87_inverse(value):
  Node87_inverse_go(value, [])

law Node88_append:
  for +xs: +List<F.PendingConsolidationValue()>
  for +ys: +List<F.PendingConsolidationValue()>
  for +acc: T.Value
  {F.PendingConsolidationValue.seq_to_go(List.append(&2, F.PendingConsolidationValue(), xs, ys), acc) == F.PendingConsolidationValue.seq_to_go(ys, F.PendingConsolidationValue.seq_to_go(xs, acc)) : T.Value}
def Node88_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node88_append(t, ys, T.Items{F.PendingConsolidationValue.to_value(h), acc})

law Node88_cons:
  for +h: F.PendingConsolidationValue()
  for +t: +List<F.PendingConsolidationValue()>
  {F.PendingConsolidationValue.seq_to(h <> t) == T.Items{F.PendingConsolidationValue.to_value(h), F.PendingConsolidationValue.seq_to(t)} : T.Value}
def Node88_cons(h, t):
  %Equal.sym(+List<F.PendingConsolidationValue()>, List.reverse.go(&2, F.PendingConsolidationValue(), t, [h]), List.append(&2, F.PendingConsolidationValue(), List.reverse(&2, F.PendingConsolidationValue(), t), [h]), L.reverse_acc_append(F.PendingConsolidationValue(), t, [], [h])) : {F.PendingConsolidationValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.PendingConsolidationValue.to_value(h), F.PendingConsolidationValue.seq_to(t)} : T.Value}
  Node88_append(List.reverse(&2, F.PendingConsolidationValue(), t), [h], T.EmptyItems{})

law Node88_inverse_go:
  for +xs: +List<F.PendingConsolidationValue()>
  for +acc: +List<F.PendingConsolidationValue()>
  {F.PendingConsolidationValue.seq_from_go(F.PendingConsolidationValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.PendingConsolidationValue(), acc, xs)} : Maybe<&2, +List<F.PendingConsolidationValue()>>}
def Node88_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.PendingConsolidationValue.seq_to(h <> t), T.Items{F.PendingConsolidationValue.to_value(h), F.PendingConsolidationValue.seq_to(t)}, Node88_cons(h, t)) : {F.PendingConsolidationValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.PendingConsolidationValue(), acc, h <> t)} : Maybe<&2, +List<F.PendingConsolidationValue()>>}
      %Equal.sym(Maybe<&2, F.PendingConsolidationValue()>, F.PendingConsolidationValue.from_value(F.PendingConsolidationValue.to_value(h)), Some{h}, PendingConsolidationValue_inverse(h)) : {F.PendingConsolidationValue.seq_step(_, acc, next => F.PendingConsolidationValue.seq_from_go(F.PendingConsolidationValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.PendingConsolidationValue(), acc, h <> t)} : Maybe<&2, +List<F.PendingConsolidationValue()>>}
      Node88_inverse_go(t, h <> acc)

law Node88_inverse:
  for +value: F.Node88()
  {F.Node88.from_value(F.Node88.to_value(value)) == Some{value} : Maybe<&2, F.Node88()>}
def Node88_inverse(value):
  Node88_inverse_go(value, [])

law Node89_append:
  for +xs: +List<F.Node3()>
  for +ys: +List<F.Node3()>
  for +acc: T.Value
  {F.Node3.seq_to_go(List.append(&2, F.Node3(), xs, ys), acc) == F.Node3.seq_to_go(ys, F.Node3.seq_to_go(xs, acc)) : T.Value}
def Node89_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node89_append(t, ys, T.Items{F.Node3.to_value(h), acc})

law Node89_cons:
  for +h: F.Node3()
  for +t: +List<F.Node3()>
  {F.Node3.seq_to(h <> t) == T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)} : T.Value}
def Node89_cons(h, t):
  %Equal.sym(+List<F.Node3()>, List.reverse.go(&2, F.Node3(), t, [h]), List.append(&2, F.Node3(), List.reverse(&2, F.Node3(), t), [h]), L.reverse_acc_append(F.Node3(), t, [], [h])) : {F.Node3.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)} : T.Value}
  Node89_append(List.reverse(&2, F.Node3(), t), [h], T.EmptyItems{})

law Node89_inverse_go:
  for +xs: +List<F.Node3()>
  for +acc: +List<F.Node3()>
  {F.Node3.seq_from_go(F.Node3.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node3(), acc, xs)} : Maybe<&2, +List<F.Node3()>>}
def Node89_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node3.seq_to(h <> t), T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)}, Node89_cons(h, t)) : {F.Node3.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node3(), acc, h <> t)} : Maybe<&2, +List<F.Node3()>>}
      %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(h)), Some{h}, Node3_inverse(h)) : {F.Node3.seq_step(_, acc, next => F.Node3.seq_from_go(F.Node3.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node3(), acc, h <> t)} : Maybe<&2, +List<F.Node3()>>}
      Node89_inverse_go(t, h <> acc)

law Node89_inverse:
  for +value: F.Node89()
  {F.Node89.from_value(F.Node89.to_value(value)) == Some{value} : Maybe<&2, F.Node89()>}
def Node89_inverse(value):
  Node89_inverse_go(value, [])

law BeaconStateValue_inverse:
  for +value: F.BeaconStateValue()
  {F.BeaconStateValue.from_value(F.BeaconStateValue.to_value(value)) == Some{value} : Maybe<&2, F.BeaconStateValue()>}
def BeaconStateValue_inverse(value):
  F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(genesis_time)), Some{genesis_time}, Node3_inverse(genesis_time)) : {F.BeaconStateValue.assemble(_, F.Node7.from_value(F.Node7.to_value(genesis_validators_root)), F.Node3.from_value(F.Node3.to_value(slot)), F.ForkValue.from_value(F.ForkValue.to_value(fork)), F.BeaconBlockHeaderValue.from_value(F.BeaconBlockHeaderValue.to_value(latest_block_header)), F.Node33.from_value(F.Node33.to_value(block_roots)), F.Node33.from_value(F.Node33.to_value(state_roots)), F.Node77.from_value(F.Node77.to_value(historical_roots)), F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(eth1_data)), F.Node78.from_value(F.Node78.to_value(eth1_data_votes)), F.Node3.from_value(F.Node3.to_value(eth1_deposit_index)), F.Node79.from_value(F.Node79.to_value(validators)), F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(genesis_validators_root)), Some{genesis_validators_root}, Node7_inverse(genesis_validators_root)) : {F.BeaconStateValue.assemble(Some{genesis_time}, _, F.Node3.from_value(F.Node3.to_value(slot)), F.ForkValue.from_value(F.ForkValue.to_value(fork)), F.BeaconBlockHeaderValue.from_value(F.BeaconBlockHeaderValue.to_value(latest_block_header)), F.Node33.from_value(F.Node33.to_value(block_roots)), F.Node33.from_value(F.Node33.to_value(state_roots)), F.Node77.from_value(F.Node77.to_value(historical_roots)), F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(eth1_data)), F.Node78.from_value(F.Node78.to_value(eth1_data_votes)), F.Node3.from_value(F.Node3.to_value(eth1_deposit_index)), F.Node79.from_value(F.Node79.to_value(validators)), F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(slot)), Some{slot}, Node3_inverse(slot)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, _, F.ForkValue.from_value(F.ForkValue.to_value(fork)), F.BeaconBlockHeaderValue.from_value(F.BeaconBlockHeaderValue.to_value(latest_block_header)), F.Node33.from_value(F.Node33.to_value(block_roots)), F.Node33.from_value(F.Node33.to_value(state_roots)), F.Node77.from_value(F.Node77.to_value(historical_roots)), F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(eth1_data)), F.Node78.from_value(F.Node78.to_value(eth1_data_votes)), F.Node3.from_value(F.Node3.to_value(eth1_deposit_index)), F.Node79.from_value(F.Node79.to_value(validators)), F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.ForkValue()>, F.ForkValue.from_value(F.ForkValue.to_value(fork)), Some{fork}, ForkValue_inverse(fork)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, _, F.BeaconBlockHeaderValue.from_value(F.BeaconBlockHeaderValue.to_value(latest_block_header)), F.Node33.from_value(F.Node33.to_value(block_roots)), F.Node33.from_value(F.Node33.to_value(state_roots)), F.Node77.from_value(F.Node77.to_value(historical_roots)), F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(eth1_data)), F.Node78.from_value(F.Node78.to_value(eth1_data_votes)), F.Node3.from_value(F.Node3.to_value(eth1_deposit_index)), F.Node79.from_value(F.Node79.to_value(validators)), F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.BeaconBlockHeaderValue()>, F.BeaconBlockHeaderValue.from_value(F.BeaconBlockHeaderValue.to_value(latest_block_header)), Some{latest_block_header}, BeaconBlockHeaderValue_inverse(latest_block_header)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, _, F.Node33.from_value(F.Node33.to_value(block_roots)), F.Node33.from_value(F.Node33.to_value(state_roots)), F.Node77.from_value(F.Node77.to_value(historical_roots)), F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(eth1_data)), F.Node78.from_value(F.Node78.to_value(eth1_data_votes)), F.Node3.from_value(F.Node3.to_value(eth1_deposit_index)), F.Node79.from_value(F.Node79.to_value(validators)), F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node33()>, F.Node33.from_value(F.Node33.to_value(block_roots)), Some{block_roots}, Node33_inverse(block_roots)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, _, F.Node33.from_value(F.Node33.to_value(state_roots)), F.Node77.from_value(F.Node77.to_value(historical_roots)), F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(eth1_data)), F.Node78.from_value(F.Node78.to_value(eth1_data_votes)), F.Node3.from_value(F.Node3.to_value(eth1_deposit_index)), F.Node79.from_value(F.Node79.to_value(validators)), F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node33()>, F.Node33.from_value(F.Node33.to_value(state_roots)), Some{state_roots}, Node33_inverse(state_roots)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, _, F.Node77.from_value(F.Node77.to_value(historical_roots)), F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(eth1_data)), F.Node78.from_value(F.Node78.to_value(eth1_data_votes)), F.Node3.from_value(F.Node3.to_value(eth1_deposit_index)), F.Node79.from_value(F.Node79.to_value(validators)), F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node77()>, F.Node77.from_value(F.Node77.to_value(historical_roots)), Some{historical_roots}, Node77_inverse(historical_roots)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, _, F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(eth1_data)), F.Node78.from_value(F.Node78.to_value(eth1_data_votes)), F.Node3.from_value(F.Node3.to_value(eth1_deposit_index)), F.Node79.from_value(F.Node79.to_value(validators)), F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Eth1DataValue()>, F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(eth1_data)), Some{eth1_data}, Eth1DataValue_inverse(eth1_data)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, _, F.Node78.from_value(F.Node78.to_value(eth1_data_votes)), F.Node3.from_value(F.Node3.to_value(eth1_deposit_index)), F.Node79.from_value(F.Node79.to_value(validators)), F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node78()>, F.Node78.from_value(F.Node78.to_value(eth1_data_votes)), Some{eth1_data_votes}, Node78_inverse(eth1_data_votes)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, _, F.Node3.from_value(F.Node3.to_value(eth1_deposit_index)), F.Node79.from_value(F.Node79.to_value(validators)), F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(eth1_deposit_index)), Some{eth1_deposit_index}, Node3_inverse(eth1_deposit_index)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, _, F.Node79.from_value(F.Node79.to_value(validators)), F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node79()>, F.Node79.from_value(F.Node79.to_value(validators)), Some{validators}, Node79_inverse(validators)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, _, F.Node80.from_value(F.Node80.to_value(balances)), F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node80()>, F.Node80.from_value(F.Node80.to_value(balances)), Some{balances}, Node80_inverse(balances)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, _, F.Node81.from_value(F.Node81.to_value(randao_mixes)), F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node81()>, F.Node81.from_value(F.Node81.to_value(randao_mixes)), Some{randao_mixes}, Node81_inverse(randao_mixes)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, _, F.Node82.from_value(F.Node82.to_value(slashings)), F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node82()>, F.Node82.from_value(F.Node82.to_value(slashings)), Some{slashings}, Node82_inverse(slashings)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, _, F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node83()>, F.Node83.from_value(F.Node83.to_value(previous_epoch_participation)), Some{previous_epoch_participation}, Node83_inverse(previous_epoch_participation)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, _, F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node83()>, F.Node83.from_value(F.Node83.to_value(current_epoch_participation)), Some{current_epoch_participation}, Node83_inverse(current_epoch_participation)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, _, F.Node84.from_value(F.Node84.to_value(justification_bits)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node84()>, F.Node84.from_value(F.Node84.to_value(justification_bits)), Some{justification_bits}, Node84_inverse(justification_bits)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, _, F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.CheckpointValue()>, F.CheckpointValue.from_value(F.CheckpointValue.to_value(previous_justified_checkpoint)), Some{previous_justified_checkpoint}, CheckpointValue_inverse(previous_justified_checkpoint)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, _, F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.CheckpointValue()>, F.CheckpointValue.from_value(F.CheckpointValue.to_value(current_justified_checkpoint)), Some{current_justified_checkpoint}, CheckpointValue_inverse(current_justified_checkpoint)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, _, F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.CheckpointValue()>, F.CheckpointValue.from_value(F.CheckpointValue.to_value(finalized_checkpoint)), Some{finalized_checkpoint}, CheckpointValue_inverse(finalized_checkpoint)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, _, F.Node80.from_value(F.Node80.to_value(inactivity_scores)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node80()>, F.Node80.from_value(F.Node80.to_value(inactivity_scores)), Some{inactivity_scores}, Node80_inverse(inactivity_scores)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, _, F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.SyncCommitteeValue()>, F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), Some{current_sync_committee}, SyncCommitteeValue_inverse(current_sync_committee)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, _, F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.SyncCommitteeValue()>, F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), Some{next_sync_committee}, SyncCommitteeValue_inverse(next_sync_committee)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, _, F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.ExecutionPayloadHeaderValue()>, F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(latest_execution_payload_header)), Some{latest_execution_payload_header}, ExecutionPayloadHeaderValue_inverse(latest_execution_payload_header)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, _, F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(next_withdrawal_index)), Some{next_withdrawal_index}, Node3_inverse(next_withdrawal_index)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, _, F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(next_withdrawal_validator_index)), Some{next_withdrawal_validator_index}, Node3_inverse(next_withdrawal_validator_index)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, _, F.Node85.from_value(F.Node85.to_value(historical_summaries)), F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node85()>, F.Node85.from_value(F.Node85.to_value(historical_summaries)), Some{historical_summaries}, Node85_inverse(historical_summaries)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, Some{next_withdrawal_validator_index}, _, F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(deposit_requests_start_index)), Some{deposit_requests_start_index}, Node3_inverse(deposit_requests_start_index)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, Some{next_withdrawal_validator_index}, Some{historical_summaries}, _, F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(deposit_balance_to_consume)), Some{deposit_balance_to_consume}, Node3_inverse(deposit_balance_to_consume)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, Some{next_withdrawal_validator_index}, Some{historical_summaries}, Some{deposit_requests_start_index}, _, F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(exit_balance_to_consume)), Some{exit_balance_to_consume}, Node3_inverse(exit_balance_to_consume)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, Some{next_withdrawal_validator_index}, Some{historical_summaries}, Some{deposit_requests_start_index}, Some{deposit_balance_to_consume}, _, F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(earliest_exit_epoch)), Some{earliest_exit_epoch}, Node3_inverse(earliest_exit_epoch)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, Some{next_withdrawal_validator_index}, Some{historical_summaries}, Some{deposit_requests_start_index}, Some{deposit_balance_to_consume}, Some{exit_balance_to_consume}, _, F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(consolidation_balance_to_consume)), Some{consolidation_balance_to_consume}, Node3_inverse(consolidation_balance_to_consume)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, Some{next_withdrawal_validator_index}, Some{historical_summaries}, Some{deposit_requests_start_index}, Some{deposit_balance_to_consume}, Some{exit_balance_to_consume}, Some{earliest_exit_epoch}, _, F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(earliest_consolidation_epoch)), Some{earliest_consolidation_epoch}, Node3_inverse(earliest_consolidation_epoch)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, Some{next_withdrawal_validator_index}, Some{historical_summaries}, Some{deposit_requests_start_index}, Some{deposit_balance_to_consume}, Some{exit_balance_to_consume}, Some{earliest_exit_epoch}, Some{consolidation_balance_to_consume}, _, F.Node86.from_value(F.Node86.to_value(pending_deposits)), F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node86()>, F.Node86.from_value(F.Node86.to_value(pending_deposits)), Some{pending_deposits}, Node86_inverse(pending_deposits)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, Some{next_withdrawal_validator_index}, Some{historical_summaries}, Some{deposit_requests_start_index}, Some{deposit_balance_to_consume}, Some{exit_balance_to_consume}, Some{earliest_exit_epoch}, Some{consolidation_balance_to_consume}, Some{earliest_consolidation_epoch}, _, F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node87()>, F.Node87.from_value(F.Node87.to_value(pending_partial_withdrawals)), Some{pending_partial_withdrawals}, Node87_inverse(pending_partial_withdrawals)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, Some{next_withdrawal_validator_index}, Some{historical_summaries}, Some{deposit_requests_start_index}, Some{deposit_balance_to_consume}, Some{exit_balance_to_consume}, Some{earliest_exit_epoch}, Some{consolidation_balance_to_consume}, Some{earliest_consolidation_epoch}, Some{pending_deposits}, _, F.Node88.from_value(F.Node88.to_value(pending_consolidations)), F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node88()>, F.Node88.from_value(F.Node88.to_value(pending_consolidations)), Some{pending_consolidations}, Node88_inverse(pending_consolidations)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, Some{next_withdrawal_validator_index}, Some{historical_summaries}, Some{deposit_requests_start_index}, Some{deposit_balance_to_consume}, Some{exit_balance_to_consume}, Some{earliest_exit_epoch}, Some{consolidation_balance_to_consume}, Some{earliest_consolidation_epoch}, Some{pending_deposits}, Some{pending_partial_withdrawals}, _, F.Node89.from_value(F.Node89.to_value(proposer_lookahead))) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  %Equal.sym(Maybe<&2, F.Node89()>, F.Node89.from_value(F.Node89.to_value(proposer_lookahead)), Some{proposer_lookahead}, Node89_inverse(proposer_lookahead)) : {F.BeaconStateValue.assemble(Some{genesis_time}, Some{genesis_validators_root}, Some{slot}, Some{fork}, Some{latest_block_header}, Some{block_roots}, Some{state_roots}, Some{historical_roots}, Some{eth1_data}, Some{eth1_data_votes}, Some{eth1_deposit_index}, Some{validators}, Some{balances}, Some{randao_mixes}, Some{slashings}, Some{previous_epoch_participation}, Some{current_epoch_participation}, Some{justification_bits}, Some{previous_justified_checkpoint}, Some{current_justified_checkpoint}, Some{finalized_checkpoint}, Some{inactivity_scores}, Some{current_sync_committee}, Some{next_sync_committee}, Some{latest_execution_payload_header}, Some{next_withdrawal_index}, Some{next_withdrawal_validator_index}, Some{historical_summaries}, Some{deposit_requests_start_index}, Some{deposit_balance_to_consume}, Some{exit_balance_to_consume}, Some{earliest_exit_epoch}, Some{consolidation_balance_to_consume}, Some{earliest_consolidation_epoch}, Some{pending_deposits}, Some{pending_partial_withdrawals}, Some{pending_consolidations}, _) == Some{F.BeaconState{genesis_time, genesis_validators_root, slot, fork, latest_block_header, block_roots, state_roots, historical_roots, eth1_data, eth1_data_votes, eth1_deposit_index, validators, balances, randao_mixes, slashings, previous_epoch_participation, current_epoch_participation, justification_bits, previous_justified_checkpoint, current_justified_checkpoint, finalized_checkpoint, inactivity_scores, current_sync_committee, next_sync_committee, latest_execution_payload_header, next_withdrawal_index, next_withdrawal_validator_index, historical_summaries, deposit_requests_start_index, deposit_balance_to_consume, exit_balance_to_consume, earliest_exit_epoch, consolidation_balance_to_consume, earliest_consolidation_epoch, pending_deposits, pending_partial_withdrawals, pending_consolidations, proposer_lookahead}} : Maybe<&2, F.BeaconStateValue()>}
  {==}

law Node90_append:
  for +xs: +List<F.Node7()>
  for +ys: +List<F.Node7()>
  for +acc: T.Value
  {F.Node7.seq_to_go(List.append(&2, F.Node7(), xs, ys), acc) == F.Node7.seq_to_go(ys, F.Node7.seq_to_go(xs, acc)) : T.Value}
def Node90_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node90_append(t, ys, T.Items{F.Node7.to_value(h), acc})

law Node90_cons:
  for +h: F.Node7()
  for +t: +List<F.Node7()>
  {F.Node7.seq_to(h <> t) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
def Node90_cons(h, t):
  %Equal.sym(+List<F.Node7()>, List.reverse.go(&2, F.Node7(), t, [h]), List.append(&2, F.Node7(), List.reverse(&2, F.Node7(), t), [h]), L.reverse_acc_append(F.Node7(), t, [], [h])) : {F.Node7.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
  Node90_append(List.reverse(&2, F.Node7(), t), [h], T.EmptyItems{})

law Node90_inverse_go:
  for +xs: +List<F.Node7()>
  for +acc: +List<F.Node7()>
  {F.Node7.seq_from_go(F.Node7.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node7(), acc, xs)} : Maybe<&2, +List<F.Node7()>>}
def Node90_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node7.seq_to(h <> t), T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)}, Node90_cons(h, t)) : {F.Node7.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(h)), Some{h}, Node7_inverse(h)) : {F.Node7.seq_step(_, acc, next => F.Node7.seq_from_go(F.Node7.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      Node90_inverse_go(t, h <> acc)

law Node90_inverse:
  for +value: F.Node90()
  {F.Node90.from_value(F.Node90.to_value(value)) == Some{value} : Maybe<&2, F.Node90()>}
def Node90_inverse(value):
  Node90_inverse_go(value, [])

law LightClientHeaderValue_inverse:
  for +value: F.LightClientHeaderValue()
  {F.LightClientHeaderValue.from_value(F.LightClientHeaderValue.to_value(value)) == Some{value} : Maybe<&2, F.LightClientHeaderValue()>}
def LightClientHeaderValue_inverse(value):
  F.LightClientHeader{beacon, execution, execution_branch} = value
  %Equal.sym(Maybe<&2, F.BeaconBlockHeaderValue()>, F.BeaconBlockHeaderValue.from_value(F.BeaconBlockHeaderValue.to_value(beacon)), Some{beacon}, BeaconBlockHeaderValue_inverse(beacon)) : {F.LightClientHeaderValue.assemble(_, F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(execution)), F.Node90.from_value(F.Node90.to_value(execution_branch))) == Some{F.LightClientHeader{beacon, execution, execution_branch}} : Maybe<&2, F.LightClientHeaderValue()>}
  %Equal.sym(Maybe<&2, F.ExecutionPayloadHeaderValue()>, F.ExecutionPayloadHeaderValue.from_value(F.ExecutionPayloadHeaderValue.to_value(execution)), Some{execution}, ExecutionPayloadHeaderValue_inverse(execution)) : {F.LightClientHeaderValue.assemble(Some{beacon}, _, F.Node90.from_value(F.Node90.to_value(execution_branch))) == Some{F.LightClientHeader{beacon, execution, execution_branch}} : Maybe<&2, F.LightClientHeaderValue()>}
  %Equal.sym(Maybe<&2, F.Node90()>, F.Node90.from_value(F.Node90.to_value(execution_branch)), Some{execution_branch}, Node90_inverse(execution_branch)) : {F.LightClientHeaderValue.assemble(Some{beacon}, Some{execution}, _) == Some{F.LightClientHeader{beacon, execution, execution_branch}} : Maybe<&2, F.LightClientHeaderValue()>}
  {==}

law LightClientOptimisticUpdateValue_inverse:
  for +value: F.LightClientOptimisticUpdateValue()
  {F.LightClientOptimisticUpdateValue.from_value(F.LightClientOptimisticUpdateValue.to_value(value)) == Some{value} : Maybe<&2, F.LightClientOptimisticUpdateValue()>}
def LightClientOptimisticUpdateValue_inverse(value):
  F.LightClientOptimisticUpdate{attested_header, sync_aggregate, signature_slot} = value
  %Equal.sym(Maybe<&2, F.LightClientHeaderValue()>, F.LightClientHeaderValue.from_value(F.LightClientHeaderValue.to_value(attested_header)), Some{attested_header}, LightClientHeaderValue_inverse(attested_header)) : {F.LightClientOptimisticUpdateValue.assemble(_, F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientOptimisticUpdate{attested_header, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientOptimisticUpdateValue()>}
  %Equal.sym(Maybe<&2, F.SyncAggregateValue()>, F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), Some{sync_aggregate}, SyncAggregateValue_inverse(sync_aggregate)) : {F.LightClientOptimisticUpdateValue.assemble(Some{attested_header}, _, F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientOptimisticUpdate{attested_header, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientOptimisticUpdateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(signature_slot)), Some{signature_slot}, Node3_inverse(signature_slot)) : {F.LightClientOptimisticUpdateValue.assemble(Some{attested_header}, Some{sync_aggregate}, _) == Some{F.LightClientOptimisticUpdate{attested_header, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientOptimisticUpdateValue()>}
  {==}

law LightClientFinalityUpdateValue_inverse:
  for +value: F.LightClientFinalityUpdateValue()
  {F.LightClientFinalityUpdateValue.from_value(F.LightClientFinalityUpdateValue.to_value(value)) == Some{value} : Maybe<&2, F.LightClientFinalityUpdateValue()>}
def LightClientFinalityUpdateValue_inverse(value):
  F.LightClientFinalityUpdate{attested_header, finalized_header, finality_branch, sync_aggregate, signature_slot} = value
  %Equal.sym(Maybe<&2, F.LightClientHeaderValue()>, F.LightClientHeaderValue.from_value(F.LightClientHeaderValue.to_value(attested_header)), Some{attested_header}, LightClientHeaderValue_inverse(attested_header)) : {F.LightClientFinalityUpdateValue.assemble(_, F.LightClientHeaderValue.from_value(F.LightClientHeaderValue.to_value(finalized_header)), F.Node12.from_value(F.Node12.to_value(finality_branch)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientFinalityUpdate{attested_header, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientFinalityUpdateValue()>}
  %Equal.sym(Maybe<&2, F.LightClientHeaderValue()>, F.LightClientHeaderValue.from_value(F.LightClientHeaderValue.to_value(finalized_header)), Some{finalized_header}, LightClientHeaderValue_inverse(finalized_header)) : {F.LightClientFinalityUpdateValue.assemble(Some{attested_header}, _, F.Node12.from_value(F.Node12.to_value(finality_branch)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientFinalityUpdate{attested_header, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientFinalityUpdateValue()>}
  %Equal.sym(Maybe<&2, F.Node12()>, F.Node12.from_value(F.Node12.to_value(finality_branch)), Some{finality_branch}, Node12_inverse(finality_branch)) : {F.LightClientFinalityUpdateValue.assemble(Some{attested_header}, Some{finalized_header}, _, F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientFinalityUpdate{attested_header, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientFinalityUpdateValue()>}
  %Equal.sym(Maybe<&2, F.SyncAggregateValue()>, F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), Some{sync_aggregate}, SyncAggregateValue_inverse(sync_aggregate)) : {F.LightClientFinalityUpdateValue.assemble(Some{attested_header}, Some{finalized_header}, Some{finality_branch}, _, F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientFinalityUpdate{attested_header, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientFinalityUpdateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(signature_slot)), Some{signature_slot}, Node3_inverse(signature_slot)) : {F.LightClientFinalityUpdateValue.assemble(Some{attested_header}, Some{finalized_header}, Some{finality_branch}, Some{sync_aggregate}, _) == Some{F.LightClientFinalityUpdate{attested_header, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientFinalityUpdateValue()>}
  {==}

law LightClientUpdateValue_inverse:
  for +value: F.LightClientUpdateValue()
  {F.LightClientUpdateValue.from_value(F.LightClientUpdateValue.to_value(value)) == Some{value} : Maybe<&2, F.LightClientUpdateValue()>}
def LightClientUpdateValue_inverse(value):
  F.LightClientUpdate{attested_header, next_sync_committee, next_sync_committee_branch, finalized_header, finality_branch, sync_aggregate, signature_slot} = value
  %Equal.sym(Maybe<&2, F.LightClientHeaderValue()>, F.LightClientHeaderValue.from_value(F.LightClientHeaderValue.to_value(attested_header)), Some{attested_header}, LightClientHeaderValue_inverse(attested_header)) : {F.LightClientUpdateValue.assemble(_, F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), F.Node59.from_value(F.Node59.to_value(next_sync_committee_branch)), F.LightClientHeaderValue.from_value(F.LightClientHeaderValue.to_value(finalized_header)), F.Node12.from_value(F.Node12.to_value(finality_branch)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientUpdate{attested_header, next_sync_committee, next_sync_committee_branch, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientUpdateValue()>}
  %Equal.sym(Maybe<&2, F.SyncCommitteeValue()>, F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(next_sync_committee)), Some{next_sync_committee}, SyncCommitteeValue_inverse(next_sync_committee)) : {F.LightClientUpdateValue.assemble(Some{attested_header}, _, F.Node59.from_value(F.Node59.to_value(next_sync_committee_branch)), F.LightClientHeaderValue.from_value(F.LightClientHeaderValue.to_value(finalized_header)), F.Node12.from_value(F.Node12.to_value(finality_branch)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientUpdate{attested_header, next_sync_committee, next_sync_committee_branch, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientUpdateValue()>}
  %Equal.sym(Maybe<&2, F.Node59()>, F.Node59.from_value(F.Node59.to_value(next_sync_committee_branch)), Some{next_sync_committee_branch}, Node59_inverse(next_sync_committee_branch)) : {F.LightClientUpdateValue.assemble(Some{attested_header}, Some{next_sync_committee}, _, F.LightClientHeaderValue.from_value(F.LightClientHeaderValue.to_value(finalized_header)), F.Node12.from_value(F.Node12.to_value(finality_branch)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientUpdate{attested_header, next_sync_committee, next_sync_committee_branch, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientUpdateValue()>}
  %Equal.sym(Maybe<&2, F.LightClientHeaderValue()>, F.LightClientHeaderValue.from_value(F.LightClientHeaderValue.to_value(finalized_header)), Some{finalized_header}, LightClientHeaderValue_inverse(finalized_header)) : {F.LightClientUpdateValue.assemble(Some{attested_header}, Some{next_sync_committee}, Some{next_sync_committee_branch}, _, F.Node12.from_value(F.Node12.to_value(finality_branch)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientUpdate{attested_header, next_sync_committee, next_sync_committee_branch, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientUpdateValue()>}
  %Equal.sym(Maybe<&2, F.Node12()>, F.Node12.from_value(F.Node12.to_value(finality_branch)), Some{finality_branch}, Node12_inverse(finality_branch)) : {F.LightClientUpdateValue.assemble(Some{attested_header}, Some{next_sync_committee}, Some{next_sync_committee_branch}, Some{finalized_header}, _, F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientUpdate{attested_header, next_sync_committee, next_sync_committee_branch, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientUpdateValue()>}
  %Equal.sym(Maybe<&2, F.SyncAggregateValue()>, F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), Some{sync_aggregate}, SyncAggregateValue_inverse(sync_aggregate)) : {F.LightClientUpdateValue.assemble(Some{attested_header}, Some{next_sync_committee}, Some{next_sync_committee_branch}, Some{finalized_header}, Some{finality_branch}, _, F.Node3.from_value(F.Node3.to_value(signature_slot))) == Some{F.LightClientUpdate{attested_header, next_sync_committee, next_sync_committee_branch, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientUpdateValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(signature_slot)), Some{signature_slot}, Node3_inverse(signature_slot)) : {F.LightClientUpdateValue.assemble(Some{attested_header}, Some{next_sync_committee}, Some{next_sync_committee_branch}, Some{finalized_header}, Some{finality_branch}, Some{sync_aggregate}, _) == Some{F.LightClientUpdate{attested_header, next_sync_committee, next_sync_committee_branch, finalized_header, finality_branch, sync_aggregate, signature_slot}} : Maybe<&2, F.LightClientUpdateValue()>}
  {==}

law LightClientBootstrapValue_inverse:
  for +value: F.LightClientBootstrapValue()
  {F.LightClientBootstrapValue.from_value(F.LightClientBootstrapValue.to_value(value)) == Some{value} : Maybe<&2, F.LightClientBootstrapValue()>}
def LightClientBootstrapValue_inverse(value):
  F.LightClientBootstrap{header, current_sync_committee, current_sync_committee_branch} = value
  %Equal.sym(Maybe<&2, F.LightClientHeaderValue()>, F.LightClientHeaderValue.from_value(F.LightClientHeaderValue.to_value(header)), Some{header}, LightClientHeaderValue_inverse(header)) : {F.LightClientBootstrapValue.assemble(_, F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), F.Node59.from_value(F.Node59.to_value(current_sync_committee_branch))) == Some{F.LightClientBootstrap{header, current_sync_committee, current_sync_committee_branch}} : Maybe<&2, F.LightClientBootstrapValue()>}
  %Equal.sym(Maybe<&2, F.SyncCommitteeValue()>, F.SyncCommitteeValue.from_value(F.SyncCommitteeValue.to_value(current_sync_committee)), Some{current_sync_committee}, SyncCommitteeValue_inverse(current_sync_committee)) : {F.LightClientBootstrapValue.assemble(Some{header}, _, F.Node59.from_value(F.Node59.to_value(current_sync_committee_branch))) == Some{F.LightClientBootstrap{header, current_sync_committee, current_sync_committee_branch}} : Maybe<&2, F.LightClientBootstrapValue()>}
  %Equal.sym(Maybe<&2, F.Node59()>, F.Node59.from_value(F.Node59.to_value(current_sync_committee_branch)), Some{current_sync_committee_branch}, Node59_inverse(current_sync_committee_branch)) : {F.LightClientBootstrapValue.assemble(Some{header}, Some{current_sync_committee}, _) == Some{F.LightClientBootstrap{header, current_sync_committee, current_sync_committee_branch}} : Maybe<&2, F.LightClientBootstrapValue()>}
  {==}

law BlobIdentifierValue_inverse:
  for +value: F.BlobIdentifierValue()
  {F.BlobIdentifierValue.from_value(F.BlobIdentifierValue.to_value(value)) == Some{value} : Maybe<&2, F.BlobIdentifierValue()>}
def BlobIdentifierValue_inverse(value):
  F.BlobIdentifier{block_root, index} = value
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(block_root)), Some{block_root}, Node7_inverse(block_root)) : {F.BlobIdentifierValue.assemble(_, F.Node3.from_value(F.Node3.to_value(index))) == Some{F.BlobIdentifier{block_root, index}} : Maybe<&2, F.BlobIdentifierValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(index)), Some{index}, Node3_inverse(index)) : {F.BlobIdentifierValue.assemble(Some{block_root}, _) == Some{F.BlobIdentifier{block_root, index}} : Maybe<&2, F.BlobIdentifierValue()>}
  {==}

law Node98_append:
  for +xs: +List<F.ProposerSlashingValue()>
  for +ys: +List<F.ProposerSlashingValue()>
  for +acc: T.Value
  {F.ProposerSlashingValue.seq_to_go(List.append(&2, F.ProposerSlashingValue(), xs, ys), acc) == F.ProposerSlashingValue.seq_to_go(ys, F.ProposerSlashingValue.seq_to_go(xs, acc)) : T.Value}
def Node98_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node98_append(t, ys, T.Items{F.ProposerSlashingValue.to_value(h), acc})

law Node98_cons:
  for +h: F.ProposerSlashingValue()
  for +t: +List<F.ProposerSlashingValue()>
  {F.ProposerSlashingValue.seq_to(h <> t) == T.Items{F.ProposerSlashingValue.to_value(h), F.ProposerSlashingValue.seq_to(t)} : T.Value}
def Node98_cons(h, t):
  %Equal.sym(+List<F.ProposerSlashingValue()>, List.reverse.go(&2, F.ProposerSlashingValue(), t, [h]), List.append(&2, F.ProposerSlashingValue(), List.reverse(&2, F.ProposerSlashingValue(), t), [h]), L.reverse_acc_append(F.ProposerSlashingValue(), t, [], [h])) : {F.ProposerSlashingValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.ProposerSlashingValue.to_value(h), F.ProposerSlashingValue.seq_to(t)} : T.Value}
  Node98_append(List.reverse(&2, F.ProposerSlashingValue(), t), [h], T.EmptyItems{})

law Node98_inverse_go:
  for +xs: +List<F.ProposerSlashingValue()>
  for +acc: +List<F.ProposerSlashingValue()>
  {F.ProposerSlashingValue.seq_from_go(F.ProposerSlashingValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.ProposerSlashingValue(), acc, xs)} : Maybe<&2, +List<F.ProposerSlashingValue()>>}
def Node98_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.ProposerSlashingValue.seq_to(h <> t), T.Items{F.ProposerSlashingValue.to_value(h), F.ProposerSlashingValue.seq_to(t)}, Node98_cons(h, t)) : {F.ProposerSlashingValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.ProposerSlashingValue(), acc, h <> t)} : Maybe<&2, +List<F.ProposerSlashingValue()>>}
      %Equal.sym(Maybe<&2, F.ProposerSlashingValue()>, F.ProposerSlashingValue.from_value(F.ProposerSlashingValue.to_value(h)), Some{h}, ProposerSlashingValue_inverse(h)) : {F.ProposerSlashingValue.seq_step(_, acc, next => F.ProposerSlashingValue.seq_from_go(F.ProposerSlashingValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.ProposerSlashingValue(), acc, h <> t)} : Maybe<&2, +List<F.ProposerSlashingValue()>>}
      Node98_inverse_go(t, h <> acc)

law Node98_inverse:
  for +value: F.Node98()
  {F.Node98.from_value(F.Node98.to_value(value)) == Some{value} : Maybe<&2, F.Node98()>}
def Node98_inverse(value):
  Node98_inverse_go(value, [])

law Node99_append:
  for +xs: +List<F.AttesterSlashingValue()>
  for +ys: +List<F.AttesterSlashingValue()>
  for +acc: T.Value
  {F.AttesterSlashingValue.seq_to_go(List.append(&2, F.AttesterSlashingValue(), xs, ys), acc) == F.AttesterSlashingValue.seq_to_go(ys, F.AttesterSlashingValue.seq_to_go(xs, acc)) : T.Value}
def Node99_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node99_append(t, ys, T.Items{F.AttesterSlashingValue.to_value(h), acc})

law Node99_cons:
  for +h: F.AttesterSlashingValue()
  for +t: +List<F.AttesterSlashingValue()>
  {F.AttesterSlashingValue.seq_to(h <> t) == T.Items{F.AttesterSlashingValue.to_value(h), F.AttesterSlashingValue.seq_to(t)} : T.Value}
def Node99_cons(h, t):
  %Equal.sym(+List<F.AttesterSlashingValue()>, List.reverse.go(&2, F.AttesterSlashingValue(), t, [h]), List.append(&2, F.AttesterSlashingValue(), List.reverse(&2, F.AttesterSlashingValue(), t), [h]), L.reverse_acc_append(F.AttesterSlashingValue(), t, [], [h])) : {F.AttesterSlashingValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.AttesterSlashingValue.to_value(h), F.AttesterSlashingValue.seq_to(t)} : T.Value}
  Node99_append(List.reverse(&2, F.AttesterSlashingValue(), t), [h], T.EmptyItems{})

law Node99_inverse_go:
  for +xs: +List<F.AttesterSlashingValue()>
  for +acc: +List<F.AttesterSlashingValue()>
  {F.AttesterSlashingValue.seq_from_go(F.AttesterSlashingValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.AttesterSlashingValue(), acc, xs)} : Maybe<&2, +List<F.AttesterSlashingValue()>>}
def Node99_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.AttesterSlashingValue.seq_to(h <> t), T.Items{F.AttesterSlashingValue.to_value(h), F.AttesterSlashingValue.seq_to(t)}, Node99_cons(h, t)) : {F.AttesterSlashingValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.AttesterSlashingValue(), acc, h <> t)} : Maybe<&2, +List<F.AttesterSlashingValue()>>}
      %Equal.sym(Maybe<&2, F.AttesterSlashingValue()>, F.AttesterSlashingValue.from_value(F.AttesterSlashingValue.to_value(h)), Some{h}, AttesterSlashingValue_inverse(h)) : {F.AttesterSlashingValue.seq_step(_, acc, next => F.AttesterSlashingValue.seq_from_go(F.AttesterSlashingValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.AttesterSlashingValue(), acc, h <> t)} : Maybe<&2, +List<F.AttesterSlashingValue()>>}
      Node99_inverse_go(t, h <> acc)

law Node99_inverse:
  for +value: F.Node99()
  {F.Node99.from_value(F.Node99.to_value(value)) == Some{value} : Maybe<&2, F.Node99()>}
def Node99_inverse(value):
  Node99_inverse_go(value, [])

law Node100_append:
  for +xs: +List<F.AttestationValue()>
  for +ys: +List<F.AttestationValue()>
  for +acc: T.Value
  {F.AttestationValue.seq_to_go(List.append(&2, F.AttestationValue(), xs, ys), acc) == F.AttestationValue.seq_to_go(ys, F.AttestationValue.seq_to_go(xs, acc)) : T.Value}
def Node100_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node100_append(t, ys, T.Items{F.AttestationValue.to_value(h), acc})

law Node100_cons:
  for +h: F.AttestationValue()
  for +t: +List<F.AttestationValue()>
  {F.AttestationValue.seq_to(h <> t) == T.Items{F.AttestationValue.to_value(h), F.AttestationValue.seq_to(t)} : T.Value}
def Node100_cons(h, t):
  %Equal.sym(+List<F.AttestationValue()>, List.reverse.go(&2, F.AttestationValue(), t, [h]), List.append(&2, F.AttestationValue(), List.reverse(&2, F.AttestationValue(), t), [h]), L.reverse_acc_append(F.AttestationValue(), t, [], [h])) : {F.AttestationValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.AttestationValue.to_value(h), F.AttestationValue.seq_to(t)} : T.Value}
  Node100_append(List.reverse(&2, F.AttestationValue(), t), [h], T.EmptyItems{})

law Node100_inverse_go:
  for +xs: +List<F.AttestationValue()>
  for +acc: +List<F.AttestationValue()>
  {F.AttestationValue.seq_from_go(F.AttestationValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.AttestationValue(), acc, xs)} : Maybe<&2, +List<F.AttestationValue()>>}
def Node100_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.AttestationValue.seq_to(h <> t), T.Items{F.AttestationValue.to_value(h), F.AttestationValue.seq_to(t)}, Node100_cons(h, t)) : {F.AttestationValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.AttestationValue(), acc, h <> t)} : Maybe<&2, +List<F.AttestationValue()>>}
      %Equal.sym(Maybe<&2, F.AttestationValue()>, F.AttestationValue.from_value(F.AttestationValue.to_value(h)), Some{h}, AttestationValue_inverse(h)) : {F.AttestationValue.seq_step(_, acc, next => F.AttestationValue.seq_from_go(F.AttestationValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.AttestationValue(), acc, h <> t)} : Maybe<&2, +List<F.AttestationValue()>>}
      Node100_inverse_go(t, h <> acc)

law Node100_inverse:
  for +value: F.Node100()
  {F.Node100.from_value(F.Node100.to_value(value)) == Some{value} : Maybe<&2, F.Node100()>}
def Node100_inverse(value):
  Node100_inverse_go(value, [])

law Node101_append:
  for +xs: +List<F.DepositValue()>
  for +ys: +List<F.DepositValue()>
  for +acc: T.Value
  {F.DepositValue.seq_to_go(List.append(&2, F.DepositValue(), xs, ys), acc) == F.DepositValue.seq_to_go(ys, F.DepositValue.seq_to_go(xs, acc)) : T.Value}
def Node101_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node101_append(t, ys, T.Items{F.DepositValue.to_value(h), acc})

law Node101_cons:
  for +h: F.DepositValue()
  for +t: +List<F.DepositValue()>
  {F.DepositValue.seq_to(h <> t) == T.Items{F.DepositValue.to_value(h), F.DepositValue.seq_to(t)} : T.Value}
def Node101_cons(h, t):
  %Equal.sym(+List<F.DepositValue()>, List.reverse.go(&2, F.DepositValue(), t, [h]), List.append(&2, F.DepositValue(), List.reverse(&2, F.DepositValue(), t), [h]), L.reverse_acc_append(F.DepositValue(), t, [], [h])) : {F.DepositValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.DepositValue.to_value(h), F.DepositValue.seq_to(t)} : T.Value}
  Node101_append(List.reverse(&2, F.DepositValue(), t), [h], T.EmptyItems{})

law Node101_inverse_go:
  for +xs: +List<F.DepositValue()>
  for +acc: +List<F.DepositValue()>
  {F.DepositValue.seq_from_go(F.DepositValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.DepositValue(), acc, xs)} : Maybe<&2, +List<F.DepositValue()>>}
def Node101_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.DepositValue.seq_to(h <> t), T.Items{F.DepositValue.to_value(h), F.DepositValue.seq_to(t)}, Node101_cons(h, t)) : {F.DepositValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.DepositValue(), acc, h <> t)} : Maybe<&2, +List<F.DepositValue()>>}
      %Equal.sym(Maybe<&2, F.DepositValue()>, F.DepositValue.from_value(F.DepositValue.to_value(h)), Some{h}, DepositValue_inverse(h)) : {F.DepositValue.seq_step(_, acc, next => F.DepositValue.seq_from_go(F.DepositValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.DepositValue(), acc, h <> t)} : Maybe<&2, +List<F.DepositValue()>>}
      Node101_inverse_go(t, h <> acc)

law Node101_inverse:
  for +value: F.Node101()
  {F.Node101.from_value(F.Node101.to_value(value)) == Some{value} : Maybe<&2, F.Node101()>}
def Node101_inverse(value):
  Node101_inverse_go(value, [])

law Node102_append:
  for +xs: +List<F.SignedVoluntaryExitValue()>
  for +ys: +List<F.SignedVoluntaryExitValue()>
  for +acc: T.Value
  {F.SignedVoluntaryExitValue.seq_to_go(List.append(&2, F.SignedVoluntaryExitValue(), xs, ys), acc) == F.SignedVoluntaryExitValue.seq_to_go(ys, F.SignedVoluntaryExitValue.seq_to_go(xs, acc)) : T.Value}
def Node102_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node102_append(t, ys, T.Items{F.SignedVoluntaryExitValue.to_value(h), acc})

law Node102_cons:
  for +h: F.SignedVoluntaryExitValue()
  for +t: +List<F.SignedVoluntaryExitValue()>
  {F.SignedVoluntaryExitValue.seq_to(h <> t) == T.Items{F.SignedVoluntaryExitValue.to_value(h), F.SignedVoluntaryExitValue.seq_to(t)} : T.Value}
def Node102_cons(h, t):
  %Equal.sym(+List<F.SignedVoluntaryExitValue()>, List.reverse.go(&2, F.SignedVoluntaryExitValue(), t, [h]), List.append(&2, F.SignedVoluntaryExitValue(), List.reverse(&2, F.SignedVoluntaryExitValue(), t), [h]), L.reverse_acc_append(F.SignedVoluntaryExitValue(), t, [], [h])) : {F.SignedVoluntaryExitValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.SignedVoluntaryExitValue.to_value(h), F.SignedVoluntaryExitValue.seq_to(t)} : T.Value}
  Node102_append(List.reverse(&2, F.SignedVoluntaryExitValue(), t), [h], T.EmptyItems{})

law Node102_inverse_go:
  for +xs: +List<F.SignedVoluntaryExitValue()>
  for +acc: +List<F.SignedVoluntaryExitValue()>
  {F.SignedVoluntaryExitValue.seq_from_go(F.SignedVoluntaryExitValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.SignedVoluntaryExitValue(), acc, xs)} : Maybe<&2, +List<F.SignedVoluntaryExitValue()>>}
def Node102_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.SignedVoluntaryExitValue.seq_to(h <> t), T.Items{F.SignedVoluntaryExitValue.to_value(h), F.SignedVoluntaryExitValue.seq_to(t)}, Node102_cons(h, t)) : {F.SignedVoluntaryExitValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.SignedVoluntaryExitValue(), acc, h <> t)} : Maybe<&2, +List<F.SignedVoluntaryExitValue()>>}
      %Equal.sym(Maybe<&2, F.SignedVoluntaryExitValue()>, F.SignedVoluntaryExitValue.from_value(F.SignedVoluntaryExitValue.to_value(h)), Some{h}, SignedVoluntaryExitValue_inverse(h)) : {F.SignedVoluntaryExitValue.seq_step(_, acc, next => F.SignedVoluntaryExitValue.seq_from_go(F.SignedVoluntaryExitValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.SignedVoluntaryExitValue(), acc, h <> t)} : Maybe<&2, +List<F.SignedVoluntaryExitValue()>>}
      Node102_inverse_go(t, h <> acc)

law Node102_inverse:
  for +value: F.Node102()
  {F.Node102.from_value(F.Node102.to_value(value)) == Some{value} : Maybe<&2, F.Node102()>}
def Node102_inverse(value):
  Node102_inverse_go(value, [])

law Node103_append:
  for +xs: +List<F.SignedBLSToExecutionChangeValue()>
  for +ys: +List<F.SignedBLSToExecutionChangeValue()>
  for +acc: T.Value
  {F.SignedBLSToExecutionChangeValue.seq_to_go(List.append(&2, F.SignedBLSToExecutionChangeValue(), xs, ys), acc) == F.SignedBLSToExecutionChangeValue.seq_to_go(ys, F.SignedBLSToExecutionChangeValue.seq_to_go(xs, acc)) : T.Value}
def Node103_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node103_append(t, ys, T.Items{F.SignedBLSToExecutionChangeValue.to_value(h), acc})

law Node103_cons:
  for +h: F.SignedBLSToExecutionChangeValue()
  for +t: +List<F.SignedBLSToExecutionChangeValue()>
  {F.SignedBLSToExecutionChangeValue.seq_to(h <> t) == T.Items{F.SignedBLSToExecutionChangeValue.to_value(h), F.SignedBLSToExecutionChangeValue.seq_to(t)} : T.Value}
def Node103_cons(h, t):
  %Equal.sym(+List<F.SignedBLSToExecutionChangeValue()>, List.reverse.go(&2, F.SignedBLSToExecutionChangeValue(), t, [h]), List.append(&2, F.SignedBLSToExecutionChangeValue(), List.reverse(&2, F.SignedBLSToExecutionChangeValue(), t), [h]), L.reverse_acc_append(F.SignedBLSToExecutionChangeValue(), t, [], [h])) : {F.SignedBLSToExecutionChangeValue.seq_to_go(_, T.EmptyItems{}) == T.Items{F.SignedBLSToExecutionChangeValue.to_value(h), F.SignedBLSToExecutionChangeValue.seq_to(t)} : T.Value}
  Node103_append(List.reverse(&2, F.SignedBLSToExecutionChangeValue(), t), [h], T.EmptyItems{})

law Node103_inverse_go:
  for +xs: +List<F.SignedBLSToExecutionChangeValue()>
  for +acc: +List<F.SignedBLSToExecutionChangeValue()>
  {F.SignedBLSToExecutionChangeValue.seq_from_go(F.SignedBLSToExecutionChangeValue.seq_to(xs), acc) == Some{List.reverse.go(&2, F.SignedBLSToExecutionChangeValue(), acc, xs)} : Maybe<&2, +List<F.SignedBLSToExecutionChangeValue()>>}
def Node103_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.SignedBLSToExecutionChangeValue.seq_to(h <> t), T.Items{F.SignedBLSToExecutionChangeValue.to_value(h), F.SignedBLSToExecutionChangeValue.seq_to(t)}, Node103_cons(h, t)) : {F.SignedBLSToExecutionChangeValue.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.SignedBLSToExecutionChangeValue(), acc, h <> t)} : Maybe<&2, +List<F.SignedBLSToExecutionChangeValue()>>}
      %Equal.sym(Maybe<&2, F.SignedBLSToExecutionChangeValue()>, F.SignedBLSToExecutionChangeValue.from_value(F.SignedBLSToExecutionChangeValue.to_value(h)), Some{h}, SignedBLSToExecutionChangeValue_inverse(h)) : {F.SignedBLSToExecutionChangeValue.seq_step(_, acc, next => F.SignedBLSToExecutionChangeValue.seq_from_go(F.SignedBLSToExecutionChangeValue.seq_to(t), next)) == Some{List.reverse.go(&2, F.SignedBLSToExecutionChangeValue(), acc, h <> t)} : Maybe<&2, +List<F.SignedBLSToExecutionChangeValue()>>}
      Node103_inverse_go(t, h <> acc)

law Node103_inverse:
  for +value: F.Node103()
  {F.Node103.from_value(F.Node103.to_value(value)) == Some{value} : Maybe<&2, F.Node103()>}
def Node103_inverse(value):
  Node103_inverse_go(value, [])

law Node104_append:
  for +xs: +List<F.Node8()>
  for +ys: +List<F.Node8()>
  for +acc: T.Value
  {F.Node8.seq_to_go(List.append(&2, F.Node8(), xs, ys), acc) == F.Node8.seq_to_go(ys, F.Node8.seq_to_go(xs, acc)) : T.Value}
def Node104_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node104_append(t, ys, T.Items{F.Node8.to_value(h), acc})

law Node104_cons:
  for +h: F.Node8()
  for +t: +List<F.Node8()>
  {F.Node8.seq_to(h <> t) == T.Items{F.Node8.to_value(h), F.Node8.seq_to(t)} : T.Value}
def Node104_cons(h, t):
  %Equal.sym(+List<F.Node8()>, List.reverse.go(&2, F.Node8(), t, [h]), List.append(&2, F.Node8(), List.reverse(&2, F.Node8(), t), [h]), L.reverse_acc_append(F.Node8(), t, [], [h])) : {F.Node8.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node8.to_value(h), F.Node8.seq_to(t)} : T.Value}
  Node104_append(List.reverse(&2, F.Node8(), t), [h], T.EmptyItems{})

law Node104_inverse_go:
  for +xs: +List<F.Node8()>
  for +acc: +List<F.Node8()>
  {F.Node8.seq_from_go(F.Node8.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node8(), acc, xs)} : Maybe<&2, +List<F.Node8()>>}
def Node104_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node8.seq_to(h <> t), T.Items{F.Node8.to_value(h), F.Node8.seq_to(t)}, Node104_cons(h, t)) : {F.Node8.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node8(), acc, h <> t)} : Maybe<&2, +List<F.Node8()>>}
      %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(h)), Some{h}, Node8_inverse(h)) : {F.Node8.seq_step(_, acc, next => F.Node8.seq_from_go(F.Node8.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node8(), acc, h <> t)} : Maybe<&2, +List<F.Node8()>>}
      Node104_inverse_go(t, h <> acc)

law Node104_inverse:
  for +value: F.Node104()
  {F.Node104.from_value(F.Node104.to_value(value)) == Some{value} : Maybe<&2, F.Node104()>}
def Node104_inverse(value):
  Node104_inverse_go(value, [])

law BeaconBlockBodyValue_inverse:
  for +value: F.BeaconBlockBodyValue()
  {F.BeaconBlockBodyValue.from_value(F.BeaconBlockBodyValue.to_value(value)) == Some{value} : Maybe<&2, F.BeaconBlockBodyValue()>}
def BeaconBlockBodyValue_inverse(value):
  F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests} = value
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(randao_reveal)), Some{randao_reveal}, Node9_inverse(randao_reveal)) : {F.BeaconBlockBodyValue.assemble(_, F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(eth1_data)), F.Node7.from_value(F.Node7.to_value(graffiti)), F.Node98.from_value(F.Node98.to_value(proposer_slashings)), F.Node99.from_value(F.Node99.to_value(attester_slashings)), F.Node100.from_value(F.Node100.to_value(attestations)), F.Node101.from_value(F.Node101.to_value(deposits)), F.Node102.from_value(F.Node102.to_value(voluntary_exits)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.ExecutionPayloadValue.from_value(F.ExecutionPayloadValue.to_value(execution_payload)), F.Node103.from_value(F.Node103.to_value(bls_to_execution_changes)), F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.Eth1DataValue()>, F.Eth1DataValue.from_value(F.Eth1DataValue.to_value(eth1_data)), Some{eth1_data}, Eth1DataValue_inverse(eth1_data)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, _, F.Node7.from_value(F.Node7.to_value(graffiti)), F.Node98.from_value(F.Node98.to_value(proposer_slashings)), F.Node99.from_value(F.Node99.to_value(attester_slashings)), F.Node100.from_value(F.Node100.to_value(attestations)), F.Node101.from_value(F.Node101.to_value(deposits)), F.Node102.from_value(F.Node102.to_value(voluntary_exits)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.ExecutionPayloadValue.from_value(F.ExecutionPayloadValue.to_value(execution_payload)), F.Node103.from_value(F.Node103.to_value(bls_to_execution_changes)), F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(graffiti)), Some{graffiti}, Node7_inverse(graffiti)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, Some{eth1_data}, _, F.Node98.from_value(F.Node98.to_value(proposer_slashings)), F.Node99.from_value(F.Node99.to_value(attester_slashings)), F.Node100.from_value(F.Node100.to_value(attestations)), F.Node101.from_value(F.Node101.to_value(deposits)), F.Node102.from_value(F.Node102.to_value(voluntary_exits)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.ExecutionPayloadValue.from_value(F.ExecutionPayloadValue.to_value(execution_payload)), F.Node103.from_value(F.Node103.to_value(bls_to_execution_changes)), F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.Node98()>, F.Node98.from_value(F.Node98.to_value(proposer_slashings)), Some{proposer_slashings}, Node98_inverse(proposer_slashings)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, Some{eth1_data}, Some{graffiti}, _, F.Node99.from_value(F.Node99.to_value(attester_slashings)), F.Node100.from_value(F.Node100.to_value(attestations)), F.Node101.from_value(F.Node101.to_value(deposits)), F.Node102.from_value(F.Node102.to_value(voluntary_exits)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.ExecutionPayloadValue.from_value(F.ExecutionPayloadValue.to_value(execution_payload)), F.Node103.from_value(F.Node103.to_value(bls_to_execution_changes)), F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.Node99()>, F.Node99.from_value(F.Node99.to_value(attester_slashings)), Some{attester_slashings}, Node99_inverse(attester_slashings)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, Some{eth1_data}, Some{graffiti}, Some{proposer_slashings}, _, F.Node100.from_value(F.Node100.to_value(attestations)), F.Node101.from_value(F.Node101.to_value(deposits)), F.Node102.from_value(F.Node102.to_value(voluntary_exits)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.ExecutionPayloadValue.from_value(F.ExecutionPayloadValue.to_value(execution_payload)), F.Node103.from_value(F.Node103.to_value(bls_to_execution_changes)), F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.Node100()>, F.Node100.from_value(F.Node100.to_value(attestations)), Some{attestations}, Node100_inverse(attestations)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, Some{eth1_data}, Some{graffiti}, Some{proposer_slashings}, Some{attester_slashings}, _, F.Node101.from_value(F.Node101.to_value(deposits)), F.Node102.from_value(F.Node102.to_value(voluntary_exits)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.ExecutionPayloadValue.from_value(F.ExecutionPayloadValue.to_value(execution_payload)), F.Node103.from_value(F.Node103.to_value(bls_to_execution_changes)), F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.Node101()>, F.Node101.from_value(F.Node101.to_value(deposits)), Some{deposits}, Node101_inverse(deposits)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, Some{eth1_data}, Some{graffiti}, Some{proposer_slashings}, Some{attester_slashings}, Some{attestations}, _, F.Node102.from_value(F.Node102.to_value(voluntary_exits)), F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.ExecutionPayloadValue.from_value(F.ExecutionPayloadValue.to_value(execution_payload)), F.Node103.from_value(F.Node103.to_value(bls_to_execution_changes)), F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.Node102()>, F.Node102.from_value(F.Node102.to_value(voluntary_exits)), Some{voluntary_exits}, Node102_inverse(voluntary_exits)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, Some{eth1_data}, Some{graffiti}, Some{proposer_slashings}, Some{attester_slashings}, Some{attestations}, Some{deposits}, _, F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), F.ExecutionPayloadValue.from_value(F.ExecutionPayloadValue.to_value(execution_payload)), F.Node103.from_value(F.Node103.to_value(bls_to_execution_changes)), F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.SyncAggregateValue()>, F.SyncAggregateValue.from_value(F.SyncAggregateValue.to_value(sync_aggregate)), Some{sync_aggregate}, SyncAggregateValue_inverse(sync_aggregate)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, Some{eth1_data}, Some{graffiti}, Some{proposer_slashings}, Some{attester_slashings}, Some{attestations}, Some{deposits}, Some{voluntary_exits}, _, F.ExecutionPayloadValue.from_value(F.ExecutionPayloadValue.to_value(execution_payload)), F.Node103.from_value(F.Node103.to_value(bls_to_execution_changes)), F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.ExecutionPayloadValue()>, F.ExecutionPayloadValue.from_value(F.ExecutionPayloadValue.to_value(execution_payload)), Some{execution_payload}, ExecutionPayloadValue_inverse(execution_payload)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, Some{eth1_data}, Some{graffiti}, Some{proposer_slashings}, Some{attester_slashings}, Some{attestations}, Some{deposits}, Some{voluntary_exits}, Some{sync_aggregate}, _, F.Node103.from_value(F.Node103.to_value(bls_to_execution_changes)), F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.Node103()>, F.Node103.from_value(F.Node103.to_value(bls_to_execution_changes)), Some{bls_to_execution_changes}, Node103_inverse(bls_to_execution_changes)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, Some{eth1_data}, Some{graffiti}, Some{proposer_slashings}, Some{attester_slashings}, Some{attestations}, Some{deposits}, Some{voluntary_exits}, Some{sync_aggregate}, Some{execution_payload}, _, F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.Node104()>, F.Node104.from_value(F.Node104.to_value(blob_kzg_commitments)), Some{blob_kzg_commitments}, Node104_inverse(blob_kzg_commitments)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, Some{eth1_data}, Some{graffiti}, Some{proposer_slashings}, Some{attester_slashings}, Some{attestations}, Some{deposits}, Some{voluntary_exits}, Some{sync_aggregate}, Some{execution_payload}, Some{bls_to_execution_changes}, _, F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests))) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  %Equal.sym(Maybe<&2, F.ExecutionRequestsValue()>, F.ExecutionRequestsValue.from_value(F.ExecutionRequestsValue.to_value(execution_requests)), Some{execution_requests}, ExecutionRequestsValue_inverse(execution_requests)) : {F.BeaconBlockBodyValue.assemble(Some{randao_reveal}, Some{eth1_data}, Some{graffiti}, Some{proposer_slashings}, Some{attester_slashings}, Some{attestations}, Some{deposits}, Some{voluntary_exits}, Some{sync_aggregate}, Some{execution_payload}, Some{bls_to_execution_changes}, Some{blob_kzg_commitments}, _) == Some{F.BeaconBlockBody{randao_reveal, eth1_data, graffiti, proposer_slashings, attester_slashings, attestations, deposits, voluntary_exits, sync_aggregate, execution_payload, bls_to_execution_changes, blob_kzg_commitments, execution_requests}} : Maybe<&2, F.BeaconBlockBodyValue()>}
  {==}

law BeaconBlockValue_inverse:
  for +value: F.BeaconBlockValue()
  {F.BeaconBlockValue.from_value(F.BeaconBlockValue.to_value(value)) == Some{value} : Maybe<&2, F.BeaconBlockValue()>}
def BeaconBlockValue_inverse(value):
  F.BeaconBlock{slot, proposer_index, parent_root, state_root, body} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(slot)), Some{slot}, Node3_inverse(slot)) : {F.BeaconBlockValue.assemble(_, F.Node3.from_value(F.Node3.to_value(proposer_index)), F.Node7.from_value(F.Node7.to_value(parent_root)), F.Node7.from_value(F.Node7.to_value(state_root)), F.BeaconBlockBodyValue.from_value(F.BeaconBlockBodyValue.to_value(body))) == Some{F.BeaconBlock{slot, proposer_index, parent_root, state_root, body}} : Maybe<&2, F.BeaconBlockValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(proposer_index)), Some{proposer_index}, Node3_inverse(proposer_index)) : {F.BeaconBlockValue.assemble(Some{slot}, _, F.Node7.from_value(F.Node7.to_value(parent_root)), F.Node7.from_value(F.Node7.to_value(state_root)), F.BeaconBlockBodyValue.from_value(F.BeaconBlockBodyValue.to_value(body))) == Some{F.BeaconBlock{slot, proposer_index, parent_root, state_root, body}} : Maybe<&2, F.BeaconBlockValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(parent_root)), Some{parent_root}, Node7_inverse(parent_root)) : {F.BeaconBlockValue.assemble(Some{slot}, Some{proposer_index}, _, F.Node7.from_value(F.Node7.to_value(state_root)), F.BeaconBlockBodyValue.from_value(F.BeaconBlockBodyValue.to_value(body))) == Some{F.BeaconBlock{slot, proposer_index, parent_root, state_root, body}} : Maybe<&2, F.BeaconBlockValue()>}
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(state_root)), Some{state_root}, Node7_inverse(state_root)) : {F.BeaconBlockValue.assemble(Some{slot}, Some{proposer_index}, Some{parent_root}, _, F.BeaconBlockBodyValue.from_value(F.BeaconBlockBodyValue.to_value(body))) == Some{F.BeaconBlock{slot, proposer_index, parent_root, state_root, body}} : Maybe<&2, F.BeaconBlockValue()>}
  %Equal.sym(Maybe<&2, F.BeaconBlockBodyValue()>, F.BeaconBlockBodyValue.from_value(F.BeaconBlockBodyValue.to_value(body)), Some{body}, BeaconBlockBodyValue_inverse(body)) : {F.BeaconBlockValue.assemble(Some{slot}, Some{proposer_index}, Some{parent_root}, Some{state_root}, _) == Some{F.BeaconBlock{slot, proposer_index, parent_root, state_root, body}} : Maybe<&2, F.BeaconBlockValue()>}
  {==}

law SignedBeaconBlockValue_inverse:
  for +value: F.SignedBeaconBlockValue()
  {F.SignedBeaconBlockValue.from_value(F.SignedBeaconBlockValue.to_value(value)) == Some{value} : Maybe<&2, F.SignedBeaconBlockValue()>}
def SignedBeaconBlockValue_inverse(value):
  F.SignedBeaconBlock{message, signature} = value
  %Equal.sym(Maybe<&2, F.BeaconBlockValue()>, F.BeaconBlockValue.from_value(F.BeaconBlockValue.to_value(message)), Some{message}, BeaconBlockValue_inverse(message)) : {F.SignedBeaconBlockValue.assemble(_, F.Node9.from_value(F.Node9.to_value(signature))) == Some{F.SignedBeaconBlock{message, signature}} : Maybe<&2, F.SignedBeaconBlockValue()>}
  %Equal.sym(Maybe<&2, F.Node9()>, F.Node9.from_value(F.Node9.to_value(signature)), Some{signature}, Node9_inverse(signature)) : {F.SignedBeaconBlockValue.assemble(Some{message}, _) == Some{F.SignedBeaconBlock{message, signature}} : Maybe<&2, F.SignedBeaconBlockValue()>}
  {==}

law Node107_inverse:
  for +value: F.Node107()
  {F.Node107.from_value(F.Node107.to_value(value)) == Some{value} : Maybe<&2, F.Node107()>}
def Node107_inverse(value):
  {==}

law Node109_append:
  for +xs: +List<F.Node7()>
  for +ys: +List<F.Node7()>
  for +acc: T.Value
  {F.Node7.seq_to_go(List.append(&2, F.Node7(), xs, ys), acc) == F.Node7.seq_to_go(ys, F.Node7.seq_to_go(xs, acc)) : T.Value}
def Node109_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node109_append(t, ys, T.Items{F.Node7.to_value(h), acc})

law Node109_cons:
  for +h: F.Node7()
  for +t: +List<F.Node7()>
  {F.Node7.seq_to(h <> t) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
def Node109_cons(h, t):
  %Equal.sym(+List<F.Node7()>, List.reverse.go(&2, F.Node7(), t, [h]), List.append(&2, F.Node7(), List.reverse(&2, F.Node7(), t), [h]), L.reverse_acc_append(F.Node7(), t, [], [h])) : {F.Node7.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)} : T.Value}
  Node109_append(List.reverse(&2, F.Node7(), t), [h], T.EmptyItems{})

law Node109_inverse_go:
  for +xs: +List<F.Node7()>
  for +acc: +List<F.Node7()>
  {F.Node7.seq_from_go(F.Node7.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node7(), acc, xs)} : Maybe<&2, +List<F.Node7()>>}
def Node109_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node7.seq_to(h <> t), T.Items{F.Node7.to_value(h), F.Node7.seq_to(t)}, Node109_cons(h, t)) : {F.Node7.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(h)), Some{h}, Node7_inverse(h)) : {F.Node7.seq_step(_, acc, next => F.Node7.seq_from_go(F.Node7.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node7(), acc, h <> t)} : Maybe<&2, +List<F.Node7()>>}
      Node109_inverse_go(t, h <> acc)

law Node109_inverse:
  for +value: F.Node109()
  {F.Node109.from_value(F.Node109.to_value(value)) == Some{value} : Maybe<&2, F.Node109()>}
def Node109_inverse(value):
  Node109_inverse_go(value, [])

law BlobSidecarValue_inverse:
  for +value: F.BlobSidecarValue()
  {F.BlobSidecarValue.from_value(F.BlobSidecarValue.to_value(value)) == Some{value} : Maybe<&2, F.BlobSidecarValue()>}
def BlobSidecarValue_inverse(value):
  F.BlobSidecar{index, blob, kzg_commitment, kzg_proof, signed_block_header, kzg_commitment_inclusion_proof} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(index)), Some{index}, Node3_inverse(index)) : {F.BlobSidecarValue.assemble(_, F.Node107.from_value(F.Node107.to_value(blob)), F.Node8.from_value(F.Node8.to_value(kzg_commitment)), F.Node8.from_value(F.Node8.to_value(kzg_proof)), F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_block_header)), F.Node109.from_value(F.Node109.to_value(kzg_commitment_inclusion_proof))) == Some{F.BlobSidecar{index, blob, kzg_commitment, kzg_proof, signed_block_header, kzg_commitment_inclusion_proof}} : Maybe<&2, F.BlobSidecarValue()>}
  %Equal.sym(Maybe<&2, F.Node107()>, F.Node107.from_value(F.Node107.to_value(blob)), Some{blob}, Node107_inverse(blob)) : {F.BlobSidecarValue.assemble(Some{index}, _, F.Node8.from_value(F.Node8.to_value(kzg_commitment)), F.Node8.from_value(F.Node8.to_value(kzg_proof)), F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_block_header)), F.Node109.from_value(F.Node109.to_value(kzg_commitment_inclusion_proof))) == Some{F.BlobSidecar{index, blob, kzg_commitment, kzg_proof, signed_block_header, kzg_commitment_inclusion_proof}} : Maybe<&2, F.BlobSidecarValue()>}
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(kzg_commitment)), Some{kzg_commitment}, Node8_inverse(kzg_commitment)) : {F.BlobSidecarValue.assemble(Some{index}, Some{blob}, _, F.Node8.from_value(F.Node8.to_value(kzg_proof)), F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_block_header)), F.Node109.from_value(F.Node109.to_value(kzg_commitment_inclusion_proof))) == Some{F.BlobSidecar{index, blob, kzg_commitment, kzg_proof, signed_block_header, kzg_commitment_inclusion_proof}} : Maybe<&2, F.BlobSidecarValue()>}
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(kzg_proof)), Some{kzg_proof}, Node8_inverse(kzg_proof)) : {F.BlobSidecarValue.assemble(Some{index}, Some{blob}, Some{kzg_commitment}, _, F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_block_header)), F.Node109.from_value(F.Node109.to_value(kzg_commitment_inclusion_proof))) == Some{F.BlobSidecar{index, blob, kzg_commitment, kzg_proof, signed_block_header, kzg_commitment_inclusion_proof}} : Maybe<&2, F.BlobSidecarValue()>}
  %Equal.sym(Maybe<&2, F.SignedBeaconBlockHeaderValue()>, F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_block_header)), Some{signed_block_header}, SignedBeaconBlockHeaderValue_inverse(signed_block_header)) : {F.BlobSidecarValue.assemble(Some{index}, Some{blob}, Some{kzg_commitment}, Some{kzg_proof}, _, F.Node109.from_value(F.Node109.to_value(kzg_commitment_inclusion_proof))) == Some{F.BlobSidecar{index, blob, kzg_commitment, kzg_proof, signed_block_header, kzg_commitment_inclusion_proof}} : Maybe<&2, F.BlobSidecarValue()>}
  %Equal.sym(Maybe<&2, F.Node109()>, F.Node109.from_value(F.Node109.to_value(kzg_commitment_inclusion_proof)), Some{kzg_commitment_inclusion_proof}, Node109_inverse(kzg_commitment_inclusion_proof)) : {F.BlobSidecarValue.assemble(Some{index}, Some{blob}, Some{kzg_commitment}, Some{kzg_proof}, Some{signed_block_header}, _) == Some{F.BlobSidecar{index, blob, kzg_commitment, kzg_proof, signed_block_header, kzg_commitment_inclusion_proof}} : Maybe<&2, F.BlobSidecarValue()>}
  {==}

law Node110_inverse:
  for +value: F.Node110()
  {F.Node110.from_value(F.Node110.to_value(value)) == Some{value} : Maybe<&2, F.Node110()>}
def Node110_inverse(value):
  {==}

law Node112_append:
  for +xs: +List<F.Node3()>
  for +ys: +List<F.Node3()>
  for +acc: T.Value
  {F.Node3.seq_to_go(List.append(&2, F.Node3(), xs, ys), acc) == F.Node3.seq_to_go(ys, F.Node3.seq_to_go(xs, acc)) : T.Value}
def Node112_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node112_append(t, ys, T.Items{F.Node3.to_value(h), acc})

law Node112_cons:
  for +h: F.Node3()
  for +t: +List<F.Node3()>
  {F.Node3.seq_to(h <> t) == T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)} : T.Value}
def Node112_cons(h, t):
  %Equal.sym(+List<F.Node3()>, List.reverse.go(&2, F.Node3(), t, [h]), List.append(&2, F.Node3(), List.reverse(&2, F.Node3(), t), [h]), L.reverse_acc_append(F.Node3(), t, [], [h])) : {F.Node3.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)} : T.Value}
  Node112_append(List.reverse(&2, F.Node3(), t), [h], T.EmptyItems{})

law Node112_inverse_go:
  for +xs: +List<F.Node3()>
  for +acc: +List<F.Node3()>
  {F.Node3.seq_from_go(F.Node3.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node3(), acc, xs)} : Maybe<&2, +List<F.Node3()>>}
def Node112_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node3.seq_to(h <> t), T.Items{F.Node3.to_value(h), F.Node3.seq_to(t)}, Node112_cons(h, t)) : {F.Node3.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node3(), acc, h <> t)} : Maybe<&2, +List<F.Node3()>>}
      %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(h)), Some{h}, Node3_inverse(h)) : {F.Node3.seq_step(_, acc, next => F.Node3.seq_from_go(F.Node3.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node3(), acc, h <> t)} : Maybe<&2, +List<F.Node3()>>}
      Node112_inverse_go(t, h <> acc)

law Node112_inverse:
  for +value: F.Node112()
  {F.Node112.from_value(F.Node112.to_value(value)) == Some{value} : Maybe<&2, F.Node112()>}
def Node112_inverse(value):
  Node112_inverse_go(value, [])

law DataColumnsByRootIdentifierValue_inverse:
  for +value: F.DataColumnsByRootIdentifierValue()
  {F.DataColumnsByRootIdentifierValue.from_value(F.DataColumnsByRootIdentifierValue.to_value(value)) == Some{value} : Maybe<&2, F.DataColumnsByRootIdentifierValue()>}
def DataColumnsByRootIdentifierValue_inverse(value):
  F.DataColumnsByRootIdentifier{block_root, columns} = value
  %Equal.sym(Maybe<&2, F.Node7()>, F.Node7.from_value(F.Node7.to_value(block_root)), Some{block_root}, Node7_inverse(block_root)) : {F.DataColumnsByRootIdentifierValue.assemble(_, F.Node112.from_value(F.Node112.to_value(columns))) == Some{F.DataColumnsByRootIdentifier{block_root, columns}} : Maybe<&2, F.DataColumnsByRootIdentifierValue()>}
  %Equal.sym(Maybe<&2, F.Node112()>, F.Node112.from_value(F.Node112.to_value(columns)), Some{columns}, Node112_inverse(columns)) : {F.DataColumnsByRootIdentifierValue.assemble(Some{block_root}, _) == Some{F.DataColumnsByRootIdentifier{block_root, columns}} : Maybe<&2, F.DataColumnsByRootIdentifierValue()>}
  {==}

law MatrixEntryValue_inverse:
  for +value: F.MatrixEntryValue()
  {F.MatrixEntryValue.from_value(F.MatrixEntryValue.to_value(value)) == Some{value} : Maybe<&2, F.MatrixEntryValue()>}
def MatrixEntryValue_inverse(value):
  F.MatrixEntry{cell, kzg_proof, column_index, row_index} = value
  %Equal.sym(Maybe<&2, F.Node110()>, F.Node110.from_value(F.Node110.to_value(cell)), Some{cell}, Node110_inverse(cell)) : {F.MatrixEntryValue.assemble(_, F.Node8.from_value(F.Node8.to_value(kzg_proof)), F.Node3.from_value(F.Node3.to_value(column_index)), F.Node3.from_value(F.Node3.to_value(row_index))) == Some{F.MatrixEntry{cell, kzg_proof, column_index, row_index}} : Maybe<&2, F.MatrixEntryValue()>}
  %Equal.sym(Maybe<&2, F.Node8()>, F.Node8.from_value(F.Node8.to_value(kzg_proof)), Some{kzg_proof}, Node8_inverse(kzg_proof)) : {F.MatrixEntryValue.assemble(Some{cell}, _, F.Node3.from_value(F.Node3.to_value(column_index)), F.Node3.from_value(F.Node3.to_value(row_index))) == Some{F.MatrixEntry{cell, kzg_proof, column_index, row_index}} : Maybe<&2, F.MatrixEntryValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(column_index)), Some{column_index}, Node3_inverse(column_index)) : {F.MatrixEntryValue.assemble(Some{cell}, Some{kzg_proof}, _, F.Node3.from_value(F.Node3.to_value(row_index))) == Some{F.MatrixEntry{cell, kzg_proof, column_index, row_index}} : Maybe<&2, F.MatrixEntryValue()>}
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(row_index)), Some{row_index}, Node3_inverse(row_index)) : {F.MatrixEntryValue.assemble(Some{cell}, Some{kzg_proof}, Some{column_index}, _) == Some{F.MatrixEntry{cell, kzg_proof, column_index, row_index}} : Maybe<&2, F.MatrixEntryValue()>}
  {==}

law Node115_append:
  for +xs: +List<F.Node110()>
  for +ys: +List<F.Node110()>
  for +acc: T.Value
  {F.Node110.seq_to_go(List.append(&2, F.Node110(), xs, ys), acc) == F.Node110.seq_to_go(ys, F.Node110.seq_to_go(xs, acc)) : T.Value}
def Node115_append(xs, ys, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}: Node115_append(t, ys, T.Items{F.Node110.to_value(h), acc})

law Node115_cons:
  for +h: F.Node110()
  for +t: +List<F.Node110()>
  {F.Node110.seq_to(h <> t) == T.Items{F.Node110.to_value(h), F.Node110.seq_to(t)} : T.Value}
def Node115_cons(h, t):
  %Equal.sym(+List<F.Node110()>, List.reverse.go(&2, F.Node110(), t, [h]), List.append(&2, F.Node110(), List.reverse(&2, F.Node110(), t), [h]), L.reverse_acc_append(F.Node110(), t, [], [h])) : {F.Node110.seq_to_go(_, T.EmptyItems{}) == T.Items{F.Node110.to_value(h), F.Node110.seq_to(t)} : T.Value}
  Node115_append(List.reverse(&2, F.Node110(), t), [h], T.EmptyItems{})

law Node115_inverse_go:
  for +xs: +List<F.Node110()>
  for +acc: +List<F.Node110()>
  {F.Node110.seq_from_go(F.Node110.seq_to(xs), acc) == Some{List.reverse.go(&2, F.Node110(), acc, xs)} : Maybe<&2, +List<F.Node110()>>}
def Node115_inverse_go(xs, acc):
  match xs:
    case Nil{}: {==}
    case Con{h, t}:
      %Equal.sym(T.Value, F.Node110.seq_to(h <> t), T.Items{F.Node110.to_value(h), F.Node110.seq_to(t)}, Node115_cons(h, t)) : {F.Node110.seq_from_go(_, acc) == Some{List.reverse.go(&2, F.Node110(), acc, h <> t)} : Maybe<&2, +List<F.Node110()>>}
      %Equal.sym(Maybe<&2, F.Node110()>, F.Node110.from_value(F.Node110.to_value(h)), Some{h}, Node110_inverse(h)) : {F.Node110.seq_step(_, acc, next => F.Node110.seq_from_go(F.Node110.seq_to(t), next)) == Some{List.reverse.go(&2, F.Node110(), acc, h <> t)} : Maybe<&2, +List<F.Node110()>>}
      Node115_inverse_go(t, h <> acc)

law Node115_inverse:
  for +value: F.Node115()
  {F.Node115.from_value(F.Node115.to_value(value)) == Some{value} : Maybe<&2, F.Node115()>}
def Node115_inverse(value):
  Node115_inverse_go(value, [])

law DataColumnSidecarValue_inverse:
  for +value: F.DataColumnSidecarValue()
  {F.DataColumnSidecarValue.from_value(F.DataColumnSidecarValue.to_value(value)) == Some{value} : Maybe<&2, F.DataColumnSidecarValue()>}
def DataColumnSidecarValue_inverse(value):
  F.DataColumnSidecar{index, column, kzg_commitments, kzg_proofs, signed_block_header, kzg_commitments_inclusion_proof} = value
  %Equal.sym(Maybe<&2, F.Node3()>, F.Node3.from_value(F.Node3.to_value(index)), Some{index}, Node3_inverse(index)) : {F.DataColumnSidecarValue.assemble(_, F.Node115.from_value(F.Node115.to_value(column)), F.Node104.from_value(F.Node104.to_value(kzg_commitments)), F.Node104.from_value(F.Node104.to_value(kzg_proofs)), F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_block_header)), F.Node90.from_value(F.Node90.to_value(kzg_commitments_inclusion_proof))) == Some{F.DataColumnSidecar{index, column, kzg_commitments, kzg_proofs, signed_block_header, kzg_commitments_inclusion_proof}} : Maybe<&2, F.DataColumnSidecarValue()>}
  %Equal.sym(Maybe<&2, F.Node115()>, F.Node115.from_value(F.Node115.to_value(column)), Some{column}, Node115_inverse(column)) : {F.DataColumnSidecarValue.assemble(Some{index}, _, F.Node104.from_value(F.Node104.to_value(kzg_commitments)), F.Node104.from_value(F.Node104.to_value(kzg_proofs)), F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_block_header)), F.Node90.from_value(F.Node90.to_value(kzg_commitments_inclusion_proof))) == Some{F.DataColumnSidecar{index, column, kzg_commitments, kzg_proofs, signed_block_header, kzg_commitments_inclusion_proof}} : Maybe<&2, F.DataColumnSidecarValue()>}
  %Equal.sym(Maybe<&2, F.Node104()>, F.Node104.from_value(F.Node104.to_value(kzg_commitments)), Some{kzg_commitments}, Node104_inverse(kzg_commitments)) : {F.DataColumnSidecarValue.assemble(Some{index}, Some{column}, _, F.Node104.from_value(F.Node104.to_value(kzg_proofs)), F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_block_header)), F.Node90.from_value(F.Node90.to_value(kzg_commitments_inclusion_proof))) == Some{F.DataColumnSidecar{index, column, kzg_commitments, kzg_proofs, signed_block_header, kzg_commitments_inclusion_proof}} : Maybe<&2, F.DataColumnSidecarValue()>}
  %Equal.sym(Maybe<&2, F.Node104()>, F.Node104.from_value(F.Node104.to_value(kzg_proofs)), Some{kzg_proofs}, Node104_inverse(kzg_proofs)) : {F.DataColumnSidecarValue.assemble(Some{index}, Some{column}, Some{kzg_commitments}, _, F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_block_header)), F.Node90.from_value(F.Node90.to_value(kzg_commitments_inclusion_proof))) == Some{F.DataColumnSidecar{index, column, kzg_commitments, kzg_proofs, signed_block_header, kzg_commitments_inclusion_proof}} : Maybe<&2, F.DataColumnSidecarValue()>}
  %Equal.sym(Maybe<&2, F.SignedBeaconBlockHeaderValue()>, F.SignedBeaconBlockHeaderValue.from_value(F.SignedBeaconBlockHeaderValue.to_value(signed_block_header)), Some{signed_block_header}, SignedBeaconBlockHeaderValue_inverse(signed_block_header)) : {F.DataColumnSidecarValue.assemble(Some{index}, Some{column}, Some{kzg_commitments}, Some{kzg_proofs}, _, F.Node90.from_value(F.Node90.to_value(kzg_commitments_inclusion_proof))) == Some{F.DataColumnSidecar{index, column, kzg_commitments, kzg_proofs, signed_block_header, kzg_commitments_inclusion_proof}} : Maybe<&2, F.DataColumnSidecarValue()>}
  %Equal.sym(Maybe<&2, F.Node90()>, F.Node90.from_value(F.Node90.to_value(kzg_commitments_inclusion_proof)), Some{kzg_commitments_inclusion_proof}, Node90_inverse(kzg_commitments_inclusion_proof)) : {F.DataColumnSidecarValue.assemble(Some{index}, Some{column}, Some{kzg_commitments}, Some{kzg_proofs}, Some{signed_block_header}, _) == Some{F.DataColumnSidecar{index, column, kzg_commitments, kzg_proofs, signed_block_header, kzg_commitments_inclusion_proof}} : Maybe<&2, F.DataColumnSidecarValue()>}
  {==}

law boolean_representation_inverse:
  for +value: F.boolean()
  {F.boolean.from_ssz(F.boolean.to_ssz(value)) == Some{value} : Maybe<&2, F.boolean()>}
def boolean_representation_inverse(value): Node0_inverse(value)

law uint8_representation_inverse:
  for +value: F.uint8()
  {F.uint8.from_ssz(F.uint8.to_ssz(value)) == Some{value} : Maybe<&2, F.uint8()>}
def uint8_representation_inverse(value): Node1_inverse(value)

law uint32_representation_inverse:
  for +value: F.uint32()
  {F.uint32.from_ssz(F.uint32.to_ssz(value)) == Some{value} : Maybe<&2, F.uint32()>}
def uint32_representation_inverse(value): Node2_inverse(value)

law uint64_representation_inverse:
  for +value: F.uint64()
  {F.uint64.from_ssz(F.uint64.to_ssz(value)) == Some{value} : Maybe<&2, F.uint64()>}
def uint64_representation_inverse(value): Node3_inverse(value)

law uint256_representation_inverse:
  for +value: F.uint256()
  {F.uint256.from_ssz(F.uint256.to_ssz(value)) == Some{value} : Maybe<&2, F.uint256()>}
def uint256_representation_inverse(value): Node4_inverse(value)

law Bytes1_representation_inverse:
  for +value: F.Bytes1()
  {F.Bytes1.from_ssz(F.Bytes1.to_ssz(value)) == Some{value} : Maybe<&2, F.Bytes1()>}
def Bytes1_representation_inverse(value): Node5_inverse(value)

law Bytes4_representation_inverse:
  for +value: F.Bytes4()
  {F.Bytes4.from_ssz(F.Bytes4.to_ssz(value)) == Some{value} : Maybe<&2, F.Bytes4()>}
def Bytes4_representation_inverse(value): Node6_inverse(value)

law Bytes32_representation_inverse:
  for +value: F.Bytes32()
  {F.Bytes32.from_ssz(F.Bytes32.to_ssz(value)) == Some{value} : Maybe<&2, F.Bytes32()>}
def Bytes32_representation_inverse(value): Node7_inverse(value)

law Bytes48_representation_inverse:
  for +value: F.Bytes48()
  {F.Bytes48.from_ssz(F.Bytes48.to_ssz(value)) == Some{value} : Maybe<&2, F.Bytes48()>}
def Bytes48_representation_inverse(value): Node8_inverse(value)

law Bytes96_representation_inverse:
  for +value: F.Bytes96()
  {F.Bytes96.from_ssz(F.Bytes96.to_ssz(value)) == Some{value} : Maybe<&2, F.Bytes96()>}
def Bytes96_representation_inverse(value): Node9_inverse(value)

law Bytes8_representation_inverse:
  for +value: F.Bytes8()
  {F.Bytes8.from_ssz(F.Bytes8.to_ssz(value)) == Some{value} : Maybe<&2, F.Bytes8()>}
def Bytes8_representation_inverse(value): Node10_inverse(value)

law Bytes20_representation_inverse:
  for +value: F.Bytes20()
  {F.Bytes20.from_ssz(F.Bytes20.to_ssz(value)) == Some{value} : Maybe<&2, F.Bytes20()>}
def Bytes20_representation_inverse(value): Node11_inverse(value)

law Slot_representation_inverse:
  for +value: F.Slot()
  {F.Slot.from_ssz(F.Slot.to_ssz(value)) == Some{value} : Maybe<&2, F.Slot()>}
def Slot_representation_inverse(value): Node3_inverse(value)

law Epoch_representation_inverse:
  for +value: F.Epoch()
  {F.Epoch.from_ssz(F.Epoch.to_ssz(value)) == Some{value} : Maybe<&2, F.Epoch()>}
def Epoch_representation_inverse(value): Node3_inverse(value)

law Gwei_representation_inverse:
  for +value: F.Gwei()
  {F.Gwei.from_ssz(F.Gwei.to_ssz(value)) == Some{value} : Maybe<&2, F.Gwei()>}
def Gwei_representation_inverse(value): Node3_inverse(value)

law Hash32_representation_inverse:
  for +value: F.Hash32()
  {F.Hash32.from_ssz(F.Hash32.to_ssz(value)) == Some{value} : Maybe<&2, F.Hash32()>}
def Hash32_representation_inverse(value): Node7_inverse(value)

law Version_representation_inverse:
  for +value: F.Version()
  {F.Version.from_ssz(F.Version.to_ssz(value)) == Some{value} : Maybe<&2, F.Version()>}
def Version_representation_inverse(value): Node6_inverse(value)

law DomainType_representation_inverse:
  for +value: F.DomainType()
  {F.DomainType.from_ssz(F.DomainType.to_ssz(value)) == Some{value} : Maybe<&2, F.DomainType()>}
def DomainType_representation_inverse(value): Node6_inverse(value)

law BLSSignature_representation_inverse:
  for +value: F.BLSSignature()
  {F.BLSSignature.from_ssz(F.BLSSignature.to_ssz(value)) == Some{value} : Maybe<&2, F.BLSSignature()>}
def BLSSignature_representation_inverse(value): Node9_inverse(value)

law FinalityBranch_representation_inverse:
  for +value: F.FinalityBranch()
  {F.FinalityBranch.from_ssz(F.FinalityBranch.to_ssz(value)) == Some{value} : Maybe<&2, F.FinalityBranch()>}
def FinalityBranch_representation_inverse(value): Node12_inverse(value)

law VersionedHash_representation_inverse:
  for +value: F.VersionedHash()
  {F.VersionedHash.from_ssz(F.VersionedHash.to_ssz(value)) == Some{value} : Maybe<&2, F.VersionedHash()>}
def VersionedHash_representation_inverse(value): Node7_inverse(value)

law G1Point_representation_inverse:
  for +value: F.G1Point()
  {F.G1Point.from_ssz(F.G1Point.to_ssz(value)) == Some{value} : Maybe<&2, F.G1Point()>}
def G1Point_representation_inverse(value): Node8_inverse(value)

law G2Point_representation_inverse:
  for +value: F.G2Point()
  {F.G2Point.from_ssz(F.G2Point.to_ssz(value)) == Some{value} : Maybe<&2, F.G2Point()>}
def G2Point_representation_inverse(value): Node9_inverse(value)

law Fork_representation_inverse:
  for +value: F.Fork
  {F.Fork.from_ssz(F.Fork.to_ssz(value)) == Some{value} : Maybe<&2, F.Fork>}
def Fork_representation_inverse(value): ForkValue_inverse(value)

law SyncAggregate_representation_inverse:
  for +value: F.SyncAggregate
  {F.SyncAggregate.from_ssz(F.SyncAggregate.to_ssz(value)) == Some{value} : Maybe<&2, F.SyncAggregate>}
def SyncAggregate_representation_inverse(value): SyncAggregateValue_inverse(value)

law SyncAggregatorSelectionData_representation_inverse:
  for +value: F.SyncAggregatorSelectionData
  {F.SyncAggregatorSelectionData.from_ssz(F.SyncAggregatorSelectionData.to_ssz(value)) == Some{value} : Maybe<&2, F.SyncAggregatorSelectionData>}
def SyncAggregatorSelectionData_representation_inverse(value): SyncAggregatorSelectionDataValue_inverse(value)

law PowBlock_representation_inverse:
  for +value: F.PowBlock
  {F.PowBlock.from_ssz(F.PowBlock.to_ssz(value)) == Some{value} : Maybe<&2, F.PowBlock>}
def PowBlock_representation_inverse(value): PowBlockValue_inverse(value)

law CommitteeIndex_representation_inverse:
  for +value: F.CommitteeIndex()
  {F.CommitteeIndex.from_ssz(F.CommitteeIndex.to_ssz(value)) == Some{value} : Maybe<&2, F.CommitteeIndex()>}
def CommitteeIndex_representation_inverse(value): Node3_inverse(value)

law ValidatorIndex_representation_inverse:
  for +value: F.ValidatorIndex()
  {F.ValidatorIndex.from_ssz(F.ValidatorIndex.to_ssz(value)) == Some{value} : Maybe<&2, F.ValidatorIndex()>}
def ValidatorIndex_representation_inverse(value): Node3_inverse(value)

law PendingConsolidation_representation_inverse:
  for +value: F.PendingConsolidation
  {F.PendingConsolidation.from_ssz(F.PendingConsolidation.to_ssz(value)) == Some{value} : Maybe<&2, F.PendingConsolidation>}
def PendingConsolidation_representation_inverse(value): PendingConsolidationValue_inverse(value)

law PendingPartialWithdrawal_representation_inverse:
  for +value: F.PendingPartialWithdrawal
  {F.PendingPartialWithdrawal.from_ssz(F.PendingPartialWithdrawal.to_ssz(value)) == Some{value} : Maybe<&2, F.PendingPartialWithdrawal>}
def PendingPartialWithdrawal_representation_inverse(value): PendingPartialWithdrawalValue_inverse(value)

law VoluntaryExit_representation_inverse:
  for +value: F.VoluntaryExit
  {F.VoluntaryExit.from_ssz(F.VoluntaryExit.to_ssz(value)) == Some{value} : Maybe<&2, F.VoluntaryExit>}
def VoluntaryExit_representation_inverse(value): VoluntaryExitValue_inverse(value)

law SignedVoluntaryExit_representation_inverse:
  for +value: F.SignedVoluntaryExit
  {F.SignedVoluntaryExit.from_ssz(F.SignedVoluntaryExit.to_ssz(value)) == Some{value} : Maybe<&2, F.SignedVoluntaryExit>}
def SignedVoluntaryExit_representation_inverse(value): SignedVoluntaryExitValue_inverse(value)

law Root_representation_inverse:
  for +value: F.Root()
  {F.Root.from_ssz(F.Root.to_ssz(value)) == Some{value} : Maybe<&2, F.Root()>}
def Root_representation_inverse(value): Node7_inverse(value)

law HistoricalSummary_representation_inverse:
  for +value: F.HistoricalSummary
  {F.HistoricalSummary.from_ssz(F.HistoricalSummary.to_ssz(value)) == Some{value} : Maybe<&2, F.HistoricalSummary>}
def HistoricalSummary_representation_inverse(value): HistoricalSummaryValue_inverse(value)

law SyncCommitteeContribution_representation_inverse:
  for +value: F.SyncCommitteeContribution
  {F.SyncCommitteeContribution.from_ssz(F.SyncCommitteeContribution.to_ssz(value)) == Some{value} : Maybe<&2, F.SyncCommitteeContribution>}
def SyncCommitteeContribution_representation_inverse(value): SyncCommitteeContributionValue_inverse(value)

law ContributionAndProof_representation_inverse:
  for +value: F.ContributionAndProof
  {F.ContributionAndProof.from_ssz(F.ContributionAndProof.to_ssz(value)) == Some{value} : Maybe<&2, F.ContributionAndProof>}
def ContributionAndProof_representation_inverse(value): ContributionAndProofValue_inverse(value)

law SignedContributionAndProof_representation_inverse:
  for +value: F.SignedContributionAndProof
  {F.SignedContributionAndProof.from_ssz(F.SignedContributionAndProof.to_ssz(value)) == Some{value} : Maybe<&2, F.SignedContributionAndProof>}
def SignedContributionAndProof_representation_inverse(value): SignedContributionAndProofValue_inverse(value)

law SyncCommitteeMessage_representation_inverse:
  for +value: F.SyncCommitteeMessage
  {F.SyncCommitteeMessage.from_ssz(F.SyncCommitteeMessage.to_ssz(value)) == Some{value} : Maybe<&2, F.SyncCommitteeMessage>}
def SyncCommitteeMessage_representation_inverse(value): SyncCommitteeMessageValue_inverse(value)

law Eth1Block_representation_inverse:
  for +value: F.Eth1Block
  {F.Eth1Block.from_ssz(F.Eth1Block.to_ssz(value)) == Some{value} : Maybe<&2, F.Eth1Block>}
def Eth1Block_representation_inverse(value): Eth1BlockValue_inverse(value)

law BeaconBlockHeader_representation_inverse:
  for +value: F.BeaconBlockHeader
  {F.BeaconBlockHeader.from_ssz(F.BeaconBlockHeader.to_ssz(value)) == Some{value} : Maybe<&2, F.BeaconBlockHeader>}
def BeaconBlockHeader_representation_inverse(value): BeaconBlockHeaderValue_inverse(value)

law SignedBeaconBlockHeader_representation_inverse:
  for +value: F.SignedBeaconBlockHeader
  {F.SignedBeaconBlockHeader.from_ssz(F.SignedBeaconBlockHeader.to_ssz(value)) == Some{value} : Maybe<&2, F.SignedBeaconBlockHeader>}
def SignedBeaconBlockHeader_representation_inverse(value): SignedBeaconBlockHeaderValue_inverse(value)

law ProposerSlashing_representation_inverse:
  for +value: F.ProposerSlashing
  {F.ProposerSlashing.from_ssz(F.ProposerSlashing.to_ssz(value)) == Some{value} : Maybe<&2, F.ProposerSlashing>}
def ProposerSlashing_representation_inverse(value): ProposerSlashingValue_inverse(value)

law HistoricalBatch_representation_inverse:
  for +value: F.HistoricalBatch
  {F.HistoricalBatch.from_ssz(F.HistoricalBatch.to_ssz(value)) == Some{value} : Maybe<&2, F.HistoricalBatch>}
def HistoricalBatch_representation_inverse(value): HistoricalBatchValue_inverse(value)

law Eth1Data_representation_inverse:
  for +value: F.Eth1Data
  {F.Eth1Data.from_ssz(F.Eth1Data.to_ssz(value)) == Some{value} : Maybe<&2, F.Eth1Data>}
def Eth1Data_representation_inverse(value): Eth1DataValue_inverse(value)

law Checkpoint_representation_inverse:
  for +value: F.Checkpoint
  {F.Checkpoint.from_ssz(F.Checkpoint.to_ssz(value)) == Some{value} : Maybe<&2, F.Checkpoint>}
def Checkpoint_representation_inverse(value): CheckpointValue_inverse(value)

law AttestationData_representation_inverse:
  for +value: F.AttestationData
  {F.AttestationData.from_ssz(F.AttestationData.to_ssz(value)) == Some{value} : Maybe<&2, F.AttestationData>}
def AttestationData_representation_inverse(value): AttestationDataValue_inverse(value)

law SingleAttestation_representation_inverse:
  for +value: F.SingleAttestation
  {F.SingleAttestation.from_ssz(F.SingleAttestation.to_ssz(value)) == Some{value} : Maybe<&2, F.SingleAttestation>}
def SingleAttestation_representation_inverse(value): SingleAttestationValue_inverse(value)

law Attestation_representation_inverse:
  for +value: F.Attestation
  {F.Attestation.from_ssz(F.Attestation.to_ssz(value)) == Some{value} : Maybe<&2, F.Attestation>}
def Attestation_representation_inverse(value): AttestationValue_inverse(value)

law AggregateAndProof_representation_inverse:
  for +value: F.AggregateAndProof
  {F.AggregateAndProof.from_ssz(F.AggregateAndProof.to_ssz(value)) == Some{value} : Maybe<&2, F.AggregateAndProof>}
def AggregateAndProof_representation_inverse(value): AggregateAndProofValue_inverse(value)

law SignedAggregateAndProof_representation_inverse:
  for +value: F.SignedAggregateAndProof
  {F.SignedAggregateAndProof.from_ssz(F.SignedAggregateAndProof.to_ssz(value)) == Some{value} : Maybe<&2, F.SignedAggregateAndProof>}
def SignedAggregateAndProof_representation_inverse(value): SignedAggregateAndProofValue_inverse(value)

law PendingAttestation_representation_inverse:
  for +value: F.PendingAttestation
  {F.PendingAttestation.from_ssz(F.PendingAttestation.to_ssz(value)) == Some{value} : Maybe<&2, F.PendingAttestation>}
def PendingAttestation_representation_inverse(value): PendingAttestationValue_inverse(value)

law IndexedAttestation_representation_inverse:
  for +value: F.IndexedAttestation
  {F.IndexedAttestation.from_ssz(F.IndexedAttestation.to_ssz(value)) == Some{value} : Maybe<&2, F.IndexedAttestation>}
def IndexedAttestation_representation_inverse(value): IndexedAttestationValue_inverse(value)

law AttesterSlashing_representation_inverse:
  for +value: F.AttesterSlashing
  {F.AttesterSlashing.from_ssz(F.AttesterSlashing.to_ssz(value)) == Some{value} : Maybe<&2, F.AttesterSlashing>}
def AttesterSlashing_representation_inverse(value): AttesterSlashingValue_inverse(value)

law ForkData_representation_inverse:
  for +value: F.ForkData
  {F.ForkData.from_ssz(F.ForkData.to_ssz(value)) == Some{value} : Maybe<&2, F.ForkData>}
def ForkData_representation_inverse(value): ForkDataValue_inverse(value)

law ForkDigest_representation_inverse:
  for +value: F.ForkDigest()
  {F.ForkDigest.from_ssz(F.ForkDigest.to_ssz(value)) == Some{value} : Maybe<&2, F.ForkDigest()>}
def ForkDigest_representation_inverse(value): Node6_inverse(value)

law Domain_representation_inverse:
  for +value: F.Domain()
  {F.Domain.from_ssz(F.Domain.to_ssz(value)) == Some{value} : Maybe<&2, F.Domain()>}
def Domain_representation_inverse(value): Node7_inverse(value)

law SigningData_representation_inverse:
  for +value: F.SigningData
  {F.SigningData.from_ssz(F.SigningData.to_ssz(value)) == Some{value} : Maybe<&2, F.SigningData>}
def SigningData_representation_inverse(value): SigningDataValue_inverse(value)

law BLSPubkey_representation_inverse:
  for +value: F.BLSPubkey()
  {F.BLSPubkey.from_ssz(F.BLSPubkey.to_ssz(value)) == Some{value} : Maybe<&2, F.BLSPubkey()>}
def BLSPubkey_representation_inverse(value): Node8_inverse(value)

law DepositRequest_representation_inverse:
  for +value: F.DepositRequest
  {F.DepositRequest.from_ssz(F.DepositRequest.to_ssz(value)) == Some{value} : Maybe<&2, F.DepositRequest>}
def DepositRequest_representation_inverse(value): DepositRequestValue_inverse(value)

law PendingDeposit_representation_inverse:
  for +value: F.PendingDeposit
  {F.PendingDeposit.from_ssz(F.PendingDeposit.to_ssz(value)) == Some{value} : Maybe<&2, F.PendingDeposit>}
def PendingDeposit_representation_inverse(value): PendingDepositValue_inverse(value)

law SyncCommittee_representation_inverse:
  for +value: F.SyncCommittee
  {F.SyncCommittee.from_ssz(F.SyncCommittee.to_ssz(value)) == Some{value} : Maybe<&2, F.SyncCommittee>}
def SyncCommittee_representation_inverse(value): SyncCommitteeValue_inverse(value)

law DepositData_representation_inverse:
  for +value: F.DepositData
  {F.DepositData.from_ssz(F.DepositData.to_ssz(value)) == Some{value} : Maybe<&2, F.DepositData>}
def DepositData_representation_inverse(value): DepositDataValue_inverse(value)

law Deposit_representation_inverse:
  for +value: F.Deposit
  {F.Deposit.from_ssz(F.Deposit.to_ssz(value)) == Some{value} : Maybe<&2, F.Deposit>}
def Deposit_representation_inverse(value): DepositValue_inverse(value)

law DepositMessage_representation_inverse:
  for +value: F.DepositMessage
  {F.DepositMessage.from_ssz(F.DepositMessage.to_ssz(value)) == Some{value} : Maybe<&2, F.DepositMessage>}
def DepositMessage_representation_inverse(value): DepositMessageValue_inverse(value)

law Validator_representation_inverse:
  for +value: F.Validator
  {F.Validator.from_ssz(F.Validator.to_ssz(value)) == Some{value} : Maybe<&2, F.Validator>}
def Validator_representation_inverse(value): ValidatorValue_inverse(value)

law NodeID_representation_inverse:
  for +value: F.NodeID()
  {F.NodeID.from_ssz(F.NodeID.to_ssz(value)) == Some{value} : Maybe<&2, F.NodeID()>}
def NodeID_representation_inverse(value): Node4_inverse(value)

law SubnetID_representation_inverse:
  for +value: F.SubnetID()
  {F.SubnetID.from_ssz(F.SubnetID.to_ssz(value)) == Some{value} : Maybe<&2, F.SubnetID()>}
def SubnetID_representation_inverse(value): Node3_inverse(value)

law Ether_representation_inverse:
  for +value: F.Ether()
  {F.Ether.from_ssz(F.Ether.to_ssz(value)) == Some{value} : Maybe<&2, F.Ether()>}
def Ether_representation_inverse(value): Node3_inverse(value)

law ParticipationFlags_representation_inverse:
  for +value: F.ParticipationFlags()
  {F.ParticipationFlags.from_ssz(F.ParticipationFlags.to_ssz(value)) == Some{value} : Maybe<&2, F.ParticipationFlags()>}
def ParticipationFlags_representation_inverse(value): Node1_inverse(value)

law CurrentSyncCommitteeBranch_representation_inverse:
  for +value: F.CurrentSyncCommitteeBranch()
  {F.CurrentSyncCommitteeBranch.from_ssz(F.CurrentSyncCommitteeBranch.to_ssz(value)) == Some{value} : Maybe<&2, F.CurrentSyncCommitteeBranch()>}
def CurrentSyncCommitteeBranch_representation_inverse(value): Node59_inverse(value)

law NextSyncCommitteeBranch_representation_inverse:
  for +value: F.NextSyncCommitteeBranch()
  {F.NextSyncCommitteeBranch.from_ssz(F.NextSyncCommitteeBranch.to_ssz(value)) == Some{value} : Maybe<&2, F.NextSyncCommitteeBranch()>}
def NextSyncCommitteeBranch_representation_inverse(value): Node59_inverse(value)

law Transaction_representation_inverse:
  for +value: F.Transaction()
  {F.Transaction.from_ssz(F.Transaction.to_ssz(value)) == Some{value} : Maybe<&2, F.Transaction()>}
def Transaction_representation_inverse(value): Node60_inverse(value)

law ExecutionAddress_representation_inverse:
  for +value: F.ExecutionAddress()
  {F.ExecutionAddress.from_ssz(F.ExecutionAddress.to_ssz(value)) == Some{value} : Maybe<&2, F.ExecutionAddress()>}
def ExecutionAddress_representation_inverse(value): Node11_inverse(value)

law ConsolidationRequest_representation_inverse:
  for +value: F.ConsolidationRequest
  {F.ConsolidationRequest.from_ssz(F.ConsolidationRequest.to_ssz(value)) == Some{value} : Maybe<&2, F.ConsolidationRequest>}
def ConsolidationRequest_representation_inverse(value): ConsolidationRequestValue_inverse(value)

law WithdrawalRequest_representation_inverse:
  for +value: F.WithdrawalRequest
  {F.WithdrawalRequest.from_ssz(F.WithdrawalRequest.to_ssz(value)) == Some{value} : Maybe<&2, F.WithdrawalRequest>}
def WithdrawalRequest_representation_inverse(value): WithdrawalRequestValue_inverse(value)

law ExecutionRequests_representation_inverse:
  for +value: F.ExecutionRequests
  {F.ExecutionRequests.from_ssz(F.ExecutionRequests.to_ssz(value)) == Some{value} : Maybe<&2, F.ExecutionRequests>}
def ExecutionRequests_representation_inverse(value): ExecutionRequestsValue_inverse(value)

law BLSToExecutionChange_representation_inverse:
  for +value: F.BLSToExecutionChange
  {F.BLSToExecutionChange.from_ssz(F.BLSToExecutionChange.to_ssz(value)) == Some{value} : Maybe<&2, F.BLSToExecutionChange>}
def BLSToExecutionChange_representation_inverse(value): BLSToExecutionChangeValue_inverse(value)

law SignedBLSToExecutionChange_representation_inverse:
  for +value: F.SignedBLSToExecutionChange
  {F.SignedBLSToExecutionChange.from_ssz(F.SignedBLSToExecutionChange.to_ssz(value)) == Some{value} : Maybe<&2, F.SignedBLSToExecutionChange>}
def SignedBLSToExecutionChange_representation_inverse(value): SignedBLSToExecutionChangeValue_inverse(value)

law ExecutionPayloadHeader_representation_inverse:
  for +value: F.ExecutionPayloadHeader
  {F.ExecutionPayloadHeader.from_ssz(F.ExecutionPayloadHeader.to_ssz(value)) == Some{value} : Maybe<&2, F.ExecutionPayloadHeader>}
def ExecutionPayloadHeader_representation_inverse(value): ExecutionPayloadHeaderValue_inverse(value)

law PayloadId_representation_inverse:
  for +value: F.PayloadId()
  {F.PayloadId.from_ssz(F.PayloadId.to_ssz(value)) == Some{value} : Maybe<&2, F.PayloadId()>}
def PayloadId_representation_inverse(value): Node10_inverse(value)

law WithdrawalIndex_representation_inverse:
  for +value: F.WithdrawalIndex()
  {F.WithdrawalIndex.from_ssz(F.WithdrawalIndex.to_ssz(value)) == Some{value} : Maybe<&2, F.WithdrawalIndex()>}
def WithdrawalIndex_representation_inverse(value): Node3_inverse(value)

law Withdrawal_representation_inverse:
  for +value: F.Withdrawal
  {F.Withdrawal.from_ssz(F.Withdrawal.to_ssz(value)) == Some{value} : Maybe<&2, F.Withdrawal>}
def Withdrawal_representation_inverse(value): WithdrawalValue_inverse(value)

law ExecutionPayload_representation_inverse:
  for +value: F.ExecutionPayload
  {F.ExecutionPayload.from_ssz(F.ExecutionPayload.to_ssz(value)) == Some{value} : Maybe<&2, F.ExecutionPayload>}
def ExecutionPayload_representation_inverse(value): ExecutionPayloadValue_inverse(value)

law BeaconState_representation_inverse:
  for +value: F.BeaconState
  {F.BeaconState.from_ssz(F.BeaconState.to_ssz(value)) == Some{value} : Maybe<&2, F.BeaconState>}
def BeaconState_representation_inverse(value): BeaconStateValue_inverse(value)

law ExecutionBranch_representation_inverse:
  for +value: F.ExecutionBranch()
  {F.ExecutionBranch.from_ssz(F.ExecutionBranch.to_ssz(value)) == Some{value} : Maybe<&2, F.ExecutionBranch()>}
def ExecutionBranch_representation_inverse(value): Node90_inverse(value)

law LightClientHeader_representation_inverse:
  for +value: F.LightClientHeader
  {F.LightClientHeader.from_ssz(F.LightClientHeader.to_ssz(value)) == Some{value} : Maybe<&2, F.LightClientHeader>}
def LightClientHeader_representation_inverse(value): LightClientHeaderValue_inverse(value)

law LightClientOptimisticUpdate_representation_inverse:
  for +value: F.LightClientOptimisticUpdate
  {F.LightClientOptimisticUpdate.from_ssz(F.LightClientOptimisticUpdate.to_ssz(value)) == Some{value} : Maybe<&2, F.LightClientOptimisticUpdate>}
def LightClientOptimisticUpdate_representation_inverse(value): LightClientOptimisticUpdateValue_inverse(value)

law LightClientFinalityUpdate_representation_inverse:
  for +value: F.LightClientFinalityUpdate
  {F.LightClientFinalityUpdate.from_ssz(F.LightClientFinalityUpdate.to_ssz(value)) == Some{value} : Maybe<&2, F.LightClientFinalityUpdate>}
def LightClientFinalityUpdate_representation_inverse(value): LightClientFinalityUpdateValue_inverse(value)

law LightClientUpdate_representation_inverse:
  for +value: F.LightClientUpdate
  {F.LightClientUpdate.from_ssz(F.LightClientUpdate.to_ssz(value)) == Some{value} : Maybe<&2, F.LightClientUpdate>}
def LightClientUpdate_representation_inverse(value): LightClientUpdateValue_inverse(value)

law LightClientBootstrap_representation_inverse:
  for +value: F.LightClientBootstrap
  {F.LightClientBootstrap.from_ssz(F.LightClientBootstrap.to_ssz(value)) == Some{value} : Maybe<&2, F.LightClientBootstrap>}
def LightClientBootstrap_representation_inverse(value): LightClientBootstrapValue_inverse(value)

law BlobIndex_representation_inverse:
  for +value: F.BlobIndex()
  {F.BlobIndex.from_ssz(F.BlobIndex.to_ssz(value)) == Some{value} : Maybe<&2, F.BlobIndex()>}
def BlobIndex_representation_inverse(value): Node3_inverse(value)

law BlobIdentifier_representation_inverse:
  for +value: F.BlobIdentifier
  {F.BlobIdentifier.from_ssz(F.BlobIdentifier.to_ssz(value)) == Some{value} : Maybe<&2, F.BlobIdentifier>}
def BlobIdentifier_representation_inverse(value): BlobIdentifierValue_inverse(value)

law KZGCommitment_representation_inverse:
  for +value: F.KZGCommitment()
  {F.KZGCommitment.from_ssz(F.KZGCommitment.to_ssz(value)) == Some{value} : Maybe<&2, F.KZGCommitment()>}
def KZGCommitment_representation_inverse(value): Node8_inverse(value)

law BeaconBlockBody_representation_inverse:
  for +value: F.BeaconBlockBody
  {F.BeaconBlockBody.from_ssz(F.BeaconBlockBody.to_ssz(value)) == Some{value} : Maybe<&2, F.BeaconBlockBody>}
def BeaconBlockBody_representation_inverse(value): BeaconBlockBodyValue_inverse(value)

law BeaconBlock_representation_inverse:
  for +value: F.BeaconBlock
  {F.BeaconBlock.from_ssz(F.BeaconBlock.to_ssz(value)) == Some{value} : Maybe<&2, F.BeaconBlock>}
def BeaconBlock_representation_inverse(value): BeaconBlockValue_inverse(value)

law SignedBeaconBlock_representation_inverse:
  for +value: F.SignedBeaconBlock
  {F.SignedBeaconBlock.from_ssz(F.SignedBeaconBlock.to_ssz(value)) == Some{value} : Maybe<&2, F.SignedBeaconBlock>}
def SignedBeaconBlock_representation_inverse(value): SignedBeaconBlockValue_inverse(value)

law KZGProof_representation_inverse:
  for +value: F.KZGProof()
  {F.KZGProof.from_ssz(F.KZGProof.to_ssz(value)) == Some{value} : Maybe<&2, F.KZGProof()>}
def KZGProof_representation_inverse(value): Node8_inverse(value)

law Blob_representation_inverse:
  for +value: F.Blob()
  {F.Blob.from_ssz(F.Blob.to_ssz(value)) == Some{value} : Maybe<&2, F.Blob()>}
def Blob_representation_inverse(value): Node107_inverse(value)

law BlobSidecar_representation_inverse:
  for +value: F.BlobSidecar
  {F.BlobSidecar.from_ssz(F.BlobSidecar.to_ssz(value)) == Some{value} : Maybe<&2, F.BlobSidecar>}
def BlobSidecar_representation_inverse(value): BlobSidecarValue_inverse(value)

law Cell_representation_inverse:
  for +value: F.Cell()
  {F.Cell.from_ssz(F.Cell.to_ssz(value)) == Some{value} : Maybe<&2, F.Cell()>}
def Cell_representation_inverse(value): Node110_inverse(value)

law CellIndex_representation_inverse:
  for +value: F.CellIndex()
  {F.CellIndex.from_ssz(F.CellIndex.to_ssz(value)) == Some{value} : Maybe<&2, F.CellIndex()>}
def CellIndex_representation_inverse(value): Node3_inverse(value)

law CommitmentIndex_representation_inverse:
  for +value: F.CommitmentIndex()
  {F.CommitmentIndex.from_ssz(F.CommitmentIndex.to_ssz(value)) == Some{value} : Maybe<&2, F.CommitmentIndex()>}
def CommitmentIndex_representation_inverse(value): Node3_inverse(value)

law RowIndex_representation_inverse:
  for +value: F.RowIndex()
  {F.RowIndex.from_ssz(F.RowIndex.to_ssz(value)) == Some{value} : Maybe<&2, F.RowIndex()>}
def RowIndex_representation_inverse(value): Node3_inverse(value)

law ColumnIndex_representation_inverse:
  for +value: F.ColumnIndex()
  {F.ColumnIndex.from_ssz(F.ColumnIndex.to_ssz(value)) == Some{value} : Maybe<&2, F.ColumnIndex()>}
def ColumnIndex_representation_inverse(value): Node3_inverse(value)

law DataColumnsByRootIdentifier_representation_inverse:
  for +value: F.DataColumnsByRootIdentifier
  {F.DataColumnsByRootIdentifier.from_ssz(F.DataColumnsByRootIdentifier.to_ssz(value)) == Some{value} : Maybe<&2, F.DataColumnsByRootIdentifier>}
def DataColumnsByRootIdentifier_representation_inverse(value): DataColumnsByRootIdentifierValue_inverse(value)

law MatrixEntry_representation_inverse:
  for +value: F.MatrixEntry
  {F.MatrixEntry.from_ssz(F.MatrixEntry.to_ssz(value)) == Some{value} : Maybe<&2, F.MatrixEntry>}
def MatrixEntry_representation_inverse(value): MatrixEntryValue_inverse(value)

law DataColumnSidecar_representation_inverse:
  for +value: F.DataColumnSidecar
  {F.DataColumnSidecar.from_ssz(F.DataColumnSidecar.to_ssz(value)) == Some{value} : Maybe<&2, F.DataColumnSidecar>}
def DataColumnSidecar_representation_inverse(value): DataColumnSidecarValue_inverse(value)

law CustodyIndex_representation_inverse:
  for +value: F.CustodyIndex()
  {F.CustodyIndex.from_ssz(F.CustodyIndex.to_ssz(value)) == Some{value} : Maybe<&2, F.CustodyIndex()>}
def CustodyIndex_representation_inverse(value): Node3_inverse(value)

