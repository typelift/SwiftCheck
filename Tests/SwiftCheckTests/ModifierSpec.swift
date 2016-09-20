//
//  ModifierSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/29/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import SwiftCheck
import XCTest

class ModifierSpec : XCTestCase {
	func testModifiers() {
		property("All blind variables print '(*)'") <- forAll { (x : Blind<Int>) in
			return x.description == "(*)"
		}

		property("Static propositions never shrink") <- forAll { (x : Static<Int>) in
			return Static<Int>.shrink(x).isEmpty
		}

		property("Pointers behave") <- forAll { (x : PointerOf<Int>) in
			return x.size != 0
		}

		property("Positive propositions only generate positive numbers") <- forAll { (x : Positive<Int>) in
			return x.getPositive > 0
		}

		property("NonZero propositions never generate zero") <- forAll { (x : NonZero<Int>) in
			return x.getNonZero != 0
		}

		property("NonNegative propositions only generate non negative numbers") <- forAll { (x : NonNegative<Int>) in
			return x.getNonNegative >= 0
		}

		property("ArrayOf modifiers nest") <- forAll { (xxxs : ArrayOf<ArrayOf<Int8>>) in
			return true
		}

		property("The reverse of the reverse of an array is that array") <- forAll { (xs : ArrayOf<Int>) in
			return (xs.getArray.reversed().reversed() == xs.getArray) <?> "Left identity"
				^&&^
				(xs.getArray == xs.getArray.reversed().reversed()) <?> "Right identity"
		}

		property("map behaves") <- forAll { (xs : ArrayOf<Int>, f : ArrowOf<Int, Int>) in
			return xs.getArray.map(f.getArrow) == xs.getArray.map(f.getArrow)
		}

		property("IsoOf generates a real isomorphism") <- forAll { (x : Int, y : String, iso : IsoOf<Int, String>) in
			return iso.getFrom(iso.getTo(x)) == x
				^&&^
				iso.getTo(iso.getFrom(y)) == y
		}

		property("filter behaves") <- forAll { (xs : ArrayOf<Int>, pred : ArrowOf<Int, Bool>) in
			let f = pred.getArrow
			return (xs.getArray.filter(f).reduce(true, { $0.0 && f($0.1) }) as Bool)
		}
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testModifiers", testModifiers),
	])
	#endif
}
