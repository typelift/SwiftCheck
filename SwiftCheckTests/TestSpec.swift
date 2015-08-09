//
//  TestSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 6/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

import XCTest
import SwiftCheck

class TestSpec : XCTestCase {
	func testAll() {
		property("Dictionaries behave") <- forAllShrink(Dictionary<String, Int>.arbitrary, shrinker: Dictionary<String, Int>.shrink) { (xs : Dictionary<String, Int>) in
			return true
		}

		property("Optionals behave") <- forAll { (xs : Int?) in
			return true
		}

		property("Sets behave") <- forAll { (xs : Set<Int>) in
			return true
		}

		property("The reverse of the reverse of an array is that array") <- forAll { (xs : Array<Int>) in
			return
			(xs.reverse().reverse() == xs) <?> "Left identity"
			^&&^
			(xs == xs.reverse().reverse()) <?> "Right identity"
		}
		
		property("Failing conjunctions print labelled properties") <- forAll { (xs : Array<Int>) in
			return
				(xs.sort().sort() == xs.sort()).verbose <?> "Sort Left"
				^&&^
				((xs.sort() != xs.sort().sort()).verbose <?> "Bad Sort Right")
		}.expectFailure

		property("map behaves") <- forAll { (xs : Array<Int>) in
			return forAll { (f : ArrowOf<Int, Int>) in
				return xs.map(f.getArrow) == xs.map(f.getArrow)
			}
		}

		property("filter behaves") <- forAll { (xs : Array<Int>) in
			return forAll { (pred : ArrowOf<Int, Bool>) in
				let f = pred.getArrow
				return (xs.filter(f).reduce(true, combine: { $0.0 && f($0.1) }) as Bool)
			}
		}
	}
}

