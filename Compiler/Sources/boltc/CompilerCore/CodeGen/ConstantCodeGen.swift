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

import LLVM

struct ConstantCodeGen: CodeGenProtocol {

    static func emit(for expr: AbstractSyntaxTree.Expression, in codeGen: CodeGen) throws -> IRValue? {
        if case let .definition(declaration, initialValue) = expr, case .constantDeclaration = declaration {
            return try emit(constantDeclaration: declaration, initialValue: initialValue, in: codeGen)
        }
        else if case .constantDeclaration = expr {
            return try emit(constantDeclaration: expr, initialValue: nil, in: codeGen)
        }
        else {
            throw Error.codeGenError(location: expr.location,
                                     reason: .expectedConstantDeclaration(got: expr))
        }
    }

    static func emit(
        constantDeclaration declaration: AbstractSyntaxTree.Expression,
        initialValue: AbstractSyntaxTree.Expression?,
        in codeGen: CodeGen
    ) throws -> IRValue? {
        guard case let .constantDeclaration(name, type, _) = declaration else {
            throw Error.codeGenError(location: declaration.location,
                                     reason: .expectedConstantDeclaration(got: declaration))
        }

        if let initialValue = initialValue {
            if let function = codeGen.builder.currentFunction {
                // TODO: Handle constants defined in functions
                return nil
            }
            else {
                return try codeGen.emitGlobal(valueExpression: initialValue, named: name)
            }
        }

        // TODO: Determine the best thing to do if nothing could be done...
        return nil
    }

}
