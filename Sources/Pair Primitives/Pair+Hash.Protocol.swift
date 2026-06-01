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

#if swift(<6.4)
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
#else
// Under Swift 6.4+, `Hash.Protocol` REFINES `Swift.Hashable` (re-declaring a typed
// `hashValue: Hash.Value`). A conditional conformance to `Hash.Protocol` must
// therefore explicitly declare the inherited `Swift.Hashable` conformance — Swift does
// not synthesize it for conditional conformers. The typed `hashValue` is defaulted in
// hash-primitives; `Equatable` comes from Pair's `Equation.Protocol` conformance (still
// a `Swift.Equatable` typealias). See Research/se-0499-…md Addendum (2026-06-01).
extension Pair: Swift.Hashable
where
    First: Hash.`Protocol` & ~Copyable,
    Second: Hash.`Protocol` & ~Copyable
{
    /// Hashes both components into the given hasher in order.
    @inlinable
    @_disfavoredOverload
    public borrowing func hash(into hasher: inout Hasher) {
        first.hash(into: &hasher)
        second.hash(into: &hasher)
    }
}

extension Pair: Hash.`Protocol`
where
    First: Hash.`Protocol` & ~Copyable,
    Second: Hash.`Protocol` & ~Copyable
{}
#endif
