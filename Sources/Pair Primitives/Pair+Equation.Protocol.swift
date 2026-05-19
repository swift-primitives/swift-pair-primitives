// Equation.Protocol+Pair.swift
// Conformance of Pair to Equation.Protocol — unconditional.
//
// On Swift <6.4, `Equation.Protocol` is the institute fork supporting
// `borrowing` parameters for `~Copyable` arms. On Swift 6.4+, it is a
// typealias to `Swift.Equatable` per SE-0499 — this same extension then
// satisfies the stdlib conformance for arms (Copyable or `~Copyable`)
// that conform to Equation.Protocol. The stdlib `extension Pair:
// Equatable where First: Equatable, Second: Equatable {}` in `Pair.swift`
// is therefore guarded `#if swift(<6.4)` to avoid duplicate-conformance.

#if swift(<6.4)
extension Pair: Equation.`Protocol`
where
    First: Equation.`Protocol` & ~Copyable & ~Escapable,
    Second: Equation.`Protocol` & ~Copyable & ~Escapable
{
    /// Returns whether two pairs are equal componentwise.
    @inlinable
    @_disfavoredOverload
    public static func == (lhs: borrowing Pair, rhs: borrowing Pair) -> Bool {
        lhs.first == rhs.first && lhs.second == rhs.second
    }
}
#else
// Swift 6.4+: Equation.Protocol = Swift.Equatable. Stdlib Equatable
// requires Escapable, so drop the ~Escapable arm.
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
#endif
