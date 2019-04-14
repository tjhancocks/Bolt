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

extension AbstractSyntaxTree.CallNode: SemaNode {

    func performSemanticAnalysis() throws -> [AbstractSyntaxTree.Node] {
        guard let function = function.reference as? AbstractSyntaxTree.FunctionNode else {
            throw Error.semaError(location: location, reason: .expectedFunctionForCall)
        }

        guard function.parameters.count == children.count else {
            throw Error.semaError(location: location,
                                  reason: .incorrectArgumentCount(expected: function.parameters.count, got: children.count))
        }

        try zip(function.parameters, children).enumerated().forEach { offset, parameter in
            guard parameter.0.valueType == parameter.1.valueType else {
                throw Error.semaError(location: location,
                                      reason: .argumentTypeMismatch(expected: parameter.0.valueType, got: parameter.1.valueType, at: offset))
            }
        }

        return [self]
    }

}
