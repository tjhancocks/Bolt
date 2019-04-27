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

struct FunctionCodeGen: CodeGenProtocol {

    static func emit(for expr: AbstractSyntaxTree.Expression, in codeGen: CodeGen) throws -> IRValue? {
        if case  .functionDeclaration = expr {
            return try emit(functionDeclaration: expr, in: codeGen)
        }
        else if case let .definition(declaration, body) = expr, case .functionDeclaration = declaration {
            let function = try emit(functionDeclaration: declaration, in: codeGen)

            // Produce the body of the function
            codeGen.saveCurrentScope()

            // Build the parameters for the function.
            var parameters: [String: LLVM.IRValue] = [:]
            function.parameters.forEach {
                parameters[$0.name] = $0
            }
            codeGen.set(parameters: parameters)

            let entry = function.appendBasicBlock(named: "entry")
            codeGen.builder.positionAtEnd(of: entry)

            _ = try codeGen.emit(expression: body)

            codeGen.restorePreviousScope()

            return function
        }
        else {
            throw Error.codeGenError(location: expr.location,
                                     reason: .expectedFunctionDeclaration(got: expr))
        }
    }

    static func emit(functionDeclaration expr: AbstractSyntaxTree.Expression, in codeGen: CodeGen) throws -> Function {
        guard case let .functionDeclaration(name, returnType, parameters, _) = expr else {
            throw Error.codeGenError(location: expr.location,
                                     reason: .expectedFunctionDeclaration(got: expr))
        }

        // If there is already a version of the function then use that.
        if let function = codeGen.module.function(named: name) {
            return function
        }

        let functionType = FunctionType(argTypes: parameters.map { $0.type.IRType},
                                        returnType: returnType.type.IRType)
        let function = codeGen.builder.addFunction(name, type: functionType)

        for (var funcParameter, parameter) in zip(function.parameters, parameters) {
            guard case let .parameterDeclaration(name, _, _) = parameter else {
                throw Error.codeGenError(location: parameter.location,
                                         reason: .expectedParameterDeclaration(got: parameter))
            }
            funcParameter.name = name
        }

        return function
    }

}
