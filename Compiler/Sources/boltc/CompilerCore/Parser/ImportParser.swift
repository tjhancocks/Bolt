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

struct ImportParser: ParserHelperProtocol {
    func test(for scanner: Scanner<[Token]>) -> Bool {
        if case .keyword(.import, _)? = scanner.peek(), case .identifier? = scanner.peek(ahead: 1) {
            return true
        } else if case .keyword(.import, _)? = scanner.peek(), case .string? = scanner.peek(ahead: 1) {
            return true
        } else {
            return false
        }
    }

    func parse(from scanner: Scanner<[Token]>, ast: AbstractSyntaxTree) throws -> AbstractSyntaxTree.Node {
        let token = try scanner.advance()
        if case .keyword(.import, _) = token, case .identifier(let file, _)? = scanner.peek() {
            try scanner.advance()
            return try self.import(file: file)
        } else if case .keyword(.import, _) = token, case .string(let file, _)? = scanner.peek() {
            try scanner.advance()
            return try self.import(file: file)
        } else {
            throw Parser.Error.unexpectedTokenEncountered(token: token)
        }
    }

    private func `import`(file: String) throws -> AbstractSyntaxTree.ModuleNode {

        print("import \(file)")
        // Check for a user provided file first

        // Check for a library
        for libPath in BuildSystem.main.libraryPaths {
            do {
                let path = libPath.appendingPathComponent(file).appendingPathExtension("bolt")
                let ast = try BuildSystem.Module.import(for: File(url: path))

                if let module = ast.modules.first as? AbstractSyntaxTree.ModuleNode {
                    return module
                }
            }
            catch let error {
                print(error)
                continue
            }
        }

        fatalError("Failed to import \(file)")
    }
}
