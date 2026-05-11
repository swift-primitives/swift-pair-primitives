// Pair+BitwiseCopyable.swift
// Conditional conformance of Pair to BitwiseCopyable.
//
// `BitwiseCopyable` implies `Copyable`, so the conformance only fires when
// both arms are Copyable + BitwiseCopyable. Certifies Pair as a first-class
// element type for inline storage (InlineArray, Span, raw layout buffers).

extension Pair: BitwiseCopyable where First: BitwiseCopyable, Second: BitwiseCopyable {}
