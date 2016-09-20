//
//  FailureSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 9/18/15.
//  Copyright © 2016 Typelift. All rights reserved.
//

import SwiftCheck
import XCTest

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

enum SwiftCheckError : Error {
	case bogus
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
		forAll { (_ : Int) in throw SwiftCheckError.bogus },
		forAll { (_ : Int, _ : Float, _ : Int) in throw SwiftCheckError.bogus }.expectFailure.expectFailure,
		exists { (_ : Int) in throw SwiftCheckError.bogus },
		]

	func testProperties() {
		self.tests.forEach { t in
			property("Fail") <- t
		}
	}

	/// h/t @robrix for the suggestion ~( https://github.com/antitypical/Assertions/blob/master/AssertionsTests/AssertionsTests.swift )
	/// and @ishikawa for the idea ~( https://github.com/antitypical/Assertions/pull/3#issuecomment-76337761 )
	override func recordFailure(withDescription message : String, inFile file : String, atLine line : UInt, expected : Bool) {
		if !expected {
			assert(false, "Assertion should never throw.")
		} else {
			//            super.recordFailureWithDescription(message, inFile: file, atLine: line, expected: expected)
			failCount = (failCount + 1)
		}
	}

	override func tearDown() {
		XCTAssert(failCount == tests.count)
	}


	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testProperties", testProperties),
	])
	#endif
}
