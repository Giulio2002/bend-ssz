"""The registry of the generators: the one list regen_all.py, tools/strictcheck.sh and the tests read.

A generator is a script `codegen/<dir>/<name>.py` that writes generated files and accepts `--check` (exit 0 when
every file it owns is what it would write). Everything else under codegen/ is a library the generators import
(codegen/core/, the shared modules of codegen/proofs/support/ ...), or the driver (regen_all.py, regen_touched.py).
codegen/tests/test_registry.py keeps this list and the tree in step: every file that accepts --check is registered,
every entry exists, the dependencies are acyclic.

Run order (`ordered()`): the `first` stage (generate: the object API every law generator reads), then the `mid`
generators (independent of each other: they run in the pool, alphabetical here), then the `last` stage in dependency
order (`after`): a generator that reads another's output (the gates and facades index the laws, the bridges index the
facades, the witnesses and composed theorems read the bridges, the statements read those, the doc figures read the
statements). A `pool` names last-stage generators that do not read each other and may run together.
`heavy` ranks the slowest generators (measured; 0 first): the pool starts them first so its tail is short.
"""
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


@dataclass(frozen=True)
class Gen:
    name: str                      # the file stem; `--only name`, the stamp key of regen_touched
    dir: str                       # the directory below codegen/
    stage: str = 'mid'             # 'first' | 'mid' | 'last'
    after: tuple = ()              # names whose outputs this generator reads (last stage: run after them)
    heavy: int | None = None       # rank among the slowest generators, 0 first
    pool: str | None = None        # last-stage generators with the same pool may run in the pool together

    @property
    def path(self) -> Path:
        return ROOT / 'codegen' / self.dir / f'{self.name}.py'


GENERATORS = (
    # codegen/core/
    Gen('names', 'core'),
    # codegen/impl/
    Gen('check_schema', 'impl'),
    Gen('generate', 'impl', stage='first'),
    Gen('runtime_refs', 'impl'),
    Gen('tool_generators', 'impl'),
    # codegen/docs/
    Gen('doc_figures', 'docs', stage='last', after=('statements',)),
    Gen('import_graph', 'docs'),
    Gen('statements', 'docs', stage='last', after=('e2e_witness', 'e2e_compose')),
    # codegen/proofs/laws/
    Gen('arr_laws', 'proofs/laws'),
    Gen('bitlist_laws', 'proofs/laws'),
    Gen('blist_laws', 'proofs/laws'),
    Gen('cached_laws', 'proofs/laws'),
    Gen('fix_reject', 'proofs/laws'),
    Gen('fix_reject_chk', 'proofs/laws'),
    Gen('fix_reject_pad', 'proofs/laws'),
    Gen('mutation_laws', 'proofs/laws'),
    Gen('mutation_laws_cap', 'proofs/laws'),
    Gen('mutation_laws_const', 'proofs/laws'),
    Gen('mutation_laws_arith', 'proofs/laws'),
    Gen('mutation_laws_offset', 'proofs/laws'),
    Gen('mutation_laws_validity', 'proofs/laws'),
    Gen('packed_laws', 'proofs/laws'),
    Gen('prog_laws', 'proofs/laws'),
    Gen('root_laws', 'proofs/laws'),
    Gen('root_laws_b', 'proofs/laws', heavy=5),
    Gen('root_laws_generic', 'proofs/laws'),
    Gen('schema_shapes', 'proofs/laws'),
    Gen('sha_laws', 'proofs/laws'),
    Gen('spec_laws', 'proofs/laws', heavy=4),
    Gen('sub_laws', 'proofs/laws'),
    Gen('valid_laws', 'proofs/laws', heavy=7),
    # codegen/proofs/var/
    Gen('encx_children', 'proofs/var'),
    Gen('encx_d', 'proofs/var'),
    Gen('var_agg_enc', 'proofs/var'),
    Gen('var_bitc', 'proofs/var'),
    Gen('var_bits', 'proofs/var'),
    Gen('var_bits_enc', 'proofs/var'),
    Gen('var_bits_encx', 'proofs/var'),
    Gen('var_bytes', 'proofs/var'),
    Gen('var_bytes_x', 'proofs/var'),
    Gen('var_cont_enc', 'proofs/var', heavy=0),
    Gen('var_cont_top', 'proofs/var'),
    Gen('var_fixx', 'proofs/var'),
    Gen('var_laws', 'proofs/var'),
    Gen('var_multi', 'proofs/var'),
    Gen('var_pbits', 'proofs/var'),
    Gen('var_plist', 'proofs/var'),
    Gen('var_plist_sub', 'proofs/var'),
    Gen('var_rec_enc', 'proofs/var'),
    Gen('var_rlist', 'proofs/var'),
    Gen('var_rlist_sub', 'proofs/var'),
    Gen('var_top', 'proofs/var'),
    Gen('var_ua', 'proofs/var'),
    Gen('var_uw', 'proofs/var'),
    Gen('var_uwl', 'proofs/var'),
    Gen('var_uwv', 'proofs/var'),
    Gen('var_vlist', 'proofs/var'),
    Gen('var_vlist_enc', 'proofs/var'),
    Gen('var_win', 'proofs/var'),
    Gen('var_winb', 'proofs/var', heavy=1),
    Gen('var_winb_lc', 'proofs/var'),
    Gen('var_winbits', 'proofs/var'),
    Gen('var_winl', 'proofs/var'),
    Gen('var_winl16', 'proofs/var'),
    Gen('var_winu', 'proofs/var'),
    Gen('var_winv', 'proofs/var'),
    Gen('var_winx_c', 'proofs/var'),
    Gen('vedge', 'proofs/var'),
    # codegen/proofs/collections/
    Gen('bits_view', 'proofs/collections'),
    Gen('boxedview', 'proofs/collections'),
    Gen('coll_laws', 'proofs/collections'),
    Gen('e2e_setters', 'proofs/collections', stage='last', after=('e2e_bridge',)),
    Gen('laws', 'proofs/collections'),
    Gen('rep_laws', 'proofs/collections'),
    Gen('serialize_e2e', 'proofs/collections'),
    Gen('u32_split', 'proofs/collections'),
    Gen('view_laws', 'proofs/collections'),
    Gen('viewcells', 'proofs/collections'),
    # codegen/proofs/facades/
    Gen('api_facade', 'proofs/facades', stage='last', after=('api_gate',), heavy=6),
    Gen('api_gate', 'proofs/facades', stage='last', after=('generate',), heavy=3),
    # codegen/proofs/bridges/
    Gen('e2e_bridge', 'proofs/bridges', stage='last', after=('api_facade',), heavy=2),
    Gen('e2e_vlm_gen', 'proofs/bridges'),
    # codegen/proofs/witnesses/
    Gen('decode_witness', 'proofs/witnesses'),
    Gen('obytes_len', 'proofs/witnesses'),
    Gen('coll_witness', 'proofs/witnesses'),
    Gen('e2e_witness', 'proofs/witnesses', stage='last', after=('e2e_setters',), pool='witness-compose'),
    # codegen/proofs/composed/
    Gen('e2e_compose', 'proofs/composed', stage='last', after=('e2e_setters',), pool='witness-compose'),
    # codegen/proofs/decoded/
    Gen('e2e_dbs', 'proofs/decoded'),
    Gen('e2e_dfl', 'proofs/decoded'),
    Gen('e2e_dvp', 'proofs/decoded'),
    Gen('e2e_hpl', 'proofs/decoded'),
    Gen('e2e_dvv2', 'proofs/decoded'),
    Gen('e2e_hkv', 'proofs/decoded'),
    Gen('e2e_hkp', 'proofs/decoded'),
    Gen('e2e_dbl', 'proofs/decoded'),
    Gen('e2e_decbb', 'proofs/decoded'),
    Gen('e2e_decbits', 'proofs/decoded'),
    Gen('e2e_decbk', 'proofs/decoded'),
    Gen('e2e_decbs', 'proofs/decoded'),
    Gen('e2e_decep', 'proofs/decoded'),
    Gen('e2e_decfx', 'proofs/decoded'),
    Gen('e2e_decoded', 'proofs/decoded'),
    Gen('e2e_decpl', 'proofs/decoded'),
    Gen('e2e_decrl', 'proofs/decoded'),
    Gen('e2e_decrq', 'proofs/decoded'),
    Gen('e2e_dvl', 'proofs/decoded'),
    # codegen/proofs/support/
    Gen('light_split', 'proofs/support'),
)

STAGES = ('first', 'mid', 'last')


def by_name() -> dict:
    """{name: Gen}; names are unique across the tree (they are the file stems and the --only keys)."""
    return {g.name: g for g in GENERATORS}


def ordered() -> list:
    """The generators in run order: first, mid (alphabetical), then the last stage topologically by `after`
    (ties in registry order). Raises ValueError on an unknown dependency or a cycle."""
    names = by_name()
    for g in GENERATORS:
        for a in g.after:
            if a not in names:
                raise ValueError(f'{g.name}: unknown dependency {a}')
    out = [g for g in GENERATORS if g.stage == 'first'] + sorted((g for g in GENERATORS if g.stage == 'mid'), key=lambda g: g.name)
    pending = [g for g in GENERATORS if g.stage == 'last']
    done = {g.name for g in out}
    while pending:
        ready = next((g for g in pending if all(a in done for a in g.after)), None)
        if ready is None:
            raise ValueError('dependency cycle among: ' + ', '.join(g.name for g in pending))
        out.append(ready)
        done.add(ready.name)
        pending.remove(ready)
    return out
