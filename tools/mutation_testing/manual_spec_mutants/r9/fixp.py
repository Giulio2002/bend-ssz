# fixp.py PATCH...: regenerate a mk8 patch whose hunk touches the file's last line (difflib's trailing '' context breaks patch(1)) with diff -u
import sys, subprocess, os, tempfile
for p in sys.argv[1:]:
    L = open(p).read().split('\n')
    hdr = [l for l in L if l.startswith('# ')]
    f = [l for l in hdr if l.startswith('# file: ')][0][8:]
    old = [l[1:] for l in L if l.startswith('-') and not l.startswith('---')]
    new = [l[1:] for l in L if l.startswith('+') and not l.startswith('+++')]
    t = open(f).read()
    o, n = '\n'.join(old), '\n'.join(new)
    assert t.count(o) == 1, (p, t.count(o))
    tmp = tempfile.mktemp()
    open(tmp, 'w').write(t.replace(o, n))
    d = subprocess.run(['diff', '-u', '--label', 'a/' + f, '--label', 'b/' + f, f, tmp], capture_output=True, text=True).stdout
    os.unlink(tmp)
    open(p, 'w').write('\n'.join(hdr) + '\n' + d)
    print('fixed', p)
