#!/usr/bin/env python3
"""Runtime differential for the words_ok rule of tools/mutation_testing/exclusion_audit.py (server only).

    python3 tools/mutation_testing/exclusion_audit_words.py cases                 -> /tmp/words_cases.json (every words_ok site of every entry, with the model's verdict)
    python3 tools/mutation_testing/exclusion_audit_words.py gen BATCH SIZE        -> a Bend program on stdout: main returns a bitmask, bit i set iff
                                                                    O.words_ok(original literals) and O.words_ok(mutated literals) disagree
                                                                    on some byte length n of a boundary set (an object Words{zeros(n+4), n})
Run: python3 tools/mutation_testing/exclusion_audit_words.py gen 0 25 > proofs/_audit_w0.bend; bend proofs/_audit_w0.bend; compare bit i with
case i's `model` (DIFFERS <-> bit set), then delete proofs/_audit_w*.bend. Result of the audit: 83 sites, model and runtime agree on all.
"""
import json, pathlib, sys
sys.path.insert(0, 'tools/mutation_testing')
import exclusion_audit as X


def cases_cmd():
    cases=[]
    for e in X.EXCL:
        if X.rule_of(e)!='words_ok': continue
        for (i,col) in X.entry_sites(e):
            line=pathlib.Path(e['file']).read_text().split('\n')[i]
            c=X.call_at(line,col)
            if not c or c[0]!='O.words_ok': continue
            args=[line[a:b].strip() for a,b in c[1]]
            idx=[k for k,(a,b) in enumerate(c[1]) if a<=col<b][0]
            lo,hi,unit=int(args[1]),int(args[2]),int(args[4]); big=args[3]=='True{}'
            new=[lo,hi,unit]; new[{1:0,2:1,4:2}[idx]]=int(e['after'])
            cases.append(dict(file=e['file'],line=i+1,idx=idx,lo=lo,hi=hi,big=big,unit=unit,new=new,
                              model=X.check_words(e,i,col)[0]))
    json.dump(cases,open('/tmp/words_cases.json','w'))
    print(len(cases))


def gen_cmd(B, K):
    cases = json.load(open('/tmp/words_cases.json'))
    def ns(c):
        s=set(range(0,40))
        for v in (c['lo'],c['hi'],c['unit'],c['new'][0],c['new'][1],c['new'][2]):
            for d in range(-3,4): s.add(v+d)
            for d in range(-3,4): s.add(2*v+d)
        for k in range(1,6):
            for d in (-1,0,1): s.add(k*c['unit']+d)
        s.add(c['hi']+c['unit']); s.add(c['hi']+2*c['unit']+1)
        return sorted(x for x in s if 0<=x<=70000)
    batch=cases[B*K:(B+1)*K]
    out=['import Base','import ../src/obj.bend as O','import ../src/buffer.bend as B','','def mk(+n: U32) -> O.Words: O.Words{B.zeros_bytes((n + 4 : U32)), n}','def snd(p: O.Words & Bool) -> Bool:','  (o, b) = p','  b','',
    'def okw(+lo: U32, +hi: U32, big: Bool, +unit: U32, +n: U32) -> Bool:',
    '  snd(O.words_ok(mk(n), lo, hi, big, unit))','',
    'def dif(+lo: U32, +hi: U32, big: Bool, +unit: U32, big2: Bool, +lo2: U32, +hi2: U32, +unit2: U32, +n: U32) -> U32:',
    '  O.pick(U32.is_eq(O.pick(okw(lo, hi, big, unit, n), 1, 0), O.pick(okw(lo2, hi2, big2, unit2, n), 1, 0)), 0, 1)','']
    tot=[]
    for i,c in enumerate(batch):
        b='True{}' if c['big'] else 'False{}'
        body=' + '.join('dif(%d, %d, %s, %d, %s, %d, %d, %d, %d)'%(c['lo'],c['hi'],b,c['unit'],b,*c['new'],n) for n in ns(c))
        # sum in chunks to keep expressions shallow
        out.append('def c%d() -> U32: (%s : U32)'%(i,body.replace(' + ',' + ')))
        tot.append('O.pick(U32.is_lt(0, c%d()), %d, 0)'%(i,1<<i))
    out.append('')
    out.append('def main() -> U32: ('+' + '.join(tot)+' : U32)')
    print('\n'.join(out))
    json.dump(batch,open('/tmp/words_batch%d.json'%B,'w'))


if __name__ == '__main__':
    if sys.argv[1] == 'cases': cases_cmd()
    else: gen_cmd(int(sys.argv[2]), int(sys.argv[3]))
