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

struct ImportParser: SubParserProtocol {

    private static func testIdentifierVariant(scanner: Scanner<[Token]>) -> Bool {
        return scanner.test(weakIdentifier: true, expected:
            .keyword(keyword: .import, mark: scanner.location),
			.identifier(text: "foo", mark: scanner.location)
        )
    }

    private static func testStringVariant(scanner: Scanner<[Token]>) -> Bool {
        return scanner.test(expected:
            .keyword(keyword: .import, mark: scanner.location),
            .string(text: "foo", mark: scanner.location)
        )
    }

    static func test(scanner: Scanner<[Token]>) -> Bool {
        return testIdentifierVariant(scanner: scanner) || testStringVariant(scanner: scanner)
    }

    static func parse(scanner: Scanner<[Token]>, owner parser: Parser) throws -> AbstractSyntaxTree.Expression {
        if testIdentifierVariant(scanner: scanner) {
            scanner.advance()
            if case let .identifier(file, location)? = scanner.peek() {
                scanner.advance()
                return .module(try self.import(file: file), location: location)
            }
        }
        else if testStringVariant(scanner: scanner) {
            scanner.advance()
            if case let .string(file, location)? = scanner.peek() {
                scanner.advance()
                return .module(try self.import(file: file), location: location)
            }
        }

        throw Error.parserError(location: scanner.location,
                                reason: .unexpectedTokenEncountered(token: scanner.advance()))
    }

    private static func `import`(file: String) throws -> [AbstractSyntaxTree.Expression] {
        // Check for a user provided file first

        // Check for a library
        for libPath in BuildSystem.main.libraryPaths {
            do {
                let path = libPath.appendingPathComponent(file).appendingPathExtension("bolt")
                let ast = try BuildSystem.Module.import(for: File(url: path))

                return ast.expressions
            }
            catch let error {
                print(error)
                continue
            }
        }

        throw Error.fileError(reason: .importFailed(fileNamed: file))
    }
}
