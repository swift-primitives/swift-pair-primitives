// Pair+BitwiseCopyable Tests.swift

import Pair_Primitives
import Testing

// MARK: - Static Verifier

/// Compile-time witness: requires that `T` conforms to `BitwiseCopyable`.
///
/// If the call site compiles, the conformance is statically established.
private func requiresBitwiseCopyable<T: BitwiseCopyable>(_: T.Type) {}

// MARK: - Suite Structure

@Suite
struct `Pair BitwiseCopyable Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Pair BitwiseCopyable Tests`.Unit {
    @Suite struct Layout {}
    @Suite struct Conformance {}
}

// MARK: - Layout

extension `Pair BitwiseCopyable Tests`.Unit.Layout {

    @Test
    func `Pair of two Ints has same size as tuple of two Ints`() {
        #expect(MemoryLayout<Pair<Int, Int>>.size == MemoryLayout<(Int, Int)>.size)
    }

    @Test
    func `Pair of two Ints has same stride as tuple of two Ints`() {
        #expect(MemoryLayout<Pair<Int, Int>>.stride == MemoryLayout<(Int, Int)>.stride)
    }

    @Test
    func `Pair of two Ints has same alignment as tuple of two Ints`() {
        #expect(MemoryLayout<Pair<Int, Int>>.alignment == MemoryLayout<(Int, Int)>.alignment)
    }

    @Test
    func `Pair of mixed-width primitives has same size as tuple`() {
        #expect(MemoryLayout<Pair<Int8, Int64>>.size == MemoryLayout<(Int8, Int64)>.size)
        #expect(MemoryLayout<Pair<Int8, Int64>>.stride == MemoryLayout<(Int8, Int64)>.stride)
        #expect(MemoryLayout<Pair<Int8, Int64>>.alignment == MemoryLayout<(Int8, Int64)>.alignment)
    }
}

// MARK: - Conformance

extension `Pair BitwiseCopyable Tests`.Unit.Conformance {

    @Test
    func `Pair of BitwiseCopyable arms conforms to BitwiseCopyable`() {
        requiresBitwiseCopyable(Pair<Int, Int>.self)
        requiresBitwiseCopyable(Pair<Int8, Int64>.self)
        requiresBitwiseCopyable(Pair<UInt32, Double>.self)
    }

    @Test
    func `Nested Pair of BitwiseCopyable arms conforms to BitwiseCopyable`() {
        requiresBitwiseCopyable(Pair<Pair<Int, Int>, Int>.self)
        requiresBitwiseCopyable(Pair<Int, Pair<Int, Int>>.self)
        requiresBitwiseCopyable(Pair<Pair<Int, Int>, Pair<Int, Int>>.self)
    }

    @Test
    func `InlineArray of Pair preserves element layout`() {
        // Smoke test: InlineArray requires BitwiseCopyable elements.
        // If this compiles, the conformance is reachable from generic
        // contexts that gate on BitwiseCopyable.
        let array: InlineArray<3, Pair<Int, Int>> = [
            Pair(1, 2),
            Pair(3, 4),
            Pair(5, 6),
        ]
        #expect(array[0].first == 1)
        #expect(array[0].second == 2)
        #expect(array[1].first == 3)
        #expect(array[2].second == 6)
    }
}
