public import Pair

#if !hasFeature(Embedded)
    extension Pair: Codable where First: Codable, Second: Codable {

        @usableFromInline
        enum CodingKeys: String, CodingKey {
            case first
            case second
        }

        @inlinable
        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.init(
                try container.decode(First.self, forKey: .first),
                try container.decode(Second.self, forKey: .second)
            )
        }

        @inlinable
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.first, forKey: .first)
            try container.encode(self.second, forKey: .second)
        }
    }
#endif
