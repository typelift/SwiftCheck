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
//: and reveal the real concepts and types of the operations in the library, which are often much more
//: powerful and generic than previously presented.
//:
//: This tutorial is divided into 3 parts, each meant to espouse a different aspect of the SwiftCheck
//: library.

//: # `Gen`erators

//: In Swift, when one thinks of a Generator, they usually think of the `GeneratorType` protocol or the
//: many many individual structures the Swift Standard Library exposes to allow loops to work with data
//: structures like `[T]` and `Set<T>`.  In Swift, we also have Generators, but we spell them `Gen`erators,
//: as in the universal Generator type `Gen`.  `Gen` is a struct defined generically over any kind of type
//: that looks like this:
//
//     /// We're not defining this here; We'll be using SwiftCheck's `Gen` from here on out.
//     struct Gen<Wrapped> { }
//
//: `Gen`, unlike `GeneratorType`, is not backed by a concrete data structure like an array or dictionary,
//: but is instead constructed by invoking methods that refine the kind of data that gets generated.  Below
//: are some examples of `Gen`erators that generate random instances of simple data types.

// `Gen.pure` constructs a generator that *only* produces the given value.
let onlyFive = Gen.pure(5)

onlyFive.generate
onlyFive.generate
onlyFive.generate
onlyFive.generate
onlyFive.generate

// `Gen.fromElementsIn` constructs a generator that pulls values from inside the 
// bounds of the given Range.  Because generation is random, some values may be repeated.
let fromOnetoFive = Gen<Int>.fromElementsIn(1...5)

fromOnetoFive.generate
fromOnetoFive.generate
fromOnetoFive.generate
fromOnetoFive.generate
fromOnetoFive.generate

let lowerCaseLetters : Gen<Character> = Gen<Character>.fromElementsIn("a"..."z")

lowerCaseLetters.generate
lowerCaseLetters.generate
lowerCaseLetters.generate

let upperCaseLetters : Gen<Character> = Gen<Character>.fromElementsIn("A"..."Z")

upperCaseLetters.generate
upperCaseLetters.generate
upperCaseLetters.generate

// `Gen.fromElementsOf` works like `Gen.fromElementsIn` but over an Array, not just a Range.
let specialCharacters = Gen<Character>.fromElementsOf([ "!", "@", "#", "$", "%", "^", "&", "*", "(", ")" ])

specialCharacters.generate
specialCharacters.generate
specialCharacters.generate
specialCharacters.generate

//: But SwiftCheck `Gen`erators aren't just flat types, they stack and compose and fit together in amazing
//: ways.

// `Gen.oneOf` randomly picks one of the generators from the given list and draws element from it.
let uppersAndLowers = Gen<Character>.oneOf([
	lowerCaseLetters,
	upperCaseLetters,
])

uppersAndLowers.generate
uppersAndLowers.generate
uppersAndLowers.generate
uppersAndLowers.generate
uppersAndLowers.generate

// `Gen.zip` works like `zip` in Swift but with `Gen`erators.
let pairsOfNumbers = Gen<(Int, Int)>.zip(fromOnetoFive, fromOnetoFive)

pairsOfNumbers.generate
pairsOfNumbers.generate
pairsOfNumbers.generate

//: `Gen`erators don't have to always generate their elements with equal frequency.  SwiftCheck includes a number
//: of functions for creating `Gen`erators with "weights" attached to their elements.

// This generator ideally generates nil 1/4 (1 / (1 + 3)) of the time and `.Some(5)` 3/4 of the time.
let weightedGen = Gen<Int?>.weighted([
	(1, nil),
	(3, .Some(5)),
])

weightedGen.generate
weightedGen.generate
weightedGen.generate
weightedGen.generate

// `Gen.frequency` works like `Gen.weighted` and `Gen.oneOf` put together.
let biasedUppersAndLowers = Gen<Character>.frequency([
	(1, uppersAndLowers),
	(3, lowerCaseLetters),
])

//: `Gen`erators can even filter, modify, or combine the elements they create to produce.

// `suchThat` takes a predicate function that filters generated elements.
let oneToFiveEven = fromOnetoFive.suchThat { $0 % 2 == 0 }

oneToFiveEven.generate
oneToFiveEven.generate
oneToFiveEven.generate

// `proliferate` turns a generator of single elements into a generator of arrays of those elements. 
let characterArray = uppersAndLowers.proliferate()

characterArray.generate
characterArray.generate
characterArray.generate

/// `proliferateNonEmpty` works like `proliferate` but guarantees the generated array is never empty.
let oddLengthArrays = fromOnetoFive.proliferateNonEmpty().suchThat { $0.count % 2 == 1 }

oddLengthArrays.generate.count
oddLengthArrays.generate.count
oddLengthArrays.generate.count










