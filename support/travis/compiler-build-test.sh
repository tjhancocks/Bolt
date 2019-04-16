# Copyright (c) 2019 Tom Hancocks
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

echo "Building bolt compiler and checking for valid response."

# Switch to the compiler directory and then build and run boltc.
cd Compiler
swift package resolve
swift .build/checkouts/LLVMSwift/utils/make-pkgconfig.swift 
RESULT=$(swift run boltc --validate-bolt)

# Check if the result contains the required response text.
if [[ ${RESULT} == *"boltc built ok"* ]]; then
	echo "Bolt compiler built successfully."
else
	echo "Bolt compiler built with errors."
	exit 1
fi

# Attempt to build "hello.bolt" and verify its output.
RESULT=$(swift run boltc -o test ../Samples/hello.bolt && ./test)
if [[ ${RESULT} == *"Hello, World!"* ]]; then
	echo "hello.bolt was built and run correctly."
else
	echo "hello.bolt was built and run with errors."
	exit 1
fi