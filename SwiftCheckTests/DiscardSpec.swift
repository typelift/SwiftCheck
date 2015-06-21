//
//  DiscardSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import XCTest
import SwiftCheck

class DiscardSpec : XCTestCase {
	func testDiscardFailure() {
		property("P != NP") <- Discard()
		property("P = NP") <- Discard().expectFailure
	}
}
