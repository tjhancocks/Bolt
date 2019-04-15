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

extension AbstractSyntaxTree.FunctionNode: CodeGeneratorProtocol {
    @discardableResult
    func generate(for context: CodeGen.Context) throws -> IRValue? {
        // Check if the function has already been defined/declared.
        if let function = context.module.function(named: name) {
            print("Note: Already generated function \(name)")
            return function
        }


        // It hasn't so build it.
        let functionType = FunctionType(argTypes: parameters.map({ $0.valueType.IRType }),
                                        returnType: valueType.IRType)
        let function = context.builder.addFunction(name, type: functionType)

        for (var param, node) in zip(function.parameters, parameters) {
            param.name = node.name
        }

        if children.isEmpty == false {
            // Save the current parameters for now, use the ones for this function
            let oldParameters = context.parameters
            context.parameters = [:]
            function.parameters.forEach {
                context.parameters[$0.name] = $0
            }

            let entry = function.appendBasicBlock(named: "entry")
            context.builder.positionAtEnd(of: entry)

            try children.forEach { child in
                guard let child = child as? CodeGeneratorProtocol else {
                    fatalError("-")
                }
                try child.generate(for: context)
            }

            // Restore the old parameters
            context.parameters = oldParameters
        }

        return function
    }
}
