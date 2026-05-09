# ``Pair_Primitives``

@Metadata {
    @DisplayName("Pair Primitives")
    @TitleHeading("Swift Institute — Primitives Layer")
}

The binary cartesian product type for typed two-component values.

## Overview

`Pair Primitives` ships ``Pair_Primitives/Pair``, a generic struct
representing the categorical product `First × Second` — two values
held together as one. `Pair` is `~Copyable`-aware: when both components
are `~Copyable`, the pair itself is `~Copyable`, enabling resource-pair
patterns (read/write descriptors, owner/borrow handles) without copying.

When both components are `Copyable`, `Pair` is `Copyable` and gains
ergonomic instance conveniences (overloaded `map(first:)` /
`map(second:)` / `map(first:second:)`, plus `swapped` and tuple
conversion). The static implementations that drive these conveniences
are also available directly for `~Copyable` element use.

`Pair` is conditionally `Sendable`, `Equatable`, `Hashable`, `Comparable`,
and `Codable` based on its components, with `swapped` returning the
components in exchanged order and `apply` folding both components into
a single result.

For `~Copyable` components, equality / hashing / ordering flow through
the institute `borrowing`-parameter forks `Equation.Protocol`,
`Hash.Protocol`, and `Comparison.Protocol`. On Swift 6.4+ each fork is a
typealias to its stdlib counterpart per SE-0499, so the same conformances
cover both the `~Copyable` and stdlib paths.

`Comparable` orders `Pair` lexicographically over `(first, second)`.

## Lifecycle: movement, not management

`Pair` is a *movement vehicle* — it transports two values as one unit. It
does NOT close, unlock, or otherwise act on its components on drop. A
`Pair(readDescriptor, writeDescriptor)` does not close the descriptors when
the pair is destroyed; lifecycle decisions belong to the consumer, typically
via `apply`. Resource-bearing types belong in resource-owning packages where
`~Copyable` + `deinit` is the active pattern.

## ~Escapable arm support

Both arms may be `~Copyable` and `~Escapable`. Non-closure operations —
construction, ``Pair_Primitives/Pair/swapped()``, ``Pair_Primitives/Pair/apply(_:)``,
and the institute-protocol conformances (`Equation.Protocol`, `Hash.Protocol`,
`Comparison.Protocol`) — admit `~Escapable` arms today. Closure-bearing
methods (`map(first:)`, `map(second:)`, `map(first:second:)`) admit
`~Escapable` on the un-transformed arm only; both arms `~Escapable` through
a closure is currently blocked by Swift's lifetime-from-closure-result
limitation.

## Topics

### The Product

- ``Pair_Primitives/Pair``
