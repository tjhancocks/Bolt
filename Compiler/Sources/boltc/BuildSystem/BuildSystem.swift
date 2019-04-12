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

import Foundation

class BuildSystem {

    // Build artefacts
    private(set) var modules: [Module] = []

    // Build flags
    var emitVersion: Bool = false
    private(set) var libraryPaths: [URL] = []

    // Only one build system should exist - so its a singleton
    static let main = BuildSystem()
    private init() {}

    func add(module moduleFile: File) {
        self.modules.append(Module(for: moduleFile))
    }

    func add(libraryPath: String) throws {
        let url = URL(fileURLWithPath: libraryPath)
        libraryPaths.append(url)
    }

}

// MARK: - Modules

extension BuildSystem {
    class Module {
        private(set) var file: File
        private(set) var buildSystem: BuildSystem
        private(set) var ast: AbstractSyntaxTree?

        init(for file: File, in buildSystem: BuildSystem = .main) {
            self.file = file
            self.buildSystem = buildSystem
        }
    }
}

// MARK: - Build

extension BuildSystem {
    func run() throws {
        // Some flags/options require an immediate action, or even termination
        // of the compiler.
        if emitVersion {
            print("Bolt Compiler")
            print(" boltc v0.0.1")
            print(" MIT License - Copyright (c) 2019 Tom Hancocks")
            exit(0)
        }

        try modules.forEach { module in
            try module.build()
        }
    }
}

extension BuildSystem.Module {
    static func `import`(for file: File) throws -> AbstractSyntaxTree {
        let lexer = Lexer(source: try file.loadSource())
        let parser = Parser(tokenStream: try lexer.performAnalysis())
        return try parser.parse()
    }

    func build() throws {
        ast = try BuildSystem.Module.import(for: file)
    }
}
