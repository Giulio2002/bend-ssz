# Toolchain: stock Bend 2.0.25 (operator-authorized migration, 2026-09-22)

## What happened

* Until 2026-09-22 the project was pinned to Bend 2.0.16 (`automation/toolchain.json`).
* On 2026-09-22 around 21:12 local, `bend update` replaced `~/.bend/bin/bend` and
  `~/.bend/bend2/` in place with upstream 2.0.25; the installer kept the old
  binary as `~/.bend/bin/bend-2.0.16` and the old Base tree as
  `~/.bend/bend2-2.0.16-backup.tgz`. Nothing in this workspace ran the update.
* The iteration-20 worker noticed the hash mismatch while checking proofs, backed
  up the 2.0.25 files unchanged to `~/.bend/bend-2.0.25-backup/` and restored
  2.0.16. It also added a hash guard to `benchmarks/checks/check_proof.py`.
* The USER TOOLCHAIN OVERRIDE of 2026-09-22 then made stock upstream 2.0.25 the
  required toolchain. The backed-up 2.0.25 binary and Base were reinstated
  byte-for-byte at the default paths. Neither compiler nor Base was modified.

## Pinned identity (verified after reinstatement)

| file | sha256 |
| --- | --- |
| `~/.bend/bin/bend` (`bend version` prints `bend 2.0.25`) | `3850c7cd281a687715a181ad6a2ecdef041704f320ea2b4304cf9e802309203c` |
| `~/.bend/bend2/base.bend` | `e5639663177f2de93ef34867c029698aa4e68a98d46629f0b15452b67b99d798` |

Provenance limit: these are the files the official `bend update` installer
(curl | sh from upstream) wrote. No independent upstream checksum was available
offline to compare them against; the evidence is the installer path and that the
files were never edited afterwards (backup and reinstated copies hash equal).

The editable pin is `benchmarks/toolchain.json`; `benchmarks/checks/check_proof.py`,
`tools/run_runtime_tests.py`, `tools/spectests.py`, `tools/bend_loader.ts` and
`tests_generated/fuzz_objects.py` read it and refuse to run on a mismatch.
`benchmarks/quick.py` keys its program cache on the compiler binary AND Base, so
every 2.0.16-built program is rebuilt. `benchmarks/run.py` records the version
from `bend version` (2.0.25 no longer accepts `--version`).

## Needed from the operator (protected files, hash-only update)

`automation/acceptance.py` (called by the native-memory gate) compares
`~/.bend/bin/bend` and Base against `automation/toolchain.json` and exits with
"Pinned 2.0.16 toolchain identity changed" otherwise. The minimal update is to
`automation/toolchain.json` only:

```json
{
  "bend": {"path": "/Users/monkeair/.bend/bin/bend",
           "sha256": "3850c7cd281a687715a181ad6a2ecdef041704f320ea2b4304cf9e802309203c"},
  "base": {"path": "/Users/monkeair/.bend/bend2/base.bend",
           "sha256": "e5639663177f2de93ef34867c029698aa4e68a98d46629f0b15452b67b99d798"},
  "version": "2.0.25"
}
```

The error string in `automation/acceptance.py` still says "2.0.16"; that is text
only and does not affect the check. No gate check needs to be removed.

## Consequences

All evidence produced before the reinstatement (proof logs, native programs,
spectest/fuzz/gate reports) is 2.0.16 evidence and is historical for 2.0.25.
