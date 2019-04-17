# Bolt ![BuildCIBadge](https://travis-ci.org/tjhancocks/Bolt.svg?branch=develop)

Bolt will be a programming language and compiler, intended to be a replacement for C in my own personal projects. For this reason it will largely be a general purpose language capable of tasks ranging from _Kernel Development_ to _App Development_.

```bolt
// A simple Hello, World program in Bolt.
import std

func<Int> main() {
	print("Hello, World")
	return 0
}
```

### The current state of Bolt
Bolt is still **very** much in its infancy. The language is still be fleshed out and designed. The ideas are changing and evolving almost daily. It is by no means ready for actual use.

I've made it publically viewable, either so people can get involved if they want to, or see the evolution of a new language and compiler. Will it ever match the popularity or usage of something like Rust, Swift, Python, etc... most likely not, but that's not why I'm developing it.

### v0.0.2 Milestone
The current v0.0.1 of the compiler is capable of building a basic _Hello, World_ program. This represents the first major milestone of the project. With that reach, my sights are now on the second major milestone. This includes improvements to the architecture of the compiler, adding the ability to use variadic arguments, better type coverage, compiler directives, arithmatic, bracketed expressions and order of operations.

### High level concepts and ideas for Bolt
_**Important:** Details listed below may change quickly and frequently, and is meant to represent a general idea of the concepts employed by the project currently._

Bolt is primarily being designed to be readable and easily written. This is easier said than done, and will likely mean that the syntax of the language is changable for some time.

One of the concepts currently being played with is how types are associated to declarations. Take a the following declaration in C.

```c
// Define foo to be an integer with value 50.
int foo = 50;
```

This is quite a simple definition, and the type _leads_ the definition. With bolt we'd write the same thing like

```bolt
var<Int> foo = 50
```

This is a convention used throughout many declaration in Bolt. The root keyword of the declaration (`var`, `let`, `func`, etc) followed by the resulting type in angle brackets `< >`. The goal is that it should be easy to tell what type something ultimately is.

### License
Bolt is provided under the MIT License, and thus free to use make use of in anyway you see fit. All that I ask is you provide the following license with any other versions of Bolt.

This license applies to the _Compiler_ and the _Standard Library_ of Bolt, but not the language itself... though I would ask for some form of attribution in any of implementation of the language.

```
Copyright (c) 2019 Tom Hancocks

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
