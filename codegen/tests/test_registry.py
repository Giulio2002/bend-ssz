"""codegen/registry.py against the tree: every generator is registered, every entry exists, the order is valid."""
import re
import unittest

from codegen import registry
from codegen.core.paths import CODEGEN

NOT_GENERATORS = {'writer.py', 'regen_all.py', 'regen_touched.py', 'registry.py', '__init__.py', 'sitecustomize.py'}


def scripts_accepting_check():
    out = {}
    for p in CODEGEN.rglob('*.py'):
        if p.name in NOT_GENERATORS or 'tests' in p.relative_to(CODEGEN).parts:
            continue
        t = p.read_text(errors='replace')
        if "'--check'" in t or '"--check"' in t:
            out[p.stem] = p
    return out


class RegistryTest(unittest.TestCase):
    def test_every_script_with_check_is_registered(self):
        have = scripts_accepting_check()
        missing = sorted(set(have) - set(registry.by_name()))
        self.assertEqual(missing, [], 'accepts --check but is not in codegen/registry.py')

    def test_every_entry_exists_in_its_directory(self):
        for g in registry.GENERATORS:
            self.assertTrue(g.path.is_file(), f'{g.name}: {g.path} does not exist')
            self.assertIn("'--check'", g.path.read_text(errors='replace').replace('"--check"', "'--check'"), f'{g.name} does not accept --check')

    def test_names_unique_and_stems_unique_in_tree(self):
        names = [g.name for g in registry.GENERATORS]
        self.assertEqual(len(names), len(set(names)))
        stems = [p.stem for p in CODEGEN.rglob('*.py') if p.name != '__init__.py' and 'tests' not in p.relative_to(CODEGEN).parts]
        dup = sorted({s for s in stems if stems.count(s) > 1})
        self.assertEqual(dup, [], 'module names must be unique across codegen/ (headers and --only name them without the directory)')

    def test_order_is_a_topological_order(self):
        order = [g.name for g in registry.ordered()]
        self.assertEqual(len(order), len(registry.GENERATORS))
        pos = {n: i for i, n in enumerate(order)}
        for g in registry.GENERATORS:
            for a in g.after:
                self.assertLess(pos[a], pos[g.name], f'{g.name} must run after {a}')
        stages = [registry.by_name()[n].stage for n in order]
        self.assertEqual(stages, sorted(stages, key=registry.STAGES.index), 'first, then mid, then last')

    def test_cycle_is_reported(self):
        saved = registry.GENERATORS
        try:
            registry.GENERATORS = (registry.Gen('a', 'core', stage='last', after=('b',)), registry.Gen('b', 'core', stage='last', after=('a',)))
            with self.assertRaises(ValueError):
                registry.ordered()
        finally:
            registry.GENERATORS = saved

    def test_heavy_ranks_distinct(self):
        ranks = [g.heavy for g in registry.GENERATORS if g.heavy is not None]
        self.assertEqual(len(ranks), len(set(ranks)))

    def test_directories_are_packages(self):
        for g in registry.GENERATORS:
            d = g.path.parent
            while d != CODEGEN.parent:
                self.assertTrue((d / '__init__.py').is_file(), f'{d} has no __init__.py')
                d = d.parent
                if d == CODEGEN.parent:
                    break

    def test_scripts_can_find_the_repo_root(self):
        for g in registry.GENERATORS:
            depth = len(g.path.relative_to(CODEGEN).parts)   # codegen/<a>/<b>/x.py -> 3 parts -> parents[3]
            text = g.path.read_text()
            self.assertIn(f'resolve().parents[{depth}]))', text, f'{g.name}: the repo-root preamble is missing or has the wrong depth')

    def test_moves_file_matches_registry_paths(self):
        # codegen/MOVES.tsv records where each pre-layout path went; every registered generator that existed before is in it
        rows = [l.split('\t') for l in (CODEGEN / 'MOVES.tsv').read_text().splitlines() if l and not l.startswith('#')]
        new = {r[1] for r in rows}
        for g in registry.GENERATORS:
            rel = str(g.path.relative_to(CODEGEN.parent))
            self.assertTrue(rel in new or not re.match(r'codegen/', rel))


if __name__ == '__main__':
    unittest.main()
