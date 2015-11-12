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
/// but with the minimal failing case reported as well.
///
/// If necessary, arguments can be provided to this function to change the behavior of the testing
/// mechanism:
///
///     let args = CheckerArguments( replay: Optional.Some((newStdGen(), 10)) // Replays all tests with a new generator of size 10
///                                , maxAllowableSuccessfulTests: 200 // Requires twice the normal amount of successes to pass.
///                                , maxAllowableDiscardedTests: 0 // Discards are not allowed anymore.
///                                , maxTestCaseSize: 1000 // Increase the size of tested values by 10x.
///                                )
///
///     property("reflexitivity", arguments: args) <- forAll { (i : Int8) in
///	        return i == i
///     }
///
/// If no arguments are provided, or nil is given, SwiftCheck will select an internal default.
public func property(msg : String, arguments : CheckerArguments? = nil, file : String = __FILE__, line : UInt = __LINE__) -> AssertiveQuickCheck {
	return AssertiveQuickCheck(msg: msg, file: file, line: line, args: arguments ?? CheckerArguments(name: msg))
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
		self.args = { var chk = args; chk.name = msg; return chk }()
	}
}

/// The interface for properties to be run through SwiftCheck without an XCTest assert.  The
/// property will still generate console output during testing.
public func reportProperty(msg : String, arguments : CheckerArguments? = nil, file : String = __FILE__, line : UInt = __LINE__) -> ReportiveQuickCheck {
	return ReportiveQuickCheck(msg: msg, file: file, line: line, args: arguments ?? CheckerArguments(name: msg))
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
		self.args = { var chk = args; chk.name = msg; return chk }()
	}
}

/// Represents the arguments the test driver will use while performing testing, shrinking, and
/// printing results.
public struct CheckerArguments {
	/// Provides a way of re-doing a test at the given size with a new generator.
	let replay : Optional<(StdGen, Int)>
	/// The maximum number of test cases that must pass before the property itself passes.
	///
	/// The default value of this property is 100.  In general, some tests may require more than
	/// this amount, but less is rare.  If you need a value less than or equal to 1, use `.once`
	/// on the property instead.
	let maxAllowableSuccessfulTests : Int
	/// The maximum number of tests cases that can be discarded before testing gives up on the
	/// property.
	///
	/// The default value of this property is 500.  In general, most tests will require less than
	/// this amount.  `Discard`ed test cases do not affect the passing or failing status of the
	/// property as a whole.
	let maxAllowableDiscardedTests : Int
	/// The limit to the size of all generators in the test.
	///
	/// The default value of this property is 100.  If "large" values, in magnitude or
	/// size, are necessary then increase this value, else keep it relatively near the default.  If
	/// it becomes too small the samples present in the test case will lose diversity.
	let maxTestCaseSize : Int

	public init(replay : Optional<(StdGen, Int)> = nil
			, maxAllowableSuccessfulTests : Int = 100
			, maxAllowableDiscardedTests : Int = 500
			, maxTestCaseSize : Int = 100
			)
	{
			self = CheckerArguments(replay: replay, maxAllowableSuccessfulTests: maxAllowableSuccessfulTests, maxAllowableDiscardedTests: maxAllowableDiscardedTests, maxTestCaseSize: maxTestCaseSize, name: "")
	}

	internal init(replay : Optional<(StdGen, Int)> = nil
				, maxAllowableSuccessfulTests : Int = 100
				, maxAllowableDiscardedTests : Int = 500
				, maxTestCaseSize : Int = 100
				, name : String
				)
	{

			self.replay = replay
			self.maxAllowableSuccessfulTests = maxAllowableSuccessfulTests
			self.maxAllowableDiscardedTests = maxAllowableDiscardedTests
			self.maxTestCaseSize = maxTestCaseSize
			self.name = name
	}

	internal var name : String
}
