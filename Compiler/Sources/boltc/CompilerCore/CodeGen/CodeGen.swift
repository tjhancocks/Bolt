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

class CodeGen {
    private(set) var ast: AbstractSyntaxTree
    private(set) var module: LLVM.Module
    private(set) var builder: LLVM.IRBuilder

    private(set) var autoLabelCount: Int = 0

    init(ast: AbstractSyntaxTree) {
        let module = LLVM.Module(name: ast.moduleName)
        self.builder = LLVM.IRBuilder(module: module)
        self.module = module
        self.ast = ast
    }

    func generateAutoLabel() -> String {
        let label = "L\(autoLabelCount)"
        autoLabelCount += 1
        return label
    }

    func emit() throws -> LLVM.Module {
        _ = try emit(expressions: ast.expressions)
        return module
    }

    func emit(expressions: [AbstractSyntaxTree.Expression]) throws -> LLVM.IRValue? {
        var outputValue: LLVM.IRValue?

        for expression in expressions {
            // We're only interested in the last value of a series of expressions.
            outputValue = try emit(expression: expression)
        }

        return outputValue
    }

    func emit(expression: AbstractSyntaxTree.Expression) throws -> LLVM.IRValue? {
        switch expression {
        case .functionDeclaration, .definition(.functionDeclaration, _):
            return try FunctionCodeGen.emit(for: expression, in: self)

        case .constantDeclaration, .definition(.constantDeclaration, _):
            return try ConstantCodeGen.emit(for: expression, in: self)

        default:
            return nil
        }
    }

    func emitGlobal(valueExpression: AbstractSyntaxTree.Expression, named name: String? = nil) throws -> LLVM.Global? {
        switch valueExpression {
        case .string:
            return try StringCodeGen.emitGlobal(for: valueExpression, named: name, in: self)

        default:
            return nil
        }
    }
}

protocol CodeGenProtocol {
    static func emit(for expr: AbstractSyntaxTree.Expression, in codeGen: CodeGen) throws -> LLVM.IRValue?
}

protocol GlobalCodeGenProtocol {
    static func emitGlobal(for expr: AbstractSyntaxTree.Expression, named name: String?, in codeGen: CodeGen) throws -> LLVM.Global?
}
