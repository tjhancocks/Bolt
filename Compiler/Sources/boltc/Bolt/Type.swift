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

indirect enum Type: Equatable {
    // Fundamental Types
    case none
    case int8
    case int16
    case int32
    case int64
    case uint8
    case uint16
    case uint32
    case uint64
    case int
    case uint

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
        case .int16:                    return "Int16"
        case .int32:                    return "Int32"
        case .int64:                    return "Int64"
        case .uint8:                    return "UInt8"
        case .uint16:                   return "UInt16"
        case .uint32:                   return "UInt32"
        case .uint64:                   return "UInt64"
        case .int:                      return "Int"
        case .uint:                     return "UInt"
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

// MARK: - Type Validation

extension Type {
    var isValidStorageType: Bool {
        switch self {
        case .none:                 return false
        default:                    return true
        }
    }
}

// MARK: - Interpret a sequence of Tokens as a type.

extension Type {
    static func resolve(from typeTokens: [Token], location: Mark = .unknown) throws -> Type {
        guard typeTokens.isEmpty == false else {
            throw Error.typeError(location: location, reason: .missingTypeInformation)
        }

        var tokens: [Token] = typeTokens
        var baseType: Type = .int8

        // Base Type: Identifier
        guard case let .identifier(baseName, _) = tokens.removeFirst() else {
            throw Error.typeError(location: location, reason: .missingTypeInformation)
        }

        switch baseName {
            // Fundamental Types
        case "None":            baseType = .none
        case "Int8":            baseType = .int8
        case "Int":             baseType = .int
        case "Int16":           baseType = .int16
        case "Int32":           baseType = .int32
        case "Int64":           baseType = .int64
        case "UInt":            baseType = .uint
        case "UInt8":           baseType = .uint8
        case "UInt16":          baseType = .uint16
        case "UInt32":          baseType = .uint32
        case "UInt64":          baseType = .uint64

            // Complex Types
        case "String":          baseType = .string

            // Unknown Types
        default:                throw Error.typeError(location: location, reason: .unrecognised(typeName: baseName))
        }

        // Nesting
        while tokens.isEmpty == false, case .symbol(let symbol, let location)? = tokens.first {
            if symbol == .star {
                baseType = .pointer(baseType)
            } else {
                throw Error.typeError(location: location, reason: .unrecognised(symbol: symbol))
            }
            tokens.removeFirst()
        }

        return baseType
    }
}
