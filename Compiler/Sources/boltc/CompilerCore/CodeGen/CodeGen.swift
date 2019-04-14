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
    private var module: LLVM.Module
    private var builder: LLVM.IRBuilder
    private(set) var ast: AbstractSyntaxTree

    init(ast: AbstractSyntaxTree) {
        let module = LLVM.Module(name: ast.initialModule.name)
        self.ast = ast
        self.module = module
        self.builder = .init(module: module)
    }
}

extension CodeGen {
    func generateLLVMModule() throws -> LLVM.Module {
        try ast.walk { node in
            guard let codeGenNode = node as? CodeGenNode else {
                fatalError("AbstractSyntaxTree node encountered that does not support code generation. Node was \(type(of: node))")
            }
            try codeGenNode.generate(for: builder)
        }
        return module
    }
}

protocol CodeGenNode {
    func generate(for builder: LLVM.IRBuilder) throws
}
