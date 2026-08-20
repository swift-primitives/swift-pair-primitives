// Equation.Protocol+Pair.swift
// Conformance of Pair to Equation.Protocol — unconditional.
//
// `Equation.Protocol` aliases `Swift.Equatable`, so this extension also
// supplies the standard-library conformance.

extension Pair: Equation.`Protocol`
where
    First: Equation.`Protocol` & ~Copyable,
    Second: Equation.`Protocol` & ~Copyable
{
    /// Returns whether two pairs are equal componentwise.
    @inlinable
    @_disfavoredOverload
    public static func == (lhs: borrowing Pair, rhs: borrowing Pair) -> Bool {
        lhs.first == rhs.first && lhs.second == rhs.second
    }
}
