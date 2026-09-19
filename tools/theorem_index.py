import os,re,sys
out=[]
for f in sorted(os.listdir('proofs')):
    p='proofs/'+f
    if os.path.getsize(p)>150000: 
        out.append(f"=== {f} (large, {os.path.getsize(p)} bytes)"); 
        laws=re.findall(r'^law (\w+):',open(p).read(),re.M)
        out.append("  laws: "+", ".join(laws[:40])+(" ..." if len(laws)>40 else ""))
        continue
    out.append("=== "+f)
    lines=open(p).read().split('\n')
    i=0
    while i<len(lines):
        if lines[i].startswith('law '):
            st=[lines[i]]
            i+=1
            while i<len(lines) and lines[i].startswith('  '):
                st.append(lines[i].strip()); i+=1
            out.append(' '.join(st))
        else: i+=1
open('build/theorem_index.txt','w').write('\n'.join(out))
