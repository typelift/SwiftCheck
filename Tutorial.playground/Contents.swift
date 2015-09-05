//: Playground - noun: a place where people can play

import SwiftCheck
import XCTest

//: # Prerequisites

//: This tutorial assumes that you have a fairly good grasp of Swift, its syntax, and terms like
//: 
//: * [(Data) Type](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TheBasics.html)
//: * [Protocol-Oriented Programming](https://developer.apple.com/videos/wwdc/2015/?id=408)
//: * [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development)
//: * [Polymorphism](https://en.wikipedia.org/wiki/Polymorphism)
//: * [Map/Filter/Reduce](https://medium.com/@ivicamil/higher-order-functions-in-swift-part-1-d8e75f963d13)
//:
//: What this tutorial does *not* require is that you know about
//:
//: * [Abstract Nonsense](https://en.wikipedia.org/wiki/Abstract_nonsense)
//: * Functional Programming
//: * What that dumb ['M' word](https://wiki.haskell.org/Monad) is/does/means

//: # Introduction

//: SwiftCheck is a testing library that augments libraries like `XCTest` and `Quick`, by giving them
//: the ability to automatically test program properties.  A property is a particular facet of an
//: algorithm, method, data structure, or program that must *hold* (that is, remain valid) even when
//: fed random or pseudo-random data.  If that all seems complicated, it may be simpler to think of
//: Property Testing like Fuzz Testing, but with the outcome being to satisfy requirements rather than
//: break the program.  Throughout this tutorial, simplifications like the above will be made to aid
//: your understanding.  Towards the end of it, we will begin to remove much of these "training wheels"
//: and reveal the real types of the operations in the library, which are often much more powerful and
//: generic than previously presented.



