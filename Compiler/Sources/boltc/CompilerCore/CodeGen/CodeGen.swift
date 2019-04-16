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
    private(set) var context: Context
    private(set) var ast: AbstractSyntaxTree

    init(ast: AbstractSyntaxTree) {
        let module = LLVM.Module(name: ast.initialModule.name)
        self.ast = ast
        self.context = .init(module: module, builder: .init(module: module))
    }
}

extension CodeGen {
    class Context {
        let module: LLVM.Module
        let builder: LLVM.IRBuilder
        var parameters: [String:LLVM.IRValue]
        var variables: [String:LLVM.IRValue]

        init(module: LLVM.Module, builder: LLVM.IRBuilder) {
            self.module = module
            self.builder = builder
            self.parameters = [:]
            self.variables = [:]
        }
    }
}

extension CodeGen {
    func generateLLVMModule() throws -> LLVM.Module {
        try ast.modules.forEach { node in
            try node.generate(for: context)
        }
        return context.module
    }
}

protocol CodeGeneratorProtocol {
    @discardableResult
    func generate(for context: CodeGen.Context) throws -> IRValue?

    func global(named name: String, for context: CodeGen.Context) throws -> Global?
}

extension CodeGeneratorProtocol {
    func global(named name: String, for context: CodeGen.Context) throws -> Global? {
        return nil
    }
}

extension AbstractSyntaxTree.ModuleNode: CodeGeneratorProtocol {
    @discardableResult
    func generate(for context: CodeGen.Context) throws -> IRValue? {
        try children.forEach { node in
            guard let node = node as? CodeGeneratorProtocol else {
                return
            }
            _ = try node.generate(for: context)
        }
        return nil
    }
}
