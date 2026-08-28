extension Pair: Equation::Equation.`Protocol`
where
    First: Equation::Equation.`Protocol` & ~Copyable,
    Second: Equation::Equation.`Protocol` & ~Copyable
{

    @inlinable
    @_disfavoredOverload
    public static func == (lhs: borrowing Pair, rhs: borrowing Pair) -> Bool {
        lhs.first == rhs.first && lhs.second == rhs.second
    }
}
