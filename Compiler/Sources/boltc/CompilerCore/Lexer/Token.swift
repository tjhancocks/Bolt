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

enum Token: Equatable {
    case string(text: String, mark: Mark)
    case integer(number: Int, text: String,  mark: Mark)
    case float(number: Double, text: String, mark: Mark)
    case identifier(text: String, mark: Mark)
    case keyword(keyword: Keyword, mark: Mark)
    case symbol(symbol: Symbol, mark: Mark)
}

// MARK: - Matching

extension Token {
    func matches(_ token: Token, absolute: Bool = false) -> Bool {
        if absolute {
            return token == self
        }

        switch (self, token) {
        case (.string, .string):                                return true
        case (.integer, .integer):                              return true
        case (.float, .float):                                  return true
        case let (.identifier(lhs, _), .identifier(rhs, _)):    return (lhs == rhs)
        case let (.keyword(lhs, _), .keyword(rhs, _)):          return (lhs == rhs)
        case let (.symbol(lhs, _), .symbol(rhs, _)):            return (lhs == rhs)
        default:                                                return false
        }
    }
}

// MARK: - Token Descriptions

extension Token: CustomStringConvertible {
    var description: String {
        switch self {
        case let .string(text, mark):
            return "[string] \(mark):\(length) -- \(text)"
        case let .integer(number, _, mark):
            return "[integer] \(mark):\(length) -- \(number)"
        case let .float(number, _, mark):
            return "[float] \(mark):\(length) -- \(number)"
        case let .identifier(text, mark):
            return "[identifier] \(mark):\(length) -- \(text)"
        case let .keyword(keyword, mark):
            return "[keyword] \(mark):\(length) -- \(keyword.text)"
        case let .symbol(symbol, mark):
            return "[symbol] \(mark):\(length) -- \(symbol.rawValue)"
        }
    }
}

// MARK: - Token Lengths

extension Token {
    var length: Int {
        switch self {
        case let .string(text, _):
            return text.count +
                LanguageSpec.current.doubleQuotedStringPrefix.count +
                LanguageSpec.current.doubleQuotedStringSuffix.count

        case let .integer(_, text, _):
            return text.count

        case let .float(_, text, _):
            return text.count

        case let .identifier(text, _):
            return text.count

        case let .keyword(keyword, _):
            return keyword.text.count

        case .symbol:
            return 1
        }
    }
}

// MARK: - Token Locations/Marks

extension Token {
    var mark: Mark {
        switch self {
        case let .string(_, mark):
            return mark

        case let .integer(_, _, mark):
            return mark

        case let .float(_, _, mark):
            return mark

        case let .identifier(_, mark):
            return mark

        case let .keyword(_, mark):
            return mark

        case let .symbol(_, mark):
            return mark
        }
    }
}
