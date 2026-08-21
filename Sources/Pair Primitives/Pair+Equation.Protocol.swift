extension Pair: Equation.`Protocol`
where
    First: Equation.`Protocol` & ~Copyable,
    Second: Equation.`Protocol` & ~Copyable
{

    @inlinable
    @_disfavoredOverload
    public static func == (lhs: borrowing Pair, rhs: borrowing Pair) -> Bool {
        lhs.first == rhs.first && lhs.second == rhs.second
    }
}
