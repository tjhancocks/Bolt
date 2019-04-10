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

class Lexer {
    private(set) var scanner: Scanner<String>

    private var line: UInt = 0
    private var lineOffset: UInt = 0
    private let file: File
    private var currentMark: Mark = .unknown

    init(source: Source) {
        self.scanner = source.scanner
        self.file = source.file
    }
}

// MARK: - Source Location

extension Lexer {

    private func handle(character: Character) {
        switch character {
        case "\n":
            line += 1
            lineOffset = 0

        default:
            lineOffset += 1
        }
    }

    private func handle(string: String) {
        string.forEach { handle(character: $0) }
    }

    private func updateMark() {
        currentMark = Mark(file: file, line: line, offset: lineOffset)
    }

}

// MARK: - Source Consumption

extension Lexer {

    private func peek(ahead n: Int = 0) -> Character? {
        return scanner.peek(ahead: n)
    }

    private func peekString(of n: Int = 0) -> String? {
        guard let subsequence = scanner.peekCollection(of: n) else {
            return nil
        }
        return String(subsequence)
    }

    @discardableResult
    private func advance(by n: Int = 1) throws -> Character {
        guard let string = peekString(of: n) else {
            throw Error.unexpectedEndOfSource
        }
        handle(string: string)
        return try scanner.advance(by: n)
    }

    private func test(_ next: String, advanceOnMatch: Bool = false) throws -> Bool {
        if let string = peekString(of: next.count), string == next {
            if advanceOnMatch {
                try advance(by: next.count)
            }
            return true
        } else {
            return false
        }
    }

    private func test(_ body: (Character) -> Bool, advanceOnMatch: Bool = false) throws -> Bool {
        if let char = peek(), body(char) {
            if advanceOnMatch {
                try advance()
            }
            return true
        } else {
            return false
        }
    }

}

// MARK: - Lexical Analysis

extension Lexer {

    @discardableResult
    func performAnalysis() throws -> TokenStream {
        var discoveredTokens: [Token] = []

        // As long as there are characters available in the scanner, we need to
        // keep going...
        while scanner.available {
            // Consume any white space leading up to the next interesting thing.
            try consumeWhitespace(newlines: true)

            updateMark()
            if try test(LanguageSpec.current.commentPrefix, advanceOnMatch: true) {
                try consumeComment()
            }
            else if try test(LanguageSpec.current.doubleQuotedStringPrefix, advanceOnMatch: true) {
                discoveredTokens.append(try consumeString())
            }
            else if try test(isNumber(_:)) {
                discoveredTokens.append(try consumeNumber())
            }
			else if try test(isIdentifier(_:)) {
				discoveredTokens.append(try consumeIdentifier())
			}
            else {
                throw Error.unexpectedCharacterEncountered(character: try advance(), mark: currentMark)
            }
        }
        
        return TokenStream(tokens: discoveredTokens)
    }

}

// MARK: - Consumers

extension Lexer {
    private func consumeWhitespace(newlines: Bool = false) throws {
        while let c = peek(), c.isWhitespace || (newlines && c.isNewline) {
            try advance()
        }
    }
    private func consumeComment() throws {
        while let c = peek(), c.isNewline == false {
            try advance()
        }
        try advance()
    }

    private func consumeString() throws -> Token {
        var text: String = ""
        while let c = peek(), String(c) != LanguageSpec.current.doubleQuotedStringSuffix {
            text.append(try advance())
        }
        try advance()
        return .string(text: text, mark: currentMark)
    }

    private func consumeNumber() throws -> Token {
        var text: String = ""
        while let c = peek(), isNumber(c) || c == "." {
            text.append(try advance())
        }

        if let number = Int(text) {
            return .integer(number: number, text: text, mark: currentMark)
        }
        else if let number = Double(text) {
            return .float(number: number, text: text,mark: currentMark)
        }
        else {
            throw Error.invalidNumericToken(text: text, mark: currentMark)
        }
    }

    private func consumeIdentifier() throws -> Token {
        var text: String = ""
        while let c = peek(), isIdentifier(c) {
            text.append(try advance())
        }

        return .identifier(text: text, mark: currentMark)
    }
}

// MARK: - Tests

extension Lexer {
    private func isNumber(_ c: Character) -> Bool {
        return CharacterSet.numberSet.contains(c)
    }
	
	private func isIdentifier(_ c: Character) -> Bool {
		return CharacterSet.identifierSet.contains(c)
	}
}

// MARK: - Error

extension Lexer {
    enum Error: Swift.Error {
        case unexpectedEndOfSource
        case invalidNumericToken(text: String, mark: Mark)
        case unexpectedCharacterEncountered(character: Character, mark: Mark)
    }
}

extension Lexer.Error: Reportable {
    var report: (severity: ReportSeverity, text: String) {
        switch self {
        case .unexpectedEndOfSource:
            return (.critical, "Unexpected end of source encountered.")
        case let .invalidNumericToken(text, mark):
            return (.error, "Invalid numeric token '\(text)' at \(mark)")
        case let .unexpectedCharacterEncountered(char, mark):
            return (.error, "Unexpected character '\(char)' encountered at \(mark)")
        }
    }
}
