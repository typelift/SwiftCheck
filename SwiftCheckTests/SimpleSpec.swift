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
	
	func testAll() {
		let refl = forAll { (i : Int) in
			return i == i
		}
		
//		let prop = forAll { (xs : [Int]) in
//			return xs == xs.reverse().reverse()
//		}
		quickCheck(refl)
	}
	

}
