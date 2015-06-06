//
//  PropertySpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 6/5/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck

class PropertySpec : XCTestCase {
	func testAll() {
		property["Once really only tests a property once"] = forAll { (n : Int) in
			var bomb : Optional<Int> = .Some(n)
			return once(forAll { (_ : Int) in
				let b = bomb! // Will explode if we test more than once
				bomb = nil
				return b == n
			})
		}

		property["Conjamb randomly picks from multiple generators"] = forAll { (n : Int, m : Int, o : Int) in
			return conjamb({
				println("picked 1")
				return true
				}(), {
					println("picked 2")
					return true
					}(), {
						println("picked 3")
						return true
						}())
		}
	}
}
