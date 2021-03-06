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

enum Error: Swift.Error {
    // Too few arguments given to the compiler.
    case tooFewArguments

    // Compiler expected an argument but found nothing
    case expectedArgument(for: String)

    // Source Error: file.bolt -- file not found
    case fileError(reason: FileError)

    // Lexical analysis error: file.bolt:1:1 -- unexpected end of stream.
    case lexerError(location: Mark, reason: LexerError)

    // Syntax error: file.bolt:1:1 -- unexpected token encountered.
    case parserError(location: Mark, reason: ParserError)

    // Type error: file.bolt:1:1 -- type mismatch
    case typeError(location: Mark, reason: TypeError)

    // Semantic error: file.bolt:1:1 -- illegal use of ...
    case semaError(location: Mark, reason: SemaError)

    // Code generation error: file.bolt:1:1 -- missing declaration
    case codeGenError(location: Mark, reason: CodeGenError)
}

extension Error: CustomStringConvertible {
    var description: String {
        switch self {
        case .lexerError(let location, let reason):
            return "Lexical analysis error: \(location) -- \(reason)"

        case .parserError(let location, let reason):
            return "Syntax error: \(location) -- \(reason)"

        case .typeError(let location, let reason):
            return "Type error: \(location) -- \(reason)"

        case .semaError(let location, let reason):
            return "Semantic error: \(location) -- \(reason)"

        case .fileError(let reason):
            return "Source error: \(reason)"

        case .codeGenError(let location, let reason):
            return "Code generation error: \(location) -- \(reason)"

        default:
            return "Unknown error occurred"
        }
    }
}

extension Error {
    func report() {
        print(self)
    }
}
