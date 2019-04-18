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

struct FunctionParser: SubParserProtocol {

    /// Check the upcoming tokens in the scanner to determine if they are the
    /// beginning of a function.
    static func test(scanner: Scanner<[Token]>) -> Bool {
        return scanner.test(expected:
            .keyword(keyword: .func, mark: .unknown),
            .symbol(symbol: .leftAngle, mark: .unknown)
        )
    }

    /// Consume a function declaration expression, and if possible a function
    /// body for a function definition expression.
    static func parse(scanner: Scanner<[Token]>, owner parser: Parser) throws -> AbstractSyntaxTree.Expression {
        let declarationLocation = scanner.location

        // Advance by the first two tokens, which should be known to be 'func' '<'
        scanner.advance(by: 2)

        // Launch a sub parser for the return type.
        let returnType = try TypeParser.parse(scanner: scanner, owner: parser)

        // The next token must be '>' to conclude the type definition
        try scanner.consume(expected:
            .symbol(symbol: .rightAngle, mark: .unknown)
        )

        // Extract the function name
        guard case let .identifier(functionName, _)? = scanner.peek() else {
            throw Error.parserError(location: scanner.location,
                                    reason: .expected(token: .identifier(text: "foo", mark: .unknown)))
        }
        scanner.advance()
        
        // Check for the presence of the parameter group. If it is not present then
        // we have no parameters.
        var parameters: [AbstractSyntaxTree.Expression] = []
        if GroupParser.test(scanner: scanner) {
            if case let .group(expressions, _) = try GroupParser.parse(scanner: scanner, owner: parser) {
                parameters = expressions
            }
        }

        // Build the function declaration using the discovered information
        let functionDeclaration: AbstractSyntaxTree.Expression = .functionDeclaration(name: functionName,
                                                                                      returnType: returnType,
                                                                                      parameters: parameters,
                                                                                      location: declarationLocation)

        return functionDeclaration
    }

}
