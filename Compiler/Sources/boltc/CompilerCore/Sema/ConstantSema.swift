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

struct ConstantSema: SemaProtocol {

    static func performSemanticAnalysis(
        on expr: AbstractSyntaxTree.Expression,
        for sema: Sema
    ) throws -> [AbstractSyntaxTree.Expression] {
        if case .constantDeclaration = expr {
            return try performSemanticAnalysis(onConstant: expr, withInitialValue: nil, for: sema)
        }
        else if case let .definition(declaration, initialValue) = expr, case .constantDeclaration = declaration {
            return try performSemanticAnalysis(onConstant: declaration, withInitialValue: initialValue, for: sema)
        }
        else {
            throw Error.semaError(location: expr.location,
                                  reason: .expectedConstantDeclarationDefinition(got: expr))
        }
    }

    private static func performSemanticAnalysis(
        onConstant declaration: AbstractSyntaxTree.Expression,
        withInitialValue value: AbstractSyntaxTree.Expression?,
        for sema: Sema
    ) throws -> [AbstractSyntaxTree.Expression] {
        guard case let .constantDeclaration(name, type, location) = declaration else {
            throw Error.semaError(location: declaration.location,
                                  reason: .expectedConstantDeclarationDefinition(got: declaration))
        }

        if let value = value {

            guard type.type.isValidStorageType else {
                throw Error.semaError(location: type.location,
                                      reason: .illegalStorageType(got: type.type))
            }

            guard type.type.resolvedType == value.type.resolvedType else {
                throw Error.semaError(location: value.location,
                                      reason: .typeMismatch(expected: type.type, got: value.type))
            }

            try sema.symbolTable.defineSymbol(name: name, expression: declaration, isDeclaration: false, location: location)

            return [
                .definition(declaration: declaration, body: value)
            ]
        } else {
            try sema.symbolTable.defineSymbol(name: name, expression: declaration, isDeclaration: true, location: location)

            return [
                declaration
            ]
        }
    }
}
