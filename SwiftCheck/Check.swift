//
//  Check.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//


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
