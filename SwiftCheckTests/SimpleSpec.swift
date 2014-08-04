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
	func prop_reverse<A: Equatable>(xs: [A]) -> Bool {
		return xs.reverse().reverse() == xs
	}

	func runTest() {
		quickCheck(prop_reverse)
	}
}

