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

class Scanner<T> where T: Collection {

    private(set) var input: T
    private var index: T.Index

    init(input: T) {
        self.input = input
        self.index = input.startIndex
    }

    /// Peek at an element `n` positions ahead of the current index.
    ///
    /// This will return nil if no element exists at that position
    func peek(ahead n: Int = 0) -> T.Element? {
        guard let offset = input.index(index, offsetBy: n, limitedBy: input.endIndex), offset < input.endIndex else {
            return nil
        }
        return input[offset]
    }

    /// Peek at a sub collection of items, that stretches from the current index
    /// to `n` positions away.
    func peekCollection(of n: Int = 0) -> T.SubSequence? {
        guard let offset = input.index(index, offsetBy: n, limitedBy: input.endIndex) else {
            return nil
        }
        return input[index..<offset]
    }

    /// Check the value of the element is equal to the specified value.
    @discardableResult
    func advance(by n: Int = 1) -> T.Element {
        guard let offset = input.index(index, offsetBy: n, limitedBy: input.endIndex) else {
            fatalError("Stream scanner has gone out of bounds! Aborting now.")
        }
        let item = input[index]
        index = offset
        return item
    }

    /// Returns true if their are still more items available for the scanner
    /// to consume.
    var available: Bool {
        return index < input.endIndex
    }
}
