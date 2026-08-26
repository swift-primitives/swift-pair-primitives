extension Pair: Comparison.`Protocol`
where
    First: Comparison.`Protocol` & ~Copyable,
    Second: Comparison.`Protocol` & ~Copyable
{

    @inlinable
    @_disfavoredOverload
    public static func < (lhs: borrowing Pair, rhs: borrowing Pair) -> Bool {
        if lhs.first < rhs.first { return true }
        if rhs.first < lhs.first { return false }
        return lhs.second < rhs.second
    }
}
