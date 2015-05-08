//
//  Operators.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/4/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

infix operator ==> {}

/// Models implication for properties.  That is, the property holds if the first argument is false
/// (in which case the test case is discarded), or if the given property holds.
public func ==>(b : Bool, p : Testable) -> Property {
	if b {
		return p.property()
	}
	return Discard().property()
}


infix operator ==== {}

/// Like equality but prints a verbose description when it fails.
public func ====<A where A : Equatable, A : Printable>(x : A, y : A) -> Property {
	return counterexample(x.description + "/=" + y.description)(p: x == y)
}
