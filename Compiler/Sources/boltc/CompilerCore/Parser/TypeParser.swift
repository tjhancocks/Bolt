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

struct TypeParser: SubParserProtocol {

    /// Check the upcoming tokens in the scanner to determine if they are the
    /// beginning of a function.
    static func test(scanner: Scanner<[Token]>) -> Bool {
        fatalError("A type is a contextual element and should be assumed to exist based on the context the parser is in.")
    }

    /// Consume a function declaration expression, and if possible a function
    /// body for a function definition expression.
    static func parse(scanner: Scanner<[Token]>, owner parser: Parser) throws -> AbstractSyntaxTree.Expression {
        let location = scanner.location
        var typeTokens: [Token] = []

        while scanner.available {
            if let token = scanner.peek(), let _ = try? Type.resolve(from: typeTokens + [token], location: location) {
                scanner.advance()
                typeTokens.append(token)
            } else {
                break
            }
        }

        let type = try Type.resolve(from: typeTokens, location: location)
        return .type(type, location: location)
    }

}
