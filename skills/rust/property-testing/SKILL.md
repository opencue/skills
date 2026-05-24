---
name: property-testing
description: Use when testing parsers, serializers, math/algorithms, anything with invariants — generate thousands of inputs and check properties hold. Covers proptest and quickcheck.
allowed-tools: Bash(cargo:*)
---

# proptest / quickcheck — property-based testing

Instead of "for these 3 inputs, output is X", you state "for ALL inputs, this property holds" and the framework hunts counter-examples.

## When to use
- **Setup proptest**: dev-dep `proptest`; test wrapper:
  ```rust
  use proptest::prelude::*;
  proptest! {
      #[test]
      fn roundtrip(s in "\\PC*") {
          let parsed: MyStruct = s.parse().unwrap();
          prop_assert_eq!(parsed.to_string(), s);
      }
  }
  ```
- **Common strategies**: `any::<u32>()`, `0..1000usize`, `prop::collection::vec(any::<u8>(), 0..100)`, regex strings `"\\PC*"`
- **Shrinking**: framework auto-shrinks failing inputs to a minimal counter-example (proptest's killer feature)
- **Persistent failures**: `proptest-regressions/*.txt` files lock in past failures — commit them
- **Quickcheck alternative**: simpler API, no shrinking config — `#[quickcheck] fn p(xs: Vec<i32>) -> bool { ... }`

## Prerequisites
- cargo
- dev-dep: `proptest` or `quickcheck` + `quickcheck_macros`

## Notes
- Property tests pair perfectly with `serde` roundtrip (serialize → deserialize → equal?), parsers (parse → display → reparse → equal?), and algorithmic invariants (sort → is sorted, original len, same multiset).
- Slow (~100ms+ per case × 256 cases). Don't put property tests in tight inner-loop CI; mark with `#[ignore]` and run separately if they get heavy.
- proptest's regression files are gold — they replay yesterday's bug for free.
