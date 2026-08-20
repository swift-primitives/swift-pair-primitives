// Comparison.Protocol+Pair.swift
// Conformance of Pair to Comparison.Protocol — unconditional.
//
// `Comparison.Protocol` aliases `Swift.Comparable`, so this extension also
// supplies the standard-library conformance.
//
// Lexicographic ordering: compare first components, then second on tie.

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
