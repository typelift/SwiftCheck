//
//  FailureSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 9/18/15.
//  Copyright © 2016 Typelift. All rights reserved.
//

import SwiftCheck
import XCTest

enum SwiftCheckError : ErrorType {
	case Bogus
}

class FailureSpec : XCTestCase {
	private var failCount : Int = 0
	private let tests : [Property] = [
		forAll { (_ : Int) in false }.expectFailure.expectFailure,
		forAll { (_ : Int) in false },
		exists { (x : Int) in x != x },
		exists { (x : Int) in x != 0 },
		forAll { (x : Int) in x != x },
		forAll { (b : Bool) in !(b || !b) },
		forAll { (x : Int) in x > (x + 1) },
		forAll { (x : Int, y : Int, c : Int) in (x > y) ==> x + c < y + c },
		forAll { (x : Int, y : Int, c : Int) in (x > y) ==> x - c < y - c },
		forAll { (x : Int, y : Int, c : Int) in (x > y) ==> x * c < y * c },
		forAll { (x : Int, y : Int, c : Int) in (x > y && c != 0) ==> x / c < y / c },
		forAll { (x : Int, y : Int, c : Int) in (x > y && c != 0) ==> x / (-c) > y / (-c) },
		forAll { (a : Float, b : Float, c : Float) in
			return exists { (x : Float) in
				return exists { (y : Float) in
					return (x != y) ==> { a * pow(x, 2) + b * x + c == a * pow(y, 2) + b * y + c }
				}
			}
		},
		forAll { (_ : Int) in throw SwiftCheckError.Bogus },
		forAll { (_ : Int, _ : Float, _ : Int) in throw SwiftCheckError.Bogus }.expectFailure.expectFailure,
		exists { (_ : Int) in throw SwiftCheckError.Bogus },
	]

	func testProperties() {
		self.tests.forEach { t in
			property("Fail") <- t
		}
	}

	/// h/t @robrix for the suggestion ~( https://github.com/antitypical/Assertions/blob/master/AssertionsTests/AssertionsTests.swift )
	/// and @ishikawa for the idea ~( https://github.com/antitypical/Assertions/pull/3#issuecomment-76337761 )
	override func recordFailureWithDescription(message : String, inFile file : String, atLine line : UInt, expected : Bool) {
		if !expected {
			assert(false, "Assertion should never throw.")
		} else {
//			super.recordFailureWithDescription(message, inFile: file, atLine: line, expected: expected)
			failCount = failCount.successor()
		}
	}

	override func tearDown() {
		XCTAssert(failCount == tests.count)
	}
}
