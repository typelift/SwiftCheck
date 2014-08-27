//
//  SimpleSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck

class SimpleSpec : XCTestCase {
    func prop(xs: [Int]) -> Bool {
        return xs == xs.reverse().reverse()
    }
  
	func refl(x : Int) -> Bool {
		return x == x
	}
	
	func testAll() {
		quickCheck(refl)
	}
	
}
