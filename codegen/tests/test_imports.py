"""Static layout checks: every `codegen.` import names a module that exists, and the core does not import upward."""
import ast
import re
import unittest

from codegen.core.repository_paths import CODEGEN, ROOT


def modules():
    for p in sorted(CODEGEN.rglob('*.py')):
        if p.name != 'sitecustomize.py':
            yield p


def resolves(dotted: str) -> bool:
    parts = dotted.split('.')
    base = ROOT.joinpath(*parts)
    return base.with_suffix('.py').is_file() or (base / '__init__.py').is_file()


class ImportTest(unittest.TestCase):
    def test_every_codegen_import_resolves(self):
        bad = []
        for p in modules():
            for n in ast.walk(ast.parse(p.read_text())):
                if isinstance(n, ast.ImportFrom) and n.module and n.module.split('.')[0] == 'codegen':
                    if not resolves(n.module):
                        bad.append(f'{p.relative_to(ROOT)}:{n.lineno}: {n.module}')
                        continue
                    for a in n.names:   # `from pkg import module` must be a module or a name the package defines
                        sub = f'{n.module}.{a.name}'
                        if not resolves(sub) and not self._defines(n.module, a.name):
                            bad.append(f'{p.relative_to(ROOT)}:{n.lineno}: {sub}')
                elif isinstance(n, ast.Import):
                    for a in n.names:
                        if a.name.split('.')[0] == 'codegen' and not resolves(a.name):
                            bad.append(f'{p.relative_to(ROOT)}:{n.lineno}: {a.name}')
        self.assertEqual(bad, [])

    @staticmethod
    def _defines(module, name):
        base = ROOT.joinpath(*module.split('.'))
        f = base.with_suffix('.py') if base.with_suffix('.py').is_file() else base / '__init__.py'
        tree = ast.parse(f.read_text())
        for n in ast.walk(tree):
            if isinstance(n, (ast.FunctionDef, ast.ClassDef)) and n.name == name:
                return True
            if isinstance(n, ast.Assign) and any(isinstance(t, ast.Name) and t.id == name for t in n.targets):
                return True
            if isinstance(n, (ast.Import, ast.ImportFrom)) and any((a.asname or a.name.split('.')[0]) == name for a in n.names):
                return True
        return False

    def test_module_attributes_exist(self):
        """`from codegen.x import mod as M` ... `M.name`: the module must define `name` at top level (a removed helper or import
        shows up here, not in the middle of a regeneration)"""
        defined = {}

        def names_of(dotted):
            if dotted not in defined:
                base = ROOT.joinpath(*dotted.split('.'))
                f = base.with_suffix('.py') if base.with_suffix('.py').is_file() else base / '__init__.py'
                out = set()
                for n in ast.walk(ast.parse(f.read_text())):
                    if isinstance(n, (ast.FunctionDef, ast.ClassDef)):
                        out.add(n.name)
                    elif isinstance(n, ast.Name) and isinstance(n.ctx, ast.Store):
                        out.add(n.id)
                    elif isinstance(n, (ast.Import, ast.ImportFrom)):
                        out.update((a.asname or a.name.split('.')[0]) for a in n.names)
                    elif isinstance(n, ast.Global):
                        out.update(n.names)
                defined[dotted] = out
            return defined[dotted]

        bad = []
        for p in modules():
            tree = ast.parse(p.read_text())
            alias = {}
            for n in ast.walk(tree):
                if isinstance(n, ast.ImportFrom) and n.module and n.module.startswith('codegen.'):
                    for a in n.names:
                        if resolves(f'{n.module}.{a.name}'):
                            alias[a.asname or a.name] = f'{n.module}.{a.name}'
            rebound = {n.id for n in ast.walk(tree) if isinstance(n, ast.Name) and isinstance(n.ctx, ast.Store)}   # a local named like the alias
            for n in ast.walk(tree):
                if isinstance(n, ast.Attribute) and isinstance(n.value, ast.Name) and n.value.id in alias and n.value.id not in rebound:
                    if n.attr not in names_of(alias[n.value.id]) and not n.attr.startswith('__'):
                        bad.append(f'{p.relative_to(ROOT)}:{n.lineno}: {n.value.id}.{n.attr}')
        self.assertEqual(bad, [])

    def test_roots_come_from_core_paths_or_are_depth_correct(self):
        bad = []
        for p in modules():
            if p.name in ('repository_paths.py', 'test_imports.py'):
                continue
            depth = len(p.relative_to(CODEGEN).parts)
            for i, line in enumerate(p.read_text().splitlines(), 1):
                if '__file__' in line and '.parent' in line and 'parents[' not in line:
                    bad.append(f'{p.relative_to(ROOT)}:{i}: {line.strip()[:80]}')
                for m in re.finditer(r'__file__\)\.resolve\(\)\.parents\[(\d+)\]', line):
                    if 'ROOT' in line.split('=')[0] and int(m.group(1)) != depth:
                        bad.append(f'{p.relative_to(ROOT)}:{i}: ROOT at parents[{m.group(1)}], depth is {depth}')
        self.assertEqual(bad, [])

    def test_core_imports_only_core(self):
        bad = []
        for p in (CODEGEN / 'core').glob('*.py'):
            for n in ast.walk(ast.parse(p.read_text())):
                if isinstance(n, ast.ImportFrom) and n.module and n.module.startswith('codegen.') and not n.module.startswith('codegen.core'):
                    bad.append(f'{p.name}:{n.lineno}: {n.module}')
        self.assertEqual(bad, [], 'codegen/core is the bottom layer: it must not import the generators')


if __name__ == '__main__':
    unittest.main()
