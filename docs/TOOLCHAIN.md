# Toolchain: stock Bend 2.0.28 (updated 2026-09-25)

## Update to 2.0.28 (2026-09-25)

`benchmarks/toolchain.json` pins the official 2.0.28 release: Linux x86_64
binary `871df0ae7b0895236e14a5c2dac4fa014fbe770c3470ee3f60f6dcfe8ae4cfcf`
(from `bend-2.0.28-linux-x64.tar.gz`), macOS arm64 binary
`8ff8223fa61c04400ed2359ad013eacaa6f760e42ed248ce96f6bb844a1a9147`, and
`base.bend` `22eea83911e2395f63594fea7c10ac0c1e5b548251681fc97cd7667e0eb7031b`
(the same bytes on every platform).

2.0.26-2.0.28 refuse a declared name that collides with Base and an import
alias used twice in one file (upstream #1042). The sources change only as
needed for that, with no statement or algorithm changed:

* SHA-256 comes from the bend-collections library, BendHub package
  `0xe4067e0d858024083f36a7abe7281e89` (list API `src/crypto/sha/`, packed API
  `src/crypto/sha/packed/`, FIPS spec `spec/crypto/sha.bend`, laws in
  `proofs/crypto/sha/`), which runs on 2.0.28. It replaces `vendor/bend_sha256`
  and the BendHub package `0xda83506fb9f059ead7afcfa2f498df5f`, whose `type
  Window` 2.0.26+ refuse (Base declares `Window`); the code and laws are the
  same, with that type renamed `ShaWindow`.
* `proofs/root_complete.bend`: a repeated `import ./root_domain_steps.bend as
  Steps` line is removed.

The 2.0.25 notes below are historical.

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
| Linux x86_64 host (2026-09-24): `~/.bend/bin/bend` -> `/srv/ssz-optimization/toolchain/bend/bin/bend` (`bend version` prints `bend 2.0.25`) | `d9c0dad1f77be6a13dd8dcc16aef4f59047a956a2744f25d5c220cb8de384693` |
| Linux x86_64 host: `~/.bend/bend2/base.bend` (same bytes as on the Mac) | `e5639663177f2de93ef34867c029698aa4e68a98d46629f0b15452b67b99d798` |

`benchmarks/toolchain.json` pins the Linux binary hash on this host (only the
platform binary differs; Base is byte-identical).

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
"Pinned 2.0.16 toolchain identity changed" otherwise (re-observed on the Linux
host on 2026-09-24). The minimal update is to `automation/toolchain.json` only
(shown with the Mac binary hash; on the Linux host the bend sha256 is
`d9c0dad1f77be6a13dd8dcc16aef4f59047a956a2744f25d5c220cb8de384693`):

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

## Linux host (2026-09-24): C compiler for Bend's native backend

The pinned Bend 2.0.25 builds binaries only with clang >= 14 (it probes `$CC`,
`clang`, `clang-<n>`; gcc is refused). The migrated Linux x86_64 host had the
LLVM 21 runtime libraries (`libllvm21`, `libclang-cpp21`) but no clang driver.
Nothing system-wide was installed: the Ubuntu packages of the same LLVM release
were downloaded with `apt-get download` and unpacked with `dpkg-deb -x` into the
SSZ-private directory `/srv/ssz-optimization/toolchain/clang21`:

| package | sha256 |
| --- | --- |
| clang-21_1:21.1.8-6ubuntu1_amd64.deb | 792701d9c82e5f237879cc0bda552d8a127ea24b0c7d520e815aff14bd314b03 |
| libclang-common-21-dev_1:21.1.8-6ubuntu1_amd64.deb | c7188f593d77017a4ebb6fea76bb4b5180a3e5a1e7b9f0e3dbd5f5abf7e7183e |
| llvm-21-linker-tools_1:21.1.8-6ubuntu1_amd64.deb | 51e9cecdb44252d9fed8209ce8d3194455210905068fbbf7c08dd016e3ed4b8f |

Native builds on this host run with
`CC=/srv/ssz-optimization/toolchain/clang21/usr/lib/llvm-21/bin/clang-21`
(Ubuntu clang 21.1.8). The Bend compiler, Base and the emitted C are unchanged;
Mac measurements used Apple clang and are historical, not Linux evidence.
The frozen gates (`automation/*`) do not set `CC`; they must be launched with
it exported (or with a clang on PATH) on this host. The gate interpreters
`/Users/monkeair/work/fulu-bend/.venv/bin/python` and
`/Users/monkeair/auto-implementer/.venv/bin/python` currently lack `psutil`
and `snappy`, which native_bench/run.py and tools/spectests.py import; the
Linux `/srv/ssz-optimization/venv` has them. That is an operator environment
item, not a source change.
