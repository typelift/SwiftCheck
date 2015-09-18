//
//  FailureSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 9/18/15.
//  Copyright © 2015 Robert Widmann. All rights reserved.
//

import SwiftCheck
import XCTest

class FailureSpec : XCTestCase {
	private var failCount : Int = 0
	private let tests : [Property] = [
		forAll { (_ : Int) in return false },
		forAll { (x : Int) in return x != x },
		forAll { (b : Bool) in return !(b || !b) },
	]

	func testProperties() {
		self.tests.forEach { t in
			property("Fail") <- t
		}
	}

	override func recordFailureWithDescription(message : String, inFile file : String, atLine line : UInt, expected : Bool) {
		if !expected {
			assert(false, "Assertion should never throw.");
		} else {
//			super.recordFailureWithDescription(message, inFile: file, atLine: line, expected: expected)
			failCount++;
		}
	}

	override func tearDown() {
		XCTAssert(failCount == tests.count)
	}
}