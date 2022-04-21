# PoW package

PoW package implements FFI wrappers for native C code in order to improve performance.

These wrappers export 2 calls:

- `generatePoW(hash, difficulty)` selects random `nonce` until it finds one which satisfies the `difficulty`
  parameter.
- `benchmarkPoW(difficulty)` tries `nonce` in increasing order, in a deterministic way, so it can be used to benchmark
  PoW generation on various systems.

At the moment ZNN Dart SDK only supports statically built libraries which are provided with this SDK in the `blobs/`
subfolder.

In the future we plan to open-source the codebase & documentation for these libraries so that developers and users alike
can build these libraries, without the need to trust the provided libraries.
