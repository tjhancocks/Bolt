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

extension AbstractSyntaxTree {
    class FunctionNode: Node {
        private(set) var name: String
        private(set) var returnType: AbstractSyntaxTree.TypeNode
        private(set) var parameters: [AbstractSyntaxTree.ParameterNode]
        private(set) var mark: Mark

        override var valueType: Type {
            return returnType.valueType
        }

        init(name: String, returnType: AbstractSyntaxTree.TypeNode, parameters: [AbstractSyntaxTree.ParameterNode], mark: Mark) {
            self.name = name
            self.mark = mark
            self.returnType = returnType
            self.parameters = parameters
        }

        override var description: String {
            return "Function '\(name)' returning '\(returnType)' and \(parameters.count) parameter(s) [\(mark)]"
        }
    }
}

