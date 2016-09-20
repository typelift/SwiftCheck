//
//  PropertySpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 6/5/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

@testable import SwiftCheck
import XCTest

func ==(l : Property, r : Property) -> Bool {
	let res1 = quickCheckWithResult(CheckerArguments(name: "", silence: true), l)
	let res2 = quickCheckWithResult(CheckerArguments(name: "", silence: true), r)

	switch (res1, res2) {
	case (.success(_, _, _), .success(_, _, _)):
		return true
	case (.gaveUp(_, _, _), .gaveUp(_, _, _)):
		return true
	case (.failure(_, _, _, _, _, _, _), .failure(_, _, _, _, _, _, _)):
		return true
	case (.existentialFailure(_, _, _, _, _, _, _), .existentialFailure(_, _, _, _, _, _, _)):
		return true
	case (.noExpectedFailure(_, _, _, _, _), .noExpectedFailure(_, _, _, _, _)):
		return true
	case (.insufficientCoverage(_, _, _, _, _), .insufficientCoverage(_, _, _, _, _)):
		return true
	default:
		return false
	}
}

func ==(l : Property, r : Bool) -> Bool {
	let res1 = quickCheckWithResult(CheckerArguments(name: "", silence: true), l)
	switch res1 {
	case .success(_, _, _):
		return r == true
	default:
		return r == false
	}
}

class PropertySpec : XCTestCase {
	func testProperties() {
		property("Once really only tests a property once") <- forAll { (n : Int) in
			var bomb : Optional<Int> = .some(n)
			return forAll { (_ : Int) in
				let b = bomb! // Will explode if we test more than once
				bomb = nil
				return b == n
			}.once
		}

		property("Again undoes once") <- forAll { (n : Int) in
			var counter : Int = 0
			quickCheck(forAll { (_ : Int) in
				counter += 1
				return true
			}.once.again)
			return counter > 1
		}
		
		property("Once undoes again") <- forAll { (n : Int) in
			var bomb : Optional<Int> = .some(n)
			return forAll { (_ : Int) in
				let b = bomb! // Will explode if we test more than once
				bomb = nil
				return b == n
			}.again.once
		}
		
		property("Conjamb randomly picks from multiple generators") <- forAll { (n : Int, m : Int, o : Int) in
			return conjamb({
				return true <?> "picked 1"
				}, {
					return true <?> "picked 2"
				}, {
					return true <?> "picked 3"
			})
		}

		property("Invert turns passing properties to failing properties") <- forAll { (n : Int) in
			return n == n
			}.invert.expectFailure

		property("Invert turns failing properties to passing properties") <- forAll { (n : Int) in
			return n != n
			}.invert

		property("Invert turns throwing properties to passing properties") <- forAll { (n : Int) in
			throw SwiftCheckError.bogus
			}.invert

		property("Invert does not affect discards") <- forAll { (n : Int) in
			return Discard()
			}.invert

		property("Existential Quantification works") <- exists { (x : Int) in
			return true
		}

		property("Cover reports failures properly") <- forAll { (s : Set<Int>) in
			return (s.count == [Int](s).count).cover(s.count >= 15, percentage: 70, label: "large")
			}.expectFailure

		property("Prop ==> true") <- forAllNoShrink(Bool.arbitrary, Gen.pure(true)) { (p1, p2) in
			let p = p2 ==> p1
			return (p == p1) ^||^ (p ^&&^ p1 ^&&^ p2)
		}

		property("==> Short Circuits") <- forAll { (n : Int) in
			func isPositive(_ n : Int) -> Bool {
				if n > 0 {
					return true
				} else if (n & 1) == 0 {
					fatalError("Should never get here")
				} else {
					return isPositive(n) // or here
				}
			}
			return (n > 0) ==> isPositive(n)
		}

		property("Prop Law of complements") <- forAll { (x : Bool) in
			return ((x ^||^ x.invert) == true) ^&&^ ((x ^&&^ x.invert) == false)
		}

		property("Prop Law of double negation") <- forAll { (x : Bool) in
			return x.invert.invert == x
		}

		property("Prop Law of idempotency") <- forAll { (x : Bool) in
			return ((x ^||^ x) == x) ^&&^ ((x ^&&^ x) == x)
		}

		property("Prop Law of dominance") <- forAll { (x : Bool) in
			return ((x ^||^ false) == x) ^&&^ ((x ^&&^ true) == x)
		}

		property("Prop Law of commutativity") <- forAll { (x : Bool, y : Bool) in
			return ((x ^||^ y) == (y ^||^ x)) ^&&^ ((x ^&&^ y) == (y ^&&^ x))
		}

		property("Prop Law of associativity") <- forAll { (x : Bool, y : Bool, z : Bool) in
			return (((x ^||^ y) ^||^ z) == (x ^||^ (y ^||^ z))) ^&&^ (((x ^&&^ y) ^&&^ z) == (x ^&&^ (y ^&&^ z)))
		}

		property("Prop DeMorgan's Law") <- forAll { (x : Bool, y : Bool) in
			let l = (x ^&&^ y).invert == (x.invert ^||^ y.invert)
			let r = (x ^||^ y).invert == (x.invert ^&&^ y.invert)
			return l ^&&^ r
		}

		property("Prop Law of absorbtion") <- forAll { (x : Bool, y : Bool) in
			let l = (x ^&&^ (x ^||^ y)) == x
			let r = (x ^||^ (x ^&&^ y)) == x
			return l ^&&^ r
		}

		property("Prop 2-part Simplification Laws") <- forAll { (x : Bool, y : Bool) in
			let l = (x ^&&^ (x.invert ^||^ y)) == (x ^&&^ y)
			let r = (x ^||^ (x.invert ^&&^ y)) == (x ^||^ y)
			return l ^&&^ r
		}

		property("Prop 3-part Simplification Law") <- forAll { (x : Bool, y : Bool, z : Bool) in
			return ((x ^&&^ y) ^||^ (x ^&&^ z) ^||^ (y.invert ^&&^ z)) == ((x ^&&^ y) ^||^ (y.invert ^&&^ z))
		}
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testProperties", testProperties),
	])
	#endif
}
