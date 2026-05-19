// Comparison.Protocol+Pair.swift
// Conformance of Pair to Comparison.Protocol — unconditional.
//
// On Swift <6.4, `Comparison.Protocol` is the institute fork supporting
// `borrowing` parameters for `~Copyable` arms. On Swift 6.4+, it is a
// typealias to `Swift.Comparable` per SE-0499 — this same extension then
// satisfies the stdlib conformance. The stdlib `extension Pair: Comparable
// where First: Comparable, Second: Comparable { ... }` in `Pair.swift` is
// therefore guarded `#if swift(<6.4)` to avoid duplicate-conformance.
//
// Lexicographic ordering: compare first components, then second on tie.

#if swift(<6.4)
extension Pair: Comparison.`Protocol`
where
    First: Comparison.`Protocol` & ~Copyable & ~Escapable,
    Second: Comparison.`Protocol` & ~Copyable & ~Escapable
{
    /// Lexicographic ordering: compare first components, then second on tie.
    @inlinable
    @_disfavoredOverload
    public static func < (lhs: borrowing Pair, rhs: borrowing Pair) -> Bool {
        if lhs.first < rhs.first { return true }
        if rhs.first < lhs.first { return false }
        return lhs.second < rhs.second
    }
}
#else
// Swift 6.4+: Comparison.Protocol = Swift.Comparable. Drops ~Escapable arm.
extension Pair: Comparison.`Protocol`
where
    First: Comparison.`Protocol` & ~Copyable,
    Second: Comparison.`Protocol` & ~Copyable
{
    /// Lexicographic ordering: compare first components, then second on tie.
    @inlinable
    @_disfavoredOverload
    public static func < (lhs: borrowing Pair, rhs: borrowing Pair) -> Bool {
        if lhs.first < rhs.first { return true }
        if rhs.first < lhs.first { return false }
        return lhs.second < rhs.second
    }
}
#endif
