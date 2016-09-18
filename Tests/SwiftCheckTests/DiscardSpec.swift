//
//  DiscardSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import SwiftCheck
import XCTest

class DiscardSpec : XCTestCase {
	func testDiscardFailure() {
		property("P != NP") <- Discard()
		property("P = NP") <- Discard().expectFailure

		let args = CheckerArguments(
			replay: Optional.some((newStdGen(), 10)),
			maxAllowableSuccessfulTests: 200,
			maxAllowableDiscardedTests: 0,
			maxTestCaseSize: 1000
		)

		property("Discards forbidden", arguments: args) <- forAll { (x : UInt) in
			return Discard()
		}.expectFailure
	}


	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testDiscardFailure", testDiscardFailure),
	])
	#endif
}
