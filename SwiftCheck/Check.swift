//
//  Check.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import XCTest

infix operator <- {}

/// The main interface for the SwiftCheck testing mechanism. To test a program property one
/// subscripts into this variable with a description of the property being tested like so:
///
///     property("") <- forAll { (i : Int8) in
///	        return i == i
///     }
///
/// SwiftCheck will report all failures through the XCTest mechanism like a normal testing assert,
/// but with minimal failing case reported as well.
public func property(msg : String, file : String = __FILE__, line : UInt = __LINE__) -> AssertiveQuickCheck {
	return AssertiveQuickCheck(msg: msg, file: file, line: line)
}

public struct AssertiveQuickCheck {
	let msg : String
	let file : String
	let line : UInt

	private init(msg : String, file : String, line : UInt) {
		self.msg = msg
		self.file = file
		self.line = line
	}
}

public func <-(checker : AssertiveQuickCheck, test : Testable) {
	let r = quickCheckWithResult(stdArgs(name: checker.msg), test)
	switch r {
	case let .Failure(numTests, numShrinks, usedSeed, usedSize, reason, labels, output):
		XCTFail(reason, file: checker.file, line: checker.line)
	case let .NoExpectedFailure(numTests, labels, output):
		XCTFail("Expected property to fail but it didn't.", file: checker.file, line: checker.line)
	default:
		return
	}
}

/// The interface for properties to be run through SwiftCheck without an XCTest assert.  The
/// property will still generate console output during testing.
public func reportProperty(msg : String, file : String = __FILE__, line : UInt = __LINE__) -> ReportiveQuickCheck {
	return ReportiveQuickCheck(msg: msg, file: file, line: line)
}

public struct ReportiveQuickCheck {
	let msg : String
	let file : String
	let line : UInt

	private init(msg : String, file : String, line : UInt) {
		self.msg = msg
		self.file = file
		self.line = line
	}
}

public func <-(checker : ReportiveQuickCheck, test : Testable) {
	quickCheckWithResult(stdArgs(name: checker.msg), test)
}
