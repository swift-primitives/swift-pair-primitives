extension Pair: Swift.Hashable
where
    First: Hash::Hash.`Protocol` & ~Copyable,
    Second: Hash::Hash.`Protocol` & ~Copyable
{

    @inlinable
    @_disfavoredOverload
    public borrowing func hash(into hasher: inout Hasher) {
        first.hash(into: &hasher)
        second.hash(into: &hasher)
    }
}

extension Pair: Hash::Hash.`Protocol`
where
    First: Hash::Hash.`Protocol` & ~Copyable,
    Second: Hash::Hash.`Protocol` & ~Copyable
{}
