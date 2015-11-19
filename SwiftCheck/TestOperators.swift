//
//  Operators.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/4/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

infix operator <- {}

/// Binds a Testable value to a property.
public func <-(checker : AssertiveQuickCheck, @autoclosure(escaping) test : () -> Testable) {
	switch quickCheckWithResult(checker.args, p: test()) {
	case let .Failure(_, sz, seed, _, reason, _, _):
		XCTFail(reason + "; Replay with \(seed) and size \(sz)", file: checker.file, line: checker.line)
	case .NoExpectedFailure(_, _, _):
		XCTFail("Expected property to fail but it didn't.", file: checker.file, line: checker.line)
	default:
		return
	}
}

/// Binds a Testable value to a property.
public func <-(checker : AssertiveQuickCheck, test : () -> Testable) {
	switch quickCheckWithResult(checker.args, p: test()) {
	case let .Failure(_, sz, seed, _, reason, _, _):
		XCTFail(reason + "; Replay with \(seed) and size \(sz)", file: checker.file, line: checker.line)
	case .NoExpectedFailure(_, _, _):
		XCTFail("Expected property to fail but it didn't.", file: checker.file, line: checker.line)
	default:
		return
	}
}

/// Binds a Testable value to a property.
public func <-(checker : ReportiveQuickCheck, test : () -> Testable) {
	quickCheckWithResult(checker.args, p: test())
}

/// Binds a Testable value to a property.
public func <-(checker : ReportiveQuickCheck, @autoclosure(escaping) test : () -> Testable) {
	quickCheckWithResult(checker.args, p: test())
}

infix operator ==> {
	associativity right
	precedence 100
}

/// Models implication for properties.  That is, the property holds if the first argument is false
/// (in which case the test case is discarded), or if the given property holds.
public func ==>(b : Bool, @autoclosure p : () -> Testable) -> Property {
	if b {
		return p().property
	}
	return Discard().property
}

/// Models implication for properties.  That is, the property holds if the first argument is false
/// (in which case the test case is discarded), or if the given property holds.
public func ==>(b : Bool, p : () -> Testable) -> Property {
	if b {
		return p().property
	}
	return Discard().property
}

infix operator ==== {
	precedence 140
}

/// Like equality but prints a verbose description when it fails.
public func ====<A where A : Equatable>(x : A, y : A) -> Property {
	return (x == y).counterexample(String(x) + "/=" + String(y))
}


infix operator <?> {
	associativity left
	precedence 200
}

/// Attaches a label to a property.
///
/// Labelled properties aid in testing conjunctions and disjunctions, or any other cases where
/// test cases need to be distinct from one another.  In addition to shrunken test cases, upon
/// failure SwiftCheck will print a distribution map for the property that shows a percentage
/// success rate for the property.
public func <?>(p : Testable, s : String) -> Property {
	return p.label(s)
}

infix operator ^&&^ {
	associativity right
	precedence 110
}

/// Takes the conjunction of two properties and treats them as a single large property.
///
/// Conjoined properties succeed only when both sub-properties succeed and fail when one or more
/// sub-properties fail.
public func ^&&^(p1 : Testable, p2 : Testable) -> Property {
	return conjoin(p1.property, p2.property)
}


infix operator ^||^ {
	associativity right
	precedence 110
}

/// Takes the disjunction of two properties and treats them as a single large property.
///
/// Disjoined properties succeed only when one or more sub-properties succeed and fail when both
/// sub-properties fail.
public func ^||^(p1 : Testable, p2 : Testable) -> Property {
	return disjoin(p1.property, p2.property)
}

@exported import XCTest
