// Copyright (c) 2019 Tom Hancocks
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

extension Scanner where T.Element == Token {

    @discardableResult
    func test(weakIdentifier: Bool = false, expected: T.Element...) -> Bool {
        var matched: [T.Element] = []

        while expected.count > matched.count, let peeked = peek(ahead: matched.count), peeked.matches(expected[matched.count], weakIdentifier: weakIdentifier) {
            matched.append(peeked)
        }

        return matched.count == expected.count
    }

    @discardableResult
    func consume(expected: T.Element...) throws -> [T.Element] {
        var expectedTokens = expected
        var matched: [T.Element] = []

        while available, let expect = expectedTokens.first {
            let item = advance()
            guard expectedTokens.removeFirst().matches(item) else {
                throw Error.parserError(location: location,
                                        reason: .expected(token: expect))
            }
            matched.append(item)
        }

        if matched.isEmpty, let expect = expected.first {
            throw Error.parserError(location: location,
                                    reason: .expected(token: expect))
        }

        return matched
    }

    func peekLast() -> T.Element? {
        if let array = input as? [Token] {
            return array.last
        } else {
            return nil
        }
    }

    var location: Mark {
        return peek()?.mark ?? peekLast()?.mark ?? .unknown
    }

    var token: Token {
        guard let token = peek() else {
            fatalError("Attempted to access a token that has been considered present, but isn't.")
        }
        return token
    }

}

