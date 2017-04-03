//: Playground - noun: a place where people can play

import SwiftCheck
import Foundation.NSDate

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

//: SwiftCheck is a testing library that augments libraries like `XCTest` and `Quick` by giving
//: them the ability to automatically test program properties.  A property is a particular facet of
//: an algorithm, method, data structure, or program that must *hold* (that is, remain valid) even 
//: when fed random or pseudo-random data.  If that all seems complicated, it may be simpler to 
//: think of Property Testing like Fuzz Testing, but with the outcome being to satisfy requirements 
//: rather than break the program.  Throughout this tutorial, simplifications like the above will be
//: made to aid your understanding.  Towards the end of it, we will begin to remove many of these
//: "training wheels" and reveal the real concepts and types of the operations in the library, which
//: are often much more powerful and generic than previously presented.
//:
//: Unlike Unit Testing, Property Testing is antithetical to the use of state and global variables.  Property 
//: Tests are local, atomic entities that ideally only use the data given to them to match a 
//: user-defined specification for the behavior of a program or algorithm.  While this may
//: seem draconian, the upshot of following these [unwritten] rules is that the produced tests become
//: "law-like", as in a [Mathematical or Scientific Law](https://en.wikipedia.org/wiki/Laws_of_science).
//:
//: When you approach your tests with a clear goal in mind, SwiftCheck allows you to turn
//: that goal into many smaller parts that are each much easier to reason about than
//: the whole problem at once.
//:
//: With that, let's begin.

//: # `Gen`erators

//: In Swift, when one thinks of a Generator, they usually think of the `GeneratorType` protocol or
//: the many many individual structures the Swift Standard Library exposes to allow loops to work 
//: with data structures like `[T]` and `Set<T>`.  In *SwiftCheck*, we also have Generators, but we spell 
//: them `Gen`erators, as in the universal Generator type `Gen`.
//:
//: `Gen` is a struct defined generically over any kind of type that looks like this:
//
//     /// We're not defining this here; We'll be using SwiftCheck's `Gen` from here on out.
//     struct Gen<Wrapped> { }
//
//: `Gen`, unlike `GeneratorType`, is not backed by a concrete data structure like an `Array` or
//: `Dictionary`, but is instead constructed by invoking methods that refine the kind of data that 
//: gets generated.  Below are some examples of `Gen`erators that generate random instances of 
//: simple data types.

// `Gen.pure` constructs a generator that *only* produces the given value.
let onlyFive = Gen.pure(5)

onlyFive.generate
onlyFive.generate
onlyFive.generate
onlyFive.generate
onlyFive.generate

// `Gen.fromElementsIn` constructs a generator that pulls values from inside the  bounds of the 
// given Range.  Because generation is random, some values may be repeated.
let fromOnetoFive = Gen<Int>.fromElements(in: 1...5)

fromOnetoFive.generate
fromOnetoFive.generate
fromOnetoFive.generate
fromOnetoFive.generate
fromOnetoFive.generate

let lowerCaseLetters : Gen<Character> = Gen<Character>.fromElements(in: "a"..."z")

lowerCaseLetters.generate
lowerCaseLetters.generate
lowerCaseLetters.generate

let upperCaseLetters : Gen<Character> = Gen<Character>.fromElements(in: "A"..."Z")

upperCaseLetters.generate
upperCaseLetters.generate
upperCaseLetters.generate

// `Gen.fromElementsOf` works like `Gen.fromElementsIn` but over an Array, not just a Range.
//
// mnemonic: Use `fromElementsIn` with an INdex.
let specialCharacters = Gen<Character>.fromElements(of: [ "!", "@", "#", "$", "%", "^", "&", "*", "(", ")" ])

specialCharacters.generate
specialCharacters.generate
specialCharacters.generate
specialCharacters.generate

//: But SwiftCheck `Gen`erators aren't just flat types, they stack and compose and fit together in 
//: amazing ways.

// `Gen.oneOf` randomly picks one of the generators from the given list and draws element from it.
let uppersAndLowers = Gen<Character>.one(of: [
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

//: `Gen`erators don't have to always generate their elements with equal frequency.  SwiftCheck 
//: includes a number of functions for creating `Gen`erators with "weights" attached to their 
//: elements.

// This generator ideally generates nil 1/4 (1 / (1 + 3)) of the time and `.Some(5)` 3/4 of the time.
let weightedGen = Gen<Int?>.weighted([
	(1, nil),
	(3, .some(5)),
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

//: `Gen`erators can even filter, modify, or combine the elements they create.

// `suchThat` takes a predicate function that filters generated elements.
let oneToFiveEven = fromOnetoFive.suchThat { $0 % 2 == 0 }

oneToFiveEven.generate
oneToFiveEven.generate
oneToFiveEven.generate

// `proliferate` turns a generator of single elements into a generator of arrays of those elements. 
let characterArray = uppersAndLowers.proliferate

characterArray.generate
characterArray.generate
characterArray.generate

/// `proliferateNonEmpty` works like `proliferate` but guarantees the generated array is never empty.
let oddLengthArrays = fromOnetoFive.proliferateNonEmpty.suchThat { $0.count % 2 == 1 }

oddLengthArrays.generate.count
oddLengthArrays.generate.count
oddLengthArrays.generate.count


//: Generators also admit functional methods like `map` and `flatMap`.

// `Gen.map` works exactly like Array's `map` method; it applies the function to any
// values it generates.
let fromTwoToSix = fromOnetoFive.map { $0 + 1 }

fromTwoToSix.generate
fromTwoToSix.generate
fromTwoToSix.generate
fromTwoToSix.generate
fromTwoToSix.generate

// `Gen.flatMap` works exactly like `Array`'s `flatMap`, but instead of concatenating the generated 
// arrays it produces a new generator that picks values from among the newly created generators 
// produced by the function.
//
// While that definition may *technically* be what occurs, it is better to think of `flatMap` as a 
// way of making a generator depend on another.  For example, you can use a generator of sizes to 
// limit the length of generators of arrays:
let generatorBoundedSizeArrays = fromOnetoFive.flatMap { len in
	return characterArray.suchThat { xs in xs.count <= len }
}

generatorBoundedSizeArrays.generate
generatorBoundedSizeArrays.generate
generatorBoundedSizeArrays.generate
generatorBoundedSizeArrays.generate
generatorBoundedSizeArrays.generate

//: # Practical Generators

//: For our purposes, we will say that an email address consists of 3 parts: A local part, a
//: hostname, and a Top-Level Domain each separated by an `@`, and a `.` respectively.
//:
//: According to RFC 2822, the local part can consist of uppercase characters, lowercase letters,
//: numbers, and certain kinds of special characters.  We already have generators for upper and
//: lower cased letters, so all we need are special characters and a more complete number generator:

let numeric : Gen<Character> = Gen<Character>.fromElements(in: "0"..."9")
let special : Gen<Character> = Gen<Character>.fromElements(of: ["!", "#", "$", "%", "&", "'", "*", "+", "-", "/", "=", "?", "^", "_", "`", "{", "|", "}", "~", "."])

//: Now for the actual generator

let allowedLocalCharacters : Gen<Character> = Gen<Character>.one(of: [
	upperCaseLetters,
	lowerCaseLetters,
	numeric,
	special,
])


//: Now we need a `String` made of these characters. so we'll just `proliferate` an array of characters and `map`
//: to get a `String` back.

let localEmail = allowedLocalCharacters
					.proliferateNonEmpty // Make a non-empty array of characters
					.suchThat({ $0[$0.index(before: $0.endIndex)] != "." }) // Such that the last character isn't a dot.
					.map { String($0) } // Then make a string.

//: The RFC says that the host name can only consist of lowercase letters, numbers, and dashes.  We'll skip some
//: steps here and combine them all into one big generator.

let hostname = Gen<Character>.one(of: [
	lowerCaseLetters,
	numeric,
	Gen.pure("-"),
]).proliferateNonEmpty.map { String($0) }

//: Finally, the RFC says the TLD for the address can only consist of lowercase letters with a length larger than 1.

let tld = lowerCaseLetters
			.proliferateNonEmpty
			.suchThat({ $0.count > 1 })
			.map { String($0) }

//: So now that we've got all the pieces, so how do we put them together to make the final generator?  Well, how
//: about some glue?

// Concatenates an array of `String` `Gen`erators together in order.
func glue(_ parts : [Gen<String>]) -> Gen<String> {
	return sequence(parts).map { $0.reduce("", +) }
}

let emailGen = glue([localEmail, Gen.pure("@"), hostname, Gen.pure("."), tld])

//: And we're done!

// Yes, these are in fact, all valid email addresses.
emailGen.generate
emailGen.generate
emailGen.generate

//: Complex cases like the above are rare in practice.  Most of the time you won't even need to use
//: generators at all!  This brings us to one of the most important parts of SwiftCheck:

//: # Arbitrary

//: Here at TypeLift, we believe that Types are the most useful part of a program.  So when we were
//: writing SwiftCheck, we thought about just using `Gen` everywhere and making instance methods on
//: values that would ask them to generate a "next" value.  But that would have been incredibly
//: boring!  Instead, we wrote a protocol called `Arbitrary` and let Types, not values, do all the
//: work.
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
//: There's our old friend, `Gen`!  So, an `Arbitrary` type is a type that can give us a generator
//: to create `Arbitrary` values.  SwiftCheck defines `Arbitrary` instances for the majority of
//: types in the Swift Standard Library in the ways you might expect e.g. The `Arbitrary` instance
//: for `Int` calls `arc4random_uniform`.
//:
//: SwiftCheck uses a strategy called a `Modifier Type`–a wrapper around one type that we can't
//: generate with another that we can–for a few of the more "difficult" types in the Swift Standard 
//: Library, but we also use them in more benign ways too.  For example, we can write a modifier type
//: that only generates positive numbers:

public struct ArbitraryPositive<A : Arbitrary & SignedNumber> : Arbitrary {
	public let getPositive : A

	public init(_ pos : A) { self.getPositive = pos }

	public static var arbitrary : Gen<ArbitraryPositive<A>> {
		return A.arbitrary.map { ArbitraryPositive.init(abs($0)) }
	}
}

ArbitraryPositive<Int>.arbitrary.generate.getPositive
ArbitraryPositive<Int>.arbitrary.generate.getPositive
ArbitraryPositive<Int>.arbitrary.generate.getPositive

//: # Quantifiers

//: What we've seen so far are the building blocks we need to introduce the final part of the
//: library: The actual testing interface.  The last concept we'll introduce is *Quantifiers*.
//:
//: A Quantifier is a contract that serves as a guarantee that a property holds when the given
//: testing block returns `true` or truthy values, and fails when the testing block returns `false`
//: or falsy values.  The testing block is usually used with Swift's abbreviated block syntax and
//: requires type annotations for all value positions being requested.  There is only one quantifier
//: in SwiftCheck, `forAll`.  As its name implies, `forAll` will produce random data and your spec
//: must pass "for all" of the values.  Here's what it looks like:
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
	return xs.reversed().reversed() == xs
}

// From now on, all of our examples will take the form above.

//: Because `forAll` is variadic it works for a large number and variety of types too:

//                                           +--- This Modifier Type produces Arrays of Integers.
//                                           |                    +--- This Modifier Type generates functions.  That's right, SwiftCheck
//                                           |                    |    can generate *functions*!!
//                                           v                    v
property("filter behaves") <- forAll { (xs : ArrayOf<Int>, pred : ArrowOf<Int, Bool>) in
	let f = pred.getArrow
	return xs.getArray.filter(f).reduce(true, { $0.0 && f($0.1) })
	// ^ This property says that if we filter an array then apply the predicate
	//   to all its elements, then they should all respond with `true`.
}

// How about a little Boolean Algebra too?
property("DeMorgan's Law") <- forAll { (x : Bool, y : Bool) in
	let l = !(x && y) == (!x || !y)
	let r = !(x || y) == (!x && !y)
	return l && r
}

//: The thing to notice about all of these examples is that there isn't a `Gen`erator in sight.  Not
//: once did we have to invoke `.generate` or have to construct a generator.  We simply told the
//: `forAll` block how many variables we wanted and of what type and SwiftCheck automagically went
//: out and was able to produce random values.
//:
//: Our not-so-magic trick is enabled behind the scenes by the judicious combination of `Arbitrary`
//: to construct default generators for each type and a testing mechanism that invokes the testing
//: block for the proper number of tests.  For some real magic, let's see what happens when we fail
//: a test:

// `reportProperty` is a variation of `property` that doesn't assert on failure.  It does, however,
// still print all failures to the console.  We use it here because XCTest does not like it when you
// assert outside of a test case.
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
//: The first line tells you what failed, the next how long it took to fail, the next our message
//: from the callback, and the last the value of `x` the property failed with.  If you keep running
//: the test over and over again you'll notice that the test keeps failing on the number 0 despite
//: the integer supposedly being random.  What's going on here?
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
//: Here's where we one-up Fuzz Testing and show the real power of Property Testing.  A "shrink" is
//: a strategy for reducing randomly generated values.  To shrink a value, all you need to do is
//: return an array of "smaller values", whether in magnitude or value.  For example, the shrinker
//: for `Array` returns Arrays that have a size less than or equal to that of the input array.

Array<Int>.shrink([1, 2, 3])

//: So herein lies the genius: Whenever SwiftCheck encounters a failing property, it simply invokes
//: the shrinker, tries the property again on the values of the array until it finds another failing
//: case, then repeats the process until it runs out of cases to try.  In other words, it *shrinks*
//: the value down to the least possible size then reports that to you as the failing test case
//: rather than the randomly generated value which could be unnecessarily large or complex.

//: Before we move on, let's write a Modifier Type with a custom shrinker for the email generator we defined a little while ago:

// SwiftCheck defines default shrinkers for most of the types it gives Arbitrary instances.  There
// will often be times when those default shrinkers don't cut it, or you need more control over
// what happens when you generate or shrink values.  Modifier Types to the rescue!
struct ArbitraryEmail : Arbitrary {
	let getEmail : String

	init(email : String) { self.getEmail = email }

	static var arbitrary : Gen<ArbitraryEmail> { return emailGen.map(ArbitraryEmail.init) }
}

// Let's be wrong for the sake of example
property("email addresses don't come with a TLD") <- forAll { (email : ArbitraryEmail) in
	return !email.getEmail.contains(".")
}.expectFailure // It turns out true things aren't the only thing we can test.  We can `expectFailure`
				// to make SwiftCheck, well, expect failure.  Beware, however, that if you don't fail
				// and live up to your expectations, SwiftCheck treats that as a failure of the test case.

//: # All Together Now!

//: Let's put all of our newfound understanding of this framework to use by writing a property that
//: tests an implementation of the Sieve of Eratosthenes:

import func Darwin.ceil
import func Darwin.sqrt

// The Sieve of Eratosthenes:
//
// To find all the prime numbers less than or equal to a given integer n:
//    - let l = [2...n]
//    - let p = 2
//    - for i in [(2 * p) through n by p] {
//          mark l[i]
//      }
//    - Remaining indices of unmarked numbers are primes
func sieve(_ n : Int) -> [Int] {
	if n <= 1 {
		return []
	}

	var marked : [Bool] = (0...n).map { _ in false }
	marked[0] = true
	marked[1] = true

	for p in 2..<n {
		for i in stride(from: 2 * p, to: n, by: p) {
			marked[i] = true
		}
	}

	var primes : [Int] = []
	for (t, i) in zip(marked, 0...n) {
		if !t {
			primes.append(i)
		}
	}
	return primes
}

// Trial Division
//
// Short and sweet check if a number is prime by enumerating from 2...⌈√(x)⌉ and checking
// for a nonzero modulus.
func isPrime(_ n : Int) -> Bool {
	if n == 0 || n == 1 {
		return false
	} else if n == 2 {
		return true
	}

	let max = Int(ceil(sqrt(Double(n))))
	for i in 2...max {
		if n % i == 0 {
			return false
		}
	}
	return true
}

//: We would like to test whether our sieve works properly, so we run it through SwiftCheck with the
//: following property:

reportProperty("All Prime") <- forAll { (n : Positive<Int>) in
	let primes = sieve(n.getPositive)
	return primes.count > 1 ==> {
		let primeNumberGen = Gen<Int>.fromElements(of: primes)
		return forAll(primeNumberGen) { (p : Int) in
			return isPrime(p)
		}
	}
}

//: This test introduces several new concepts that we'll go through 1-by-1:
//:
//: * `Positive<Wrapped>`: This is a Modifier Type defined by SwiftCheck that only produces
//:                        integers larger than zero - positive integers.  SwiftCheck also has
//:                        modifiers for `NonZero` (all integers that aren't 0) and `NonNegative`
//:                        (all positive integers including 0).
//:
//: * `==>`: This operator is called "Implication".  It is used to introduce tests that need to
//:          reject certain kinds of data that gets generated.  Here, because our prime number
//:          generator can return empty lists (which throws an error when used with `Gen.fromElementsOf`)
//:          we put a condition on the left-hand side that requires arrays have a size larger than 1.
//:
//: * `forAll` in `forAll`: The *actual* type that `forAll` expects is not `Bool`. It's a protocol
//:                         called `Testable`, `Bool` just happens to conform to it.  It turns out that
//:                         `Property`, the thing `forAll` returns, does too.  So you can nest `forAll`s
//:                         in `forAll`s to your heart's content!
//:
//: * `forAll` + `Gen`: The `forAll`s we've seen before have all been using `Arbitrary` to retrieve a
//:                     default `Gen`erator for each type.  But SwiftCheck also includes a variant of
//:                     `forAll` that takes a user-supplied generator.  For those times when you want
//:                     absolute control over generated values, like we do here, use that particular
//:                     series of overloads.

//: If you check the console, you'll notice that this property doesn't hold!
//:
//:     *** Failed! Proposition: All Prime
//:     Falsifiable (after 11 tests and 2 shrinks):
//:     Positive( 4 ) // or Positive( 9 )
//:     0
//:
//: What's wrong here?

//: Let's go back to the spec we had for the sieve:
//
// The Sieve of Eratosthenes:
//
// To find all the prime numbers less than or equal to a given integer n:
//    - let l = [2...n]
//    - let p = 2
//    - for i in [(2 * p) **through** n by p] {
//          mark l[i]
//      }
//    - Remaining indices of unmarked numbers are primes
//
//: Looks like we used `to:` when we meant `through:`.  Let's try again:

func sieveProperly(_ n : Int) -> [Int] {
	if n <= 1 {
		return []
	}

	var marked : [Bool] = (0...n).map { _ in false }
	marked[0] = true
	marked[1] = true

	for p in 2..<n {

		for i in stride(from: 2 * p, through: n, by: p) {
			marked[i] = true
		}
	}

	var primes : [Int] = []
	for (t, i) in zip(marked, 0...n) {
		if !t {
			primes.append(i)
		}
	}
	return primes
}

// Fo' Real This Time.
property("All Prime") <- forAll { (n : Positive<Int>) in
	let primes = sieveProperly(n.getPositive)
	return primes.count > 1 ==> {
		let primeNumberGen = Gen<Int>.fromElements(of: primes)
		return forAll(primeNumberGen) { (p : Int) in
			return isPrime(p)
		}
	}
}

//: And that's how you test with SwiftCheck.  When properties fail, it means some part of your algorithm
//: isn't handling the case presented.  So you search through some specification to find the mistake in
//: logic and try again.  Along the way, SwiftCheck will do its best help you by presenting minimal
//: cases at the least, and, with more advanced uses of the framework, the names of specific sub-parts of
//: cases and even percentages of failing vs. passing tests.

//: Just for fun, let's try a simpler property that checks the same outcome:

property("All Prime") <- forAll { (n : Positive<Int>) in
	// Sieving Properly then filtering for primes is the same as just Sieving, right?
	return sieveProperly(n.getPositive).filter(isPrime) == sieveProperly(n.getPositive)
}

//: # One More Thing

//: When working with failing tests, it's often tough to be able to replicate the exact conditions
//: that cause a failure or a bug.  With SwiftCheck, that is now a thing of the past.  The framework
//: comes with a replay mechanism that allows the arguments that lead to a failing test to be generated
//: in exactly the same order, with exactly the same values, as they did the first time.  When a test
//: fails, SwiftCheck will present a helpful message that looks something like this in Xcode:

//: > failed - Falsifiable; Replay with 123456789 123456789

//: Or this message in your log:

//: > Pass the seed values 123456789 123456789 to replay the test.

//: These are called *seeds*, and they can be fed back into the property that generated them to
//: activate the replay feature.  For example, here's an annoying test to debug because it only fails
//: every so often on one particular value:

reportProperty("Screw this value in particular") <- forAll { (n : UInt) in
	if (n == 42) {
		return false
	}

	return true
}

//: But with a replay seed of (1391985334, 382376411) we can always reproduce the failure because
//: 42 will always be generated as the first value.  We've turned on verbose mode to demonstrate this.

/// By passing this argument to the test, SwiftCheck will automatically use the given seed values and
/// size to completely replicate a particular set of values that caused the first test to fail.
let replayArgs = CheckerArguments(replay: (StdGen(1391985334, 382376411), 100))
reportProperty("Replay", arguments: replayArgs) <- forAll { (n : UInt) in
	if (n == 42) {
		return false
	}
	return true
}.verbose

//: # Conclusion

//: If you've made it this far, congratulations!  That's it.  Naturally, there are other combinators
//: and fancy ways of creating `Gen`erators and properties with the primitives in this framework,
//: but they are all variations on the themes present in ths tutorial.  With the power of SwiftCheck
//: and a sufficiently expressive testing suite, we can begin to check our programs not for
//: individual passing cases in a few scattershot unit tests, but declare and enforce immutable
//: properties that better describe the intent and invariants of our programs.  If you would like
//: further reading, see the files `Arbitrary.swift`, `Test.swift`, `Modifiers.swift`, and
//: `Property.swift`.  Beyond that, there are a number of resources built for the original framework
//: and its other derivatives whose concepts translate directly into SwiftCheck:
//:
//: * [FP Complete's Intro to QuickCheck](https://www.fpcomplete.com/user/pbv/an-introduction-to-quickcheck-testing)
//: * [Real World Haskell on QuickCheck for QA](http://book.realworldhaskell.org/read/testing-and-quality-assurance.html)
//: * [ScalaCheck](https://www.scalacheck.org)
//: * [The Original (slightly outdated) QuickCheck Tutorial](http://www.cse.chalmers.se/~rjmh/QuickCheck/manual.html)
//:
//: Go forth and test.
