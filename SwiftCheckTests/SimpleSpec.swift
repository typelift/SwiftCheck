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
		let reflInt = forAll { (i : Int) in
			return i == i
		}

		let reflUInt = forAll { (i : UInt) in
			return i == i
		}

		let reflFloat = forAll { (i : Float) in
			return i == i
		}

		let reflDouble = forAll { (i : Double) in
			return i == i
		}

//		let prop = forAll { (xs : [Int]) in
//			return xs == xs.reverse().reverse()
//		}
		quickCheck(reflInt)
		quickCheck(reflUInt)
		quickCheck(reflFloat)
		quickCheck(reflDouble)

	}
	

}
