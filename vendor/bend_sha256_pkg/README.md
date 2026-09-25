# bend_sha256_pkg

A copy of the BendHub package `0xda83506fb9f059ead7afcfa2f498df5f`
(Giulio2002/bend-sha256), taken from `~/.bend/lib/`, where `bend` verified it
against that hash when it fetched it.

It is vendored because a hub package cannot change, and Bend 2.0.26 and later
refuse its `type Window`: Base declares `Window` (upstream #1042). The one
change from the package is that rename, in `core.bend`, `core_model.bend` and
`conformance.bend`: `Window` is `ShaWindow`. Everything else is byte-for-byte
the package.
