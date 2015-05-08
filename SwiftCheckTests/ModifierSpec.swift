//
//  ModifierSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/29/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck

class ModifierSpec : XCTestCase {
	func testModifiers() {
		assertProperty["All blind variables print '(*)'"] = forAll { (x : Blind<Int>) in
			return x.description == "(*)"
		}
		
		assertProperty["Static propositions never shrink"] = forAll { (x : Static<Int>) in
			return Static<Int>.shrink(x).isEmpty
		}

		assertProperty["Positive propositions only generate positive numbers"] = forAll { (x : Positive<Int>) in
			return x.getPositive > 0
		}
		
		assertProperty["NonZero propositions never generate zero"] = forAll { (x : NonZero<Int>) in
			return x.getNonZero != 0
		}
		
		assertProperty["NonNegative propositions only generate non negative numbers"] = forAll { (x : NonNegative<Int>) in
			return x.getNonNegative >= 0
		}

		assertProperty["ArrayOf modifiers nest"] = forAll { (xxxs : ArrayOf<ArrayOf<Int8>>) in
			return true
		}
	}
}
