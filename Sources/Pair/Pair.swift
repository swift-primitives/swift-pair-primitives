@_exported public import Comparison_Protocol
@_exported public import Equation_Protocol
@_exported public import Hash_Protocol

@frozen
public struct Pair<First: ~Copyable & ~Escapable, Second: ~Copyable & ~Escapable>: ~Copyable,
    ~Escapable
{

    public var first: First

    public var second: Second

    @inlinable
    @_lifetime(copy first, copy second)
    public init(_ first: consuming First, _ second: consuming Second) {
        self.first = first
        self.second = second
    }
}

extension Pair: Copyable where First: Copyable & ~Escapable, Second: Copyable & ~Escapable {}
extension Pair: Escapable where First: Escapable & ~Copyable, Second: Escapable & ~Copyable {}
extension Pair: Sendable
where First: Sendable & ~Copyable & ~Escapable, Second: Sendable & ~Copyable & ~Escapable {}

#if !hasFeature(Embedded)
    extension Pair: Codable where First: Codable, Second: Codable {}
#endif

extension Pair where First: ~Copyable, Second: ~Copyable & ~Escapable {

    @inlinable
    @_lifetime(copy pair)
    public static func map<NewFirst: ~Copyable, E: Swift.Error>(
        _ pair: consuming Pair,
        first transform: (consuming First) throws(E) -> NewFirst
    ) throws(E) -> Pair<NewFirst, Second> {
        Pair<NewFirst, Second>(try transform(pair.first), pair.second)
    }
}

extension Pair where First: ~Copyable & ~Escapable, Second: ~Copyable {

    @inlinable
    @_lifetime(copy pair)
    public static func map<NewSecond: ~Copyable, E: Swift.Error>(
        _ pair: consuming Pair,
        second transform: (consuming Second) throws(E) -> NewSecond
    ) throws(E) -> Pair<First, NewSecond> {
        Pair<First, NewSecond>(pair.first, try transform(pair.second))
    }
}

extension Pair where First: ~Copyable, Second: ~Copyable {

    @inlinable
    public static func map<
        NewFirst: ~Copyable,
        NewSecond: ~Copyable,
        E: Swift.Error
    >(
        _ pair: consuming Pair,
        first firstTransform: (consuming First) throws(E) -> NewFirst,
        second secondTransform: (consuming Second) throws(E) -> NewSecond
    ) throws(E) -> Pair<NewFirst, NewSecond> {
        Pair<NewFirst, NewSecond>(
            try firstTransform(pair.first),
            try secondTransform(pair.second)
        )
    }
}

extension Pair where First: ~Copyable & ~Escapable, Second: ~Copyable & ~Escapable {

    @inlinable
    public static func apply<R: ~Copyable, E: Swift.Error>(
        _ pair: consuming Pair,
        _ body: (consuming First, consuming Second) throws(E) -> R
    ) throws(E) -> R {
        try body(pair.first, pair.second)
    }

    @inlinable
    @_lifetime(copy pair)
    public static func swapped(_ pair: consuming Pair) -> Pair<Second, First> {
        Pair<Second, First>(pair.second, pair.first)
    }
}

extension Pair where First: ~Copyable, Second: ~Copyable & ~Escapable {

    @inlinable
    @_lifetime(copy self)
    public consuming func map<NewFirst: ~Copyable, E: Swift.Error>(
        first transform: (consuming First) throws(E) -> NewFirst
    ) throws(E) -> Pair<NewFirst, Second> {
        try Self.map(self, first: transform)
    }
}

extension Pair where First: ~Copyable & ~Escapable, Second: ~Copyable {

    @inlinable
    @_lifetime(copy self)
    public consuming func map<NewSecond: ~Copyable, E: Swift.Error>(
        second transform: (consuming Second) throws(E) -> NewSecond
    ) throws(E) -> Pair<First, NewSecond> {
        try Self.map(self, second: transform)
    }
}

extension Pair where First: ~Copyable, Second: ~Copyable {

    @inlinable
    public consuming func map<
        NewFirst: ~Copyable,
        NewSecond: ~Copyable,
        E: Swift.Error
    >(
        first firstTransform: (consuming First) throws(E) -> NewFirst,
        second secondTransform: (consuming Second) throws(E) -> NewSecond
    ) throws(E) -> Pair<NewFirst, NewSecond> {
        try Self.map(self, first: firstTransform, second: secondTransform)
    }
}

extension Pair where First: ~Copyable & ~Escapable, Second: ~Copyable & ~Escapable {

    @inlinable
    public consuming func apply<R: ~Copyable, E: Swift.Error>(
        _ body: (consuming First, consuming Second) throws(E) -> R
    ) throws(E) -> R {
        try Self.apply(self, body)
    }

    @inlinable
    @_lifetime(copy self)
    public consuming func swapped() -> Pair<Second, First> {
        Self.swapped(self)
    }
}

extension Pair where First: Copyable, Second: Copyable {

    @inlinable
    public init(_ tuple: (First, Second)) {
        self.first = tuple.0
        self.second = tuple.1
    }

    @inlinable
    public var tuple: (First, Second) {
        (first, second)
    }
}
