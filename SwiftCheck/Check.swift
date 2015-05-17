//
//  Check.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

import XCTest

/// The main interface for the SwiftCheck testing mechanism. To test a program property one 
/// subscripts into this variable with a description of the property being tested like so:
///
/// property["Integer Equality is Reflexive"] = forAll { (i : Int8) in
///	    return i == i
/// }
///
/// SwiftCheck will report all failures through the XCTest mechanism like a normal testing assert,
/// but with minimal failing case reported as well.
public var property : AssertiveQuickCheck = AssertiveQuickCheck()

public struct AssertiveQuickCheck {
	public subscript(s : String) -> Testable {
		get {
			fatalError("Assertive proposition '\(s)' has an undefined test case")
		}
		set(test) {
			switch quickCheckWithResult(stdArgs(name: s), test) {
			case let .Failure(numTests, numShrinks, usedSeed, usedSize, reason, labels, output):
				XCTFail(reason)
			default:
				return
			}
		}
	}
}

/// The interface for properties to be run through SwiftCheck without an XCTest assert.  The
/// property will still generated console output during a test.
public var reportProperty : ReportiveQuickCheck = ReportiveQuickCheck()

public struct ReportiveQuickCheck {
	public subscript(s : String) -> Testable {
		get {
			fatalError("Proposition '\(s)' has an undefined test case")
		}
		set(test) {
			quickCheck(test, name: s)
		}
	}
}
