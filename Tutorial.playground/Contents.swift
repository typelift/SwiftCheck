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
//
// mnemonic: Use `fromElementsIn` with an INdex.
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
//
//     public protocol Arbitrary {
//         /// The generator for this particular type.
//         ///
//         /// This function should call out to any sources of randomness or state necessary to generate
//         /// values.  It should not, however, be written as a deterministic function.  If such a
//         /// generator is needed, combinators are provided in `Gen.swift`.
//         static var arbitrary : Gen<Self> { get }
//     }
//
//: There's our old friend, `Gen`!  So, an `Arbitrary` type is a type that can, well, give us a generator to create
//: `Arbitrary` values.  SwiftCheck defines `Arbitrary` instances for the majority of types in the Swift Standard
//: Library in the ways you might expect e.g. The `Arbitrary` instance for `Int` calls `arc4random_uniform`.
//:
//: We'll take this opportunity here to show you how to use Arbitrary for any types you might happen to write yourself.  But
//: before that, let's try to write an `Arbitrary` instance for `NSDate`.

import class Foundation.NSDate

//: Here's the obvious way to do it
//
// extension NSDate : Arbitrary {
//     public static var arbitrary : Gen<NSDate> {
//         return Gen.oneOf([
//             Gen.pure(NSDate()),
//             Gen.pure(NSDate.distantFuture()),
//             Gen.pure(NSDate.distantPast()),
//             NSDate.init <^> NSTimeInterval.arbitrary,
//         ])
//     }
// }
//
//: But this doesn't work!  Swift won't let us extend `NSDate` directly because we use `Gen<Self>` in the wrong 
//: position.  What to do?
//:
//: Let's write a wrapper!

struct ArbitraryDate : Arbitrary {
	let getDate : NSDate

	init(date : NSDate) { self.getDate = date }

	static var arbitrary : Gen<ArbitraryDate> {
		return Gen.oneOf([
			Gen.pure(NSDate()),
			Gen.pure(NSDate.distantFuture()),
			Gen.pure(NSDate.distantPast()),
			NSDate.init <^> NSTimeInterval.arbitrary,
		]).fmap(ArbitraryDate.init)
	}
}

ArbitraryDate.arbitrary.generate.getDate
ArbitraryDate.arbitrary.generate.getDate

//: What we've just written is called a `Modifier Type`; a wrapper around one type that we can't generate with
//: another that we can.
//:
//: SwiftCheck also uses this strategy for a few of the more "difficult" types in the Swift STL, but we also use them
//: in more benign ways too.  For example, we can write a modifier type that only generates positive numbers:

public struct ArbitraryPositive<A : protocol<Arbitrary, SignedNumberType>> : Arbitrary {
	public let getPositive : A

	public init(_ pos : A) { self.getPositive = pos }

	public static var arbitrary : Gen<ArbitraryPositive<A>> {
		return A.arbitrary.fmap { ArbitraryPositive.init(abs($0)) }
	}
}

ArbitraryPositive<Int>.arbitrary.generate.getPositive
ArbitraryPositive<Int>.arbitrary.generate.getPositive
ArbitraryPositive<Int>.arbitrary.generate.getPositive

//: # Quantifiers

//: What we've seen so far are the building blocks we need to introduce the final part of the library: The actual testing
//: interface.  The last concept we'll introduce is *Quantifiers*.
//:
//: A Quantifier is a contract that serves as a guarantee that a property holds when the given
//: testing block returns `true` or truthy values, and fails when the testing block returns `false`
//: or falsy values.  The testing block is usually used with Swift's abbreviated block syntax and
//: requires type annotations for all value positions being requested.  There is only one quantifier
//: in SwiftCheck, `forAll`.  As its name implies, `forAll` will produce random data and your spec must
//: pass "for all" of the values.  Here's what it looks like:
//
//     func forAll<A : Arbitrary>(_ : (A... -> Bool)) -> Property
//
//: The actual type of `forAll` is much more general and expressive than this, but for now this will do.
//:
//: Here is an example of a simple property

//     + This is "Property Notation".  It allows you to give your properties a name and instructs SwiftCheck to test it.
//     |                                                          + This backwards arrow binds a property name and a property to each other.
//     |                                                          |
//     v                                                          v
property("The reverse of the reverse of an array is that array") <- forAll { (xs : [Int]) in
	return xs.reverse().reverse() == xs
}

// From now on, all of our examples will take the form above.

//: Because `forAll` is variadic it works for a large number and variety of types too:

//                                           +--- This Modifier Type produces Arrays of Integers.
//                                           |                    +--- This Modifier Type generates functions.  That's right, SwiftCheck
//                                           |                    |    can generate *functions*!!
//                                           v                    v
property("filter behaves") <- forAll { (xs : ArrayOf<Int>, pred : ArrowOf<Int, Bool>) in
	let f = pred.getArrow
	return xs.getArray.filter(f).reduce(true, combine: { $0.0 && f($0.1) })
	// ^ This property says that if we filter an array then apply the predicate to all its elements, then they
	//   should all return true.
}

// How about a little Boolean Algebra too?
property("DeMorgan's Law") <- forAll { (x : Bool, y : Bool) in
	let l = !(x && y) == (!x || !y)
	let r = !(x || y) == (!x && !y)
	return l && r
}

//: The thing to notice about all of these examples is that there isn't a `Gen`erator in sight.  Not once did we have to invoke
//: `.generate` or have to construct a generator.  We simply told the `forAll` block how many variables we wanted and of what
//: type and SwiftCheck automagically went out and was able to produce random values.
//:
//: Our not-so-magic trick is enabled behind the scenes by the judicious combination of `Arbitrary` to construct default generators
//: for each type and a testing mechanism that invokes the testing block for the proper number of tests.  For some real magic, let's
//: see what happens when we fail a test:

// `reportProperty` is a variation of `property` that doesn't assert on failure.  It does, however, still print all failures to
// the console.  We use it here because XCTest does not like it when you assert outside of a test case.
reportProperty("Obviously wrong") <- forAll({ (x : Int) in
	return x != x
}).whenFail { // `whenFail` attaches a callback to the test when we fail.
	print("Oh noes!")
}

//: If you open the console for the playground, you'll see output very similar to the following:
//:
//:     *** Failed! Proposition: Obviously wrong
//:     Falsifiable (after 1 test):
//:     Oh noes!
//:     0
//: 
//: The first line tells you what failed, the next how long it took to fail, the next our message from the callback, and the
//: last the value of `x` the property failed with.  If you keep running the test over and over again you'll notice that the
//: test keeps failing on the number 0 despite the integer supposedly being random.  What's going on here?
//:
//: To find out, let's see the full definition of the `Arbitrary` protocol:
//
//     public protocol Arbitrary {
//         /// The generator for this particular type.
//         ///
//         /// This function should call out to any sources of randomness or state necessary to generate
//         /// values.  It should not, however, be written as a deterministic function.  If such a
//         /// generator is needed, combinators are provided in `Gen.swift`.
//         static var arbitrary : Gen<Self> { get }
//
//         /// An optional shrinking function.  If this function goes unimplemented, it is the same as
//         /// returning the empty list.
//         ///
//         /// Shrunken values must be less than or equal to the "size" of the original type but never the
//         /// same as the value provided to this function (or a loop will form in the shrinker).  It is
//         /// recommended that they be presented smallest to largest to speed up the overall shrinking
//         /// process.
//         static func shrink(_ : Self) -> [Self]
//     }
//
//: Here's where we one-up Fuzz Testing and show the real power of property testing.  A "shrink" is a strategy for reducing
//: randomly generated values.  To shrink a value, all you need to do is return an array of "smaller values", whether in
//: magnitude or value.  For example, the shrinker for `Array` returns Arrays that have a size less than or equal to that of
//: the input array.

Array<Int>.shrink([1, 2, 3])

//: So herein lies the genius: Whenever SwiftCheck encounters a failing property, it simply invokes the shrinker, tries the
//: property again on the values of the array until it finds another failing case, then repeats the process until it runs
//: out of cases to try.  In other words, it *shrinks* the value down to the least possible size then reports that to you
//: as the failing test case rather than the randomly generated value which could be unnecessarily large or complex.

//: # All Together Now!

//: 



