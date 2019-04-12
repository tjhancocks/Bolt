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

class Invocation {

    private var arguments: Scanner<[String]>

    init(arguments: [String]) {
        self.arguments = .init(input: Array<String>(arguments[1...]))
    }

    func run() throws {
        // Work through the arguments and setup the build system.
        while arguments.available {
            let arg = try arguments.advance()

            switch arg {
                // Check for a flag
            case "--version":           BuildSystem.main.emitVersion = true

                // If the flag was not found, then attempt to add a new file/module
            default:
                let file = File(path: arg)
                try file.validate()
                BuildSystem.main.add(module: file)
            }
        }

        // Now that all the arguments have been consumed. Kick off the build
        try BuildSystem.main.run()
    }

}

// MARK: - Errors

extension Invocation {
    enum Error: Swift.Error {
        case expectedArgument
    }
}
