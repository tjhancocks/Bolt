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

struct BinaryOperationSema: SemaProtocol {

    static func performSemanticAnalysis(
        on expr: AbstractSyntaxTree.Expression,
        for sema: Sema
    ) throws -> [AbstractSyntaxTree.Expression] {
        // Check if we can perform any valid code folding operations.
        if case let .binaryOperation(.integer(lhs, _), .addition, .integer(rhs, _), location) = expr {
            return [.integer(lhs + rhs, location: location)]
        }

        // This is an actual binary operation, so check it for validity.
        else if case let .binaryOperation(lhs, _, rhs, _) = expr {

            guard lhs.type.isValidStorageType else {
                throw Error.semaError(location: expr.location,
                                      reason: .illegalStorageType(got: lhs.type))
            }

            guard rhs.type.isValidStorageType else {
                throw Error.semaError(location: expr.location,
                                      reason: .illegalStorageType(got: lhs.type))
            }

            guard lhs.type == rhs.type else {
                throw Error.semaError(location: expr.location,
                                      reason: .typeMismatch(expected: lhs.type, got: rhs.type))
            }

            return [expr]
        } else {
            throw Error.semaError(location: expr.location, reason: .expectedParameterDeclaration(got: expr))
        }
    }

}
