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

class Parser {
    private(set) var tokenStream: TokenStream
    private(set) var scanner: Scanner<[Token]>

    lazy var parsers: [ParserHelperProtocol] = {
        return Parser.rootParsers
    }()

    init(tokenStream: TokenStream) {
        self.tokenStream = tokenStream
        self.scanner = tokenStream.scanner
    }
}

// MARK: - Parser Lookup

extension Parser {

    static var rootParsers: [ParserHelperProtocol] {
        return [
            FunctionParser(),
            ImportParser(),
            VariableParser()
        ]
    }

    static var scopedParsers: [ParserHelperProtocol] {
        return returnParsers + [
            ReturnParser(),
            VariableParser()
        ]
    }

    static var returnParsers: [ParserHelperProtocol] {
        return [
            StringLiteralParser(),
            FloatLiteralParser(),
            IntegerLiteralParser(),
            CallParser(),
            IdentifierParser()
        ]
    }

}

// MARK: - Parsing

extension Parser {

    @discardableResult
    func parse() throws -> AbstractSyntaxTree {
        let ast = AbstractSyntaxTree(mainModuleName: tokenStream.file.moduleName)

        while scanner.available {
            ast.add(try parseNextExpression(from: scanner, ast: ast))
        }
        
        return ast
    }

    func parseNextExpression(from scanner: Scanner<[Token]>, ast: AbstractSyntaxTree) throws -> AbstractSyntaxTree.Node {
        // Loop through the parsers and find one that matches.
        for parser in parsers {
            if parser.test(for: scanner) {
                return try parser.parse(from: scanner, ast: ast)
            }
        }

        // If we get here, then we must assume that we could not recognise
        // the sequence of tokens
        if let token = scanner.peek() {
            throw Error.parserError(location: scanner.location, reason: .unrecognised(token: token))
        }
        else {
            throw Error.parserError(location: scanner.location, reason: .unexpectedEndOfTokenStream)
        }
    }

}

// MARK: - Parser Protocol

protocol ParserHelperProtocol {
    func test(for scanner: Scanner<[Token]>) -> Bool
    func parse(from scanner: Scanner<[Token]>, ast: AbstractSyntaxTree) throws -> AbstractSyntaxTree.Node
}


// MARK: - Scanner Extensions

extension Scanner where T.Element == Token {

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
            fatalError("Attempted to access a token that has been considered presented, but isn't.")
        }
        return token
    }

}
