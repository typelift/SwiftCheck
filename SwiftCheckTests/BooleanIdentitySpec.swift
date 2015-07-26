//
//  BooleanIdentitySpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/2/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import XCTest
import SwiftCheck

class BooleanIdentitySpec : XCTestCase {
	func testAll() {
		property["Law of complements"] = forAll { (x : Bool) in
			return ((x || !x) == true) && ((x && !x) == false)
		}

		property["Law of double negation"] = forAll { (x : Bool) in
			return !(!x) == x
		}

		property["Law of idempotency"] = forAll { (x : Bool) in
			return ((x || x) == x) && ((x && x) == x)
		}

		property["Law of dominance"] = forAll { (x : Bool) in
			return ((x || false) == x) && ((x && true) == x)
		}

		property["Law of commutativity"] = forAll { (x : Bool, y : Bool) in
			return ((x || y) == (y || x)) && ((x && y) == (y && x))
		}

		property["Law of associativity"] = forAll { (x : Bool, y : Bool, z : Bool) in
			return (((x || y) || z) == (x || (y || z))) && (((x && y) && z) == (x && (y && z)))
		}

		property["DeMorgan's Law"] = forAll { (x : Bool, y : Bool) in
			let l = !(x && y) == (!x || !y)
			let r = !(x || y) == (!x && !y)
			return l && r
		}

		property["Law of absorbtion"] = forAll { (x : Bool, y : Bool) in
			let l = (x && (x || y)) == x
			let r = (x || (x && y)) == x
			return l && r
		}

		property["2-part Simplification Laws"] = forAll { (x : Bool, y : Bool) in
			let l = (x && (!x || y)) == (x && y)
			let r = (x || (!x && y)) == (x || y)
			return l && r
		}

		property["3-part Simplification Law"] = forAll { (x : Bool, y : Bool, z : Bool) in
			return ((x && y) || (x && z) || (!y && z)) == ((x && y) || (!y && z))
		}
	}
}
