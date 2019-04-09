import XCTest

import boltcTests

var tests = [XCTestCaseEntry]()
tests += CompilerTests.allTests()
XCTMain(tests)
