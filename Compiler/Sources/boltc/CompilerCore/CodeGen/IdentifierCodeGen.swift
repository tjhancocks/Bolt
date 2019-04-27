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

struct IdentifierCodeGen: CodeGenProtocol {

    static func emit(for expr: AbstractSyntaxTree.Expression, in codeGen: CodeGen) throws -> IRValue? {
        if case let .boundIdentifier(.constantDeclaration(name, type, _), _) = expr {
            // Constant
            guard let constant = codeGen.variables[name] else {
                return nil
            }

            if type.type.resolvedType == .pointer(.int8) {
                return codeGen.builder.buildGEP(constant, indices: [0, 0])
            } else {
                return constant
            }
        }
        else if case let .boundIdentifier(.parameterDeclaration(name, _, _), _) = expr {
            // Parameter
            return codeGen.parameters[name]
        }
        else {
            throw Error.codeGenError(location: expr.location,
                                     reason: .unexpectedExpression(got: expr))
        }
    }

}
