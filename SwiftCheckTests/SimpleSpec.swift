//
//  SimpleSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck

class SimpleSpec : XCTestCase {
	func testAll() {
		property["Integer Equality is Reflexive"] = forAll { (i : Int) in
			return i == i
		}

		property["Unsigned Integer Equality is Reflexive"] = forAll { (i : UInt) in
			return i == i
		}

		property["Float Equality is Reflexive"] = forAll { (i : Float) in
			return i == i
		}

		property["Double Equality is Reflexive"] = forAll { (i : Double) in
			return i == i
		}
	}
}
