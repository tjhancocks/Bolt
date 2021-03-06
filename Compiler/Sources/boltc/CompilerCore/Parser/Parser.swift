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

    init(tokenStream: TokenStream) {
        self.tokenStream = tokenStream
        self.scanner = tokenStream.scanner
    }
}

// MARK: - Parsing

extension Parser {

    @discardableResult
    func parse() throws -> AbstractSyntaxTree {
        var expressions: [AbstractSyntaxTree.Expression] = []

        while scanner.available {
            let expr = try parseGlobalExpression()
            if case let .module(moduleExpressions, _) = expr {
                expressions.append(contentsOf: moduleExpressions)
            }
            else if case let .linkerFlag(flag, _) = expr {
                BuildSystem.main.specify(linkerFlag: flag)
            }
            else {
                expressions.append(expr)
            }
        }

        return AbstractSyntaxTree(mainModuleName: tokenStream.file.moduleName, expressions: expressions)
    }

    @discardableResult
    func parseGlobalExpression() throws -> AbstractSyntaxTree.Expression {
        if test(parser: FunctionParser.self) {
            return try parse(parser: FunctionParser.self)
        }
        else if test(parser: ConstantParser.self) {
            return try parse(parser: ConstantParser.self)
        }
        else if test(parser: ImportParser.self) {
            return try parse(parser: ImportParser.self)
        }
        else if test(parser: DirectiveParser.self) {
            return try parse(parser: DirectiveParser.self)
        }
        else {
            guard let token = scanner.peek() else {
                fatalError("Expected a token to present in the token stream, but found nil.")
            }
            throw Error.parserError(location: scanner.location,
                                    reason: .unrecognised(token: token))
        }
    }

    @discardableResult
    func parseExpression() throws -> AbstractSyntaxTree.Expression {
        if test(parser: GroupParser.self) {
            return try parse(parser: GroupParser.self)
        }
        else if test(parser: BlockParser.self) {
            return try parse(parser: BlockParser.self)
        }
        else if test(parser: ReturnParser.self) {
            return try parse(parser: ReturnParser.self)
        }
        else if test(parser: IntegerParser.self) {
            return try parse(parser: IntegerParser.self)
        }
        else if test(parser: BoolParser.self) {
            return try parse(parser: BoolParser.self)
        }
        else if test(parser: StringParser.self) {
            return try parse(parser: StringParser.self)
        }
        else if test(parser: ConstantParser.self) {
            return try parse(parser: ConstantParser.self)
        }
        else if test(parser: CallParser.self) {
            return try parse(parser: CallParser.self)
        }
        else if test(parser: IdentifierParser.self) {
            return try parse(parser: IdentifierParser.self)
        }
        else {
            guard let token = scanner.peek() else {
                fatalError("Expected a token to present in the token stream, but found nil.")
            }
            throw Error.parserError(location: scanner.location,
                                    reason: .unrecognised(token: token))
        }
    }

    @discardableResult
    func test<SubParserType>(parser _: SubParserType.Type) -> Bool where SubParserType: SubParserProtocol {
        return SubParserType.test(scanner: scanner)
    }

    @discardableResult
    func parse<SubParserType>(
        parser _: SubParserType.Type
    ) throws -> AbstractSyntaxTree.Expression where SubParserType: SubParserProtocol {
        return try SubParserType.parse(scanner: scanner, owner: self)
    }

}

protocol SubParserProtocol {
    static func test(scanner: Scanner<[Token]>) -> Bool
    static func parse(scanner: Scanner<[Token]>, owner parser: Parser) throws -> AbstractSyntaxTree.Expression
}
