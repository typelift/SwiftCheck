//
//  Check.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

/// The interface to the SwiftCheck testing mechanism. To test a proposition one subscripts into
/// this variable with a description of the property being tested like so:
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
