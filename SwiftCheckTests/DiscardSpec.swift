//
//  DiscardSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck
import Basis

class DiscardSpec : XCTestCase {
	func testDiscardFailure() {
		swiftCheck["P != NP"] = Discard()
		swiftCheck["P = NP"] = expectFailure(Discard())
	}
}
