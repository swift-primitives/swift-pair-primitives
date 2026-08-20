// Pair.swift
// The binary cartesian product type.

@_exported public import Comparison_Primitives
@_exported public import Equation_Primitives
@_exported public import Hash_Primitives

/// A pair of two values (binary cartesian product).
///
/// `Pair` represents the product `First × Second`, pairing two values together.
/// Use it for classifier-value pairs (orientation + magnitude), coordinate pairs,
/// or any typed two-tuple.
///
/// ## Example
///
/// ```swift
/// let point = Pair(3, 4)
/// print(point.first)   // 3
/// print(point.second)  // 4
///
/// let scaled = point.map(second: { $0 * 2 })  // Pair(3, 8)
///
/// // Classifier-value pattern
/// let velocity: Pair<Vertical, Double> = Pair(.upward, 9.8)
/// ```
@frozen
public struct Pair<First: ~Copyable & ~Escapable, Second: ~Copyable & ~Escapable>: ~Copyable,
    ~Escapable
{
    /// First component.
    public var first: First

    /// Second component.
    public var second: Second

    /// Creates a pair from two values.
    @inlinable
    @_lifetime(copy first, copy second)
    public init(_ first: consuming First, _ second: consuming Second) {
        self.first = first
        self.second = second
    }
}

// MARK: - Conditional Conformances

extension Pair: Copyable where First: Copyable & ~Escapable, Second: Copyable & ~Escapable {}
extension Pair: Escapable where First: Escapable & ~Copyable, Second: Escapable & ~Copyable {}
extension Pair: Sendable
where First: Sendable & ~Copyable & ~Escapable, Second: Sendable & ~Copyable & ~Escapable {}

// Institute conformances (Equation.Protocol / Hash.Protocol / Comparison.Protocol)
// live in their per-protocol files alongside this one for layout symmetry with
// Either / Product. See Equation.Protocol+Pair.swift, Hash.Protocol+Pair.swift,
// Comparison.Protocol+Pair.swift.

#if !hasFeature(Embedded)
    extension Pair: Codable where First: Codable, Second: Codable {}
#endif

// MARK: - Functor surface
//
// The static layer is the canonical implementation; instance methods are
// thin delegates. All variants are `consuming`.
//
// Constraint shape: the un-transformed arm admits `~Escapable` (passes
// through unchanged); the closure-transformed arm requires `Escapable`
// because Swift's closure-parameter lifetime dependencies (Gap A in
// `nonescapable-ecosystem-state.md` §5) are not yet ready for `~Escapable`
// closure inputs/outputs. `swapped` and `apply` admit both arms ~Escapable;
// the three `map` overloads admit ~Escapable on the un-transformed arm
// only. Bodies use direct field access on the consuming parameter
// (`pair.first`, `pair.second`) — intermediate `let consumed = consume pair`
// triggers the move-checker bug "copy of noncopyable typed value" on
// generic ~Copyable & ~Escapable types (see
// `pack-expand-on-consuming-param-property.md`).
//
// `map(first:)` / `map(second:)` are deliberately ambiguous when called with
// a trailing closure (`pair.map { … }`) — consumers MUST use the explicit
// labels. The `.swift-format` config disables `AmbiguousTrailingClosureOverload`
// for this package because the ambiguity is the intended design per
// [API-NAME-008] single-form labeled-method shape.

// MARK: - Static layer (canonical implementations)

extension Pair where First: ~Copyable, Second: ~Copyable & ~Escapable {

    /// Transforms the first component while preserving the second, consuming `pair`.
    ///
    /// `Second` (the un-transformed arm) may be `~Escapable`; `First` and
    /// `NewFirst` (the transformed arm) must be `Escapable`.
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

    /// Transforms the second component while preserving the first, consuming `pair`.
    ///
    /// `First` (the un-transformed arm) may be `~Escapable`; `Second` and
    /// `NewSecond` (the transformed arm) must be `Escapable`.
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

    /// Transforms both components, consuming `pair`.
    ///
    /// Both arms must be `Escapable` (closure-parameter lifetime dependencies
    /// are not ready for `~Escapable` closure inputs/outputs).
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

    /// Applies a function to both components, consuming `pair`.
    ///
    /// The complement to ``map(_:first:second:)``: where `map` transforms
    /// components independently, `apply` folds them into a single result.
    /// Admits both arms `~Escapable` because the result `R` carries a
    /// `@_lifetime(copy pair)` annotation when the consumed pair is ~Escapable.
    ///
    /// ```swift
    /// let pair = Pair(readDescriptor, writeDescriptor)
    /// let result = Pair.apply(pair) { read, write in
    ///     close(write)
    ///     return read
    /// }
    /// ```
    @inlinable
    public static func apply<R: ~Copyable, E: Swift.Error>(
        _ pair: consuming Pair,
        _ body: (consuming First, consuming Second) throws(E) -> R
    ) throws(E) -> R {
        try body(pair.first, pair.second)
    }

    /// Returns a pair with components swapped, consuming `pair`.
    ///
    /// Admits both arms `~Escapable`; result lifetime tied to `pair`.
    @inlinable
    @_lifetime(copy pair)
    public static func swapped(_ pair: consuming Pair) -> Pair<Second, First> {
        Pair<Second, First>(pair.second, pair.first)
    }
}

// MARK: - Instance layer (delegates to static)
//
// Instance overloads mirror the static layer's where-clause shape: the
// un-transformed arm admits `~Escapable`, the transformed arm requires
// Escapable; `apply` and `swapped` admit both arms `~Escapable`.

extension Pair where First: ~Copyable, Second: ~Copyable & ~Escapable {

    /// Transforms the first component while preserving the second, consuming `self`.
    @inlinable
    @_lifetime(copy self)
    public consuming func map<NewFirst: ~Copyable, E: Swift.Error>(
        first transform: (consuming First) throws(E) -> NewFirst
    ) throws(E) -> Pair<NewFirst, Second> {
        try Self.map(self, first: transform)
    }
}

extension Pair where First: ~Copyable & ~Escapable, Second: ~Copyable {

    /// Transforms the second component while preserving the first, consuming `self`.
    @inlinable
    @_lifetime(copy self)
    public consuming func map<NewSecond: ~Copyable, E: Swift.Error>(
        second transform: (consuming Second) throws(E) -> NewSecond
    ) throws(E) -> Pair<First, NewSecond> {
        try Self.map(self, second: transform)
    }
}

extension Pair where First: ~Copyable, Second: ~Copyable {

    /// Transforms both components, consuming `self`.
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

    /// Applies a function to both components, consuming `self`.
    @inlinable
    public consuming func apply<R: ~Copyable, E: Swift.Error>(
        _ body: (consuming First, consuming Second) throws(E) -> R
    ) throws(E) -> R {
        try Self.apply(self, body)
    }

    /// Returns a pair with components swapped, consuming `self`.
    @inlinable
    @_lifetime(copy self)
    public consuming func swapped() -> Pair<Second, First> {
        Self.swapped(self)
    }
}

// MARK: - Tuple Conversion

extension Pair where First: Copyable, Second: Copyable {
    /// Creates a pair from a tuple.
    @inlinable
    public init(_ tuple: (First, Second)) {
        self.first = tuple.0
        self.second = tuple.1
    }

    /// Returns the pair as a tuple.
    @inlinable
    public var tuple: (First, Second) {
        (first, second)
    }
}
