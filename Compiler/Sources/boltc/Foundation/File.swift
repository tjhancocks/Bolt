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

/// The `File` structure is responsible for representing a file on disk.
struct File: Equatable {
    private static let unknown: String = "(unknown file)"

	private(set) var path: String
    private(set) var virtual: Bool

	/// Create a new file reference with the specified path.
	///
	/// The created file does not need to exist and can just be a reference to
	/// a file that _should_ be created.
	init(path: String) {
		self.path = path
        self.virtual = false
	}

    /// Create a new virtual file.
    ///
    /// The created file does not exist in the file system, and is used with
    /// source objects that do not originate from disk.
    init() {
        self.path = "memory"
        self.virtual = true
    }

    /// The name of the file.
    var name: String {
        guard let lastPathComponent = path.components(separatedBy: "/").last else {
            return File.unknown
        }
        return lastPathComponent
    }

    /// The proposed module name of the file.
    var moduleName: String {
        var fileComponents = name.components(separatedBy: ".")
        fileComponents.removeLast()
        return fileComponents.joined(separator: ".")
    }
}

// MARK: - Loading Source Code

extension File {
    func loadSource() throws -> Source {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            throw Error.fileNotFound(path: path)
        }

        guard let text = String(data: data, encoding: .utf8) else {
            throw Error.badFileEncoding(path: path)
        }

        return Source(text, file: self)
    }
}

// MARK: - Description

extension File: CustomStringConvertible {
    var description: String {
        return name
    }
}

// MARK: - Error

extension File {
    enum Error: Swift.Error {
        case fileNotFound(path: String)
        case badFileEncoding(path: String)
    }
}

extension File.Error: Reportable {
    var report: (severity: ReportSeverity, text: String) {
        switch self {
        case let .fileNotFound(path):
            return (.error, "File not found: \(path)")

        case let .badFileEncoding(path):
            return (.error, "File encoding was not UTF-8: \(path)")
        }
    }
}
