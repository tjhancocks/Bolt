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

struct CallSema: SemaProtocol {

    static func performSemanticAnalysis(
        on expr: AbstractSyntaxTree.Expression,
        for sema: Sema
    ) throws -> [AbstractSyntaxTree.Expression] {
        // Ensure we're checking an unbound function call
        guard case let .call(.identifier(name, idLocation), arguments, location) = expr else {
            throw Error.semaError(location: expr.location,
                                  reason: .expectedCallExpression(got: expr))
        }

        // Find the symbol for the call.
        guard let function = sema.symbolTable.find(symbolNamed: name) else {
            throw Error.semaError(location: idLocation,
                                  reason: .unknownIdentifier(name: name))
        }

        // Is the symbol actually for a function declaration?
        guard case let .functionDeclaration(_, _, parameters, _) = function.expression else {
            throw Error.semaError(location: location,
                                  reason: .expectedFunctionIdentifier(got: function.expression))
        }

        // Analyse the arguments and check the types against the function parameters.
        let semaArgs = try sema.analyse(expressions: arguments)
        for (offset, (arg, parameter)) in zip(semaArgs, parameters).enumerated() {
            if arg.type.resolvedType != parameter.type.resolvedType {
                throw Error.semaError(location: arg.location,
                                      reason: .argumentTypeMismatch(expected: parameter.type,
                                                                    got: arg.type,
                                                                    at: offset))
            }
        }

        let bound: AbstractSyntaxTree.Expression = .boundIdentifier(function.expression, location: idLocation)
        return [
            .call(identifier: bound, arguments: arguments, location: location)
        ]
    }

}
