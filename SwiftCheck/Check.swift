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
public var property : QuickCheck = QuickCheck()

public struct QuickCheck {
	public subscript(s : String) -> Testable {
		get {
			fatalError("Proposition '\(s)' has an undefined test case")
		}
		set(test) {
			quickCheck(test, name: s)
		}
	}
}

/// The main interface for the Assertive SwiftCheck testing mechanism.  Assertive checks test 
/// program properties that will fail in XCTest and not just print failures to the console.
public var assertProperty : AssertiveQuickCheck = AssertiveQuickCheck()

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
