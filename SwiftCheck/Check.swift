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
public func property(msg : String, arguments : CheckerArguments? = nil, file : String = __FILE__, line : UInt = __LINE__) -> AssertiveQuickCheck {
	return AssertiveQuickCheck(msg: msg, file: file, line: line, args: arguments ?? stdArgs(msg))
}

public struct AssertiveQuickCheck {
	let msg : String
	let file : String
	let line : UInt
	let args : CheckerArguments

	private init(msg : String, file : String, line : UInt, args : CheckerArguments) {
		self.msg = msg
		self.file = file
		self.line = line
		self.args = args
	}
}

/// The interface for properties to be run through SwiftCheck without an XCTest assert.  The
/// property will still generate console output during testing.
public func reportProperty(msg : String, arguments : CheckerArguments? = nil, file : String = __FILE__, line : UInt = __LINE__) -> ReportiveQuickCheck {
	return ReportiveQuickCheck(msg: msg, file: file, line: line, args: arguments ?? stdArgs(msg))
}

public struct ReportiveQuickCheck {
	let msg : String
	let file : String
	let line : UInt
	let args : CheckerArguments

	private init(msg : String, file : String, line : UInt, args : CheckerArguments) {
		self.msg = msg
		self.file = file
		self.line = line
		self.args = args
	}
}

public struct CheckerArguments {
	let name			: String
	let replay			: Optional<(StdGen, Int)>
	let maxSuccess		: Int
	let maxDiscard		: Int
	let maxSize			: Int
	let chatty			: Bool
}

