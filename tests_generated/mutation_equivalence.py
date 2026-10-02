"""Proof-level equivalence rules for the survivors of tests_generated/mutation_testing.py, and the exclusion list.

    python3 tests_generated/mutation_equivalence.py REPORT.json [REPORT.json ...] [--write]

A survivor of the proof batch is either a gap (the locked statements do not pin the mutated definition) or provably
equivalent: the checker converts the mutant to the original, or a lemma of arithmetic on literals makes the two values
equal. This file states which survivors are equivalent and why, by rules that read only the generated source:

  - argument never read: the mutated constant is a direct argument of a call and the callee's body never mentions
    that parameter (hl and seg of the hash_tree_root leaf wrappers, the len argument of the fixed-size field
    readers, the offset of the proglist decoders);
  - flag read only by O.is_poisoned: `(out, (o, 0))` -> `(o, 1)`: is_poisoned(fl) = 2^31 <= fl is False for both;
  - words_ok / bits_ok: the accepted set {n : lo <= n <= hi, unit | n} (or unbounded when big is True{}) is the same
    before and after the change of lo, hi or unit, checked on every n that can differ;
  - vec_bool decoders: ok_n has one caller passing the literal N, so is_eq(N, 0) and its mutants evaluate alike and the
    True{} branch of ok_nz is never taken;
  - the one uncoverable bound (Transaction, 2^30 -> 2^30+1, needs an object of 2^30+1 bytes).
    (out_at(d) -> out_at(d+1) was once excluded as harmless; the capacity laws killed it, so it is drawn again.)

With --write it rewrites tests_generated/mutation_exclusions.json (what the draws skip) from the reports.
Run from the repository root.
"""
import collections
import json
import pathlib
import re
import sys
src={f:f.read_text() for f in list(pathlib.Path('types').glob('*.bend'))+list(pathlib.Path('src').glob('*.bend'))}
def find_def(name):
    for f,t in src.items():
        m=re.search(r'^def '+re.escape(name)+r'\((.*?)\) ?->[^\n]*?:(.*?)(?=^def |\Z)',t,re.M|re.S)
        if m: return f,m.group(1),m.group(2)
def split_args(s):
    out,dep,cur=[],0,''
    for c in s:
        if c in '([{<': dep+=1
        if c in ')]}>': dep-=1
        if c==',' and dep==0: out.append(cur.strip()); cur=''
        else: cur+=c
    out.append(cur.strip()); return out
def calls(line):
    """(callee, start, end, args, arg spans) for each name( ... ) in the line"""
    out=[]
    for m in re.finditer(r'((?:\w+\.)*\w+)\(',line):
        start=m.end(); depth=1; j=start
        while depth and j<len(line):
            c=line[j]; depth+=(c=='(')-(c==')'); j+=1
        if depth: continue
        args=[]; pos=start; k0=start; dep=0; cur_start=start
        i=start
        spans=[]; dep=0; st=start
        for i in range(start,j-1):
            c=line[i]
            if c in '([{<': dep+=1
            elif c in ')]}>': dep-=1
            elif c==',' and dep==0: spans.append((st,i)); st=i+1
        spans.append((st,j-1))
        out.append((m.group(1),start,j,spans))
    return out
def unread(x):
    line=pathlib.Path(x['file']).read_text().split('\n')[x['line']-1]
    best=None
    for callee,s,e,spans in calls(line):
        for i,(a,b) in enumerate(spans):
            if line[a:b].strip()==x['before'] and a<=x['col']<b:
                if best is None or e-s<best[1]: best=(callee,e-s,i)
    if not best: return None
    callee,_,i=best
    fd=find_def(callee.split('.')[-1])
    if not fd: return ('?',callee,i)
    f,params,body=fd
    names=[re.sub(r'^[+\-]','',p.split(':')[0].strip()) for p in split_args(params)]
    if i>=len(names): return ('?',callee,i)
    return ('read' if re.search(r'\b'+re.escape(names[i])+r'\b',body) else 'NEVER READ',callee,names[i])
def arg_index(line,x):
    best=None
    for callee,s,e,spans in calls(line):
        for i,(a,b) in enumerate(spans):
            if a<=x['col']<b and (best is None or e-s<best[3]): best=(callee,i,[line[p:q].strip() for p,q in spans],e-s)
    return best
def ev(v):
    return {'True{}':True,'False{}':False}.get(v,v)
def num(s):
    s=s.strip().rstrip('n'); return int(s) if s.isdigit() else None
def accepted(lo,hi,big,unit,n): return n>=lo and (big or n<=hi) and n%unit==0
def words_equiv(x,line):
    b=arg_index(line,x)
    if not b or b[0] not in('O.words_ok','words_ok'): return None
    _,i,args,_=b
    names=['o','lo','hi','big','unit']
    if i not in (1,2,4): return None
    o,lo,hi,big,unit=args; lo,hi,unit=num(lo),num(hi),num(unit); bigv=(big=='True{}')
    if None in (lo,hi,unit): return None
    new=int(x['after'].rstrip('n'))
    L,H,U=lo,hi,unit
    if i==4 and new<=0: return None
    if i==1: L=new
    if i==2: H=new
    if i==4: U=new
    # compare accepted sets over n in [0, hi+unit+2] (periodic beyond: bounds only matter near lo/hi; big => compare on a window and by period)
    lim=max(hi,lo)+2*max(unit,U)+8
    if lim>5_000_000:
        # large ranges: sets differ unless the changed value is inert; test near the bounds and one period
        pts=sorted(set([lo-1,lo,lo+1,hi-1,hi,hi+1,hi+2]+list(range(0,64))))
    else: pts=range(0,lim)
    same=all(accepted(lo,hi,bigv,unit,n)==accepted(L,H,bigv,U,n) for n in pts if n>=0)
    if same and i==4 and bigv: same = (unit==U)  # unbounded: periodic difference forever
    if same and i==4 and not bigv and (hi-lo)>unit*U and unit!=U: same=False
    if same: return ('words_ok: the accepted byte lengths {lo<=n<=hi, unit | n} are the same set (hi/lo/unit changed only where unit or big already decides)')
    return None
def bits_equiv(x,line):
    b=arg_index(line,x)
    if b and b[0] in('O.bits_ok','bits_ok') and b[1]==1 and b[2][2]=='True{}': return 'bits_ok: limit is only read under Bool.or(big, ..) and big is True{}'
def pk_equiv(x,line):
    if x['file'].endswith('FuluExecutionBranch_encode_ssz_generated.bend'): return None   # its flag is OR-ed into the length of the light-client serializers (docs/mutation_testing/EXCLUSION_AUDIT.md)
    if (x['def'] or '').endswith('pk_ok') and x['before']=='0' and x['after']=='1' and re.search(r'\(o, 0\)',line): return 'the flag is only read by O.is_poisoned(fl) = 2^31 <= fl: false for 0 and for 1'

def boolvec_equiv(x,line):
    """vec_bool_N decoders: ok_n(buf, off, n) is only called by ok_at with the literal N; ok_nz(empty, ...) only by ok_n."""
    if x['in']!='decode' or not re.search(r'_bool_ok_n(z)?$',x['def'] or ''): return None
    t=pathlib.Path(x['file']).read_text()
    m=re.search(r'_ok_n\(buf, off, (\d+)\)',t)
    if not m or len(re.findall(r'_ok_n\(buf',t))!=2: return None   # the def itself and the one call
    N=int(m.group(1))
    if x['operator']=='cmp' and 'is_eq(n, 0)' in line:   # is_eq -> is_lt: is_lt(N, 0) is False like is_eq(N, 0) for N >= 1
        return 'ok_n has one caller, ok_at, passing the literal n = %d: is_eq(%d, 0) and is_lt(%d, 0) both evaluate to False{}' % (N,N,N) if N>=1 else None
    if x['operator']=='const+1' and 'is_eq(n, 0)' in line:
        return ('ok_n has one caller passing the literal n = %d: is_eq(%d, 0) and is_eq(%d, 1) both evaluate to False{}' % (N,N,N)) if N not in (0,1) else None
    if x['operator']=='valid' and 'case True{}: (buf, True{})' in line:
        return 'the True{} branch of ok_nz is taken only when empty = is_eq(n, 0) with the literal n = %d != 0: it is never reached' % N if N>=1 else None

def le_eq_equiv(x, line):
    """is_eq(pos .&. 3, 0) -> is_le(...) at a `_pwd(` guard: U32.is_le(x, 0) = U32.is_eq(x, 0) for an unsigned x. The law
    le_eq of proofs/slop/alignment/writer_guard_library_generated.bend states it, and the facade imports that library (checked here)."""
    if x['operator'] != 'cmp' or x['before'] != 'U32.is_eq(' or x['after'] != 'U32.is_le(' or '_pwd(' not in line or '.&. 3' not in line:
        return None
    lib = pathlib.Path('proofs/slop/alignment/writer_guard_library_generated.bend')
    api = pathlib.Path(x['checked'])
    if not lib.exists() or not re.search(r'^def le_eq\b', lib.read_text(), re.M) or 'writer_guard_library' not in api.read_text():
        return None
    return 'U32.is_le(x, 0) = U32.is_eq(x, 0) for an unsigned x: law le_eq in proofs/slop/alignment/writer_guard_library_generated.bend, imported by the facade'


def in_signature(path, line, col):
    """True if the (1-based line, column) lies in the header of the def that contains it: the parameters and the result
    type (the statement) up to the `:` that opens the body. False: the mutation is inside the body (the proof term or
    the definition's value)."""
    text = pathlib.Path(path).read_text()
    lines = text.split('\n')
    i = line - 1
    while i >= 0 and not lines[i].startswith('def '):
        i -= 1
    if i < 0:
        return None
    start = sum(len(l) + 1 for l in lines[:i])
    pos = sum(len(l) + 1 for l in lines[:line - 1]) + col
    depth, j, seen_arrow = 0, start, False
    while j < len(text):
        c = text[j]
        if c in '([{<':
            depth += 1
        elif c in ')]}>':
            depth -= 1
        elif text.startswith('->', j) and depth == 0:
            seen_arrow = True
            j += 1   # the '>' of the arrow is not a bracket
        elif c == ':' and depth == 0 and seen_arrow:
            return pos < j
        elif c == ':' and depth == 0 and not seen_arrow and text[j + 1:j + 2] in ('\n', ' '):
            return pos < j
        j += 1
    return None


def lib_proof_body(x):
    """A mutation inside the body of a lemma of the proof libraries (proofs/obj, e2e): the statement (the def's result type)
    is unchanged, so the same statement is still proved, only by a different term. That is not a gap in what is proved."""
    f = x['file']
    if not (f.startswith('proofs/obj/') or f.startswith('e2e/')):
        return None
    sig = in_signature(f, x['line'], x['col'])
    if sig is False:
        return 'a mutation inside the proof term of a lemma: its statement is unchanged and still checks, so the same statement is proved by another term'
    return None


def proof_equiv(x):
    line=pathlib.Path(x['file']).read_text().split('\n')[x['line']-1]
    if x['operator'].startswith('const'):
        u=unread(x)
        if u and u[0]=='NEVER READ': return f'argument never read: {u[1]} ignores its parameter {u[2]}'
        r=pk_equiv(x,line) or bits_equiv(x,line) or words_equiv(x,line)
        if r: return r
    return boolvec_equiv(x,line) or le_eq_equiv(x,line)


def classify_survivor(x):
    r = proof_equiv(x)
    if r:
        return 'proof-equivalent', r
    if x['file'].endswith('FuluTransaction_encode_ssz_generated.bend') and x['before'] == '1073741824':
        return 'uncoverable', ('the bound 2^30 -> 2^30+1 differs only for an object of 2^30+1 bytes (Transaction): not constructible, '
                               'no law can be checked against it')
    return None, None


def main():
    files = [a for a in sys.argv[1:] if not a.startswith('--')]
    ents, rem = {}, {}
    for fn in files:
        for x in json.load(open(fn))['survivors']:
            ln = pathlib.Path(x['file']).read_text().split('\n')[x['line'] - 1]
            key = (x['file'], x['def'], x['operator'], x['before'], x['after'], x['text'], x['col'] - (len(ln) - len(ln.lstrip())))
            cls, reason = classify_survivor(x)
            if cls:
                ents[key] = {'file': key[0], 'def': key[1], 'operator': key[2], 'before': key[3], 'after': key[4],
                             'text': key[5], 'col': key[6], 'class': cls, 'reason': reason}
            else:
                rem[key] = x
    print(len(ents), 'excluded', dict(collections.Counter(e['class'] for e in ents.values())), '|', len(rem),
          'remaining', dict(collections.Counter(x['cause'] for x in rem.values())))
    if '--write' in sys.argv:
        out = {'note': 'mutations that are never drawn and never reported (rules and reasons: tests_generated/mutation_equivalence.py; one entry per site: file, def, operator, literal, line text, column)',
               'entries': sorted(ents.values(), key=lambda e: (e['class'], e['file'], e['text'], e['col']))}
        pathlib.Path('tests_generated/mutation_exclusions.json').write_text(json.dumps(out, indent=1) + '\n')
        pathlib.Path('/tmp/remaining.json').write_text(json.dumps(list(rem.values())))


if __name__ == '__main__':
    main()
