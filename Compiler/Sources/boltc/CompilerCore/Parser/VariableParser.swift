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

struct VariableParser: ParserHelperProtocol {
    func test(for scanner: Scanner<[Token]>) -> Bool {
        if case .keyword(.let, _)? = scanner.peek(), case .symbol(.leftAngle, _)? = scanner.peek(ahead: 1) {
            return true
        } else {
            return false
        }
    }

    func parse(from scanner: Scanner<[Token]>) throws -> AbstractSyntaxTree.Node {
        // Variable declaration prologue: let<
        try scanner.consume(expected:
            .keyword(keyword: .let, mark: .unknown),
            .symbol(symbol: .leftAngle, mark: .unknown)
        )

        // Variable return type
        let type = try TypeParser.parse(from: scanner)

        // Post type: >
        try scanner.consume(expected:
            .symbol(symbol: .rightAngle, mark: .unknown)
        )

        // Variable name
        let variableNameToken = try scanner.advance()
        guard case let .identifier(name, mark) = variableNameToken else {
            throw Parser.Error.unexpectedTokenEncountered(token: variableNameToken)
        }

        // Check if there is an initial value with it? If so then use it.
        if case .symbol(.equals, _)? = scanner.peek() {
            try scanner.advance()
            
            let parsers = Parser.returnParsers
            for parser in parsers {
                if parser.test(for: scanner) {
                    let value = try parser.parse(from: scanner)
                    guard value.valueType == type.valueType else {
                        fatalError("Type mismatch")
                    }
                    return AbstractSyntaxTree.VariableNode(name: name, type: type, initialValue: value, mark: mark)
                }
            }

            // Failed to find the required value - error
            fatalError()
        } else {
            // Return a variable node without a value.
            return AbstractSyntaxTree.VariableNode(name: name, type: type, initialValue: nil, mark: mark)
        }
    }
}
