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

SHELL := /bin/bash
BUILD := .build
SUBLIME.SUPPORT = ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages

################################################################################
## GENERAL
## General rules for interacting with the project as a whole rather than in
## specific targeted ways.

.PHONY: all clean
all: compiler-test build-plugins

clean:
	-rm -rf $(BUILD)

################################################################################
## COMPILER BUILD & INSTALLATION
## Build the compiler and/or install it into /usr/local/bin directory.
.PHONY: boltc install-boltc

boltc: build/boltc

install-boltc: boltc
	cp $(BUILD)/boltc /usr/local/bin/boltc
	mkdir -p /usr/local/lib/bolt
	cp stdlib/* /usr/local/lib/bolt

build/boltc:
	sh support/build/boltc.sh

################################################################################
## COMPILER TEST
## This is a script that is run on TravisCI or locally to verify that the 
## compiler is building correctly and producing a valid output.
##
## Any alterations to this _must_ be verified before merging to develop as any
## errors in this will render test results potentially invalid.
.PHONY: compiler-test
compiler-test:
	sh support/travis/compiler-build-test.sh

################################################################################
## BUILD PLUGINS
## This section is covering the build rules for the various plugins that are
## provided by Bolt, such as Sublime Text Integration.\
.PHONY: build-plugins
build-plugins: build-sublime-package

## SUBLIME TEXT ----------------------------------------------------------------
SUBLIME-PKG := Bolt.sublime-package

.PHONY: build-sublime-package
build-sublime-package: clean $(BUILD)/Bolt.sublime-package
	- rm $(SUBLIME.SUPPORT)/$(SUBLIME-PKG)
	- sleep 1
	- cp $(BUILD)/$(SUBLIME-PKG) $(SUBLIME.SUPPORT)/$(SUBLIME-PKG)

$(BUILD)/$(SUBLIME-PKG):
	mkdir -p $(BUILD)
	zip -jr $@ support/plugins/sublime-text/Bolt