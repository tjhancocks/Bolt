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
        let token = scanner.advance()
        if case .keyword(.import, _) = token, case .identifier(let file, _)? = scanner.peek() {
            scanner.advance()
            let imported = try self.import(file: file)
            if let firstModule = imported.modules.first {
                ast.add(modules: imported.modules, symbols: imported.symbolTable.rootSymbols)
                return firstModule
            }

        } else if case .keyword(.import, _) = token, case .string(let file, _)? = scanner.peek() {
            scanner.advance()
            let imported = try self.import(file: file)
            if let firstModule = imported.modules.first {
                ast.add(modules: imported.modules, symbols: imported.symbolTable.rootSymbols)
                return firstModule
            }
            
        }

        throw Error.parserError(location: scanner.location,
                                reason: .unexpectedTokenEncountered(token: token))
    }

    private func `import`(file: String) throws -> (modules: [AbstractSyntaxTree.ModuleNode], symbolTable: SymbolTable) {
        // Check for a user provided file first

        // Check for a library
        for libPath in BuildSystem.main.libraryPaths {
            do {
                let path = libPath.appendingPathComponent(file).appendingPathExtension("bolt")
                let ast = try BuildSystem.Module.import(for: File(url: path))

                return (ast.modules, ast.symbolTable)
            }
            catch let error {
                print(error)
                continue
            }
        }

        throw Error.fileError(reason: .importFailed(fileNamed: file))
    }
}
