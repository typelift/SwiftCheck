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
//: as in the universal Generator type `Gen`.  
//:
//: `Gen` is a struct defined generically over any kind of type that looks like this:
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

//: Generators also admit functional methods like `map` and `flatMap`, but with different names than you might
//: be used to.

// `fmap` (function map) works exactly like Array's `map` method; it applies the function to any 
// values it generates.
let fromTwoToSix = fromOnetoFive.fmap { $0 + 1 }

fromTwoToSix.generate
fromTwoToSix.generate
fromTwoToSix.generate
fromTwoToSix.generate
fromTwoToSix.generate

// `bind` works exactly like Array's `flatMap`, but instead of concatenating the generated arrays it produces
// a new generator that picks values from among the newly created generators produced by the function.  While
// That definition may *technically* be what occurs, it is better to think of `bind` as a way of making a generator
// depend on another.  For example, you can use a generator of sizes to limit the length of generators of arrays:

let generatorBoundedSizeArrays = fromOnetoFive.bind { len in
	return characterArray.suchThat { xs in xs.count <= len }
}

generatorBoundedSizeArrays.generate
generatorBoundedSizeArrays.generate
generatorBoundedSizeArrays.generate
generatorBoundedSizeArrays.generate
generatorBoundedSizeArrays.generate

//: Because SwiftCheck is based on the functional concepts in our other library [Swiftz](https://github.com/typelift/Swiftz),
//: each of these functions has an operator alias:
//:
//: * `<^>` is an alias for `fmap`
//: * `<*>` is an alias for `ap`
//: * `>>-` is an alias for `bind`

// <^> is backwards for aesthetic and historical purposes.  Its true use will be revealled soon.
let fromTwoToSix_ = { $0 + 1 } <^> fromOnetoFive

fromTwoToSix_.generate
fromTwoToSix_.generate
fromTwoToSix_.generate

let generatorBoundedSizeArrays_ = fromOnetoFive >>- { len in
	return characterArray.suchThat { xs in xs.count <= len }
}

generatorBoundedSizeArrays_.generate
generatorBoundedSizeArrays_.generate
generatorBoundedSizeArrays_.generate

//: Now that you've seen what generators can do, we'll use all we've learned to create a generator that
//: produces email addresses.  To do this, we'll need one more operator/method notated `<*>` or `ap`.
//: `ap` comes from [Applicative Functors](http://staff.city.ac.uk/~ross/papers/Applicative.html) and is
//: used to "zip together" `Gen`erators of functions with `Gen`erators of of values, applying each function
//: during the zipping phase.  That definition is a little hand-wavey and technical, so for now we'll say that
//: `ap` works like "glue" that sticks special kinds of generators togethers.
//:
//: For our purposes, we will say that an email address consists of 3 parts: A local part, a hostname, and a 
//: Top-Level Domain each separated by an `@`, and a `.` respectively.
//:
//: According to RFC 2822, the local part can consist of uppercase characters, lowercase letters, numbers, and
//: certain kinds of special characters.  We already have generators for upper and lower cased letters, so all we
//: need are special characters and a more complete number generator:

let numeric : Gen<Character> = Gen<Character>.fromElementsIn("0"..."9")
let special : Gen<Character> = Gen<Character>.fromElementsOf(["!", "#", "$", "%", "&", "'", "*", "+", "-", "/", "=", "?", "^", "_", "`", "{", "|", "}", "~", "."])

//: Now for the actual generator

let allowedLocalCharacters : Gen<Character> = Gen<Character>.oneOf([
	upperCaseLetters,
	lowerCaseLetters,
	numeric,
	special,
])

//: Now we need a `String` made of these characters. so we'll just `proliferate` an array of characters and `fmap`
//: to get a `String` back.

let localEmail = allowedLocalCharacters.proliferateNonEmpty().fmap(String.init)

//: The RFC says that the host name can only consist of lowercase letters, numbers, and dashes.  We'll skip some
//: steps here and combine both steps above into one big generator.

let hostname = Gen<Character>.oneOf([
	lowerCaseLetters,
	numeric,
	Gen.pure("-"),
]).proliferateNonEmpty().fmap(String.init)

//: Finally, the RFC says the TLD for the address can only consist of lowercase letters with a length larger than 1.

let tld = lowerCaseLetters.proliferateNonEmpty().suchThat({ $0[$0.endIndex.predecessor()] != "." }).fmap(String.init)

//: So now we've got all the pieces together, so how do we put them together to make the final generator?  Well, how
//: about some glue?

// Concatenates 5 strings together in order.
func glue5(l : String) -> String -> String -> String -> String -> String {
	return { m in { m2 in { m3 in { r in l + m + m2 + m3 + r } } } }
}

//: This big thing looks a bit complicated, let's go through it part by part:

//:            +--- Here's our glue function.
//:            |     +--- This says we're mapping that function over all these pieces.
//:            |     |              +--- Here's our funtional "glue" from before.
//:            |     |              |
//:            v     v              v
let emailGen = glue5 <^> localEmail <*> Gen.pure("@") <*> hostname <*> Gen.pure(".") <*> tld

//: And we're done!

// Yes, these are in fact, all valid email addresses.
emailGen.generate

//: By now you may be asking "why do we need all of this in the first place?  Can't we just apply the parts to the
//: function to get back a result?"  Well, we do it because we aren't working with Characters or Strings or Arrays,
//: we're working with `Gen<String>`.  And we can't apply `Gen<String>` to a function that expects `String`, that wouldn't
//: make any sense - and it would never compile!  Instead we use these operators to "lift" our function over `String`s to
//: functions over `Gen<String>`s.
//:
//: Complex cases like the above are rare in practice.  Most of the time you won't even need to use generators at all!  This
//: brings us to one of the most important parts of SwiftCheck:

//: # Randomness

//: Here at TypeLift, we believe that Types are the most useful part of a program.  So when we were writing 
//: SwiftCheck, we thought about just using `Gen` everywhere and making instance methods on values that would ask them
//: to generate a "next" value.  But that would have been incredibly boring!  Instead, we wrote a protocol called `Arbitrary`
//: and let Types, not values, do all the work.
//:
//: The `Arbitrary` protocol looks like this:







