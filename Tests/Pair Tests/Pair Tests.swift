import Pair
import Testing

struct Token: ~Copyable, Sendable {
    let value: Int
}

struct Span: ~Copyable, ~Escapable {
    let value: Int
    @_lifetime(immortal)
    init(value: Int) { self.value = value }
}

@Suite
struct `Pair Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite(.serialized) struct Performance {}
}

extension `Pair Tests`.Unit {

    @Test
    func `init with noncopyable values`() {
        let pair = Pair(Token(value: 1), Token(value: 2))
        let first = pair.first.value
        let second = pair.second.value
        #expect(first == 1)
        #expect(second == 2)
    }

    @Test
    func `partial consumption of frozen struct`() {
        func consumeBoth(_ pair: consuming Pair<Token, Token>) -> (Int, Int) {
            let f = pair.first.value
            let s = pair.second.value
            return (f, s)
        }

        let pair = Pair(Token(value: 10), Token(value: 20))
        let (f, s) = consumeBoth(pair)
        #expect(f == 10)
        #expect(s == 20)
    }

    @Test
    func `static map second transforms second preserving first`() {
        let pair = Pair(Token(value: 1), Token(value: 2))
        let mapped = Pair<Token, Token>.map(pair, second: { Token(value: $0.value * 10) })
        let first = mapped.first.value
        let second = mapped.second.value
        #expect(first == 1)
        #expect(second == 20)
    }

    @Test
    func `static map first transforms first preserving second`() {
        let pair = Pair(Token(value: 1), Token(value: 2))
        let mapped = Pair<Token, Token>.map(pair, first: { Token(value: $0.value * 10) })
        let first = mapped.first.value
        let second = mapped.second.value
        #expect(first == 10)
        #expect(second == 2)
    }

    @Test
    func `static map first and second transforms both components`() {
        let pair = Pair(Token(value: 3), Token(value: 4))
        let mapped = Pair<Token, Token>.map(
            pair,
            first: { Token(value: $0.value + 10) },
            second: { Token(value: $0.value + 20) }
        )
        let first = mapped.first.value
        let second = mapped.second.value
        #expect(first == 13)
        #expect(second == 24)
    }

    @Test
    func `static swapped exchanges components`() {
        let pair = Pair(Token(value: 1), Token(value: 2))
        let swapped = Pair<Token, Token>.swapped(pair)
        let first = swapped.first.value
        let second = swapped.second.value
        #expect(first == 2)
        #expect(second == 1)
    }

    @Test
    func `consuming swapped instance method`() {
        let pair = Pair(Token(value: 5), Token(value: 6))
        let swapped = pair.swapped()
        let first = swapped.first.value
        let second = swapped.second.value
        #expect(first == 6)
        #expect(second == 5)
    }
}

extension `Pair Tests`.Unit {

    @Test
    func `instance map second transforms second`() {
        let pair = Pair("hello", 3)
        let mapped = pair.map(second: { $0 + 7 })
        #expect(mapped.first == "hello")
        #expect(mapped.second == 10)
    }

    @Test
    func `instance map first transforms first`() {
        let pair = Pair(1, "world")
        let mapped = pair.map(first: { $0 * 5 })
        #expect(mapped.first == 5)
        #expect(mapped.second == "world")
    }

    @Test
    func `instance map first and second transforms both`() {
        let pair = Pair(2, 3)
        let mapped = pair.map(first: { $0 * 10 }, second: { $0 * 100 })
        #expect(mapped.first == 20)
        #expect(mapped.second == 300)
    }

    @Test
    func `consuming swapped on copyable pair`() {
        let pair = Pair(1, 2)
        let swapped = pair.swapped()
        #expect(swapped.first == 2)
        #expect(swapped.second == 1)
    }
}

extension `Pair Tests`.Unit {

    @Test
    func `init from tuple`() {
        let pair = Pair((10, 20))
        #expect(pair.first == 10)
        #expect(pair.second == 20)
    }

    @Test
    func `tuple property round-trips`() {
        let pair = Pair(3, 4)
        let tuple = pair.tuple
        #expect(tuple.0 == 3)
        #expect(tuple.1 == 4)
    }
}

extension `Pair Tests`.Unit {

    @Test
    func `noncopyable sendable pair satisfies Sendable`() {
        func assertSendable<T: Sendable & ~Copyable>(_: borrowing T) {}
        let pair = Pair(Token(value: 42), Token(value: 99))
        assertSendable(pair)
    }

    @Test
    func `copyable sendable pair satisfies Sendable`() async {
        let pair = Pair(42, 99)
        let result = await Task { pair.first + pair.second }.value
        #expect(result == 141)
    }
}

extension `Pair Tests`.`Edge Case` {

    @Test
    func `map second with identity preserves value`() {
        let pair = Pair(Token(value: 7), Token(value: 8))
        let mapped = Pair<Token, Token>.map(pair, second: { $0 })
        let second = mapped.second.value
        #expect(second == 8)
    }

    @Test
    func `double swap is identity`() {
        let pair = Pair(Token(value: 1), Token(value: 2))
        let once = Pair<Token, Token>.swapped(pair)
        let twice = Pair<Token, Token>.swapped(once)
        let first = twice.first.value
        let second = twice.second.value
        #expect(first == 1)
        #expect(second == 2)
    }

    @Test
    func `map second with throwing transform propagates error`() {
        struct Fail: Swift.Error, Equatable {}
        let pair = Pair(1, 2)
        do throws(Fail) {
            _ = try pair.map(second: { _ throws(Fail) -> Int in throw Fail() })
            Issue.record("Expected Fail to be thrown")
        } catch {
            #expect(error == Fail())
        }
    }

    @Test
    func `map first and second with throwing transform propagates error`() {
        struct Fail: Swift.Error, Equatable {}
        let pair = Pair(1, 2)
        do throws(Fail) {
            _ = try pair.map(
                first: { (x: Int) throws(Fail) -> Int in x },
                second: { _ throws(Fail) -> Int in throw Fail() }
            )
            Issue.record("Expected Fail to be thrown")
        } catch {
            #expect(error == Fail())
        }
    }

    @Test
    func `Pair admits noncopyable nonescapable arms via swapped`() {
        struct View: ~Escapable {
            let id: Int
            @_lifetime(immortal)
            init(_ id: Int) { self.id = id }
        }
        let pair = Pair(View(7), View(11))
        let flipped = pair.swapped()
        #expect(flipped.first.id == 11)
        #expect(flipped.second.id == 7)
    }

    @Test
    func `Pair apply admits noncopyable nonescapable arms`() {
        struct View: ~Escapable {
            let id: Int
            @_lifetime(immortal)
            init(_ id: Int) { self.id = id }
        }
        let pair = Pair(View(3), View(5))
        let sum = pair.apply { lhs, rhs in
            lhs.id + rhs.id
        }
        #expect(sum == 8)
    }

    @Test
    func `Pair swapped admits noncopyable nonescapable arms`() {
        let pair = Pair(Span(value: 13), Span(value: 17))
        let flipped = pair.swapped()
        #expect(flipped.first.value == 17)
        #expect(flipped.second.value == 13)
    }

    @Test
    func `Pair apply admits noncopyable nonescapable arms (mixed-suppression)`() {
        let pair = Pair(Span(value: 4), Span(value: 6))
        let sum = pair.apply { lhs, rhs in
            lhs.value + rhs.value
        }
        #expect(sum == 10)
    }
}
