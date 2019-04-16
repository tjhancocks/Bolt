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
    class IdentifierNode: Node {
        private(set) var identifier: String
        private(set) var reference: AbstractSyntaxTree.Node?
        private(set) var mark: Mark

        init(identifier: String, referencing node: AbstractSyntaxTree.Node? = nil, mark: Mark) {
            self.identifier = identifier
            self.reference = node
            self.mark = mark
        }

        override var valueType: Type {
            return reference?.valueType ?? .none
        }

        override var description: String {
            if let reference = reference {
                return "Identifier '\(identifier)' [\(mark)] referencing \(reference)"
            } else {
                return "Identifier '\(identifier)' [\(mark)]"
            }
        }
    }
}

