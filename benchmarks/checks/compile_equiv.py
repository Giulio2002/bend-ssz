#!/usr/bin/env python3
"""Does src/ccompile.bend compute exactly the compact schemas that were
generated as literals? Writes build/compile_equiv.bend, which compares
`compile(Spec.X())` with the literal table the generators still write to
build/cschema_literal/ (tools/generate_cschema.py and
tools/generate_cschema_generic.py) structurally for every Fulu name and every
official generic test type, runs it with the pinned bend, and reports every
mismatch.

    python3 benchmarks/checks/compile_equiv.py
"""
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'build/compile_equiv/main.bend'

EQ = '''
def u(+a: U32, +b: U32) -> Bool: U32.is_eq(a, b)

def bo(a: Bool, b: Bool) -> Bool:
  match a b:
    case True{} True{}: True{}
    case False{} False{}: True{}
    case _ _: False{}

def eq(a: S.CS, b: S.CS) -> Bool:
  match a b:
    case S.CBool{} S.CBool{}: True{}
    case S.CUint{x} S.CUint{y}: u(x, y)
    case S.CBytes{a1, a2} S.CBytes{b1, b2}: Bool.and(u(a1, b1), u(a2, b2))
    case S.CByteList{a1, a2, a3} S.CByteList{b1, b2, b3}: Bool.and(u(a1, b1), Bool.and(bo(a2, b2), u(a3, b3)))
    case S.CBitVec{a1, a2, a3} S.CBitVec{b1, b2, b3}: Bool.and(u(a1, b1), Bool.and(u(a2, b2), u(a3, b3)))
    case S.CBitList{a1, a2, a3} S.CBitList{b1, b2, b3}: Bool.and(u(a1, b1), Bool.and(bo(a2, b2), u(a3, b3)))
    case S.CVec{a1, a2, a3, a4, a5, a6} S.CVec{b1, b2, b3, b4, b5, b6}:
      Bool.and(eq(a1, b1), Bool.and(u(a2, b2), Bool.and(u(a3, b3), Bool.and(u(a4, b4), Bool.and(bo(a5, b5), bo(a6, b6))))))
    case S.CVecVar{a1, a2, a3} S.CVecVar{b1, b2, b3}: Bool.and(eq(a1, b1), Bool.and(u(a2, b2), u(a3, b3)))
    case S.CList{a1, a2, a3, a4, a5, a6, a7} S.CList{b1, b2, b3, b4, b5, b6, b7}:
      Bool.and(eq(a1, b1), Bool.and(u(a2, b2), Bool.and(bo(a3, b3), Bool.and(u(a4, b4), Bool.and(u(a5, b5), Bool.and(bo(a6, b6), bo(a7, b7)))))))
    case S.CListVar{a1, a2, a3, a4} S.CListVar{b1, b2, b3, b4}: Bool.and(eq(a1, b1), Bool.and(u(a2, b2), Bool.and(bo(a3, b3), u(a4, b4))))
    case S.CCont{a1, a2, a3, a4, a5, a6, a7, a8, a9, a10} S.CCont{b1, b2, b3, b4, b5, b6, b7, b8, b9, b10}:
      Bool.and(eq(a1, b1), Bool.and(u(a2, b2), Bool.and(u(a3, b3), Bool.and(u(a4, b4), Bool.and(bo(a5, b5),
        Bool.and(u(a6, b6), Bool.and(bo(a7, b7), Bool.and(eq(a8, b8), Bool.and(u(a9, b9), bo(a10, b10))))))))))
    case S.CPCont{a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11} S.CPCont{b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11}:
      Bool.and(eq(a1, b1), Bool.and(u(a2, b2), Bool.and(u(a3, b3), Bool.and(u(a4, b4), Bool.and(bo(a5, b5),
        Bool.and(bo(a6, b6), Bool.and(eq(a7, b7), Bool.and(u(a8, b8), Bool.and(eq(a9, b9), Bool.and(u(a10, b10), u(a11, b11)))))))))))
    case S.CUnion{a1, a2} S.CUnion{b1, b2}: Bool.and(eq(a1, b1), u(a2, b2))
    case S.CNull{} S.CNull{}: True{}
    case S.CFLeaf{a1, a2, a3, a4} S.CFLeaf{b1, b2, b3, b4}: Bool.and(eq(a1, b1), Bool.and(u(a2, b2), Bool.and(u(a3, b3), bo(a4, b4))))
    case S.CFNode{a1, a2, a3} S.CFNode{b1, b2, b3}: Bool.and(eq(a1, b1), Bool.and(eq(a2, b2), u(a3, b3)))
    case S.CFNone{} S.CFNone{}: True{}
    case _ _: False{}

def verdict(ok: Bool) -> U32:
  match ok:
    case True{}: 0
    case False{}: 1
'''


def main():
    text = (ROOT / 'spec/fulu_schemas.bend').read_text()
    names = [n for n in re.findall(r'^def (\w+)\(\) -> T\.Schema:', text, re.M) if not re.fullmatch(r'Schema\d+', n)]
    lines = ['import Base',
             'import ../../src/cschema.bend as S',
             'import ../../src/ccompile.bend as K',
             'import ../../spec/fulu_schemas.bend as Spec',
             'import ../cschema_literal/fulu_cschema.bend as C',
             'import ../../types/generic_spec.bend as GS',
             'import ../cschema_literal/generic_cschema.bend as GC',
             EQ]
    # one check per name, summed; the names of mismatches are printed
    checks = []
    for n in names:
        checks.append(f'def check_{n}() -> U32: verdict(eq(K.compile(Spec.{n}()), C.{n}()))')
    generic = re.findall(r'^def (G\d+)\(\) -> T\.Schema:', (ROOT / 'types/generic_spec.bend').read_text(), re.M)
    for g in generic:
        checks.append(f'def check_{g}() -> U32: verdict(eq(K.compile(GS.{g}()), GC.{g}()))')
    lines += checks
    names = names + generic
    body = ['def main() -> IO(Unit):', '  do IO<Unit>:']
    for n in names:
        body.append(f'    IO.print("{n} " ++ U32.show(check_{n}()))')
    lines += [''] + body
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text('\n'.join(lines) + '\n')
    r = subprocess.run(['/Users/monkeair/.bend/bin/bend', str(OUT)], cwd=ROOT, capture_output=True, text=True,
                       env={'BEND_NO_TELEMETRY': '1', 'PATH': '/usr/bin:/bin', 'HOME': str(Path.home())})
    out = r.stdout + r.stderr
    rows = re.findall(r'^(\w+) (\d+)$', out, re.M)
    bad = [n for n, v in rows if v != '0']
    print(f'compared {len(rows)} of {len(names)} names; mismatches: {len(bad)} {bad}')
    if len(rows) != len(names):
        print(out[-4000:])
    return 0 if (len(rows) == len(names) and not bad) else 1


if __name__ == '__main__':
    sys.exit(main())
