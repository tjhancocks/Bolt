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

indirect enum Type {
    // Fundamental Types
    case none
    case int8
    case int

    // Nested
    case pointer(Type)

    // Complex
    case string
}

extension Type: CustomStringConvertible {
    var text: String {
        switch self {
        case .none:                     return "None"
        case .int8:                     return "Int8"
        case .int:                      return "Int"
        case .pointer(let type):        return "\(type.text)*"
        case .string:                   return resolvedType.text
        }
    }

    var description: String {
        return text
    }
}

// MARK: - Complex Type Resolution

extension Type {
    var resolvedType: Type {
        switch self {
        case .string:               return .pointer(.int8)
        default:                    return self
        }
    }
}

// MARK: - Interpret a sequence of Tokens as a type.

extension Type {
    static func resolve(from typeTokens: [Token]) throws -> Type {
        var tokens: [Token] = typeTokens
        var baseType: Type = .int8

        // Base Type: Identifier
        guard case let .identifier(baseName, _) = tokens.removeFirst() else {
            throw Error.badType(name: "?")
        }

        switch baseName {
            // Fundamental Types
        case "None":            baseType = .none
        case "Int8":            baseType = .int8
        case "Int":             baseType = .int

            // Complex Types
        case "String":          baseType = .string

            // Unknown Types
        default:                throw Error.badType(name: baseName)
        }

        // Nesting
        while tokens.isEmpty == false {
            if case .symbol(.star, _)? = tokens.first {
                baseType = .pointer(baseType)
            } else {
                throw Error.badType(name: "?")
            }
            tokens.removeFirst()
        }

        return baseType
    }
}

extension Type {
    enum Error: Swift.Error {
        case badType(name: String)
    }
}
