public import Pair

extension Pair: BitwiseCopyable where First: BitwiseCopyable, Second: BitwiseCopyable {}
