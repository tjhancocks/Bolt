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

final class LanguageSpec {
    static var version: Version {
        return current.version
    }

    static let current = LanguageSpec()

    var version: Version = .v001
}

// MARK: - Versioning Support

protocol LanguageSpecVersion {
    var commentPrefix: String { get }
}


// MARK: - Versions

extension LanguageSpec {
    struct Version: LanguageSpecVersion {
        var commentPrefix: String = "//"
        var doubleQuotedStringPrefix: String = "\""
        var doubleQuotedStringSuffix: String = "\""
    }
}

extension LanguageSpec: LanguageSpecVersion {
    var commentPrefix: String {
        return version.commentPrefix
    }

    var doubleQuotedStringPrefix: String {
        return version.doubleQuotedStringPrefix
    }

    var doubleQuotedStringSuffix: String {
        return version.doubleQuotedStringSuffix
    }
}


// MARK: - v0.0.1

extension LanguageSpec.Version {
    static var v001: LanguageSpec.Version {
        return .init()
    }
}
