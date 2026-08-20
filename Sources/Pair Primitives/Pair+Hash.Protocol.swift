// Hash.Protocol+Pair.swift
// Conformance of Pair to Hash.Protocol — unconditional.
//
// `Hash.Protocol` refines `Swift.Hashable` and adds a typed hash value.

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
