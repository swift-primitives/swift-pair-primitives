# Pair Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

`Pair<First, Second>` — a generic struct representing the binary cartesian product, two values held together as one. `~Copyable`-aware: when both components are `~Copyable`, the pair itself is `~Copyable`, enabling resource-pair patterns (read/write descriptors, owner/borrow handles) without copying.

Conditionally `Sendable` / `Equatable` / `Hashable` / `Comparable` / `Codable` based on its components, with overloaded `map(first:)` / `map(second:)` / `map(first:second:)` plus `swapped` / `apply` for compositional transformation. `Comparable` is lexicographic over `(first, second)`. Tuple conversion is available for the `Copyable` tier.

For `~Copyable` components, conformance flows through [`Equation.Protocol`](https://github.com/swift-primitives/swift-equation-primitives) / [`Hash.Protocol`](https://github.com/swift-primitives/swift-hash-primitives) / [`Comparison.Protocol`](https://github.com/swift-primitives/swift-comparison-primitives) — the `borrowing`-parameter forks that admit move-only conformers on Swift 6.3. On Swift 6.4 and later (where SE-0499 lands), each `*.Protocol` is a typealias to its stdlib counterpart, so the same conformances cover both the `~Copyable` and stdlib paths uniformly.

---

## Quick Start

`Pair` works with both `Copyable` and `~Copyable` element types:

```swift
import Pair_Primitives

let point = Pair(3, 4)
print(point.first)   // 3
print(point.second)  // 4

let scaled = point.map(second: { $0 * 2 })   // Pair(3, 8)
let flipped = point.swapped()                // Pair(4, 3)
```

The `~Copyable` tier preserves move-only semantics for paired values. The
pair transports the two values as one unit; it does not close, unlock, or
otherwise act on them on drop. Lifecycle decisions belong to the consumer,
typically via `apply`:

```swift
struct Descriptor: ~Copyable { let raw: Int32 }

let pipe = Pair(Descriptor(raw: 3), Descriptor(raw: 4))
let result = pipe.apply { read, write in
    close(write.raw)        // consumer chooses what to close
    return read.raw
}   // pair consumed; single value returned
```

Both arms may be `~Copyable` and `~Escapable`. Non-closure operations —
construction, `swapped`, `apply`, institute-protocol conformances
(`Equation.Protocol` / `Hash.Protocol` / `Comparison.Protocol`) — admit
`~Escapable` arms today. Closure-bearing methods (`map(first:)` /
`map(second:)` / `map(first:second:)`) admit `~Escapable` on the
un-transformed arm only; both arms `~Escapable` through a closure is
currently blocked by Swift's lifetime-from-closure-result limitation.

`map(first:second:)` transforms both components independently:

```swift
let labelled = Pair(7, "answer")
let widened = labelled.map(
    first:  { Double($0) },
    second: { $0.uppercased() }
)   // Pair(7.0, "ANSWER")
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-pair-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Pair Primitives", package: "swift-pair-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain).

---

## Architecture

One library product. Three sibling-primitive dependencies for `~Copyable`-aware equality / hashing / ordering.

| Product | Target | Contents |
|---------|--------|----------|
| `Pair Primitives` | `Sources/Pair Primitives/` | `Pair<First, Second>` (conditionally `~Copyable`) + overloaded `map(first:)` / `map(second:)` / `map(first:second:)` + `swapped` + `apply` + tuple conversion. Conditionally `Equatable` / `Hashable` / `Comparable` / `Codable` (stdlib) and `Equation.Protocol` / `Hash.Protocol` / `Comparison.Protocol` (forks for ~Copyable on Swift 6.3). |

Dependencies (re-exported via `@_exported public import` so consumers don't need to add them):
- [`swift-equation-primitives`](https://github.com/swift-primitives/swift-equation-primitives)
- [`swift-hash-primitives`](https://github.com/swift-primitives/swift-hash-primitives)
- [`swift-comparison-primitives`](https://github.com/swift-primitives/swift-comparison-primitives)

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |
| Swift Embedded | Supported (Codable conformance gated behind `#if !hasFeature(Embedded)`) |

---

## Community

<!-- BEGIN: discussion -->
Discuss this package: [swift-institute/discussions/21](https://github.com/orgs/swift-institute/discussions/21)
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
