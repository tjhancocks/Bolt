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
            FunctionParser()
        ]
    }

    static var scopedParsers: [ParserHelperProtocol] {
        return returnParsers + [
            ReturnParser()
        ]
    }

    static var returnParsers: [ParserHelperProtocol] {
        return [
            StringLiteralParser(),
            FloatLiteralParser(),
            IntegerLiteralParser(),
            CallParser()
        ]
    }

}

// MARK: - Parsing

extension Parser {

    @discardableResult
    func parse() throws -> AbstractSyntaxTree {
        let ast = AbstractSyntaxTree(mainModuleName: tokenStream.file.moduleName)

        while scanner.available {
            ast.add(try parseNextExpression(from: scanner))
        }

        ast.modules.forEach {
            print($0)
        }

        return ast
    }

    func parseNextExpression(from scanner: Scanner<[Token]>) throws -> AbstractSyntaxTree.Node {
        // Loop through the parsers and find one that matches.
        for parser in parsers {
            if parser.test(for: scanner) {
                return try parser.parse(from: scanner)
            }
        }

        // If we get here, then we must assume that we could not recognise
        // the sequence of tokens
        if let token = scanner.peek() {
            throw Error.unrecognised(token: token)
        }
        else {
            throw Error.unexpectedEndOfTokenStream
        }
    }

}

// MARK: - Parser Protocol

protocol ParserHelperProtocol {
    func test(for scanner: Scanner<[Token]>) -> Bool
    func parse(from scanner: Scanner<[Token]>) throws -> AbstractSyntaxTree.Node
}


// MARK: - Scanner Extensions

extension Scanner where T.Element == Token {

    @discardableResult
    func consume(expected: T.Element...) throws -> [T.Element] {
        var expected = expected
        var matched: [T.Element] = []

        while available, expected.isEmpty == false {
            let item = try advance()
            guard expected.removeFirst().matches(item) else {
                throw Parser.Error.unexpectedTokenEncountered(token: item)
            }
            matched.append(item)
        }

        return matched
    }

}

// MARK: - Errors

extension Parser {
    enum Error: Swift.Error {
        case unexpectedEndOfTokenStream
        case unrecognised(token: Token)
        case unexpectedTokenEncountered(token: Token)
    }
}

extension Parser.Error: Reportable {
    var report: (severity: ReportSeverity, text: String) {
        switch self {
        case .unexpectedEndOfTokenStream:
            return (.error, "Parser unexpectedly encountered end of token stream.")
        case let .unrecognised(token):
            return (.error, "Parser encountered an unrecognised token: \(token)")
        case let .unexpectedTokenEncountered(token):
            return (.error, "Unexpected token encountered: \(token)")
        }
    }
}
