//
//  DiscardSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck

class DiscardSpec : XCTestCase {
	func testDiscardFailure() {
		assertProperty["P != NP"] = Discard()
		assertProperty["P = NP"] = expectFailure(Discard())
	}
}
