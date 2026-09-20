#!/usr/bin/env python3
"""Write docs/LAW_MIGRATION.json: the machine-readable old-to-new law map that
automation/native_memory_acceptance.py checks.

For every law in the frozen snapshot `memory_bench/law-statements.json` the map
records the original statement, the law that carries it today, that law's
current statement read out of END_TO_END.bend, and why the current statement is
not weaker than the original.

The representation migration described in docs/LAW_API_MAP.md deliberately keeps
every one of these propositions byte-for-byte: the array-backed entry points are
introduced *underneath* the existing ones (the byte-list form is defined as
fill-to-buffer, primary operation, forget), so a law about the list-level entry
point is a law about the array path composed with the storage bridge. Nothing
here is a signature migration, so every `equivalence_argument` says exactly
that, plus what that law specifically constrains.

    python3 tools/generate_law_migration.py
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# What each law pins down, used to make the argument specific rather than
# boilerplate. Every entry states the conclusion strength and the input domain
# that must not shrink.
SUBJECT = {
    'decide_invalid': 'the validity decision for a schema, with no storage in the statement',
    'illegal_invalid': 'that an illegal type is rejected by the validity decision',
    'serialize_illegal': 'that serialization refuses every value of an illegal type',
    'serialize_correct': 'that serialization returns exactly the independent canonical encoding',
    'accepted_spec': 'that an accepted input is in the canonical image of the decoded value',
    'spec_accepted': 'that every canonical encoding is accepted and decodes to its value',
    'deserialize_correct': 'both directions of deserialization against the decoding relation',
    'deserialize_unique': 'injectivity: one input decodes to at most one value',
    'reject_decide': 'that an input outside the image, or of an illegal type, is rejected',
    'deserialize_rejection_correct': 'both directions of the rejection characterisation',
    'root_accepted': 'that a returned root satisfies the relational root semantics and is 32 bytes',
    'hash_tree_root_correct': 'soundness, completeness and totality of hash_tree_root on its domain',
    'named_valid': 'that every named Fulu schema is legal',
    'preserved': 'that the typed adapter round trips a named value',
    'named_accepted_result': 'the named deserialization result against the generic law',
    'named_decoded': 'that a named encoding decodes to the named value',
    'decoded_shape': 'the shape of a decoded value against its schema',
    'named_rejected_result': 'named rejection against the generic rejection law',
    'named_root_accepted': 'named hash_tree_root against the relational root semantics',
    'named_outside': 'that a named type rejects inputs outside its image',
    'fulu_types_correct': 'the four generic guarantees for every one of the 109 names',
    'legal_boolean_exists': 'a closed witness that a legal type exists',
    'boolean_image_exists': 'a closed witness of a canonical encoding',
    'boolean_image_decoded': 'a closed witness that the encoding decodes back',
    'boolean_rejects_two': 'a closed witness that a malformed boolean byte is rejected',
    'boolean_root_domain': 'a closed witness inside the root domain',
    'empty_container_absurd': 'that an empty container type is not legal',
    'illegal_empty_container': 'the same as a standalone proposition',
    'checkpoint_named_legal': 'a closed witness that a named Fulu type is legal',
}

ARGUMENT = (
    'Statement unchanged, character for character, from the frozen snapshot; '
    'this law still constrains {subject}. The array migration in '
    'docs/LAW_API_MAP.md introduces packed buffers underneath this entry point '
    'rather than beside it - the byte-list form is defined as (fill buffer, run '
    'the primary operation, read the result back), so the same proposition '
    'quantifies over the same inputs, keeps the same rejection cases and yields '
    'the same conclusion, now about the array path composed with the storage '
    'bridge. No premise was added, no domain narrowed, no conclusion weakened. '
    'Migration status: not yet implemented, so the current statement and the '
    'original statement are the identical text; when the storage changes this '
    'row must be re-checked against the bridge theorems store_denotation and '
    'store_index rather than restated.'
)


def main():
    expected = json.loads((ROOT / 'memory_bench/law-statements.json').read_text())
    text = (ROOT / 'END_TO_END.bend').read_text()
    actual = {m.group(1): m.group(0) for m in re.finditer(r'(?ms)^law (\w+):\n.*?(?=^def \1\()', text)}

    missing = [name for name in expected if name not in actual]
    if missing:
        raise SystemExit('END_TO_END.bend no longer declares: ' + ', '.join(missing))

    mapping = {}
    for name, statement in expected.items():
        if actual[name] != statement:
            raise SystemExit('Statement drift for ' + name + '; the map must not paper over it')
        mapping[name] = {
            'original_statement': statement,
            'new_law': name,
            'new_statement': actual[name],
            'equivalence_argument': ARGUMENT.format(subject=SUBJECT.get(name, 'its stated property')),
            'representation_change': 'none yet: the statement is representation independent',
            'bridges': ['store_denotation', 'store_index'],
        }
    out = ROOT / 'docs/LAW_MIGRATION.json'
    out.write_text(json.dumps(mapping, indent=2) + '\n')
    print('docs/LAW_MIGRATION.json:', len(mapping), 'laws mapped')


if __name__ == '__main__':
    main()
