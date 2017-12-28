//
//  Check.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/4/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// The main interface for the SwiftCheck testing mechanism.  `property`
/// notation is used to define a property that SwiftCheck can generate test
/// cases for and a human-readable label for debugging output.  A simple
/// property test might look like the following:
///
///     property("reflexitivity") <- forAll { (i : Int8) in
///            return i == i
///     }
///
/// SwiftCheck will report all failures through the XCTest mechanism like a
/// normal testing assert, but with the minimal failing case reported as well.
///
/// If necessary, arguments can be provided to this function to change the
/// behavior of the testing mechanism:
///
///     let args = CheckerArguments
///                  ( replay: Optional.Some((newStdGen(), 10)) // Replays all tests with a new generator of size 10
///                  , maxAllowableSuccessfulTests: 200 // Requires twice the normal amount of successes to pass.
///                  , maxAllowableDiscardedTests: 0 // Discards are not allowed anymore.
///                  , maxTestCaseSize: 1000 // Increase the size of tested values by 10x.
///                  )
///
///     property("reflexitivity", arguments: args) <- forAll { (i : Int8) in
///            return i == i
///     }
///
/// If no arguments are provided, or nil is given, SwiftCheck will select an
/// internal default.
///
/// - Parameters:
///   - message: A description of the property.
///   - arguments: An optional set of arguments to tune the test runner.
///   - file: The file in which test occurred. Defaults to the file name of the
///     test case in which this function was called.
///   - line: The line number on which test occurred. Defaults to the line
///     number on which this function was called.
public func property(_ message : String, arguments : CheckerArguments? = nil, file : StaticString = #file, line : UInt = #line) -> AssertiveQuickCheck {
	return AssertiveQuickCheck(msg: message, file: file, line: line, args: arguments ?? CheckerArguments(name: message))
}

/// Describes a checker that uses XCTest to assert all testing failures and
/// display them in both the testing log and Xcode.
public struct AssertiveQuickCheck {
	fileprivate let msg : String
	fileprivate let file : StaticString
	fileprivate let line : UInt
	fileprivate let args : CheckerArguments

	fileprivate init(msg : String, file : StaticString, line : UInt, args : CheckerArguments) {
		self.msg = msg
		self.file = file
		self.line = line
		self.args = { var chk = args; chk.name = msg; return chk }()
	}
}

/// The interface for properties to be run through SwiftCheck without an XCTest
/// assert.  The property will still generate console output during testing.
///
/// - Parameters:
///   - message: A description of the property.
///   - arguments: An optional set of arguments to tune the test runner.
///   - file: The file in which test occurred. Defaults to the file name of the
///     test case in which this function was called.
///   - line: The line number on which test occurred. Defaults to the line
///     number on which this function was called.
public func reportProperty(_ message : String, arguments : CheckerArguments? = nil, file : StaticString = #file, line : UInt = #line) -> ReportiveQuickCheck {
	return ReportiveQuickCheck(msg: message, file: file, line: line, args: arguments ?? CheckerArguments(name: message))
}

/// Describes a checker that only reports failures to the testing log but does
/// not assert when a property fails.
public struct ReportiveQuickCheck {
	fileprivate let msg : String
	fileprivate let file : StaticString
	fileprivate let line : UInt
	fileprivate let args : CheckerArguments

	fileprivate init(msg : String, file : StaticString, line : UInt, args : CheckerArguments) {
		self.msg = msg
		self.file = file
		self.line = line
		self.args = { var chk = args; chk.name = msg; return chk }()
	}
}

/// Represents the arguments the test driver will use while performing testing,
/// shrinking, and printing results.
public struct CheckerArguments {
	/// Provides a way of re-doing a test at the given size with a new
	/// generator.
	let replay : Optional<(StdGen, Int)>
	/// The maximum number of test cases that must pass before the property
	/// itself passes.
	///
	/// The default value of this property is 100.  In general, some tests may
	/// require more than this amount, but less is rare.  If you need a value of
	/// 1 use `.once` on the property instead.
	let maxAllowableSuccessfulTests : Int
	/// The maximum number of tests cases that can be discarded before testing
	/// gives up on the property.
	///
	/// The default value of this property is 500.  In general, most tests will
	/// require less than this amount.  `Discard`ed test cases do not affect
	/// the passing or failing status of the property as a whole.
	let maxAllowableDiscardedTests : Int
	/// The limit to the size of all generators in the test.
	///
	/// The default value of this property is 100.  If "large" values, in
	/// magnitude or size, are necessary then increase this value, else keep it
	/// relatively near the default.  If it becomes too small the samples
	/// present in the test case will lose diversity.
	let maxTestCaseSize : Int

	internal let silence : Bool

	public init(replay : Optional<(StdGen, Int)> = nil
		, maxAllowableSuccessfulTests : Int = 100
		, maxAllowableDiscardedTests : Int = 500
		, maxTestCaseSize : Int = 100
		)
	{
		self = CheckerArguments(  replay: replay
			, maxAllowableSuccessfulTests: maxAllowableSuccessfulTests
			, maxAllowableDiscardedTests: maxAllowableDiscardedTests
			, maxTestCaseSize: maxTestCaseSize
			, name: ""
		)
	}

	internal init(replay : Optional<(StdGen, Int)> = nil
		, maxAllowableSuccessfulTests : Int = 100
		, maxAllowableDiscardedTests : Int = 500
		, maxTestCaseSize : Int = 100
		, name : String
		, silence : Bool = false
		)
	{

		self.replay = replay
		self.maxAllowableSuccessfulTests = maxAllowableSuccessfulTests
		self.maxAllowableDiscardedTests = maxAllowableDiscardedTests
		self.maxTestCaseSize = maxTestCaseSize
		self.name = name
		self.silence = silence
	}

	internal var name : String
}

infix operator <-

/// Binds a Testable value to a property.
public func <- (checker : AssertiveQuickCheck, test : @autoclosure @escaping () -> Testable) {
	switch quickCheckWithResult(checker.args, test()) {
	case let .failure(_, _, seed, sz, reason, _, _):
		XCTFail(reason + "; Replay with \(seed) and size \(sz)", file: checker.file, line: checker.line)
	case let .noExpectedFailure(_, seed, sz, _, _):
		XCTFail("Expected property to fail but it didn't.  Replay with \(seed) and size \(sz)", file: checker.file, line: checker.line)
	case let .insufficientCoverage(_, seed, sz, _, _):
		XCTFail("Property coverage insufficient.  Replay with \(seed) and size \(sz)", file: checker.file, line: checker.line)
	default: ()
	}
}

/// Binds a Testable value to a property.
public func <- (checker : AssertiveQuickCheck, test : () -> Testable) {
	switch quickCheckWithResult(checker.args, test()) {
	case let .failure(_, _, seed, sz, reason, _, _):
		XCTFail(reason + "; Replay with \(seed) and size \(sz)", file: checker.file, line: checker.line)
	case let .noExpectedFailure(_, seed, sz, _, _):
		XCTFail("Expected property to fail but it didn't.  Replay with \(seed) and size \(sz)", file: checker.file, line: checker.line)
	case let .insufficientCoverage(_, seed, sz, _, _):
		XCTFail("Property coverage insufficient.  Replay with \(seed) and size \(sz)", file: checker.file, line: checker.line)
	default: ()
	}
}

/// Binds a Testable value to a property.
public func <- (checker : ReportiveQuickCheck, test : () -> Testable) {
	_ = quickCheckWithResult(checker.args, test())
}

/// Binds a Testable value to a property.
public func <- (checker : ReportiveQuickCheck, test : @autoclosure @escaping () -> Testable) {
	_ = quickCheckWithResult(checker.args, test())
}

/// Tests a property and prints the results to stdout.
///
/// - parameter prop: The property to be tested.
/// - parameter name: The name of the property being tested.
@available(*, deprecated, message: "Use quickCheck(asserting:) or quickCheck(reporting:) instead.")
public func quickCheck(_ prop : Testable, name : String = "") {
	_ = quickCheckWithResult(CheckerArguments(name: name), prop)
}

/// The interface for properties to be run through SwiftCheck with an XCTest
/// assert.  The property will still generate console output during testing.
///
/// - Parameters:
///   - message: A description of the property.
///   - arguments: An optional set of arguments to tune the test runner.
///   - file: The file in which test occurred. Defaults to the file name of the
///     test case in which this function was called.
///   - line: The line number on which test occurred. Defaults to the line
///     number on which this function was called.
///   - prop: A block that carries the property or invariant to be tested.
public func quickCheck(
	asserting message: String, arguments: CheckerArguments? = nil,
	file : StaticString = #file, line : UInt = #line,
	property prop : @autoclosure @escaping () -> Testable
) {
	property(message, arguments: arguments, file: file, line: line) <- prop
}

/// The interface for properties to be run through SwiftCheck with an XCTest
/// assert.  The property will still generate console output during testing.
///
/// - Parameters:
///   - message: A description of the property.
///   - arguments: An optional set of arguments to tune the test runner.
///   - file: The file in which test occurred. Defaults to the file name of the
///     test case in which this function was called.
///   - line: The line number on which test occurred. Defaults to the line
///     number on which this function was called.
///   - prop: A block that carries the property or invariant to be tested.
public func quickCheck(
	asserting message: String, arguments: CheckerArguments? = nil,
	file : StaticString = #file, line : UInt = #line,
	property prop : () -> Testable
) {
	property(message, arguments: arguments, file: file, line: line) <- prop
}

/// The interface for properties to be run through SwiftCheck without an XCTest
/// assert.  The property will still generate console output during testing.
///
/// - Parameters:
///   - message: A description of the property.
///   - arguments: An optional set of arguments to tune the test runner.
///   - file: The file in which test occurred. Defaults to the file name of the
///     test case in which this function was called.
///   - line: The line number on which test occurred. Defaults to the line
///     number on which this function was called.
///   - prop: A block that carries the property or invariant to be tested.
public func quickCheck(
	reporting message: String, arguments: CheckerArguments? = nil,
	file : StaticString = #file, line : UInt = #line,
	property prop : @autoclosure @escaping () -> Testable
) {
	reportProperty(message, arguments: arguments, file: file, line: line) <- prop
}

/// The interface for properties to be run through SwiftCheck without an XCTest
/// assert.  The property will still generate console output during testing.
///
/// - Parameters:
///   - message: A description of the property.
///   - arguments: An optional set of arguments to tune the test runner.
///   - file: The file in which test occurred. Defaults to the file name of the
///     test case in which this function was called.
///   - line: The line number on which test occurred. Defaults to the line
///     number on which this function was called.
///   - prop: A block that carries the property or invariant to be tested.
public func quickCheck(
	reporting message: String, arguments: CheckerArguments? = nil,
	file : StaticString = #file, line : UInt = #line,
	property prop : () -> Testable
) {
	reportProperty(message, arguments: arguments, file: file, line: line) <- prop
}

precedencegroup SwiftCheckImplicationPrecedence {
	associativity: right
	lowerThan: ComparisonPrecedence
}

infix operator ==> : SwiftCheckImplicationPrecedence

/// Models implication for properties.  That is, the property holds if the first
/// argument is false (in which case the test case is discarded), or if the
/// given property holds.
public func ==> (b : Bool, p : @autoclosure() -> Testable) -> Property {
	if b {
		return p().property
	}
	return Discard().property
}

/// Models implication for properties.  That is, the property holds if the first
/// argument is false (in which case the test case is discarded), or if the
/// given property holds.
public func ==> (b : Bool, p : () -> Testable) -> Property {
	if b {
		return p().property
	}
	return Discard().property
}

infix operator ==== : ComparisonPrecedence

/// Like equality but prints a verbose description when it fails.
public func ==== <A>(x : A, y : A) -> Property
	where A : Equatable
{
	let isEq = (x == y)
	let text = isEq ? "==" : "!="
	return isEq.counterexample("\(x) \(text) \(y)")
}

precedencegroup SwiftCheckLabelPrecedence {
	associativity: right
	higherThan: BitwiseShiftPrecedence
}

infix operator <?> : SwiftCheckLabelPrecedence

/// Attaches a label to a property.
///
/// Labelled properties aid in testing conjunctions and disjunctions, or any
/// other cases where test cases need to be distinct from one another.  In
/// addition to shrunken test cases, upon failure SwiftCheck will print a
/// distribution map for the property that shows a percentage success rate for
/// the property.
public func <?> (p : Testable, s : String) -> Property {
	return p.label(s)
}

precedencegroup SwiftCheckLogicalPrecedence {
	associativity: left
	higherThan: LogicalConjunctionPrecedence
	lowerThan: ComparisonPrecedence
}

infix operator ^&&^ : SwiftCheckLogicalPrecedence

/// Takes the conjunction of two properties and treats them as a single large
/// property.
///
/// Conjoined properties succeed only when both sub-properties succeed and fail
/// when one or more sub-properties fail.
public func ^&&^ (p1 : Testable, p2 : Testable) -> Property {
	return conjoin(p1.property, p2.property)
}


infix operator ^||^ : SwiftCheckLogicalPrecedence

/// Takes the disjunction of two properties and treats them as a single large
/// property.
///
/// Disjoined properties succeed only when one or more sub-properties succeed
/// and fail when both sub-properties fail.
public func ^||^ (p1 : Testable, p2 : Testable) -> Property {
	return disjoin(p1.property, p2.property)
}

import XCTest
