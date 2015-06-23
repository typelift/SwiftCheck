//
//  TestSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 6/23/15.
//  Copyright © 2015 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck

class TestSpec : XCTestCase {
	func testAll() {
		property("The reverse of the reverse of an array is that array") <- forAllShrink(Array<Int>.arbitrary(), shrinker: Array<Int>.shrink) { (xs : Array<Int>) in
			return
			(xs.reverse().reverse() == xs) <?> "Left identity"
			^&&^
			(xs == xs.reverse().reverse()) <?> "Right identity"
		}

		property("map behaves") <- forAllShrink(Array<Int>.arbitrary(), shrinker: Array<Int>.shrink) { (xs : Array<Int>) in
			return forAll { (f : ArrowOf<Int, Int>) in
				return xs.map(f.getArrow) == xs.map(f.getArrow)
			}
		}

		property("filter behaves") <- forAllShrink(Array<Int>.arbitrary(), shrinker: Array<Int>.shrink) { (xs : Array<Int>) in
			return forAll { (pred : ArrowOf<Int, Bool>) in
				let f = pred.getArrow
				return (xs.filter(f).reduce(true, combine: { $0.0 && f($0.1) }) as Bool)
			}
		}
	}
}

