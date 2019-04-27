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

struct StringCodeGen: CodeGenProtocol, GlobalCodeGenProtocol {

    static func emit(for expr: AbstractSyntaxTree.Expression, in codeGen: CodeGen) throws -> IRValue? {
        guard case let .string(value, _) = expr else {
            throw Error.codeGenError(location: expr.location,
                                     reason: .expectedString(got: expr))
        }

        if codeGen.builder.currentFunction != nil {
            return codeGen.builder.buildGlobalStringPtr(value)
        }
        else {
            return try emitGlobal(for: expr, in: codeGen)
        }
    }

    static func emitGlobal(for expr: AbstractSyntaxTree.Expression, named name: String? = nil, in codeGen: CodeGen) throws -> Global? {
        guard case let .string(value, _) = expr else {
            throw Error.codeGenError(location: expr.location,
                                     reason: .expectedString(got: expr))
        }

        return codeGen.builder.addGlobalString(name: name ?? codeGen.generateAutoLabel(), value: value)
    }

}
