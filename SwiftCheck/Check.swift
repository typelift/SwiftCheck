//
//  Check.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// The main interface for the SwiftCheck testing mechanism.  `property` notation is used to define
/// a property that SwiftCheck can generate test cases for and a human-readable label for debugging
/// output.  A simple property test might look like the following:
///
///     property("reflexitivity") <- forAll { (i : Int8) in
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
