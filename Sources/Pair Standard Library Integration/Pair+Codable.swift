public import Pair

#if !hasFeature(Embedded)
    extension Pair: Codable where First: Codable, Second: Codable {}
#endif
