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

struct ParameterParser {

    static func parse(from scanner: Scanner<[Token]>, ast: AbstractSyntaxTree) throws -> AbstractSyntaxTree.ParameterNode {
        guard case let .identifier(name, mark) = scanner.advance() else {
            throw Error.expectedIdentifier
        }

        try scanner.consume(expected: .symbol(symbol: .colon, mark: .unknown))
        let type = try TypeParser.parse(from: scanner, ast: ast)

        return .init(name: name, type: type, mark: mark)
    }

}

extension ParameterParser {
    enum Error: Swift.Error {
        case expectedIdentifier
    }
}
