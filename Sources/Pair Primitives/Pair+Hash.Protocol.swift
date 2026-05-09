// Hash.Protocol+Pair.swift
// Conformance of Pair to Hash.Protocol — unconditional.
//
// On Swift <6.4, `Hash.Protocol` is the institute fork supporting
// `borrowing self` for `~Copyable` arms. On Swift 6.4+, it is a typealias
// to `Swift.Hashable` per SE-0499 — this same extension then satisfies
// the stdlib conformance for arms (Copyable or `~Copyable`) that conform
// to Hash.Protocol. The stdlib `extension Pair: Hashable where First:
// Hashable, Second: Hashable {}` in `Pair.swift` is therefore guarded
// `#if swift(<6.4)` to avoid duplicate-conformance.

extension Pair: Hash.`Protocol`
where
    First: Hash.`Protocol` & ~Copyable & ~Escapable,
    Second: Hash.`Protocol` & ~Copyable & ~Escapable
{
    /// Hashes both components into the given hasher in order.
    @inlinable
    @_disfavoredOverload
    public borrowing func hash(into hasher: inout Hasher) {
        first.hash(into: &hasher)
        second.hash(into: &hasher)
    }
}
