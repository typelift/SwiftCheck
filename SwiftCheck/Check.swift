//
//  Check.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

import Basis

public var swiftCheck : QuickCheck = QuickCheck()

public struct QuickCheck {
	public subscript(s : String) -> Testable {
		get {
			return undefined()
		}
		set(test) {
			quickCheck(test)
		}
	}
}
