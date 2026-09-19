"""Content-addressed SSZ reports; never overwrite a historical archive."""
import hashlib
import json
from pathlib import Path


def sha256_file(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def preserve_report(report, destination):
    destination=Path(destination)
    payload=(json.dumps(report,indent=2)+'\n').encode()
    digest=hashlib.sha256(payload).hexdigest()
    archive=destination.parent/'reports'/(digest+'.json')
    archive.parent.mkdir(parents=True,exist_ok=True)
    try:
        with archive.open('xb') as stream: stream.write(payload)
    except FileExistsError:
        if archive.read_bytes()!=payload:
            raise RuntimeError('immutable report archive content mismatch')
    destination.write_bytes(payload)
    destination.with_suffix(destination.suffix+'.provenance.json').write_text(
        json.dumps({'sha256':digest,'archive':str(archive.resolve()),
                    'run_id':report['evidence']['run_id']},indent=2)+'\n')
    return archive
