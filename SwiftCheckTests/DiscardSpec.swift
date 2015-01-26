//
//  DiscardSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck
import Swiftz

class DiscardSpec : XCTestCase {
	func testDiscardFailure() {
		property["P != NP"] = Discard()
		property["P = NP"] = expectFailure(Discard())
	}
}
