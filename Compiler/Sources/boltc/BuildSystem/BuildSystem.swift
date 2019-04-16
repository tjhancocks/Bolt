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
import LLVM

class BuildSystem {

    // Build artefacts
    private(set) var modules: [Module] = []

    // Build flags
    var emitValidationResponse: Bool = false
    var emitVersion: Bool = false
    var outputPath: String = "program"
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
        if emitValidationResponse {
            print("boltc built ok")
            exit(0)
        }

        if emitVersion {
            print("Bolt Compiler")
            print(" boltc v0.0.1")
            print(" MIT License - Copyright (c) 2019 Tom Hancocks")
            exit(0)
        }

        try modules.forEach { module in
            try module.build()
        }

        // Link all modules together
        try BuildSystem.main.link(binary: BuildSystem.main.outputPath, objects: modules.map({ $0.objectFile }))
    }
}

extension BuildSystem.Module {
    private func artefactPath(for moduleName: String, and fileExtension: String) -> String {
        let buildDirectory = URL(fileURLWithPath: ".bolt-build", isDirectory: true)

        // Attempt to create the build directory if its needed.
        do {
            try FileManager.default.createDirectory(at: buildDirectory, withIntermediateDirectories: true, attributes: nil)
            return buildDirectory.appendingPathComponent(moduleName).appendingPathExtension(fileExtension).path
        }
        catch {
            fatalError()
        }
    }

    private func target() throws -> LLVM.TargetMachine {
        return try .init()
    }

    var objectFile: String {
        return artefactPath(for: file.moduleName, and: "o")
    }

    var asmFile: String {
        return artefactPath(for: file.moduleName, and: "s")
    }

    var irFile: String {
        return artefactPath(for: file.moduleName, and: "ll")
    }

    static func `import`(for file: File) throws -> AbstractSyntaxTree {
        let lexer = Lexer(source: try file.loadSource())
        let parser = Parser(tokenStream: try lexer.performAnalysis())
        return try parser.parse()
    }

    func build() throws {
        ast = try BuildSystem.Module.import(for: file)

        guard let ast = ast else {
            fatalError("The compiler has lost track of the AbstractSyntaxTree. This should not happen.")
        }

        let sema = Sema(ast: ast)
        try sema.performAnalysis()

        let generator = CodeGen(ast: ast)
        let module = try generator.generateLLVMModule()

        try exportIr(module: module)
        try exportObject(module: module)
        try exportAsm(module: module)
    }

    func exportIr(module: LLVM.Module) throws {
        do {
            try module.print(to: irFile)
        }
        catch let error {
            fatalError("\(error)")
        }
    }

    func exportObject(module: LLVM.Module) throws {
        do {
            try target().emitToFile(module: module, type: .object, path: objectFile)
        }
        catch let error {
            fatalError("\(error)")
        }
    }

    func exportAsm(module: LLVM.Module) throws {
        do {
            try target().emitToFile(module: module, type: .assembly, path: asmFile)
        }
        catch let error {
            fatalError("\(error)")
        }
    }
}

extension BuildSystem {
    private func shell(launchPath: String, arguments: [String]) -> String? {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: String.Encoding.utf8)

        return output
    }

    func link(binary: String, objects: [String]) throws {
        if let result = shell(launchPath: "/usr/bin/ld", arguments: ["-lc", "-o", binary] + objects), result.isEmpty == false {
            print("\(result)")
        }
    }
}
