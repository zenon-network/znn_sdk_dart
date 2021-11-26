# ZNN PoW links package

ZNN PoW links package implements FFI (Foreign Function Interface) wrappers for native C code in order to improve performance.

These wrappers export 2 calls:

- `generatePoW(hash, difficulty)` selects a random `nonce` until it finds one which satisfies the `difficulty`
  parameter.
- `benchmarkPoW(difficulty)` tries `nonce` in increasing order, in a deterministic way, so it can be used to benchmark
  PoW generation on various systems.

At the moment Zenon Dart SDK only supports statically built libraries which are provided with this SDK in the `blobs/`
subfolder.
