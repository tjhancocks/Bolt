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

struct TypeParser: ParserHelperProtocol {

    // MARK: - Contextual Parser Helper
    static func parse(from scanner: Scanner<[Token]>, ast: AbstractSyntaxTree) throws -> AbstractSyntaxTree.TypeNode {
        var typeTokens: [Token] = []

        // Extract each of the tokens
        while scanner.available {
            if test(for: scanner) == false {
                break
            }

            // Attempt to create a new type
            if let token = scanner.peek(), let _ = try? Type.resolve(from: typeTokens + [token]) {
                typeTokens.append(scanner.advance())
            } else {
                break
            }
        }

        return AbstractSyntaxTree.TypeNode(type: try Type.resolve(from: typeTokens), mark: .unknown)
    }

    static func test(for scanner: Scanner<[Token]>) -> Bool {
        if case .identifier? = scanner.peek() {
            return true
        }
        else if case .symbol(.star, _)? = scanner.peek() {
            return true
        }
        else {
            return false
        }
    }

    // MARK: - Lone Parser Helper

    func test(for scanner: Scanner<[Token]>) -> Bool {
        return TypeParser.test(for: scanner)
    }

    func parse(from scanner: Scanner<[Token]>, ast: AbstractSyntaxTree) throws -> AbstractSyntaxTree.Node {
        return try TypeParser.parse(from: scanner, ast: ast)
    }
}
