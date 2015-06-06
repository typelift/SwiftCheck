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

		property["Invert turns passing properties to failing properties"] = expectFailure(invert(forAll { (n : Int) in
			return n == n
		}))

		property["Invert turns failing properties to passing properties"] = invert(forAll { (n : Int) in
			return n != n
		})

		property["Invert does not affect discards"] = invert(forAll { (n : Int) in
			return Discard()
		})

		property["Existential Quantification works"] = exists { (x : Int) in
			return true
		}
	}
}
