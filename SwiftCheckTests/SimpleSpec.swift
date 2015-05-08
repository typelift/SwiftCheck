//
//  SimpleSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck

public struct ArbitraryFoo {
	let x : Int
	let y : Int
	
	public static func create(x : Int) -> Int -> ArbitraryFoo {
		return { y in ArbitraryFoo(x: x, y: y) }
	} 
	
	public var description : String {
		return "Arbitrary Foo!"
	}
}

extension ArbitraryFoo : Arbitrary {
	public static func arbitrary() -> Gen<ArbitraryFoo> {
		return Int.arbitrary().bind { i in
			return Int.arbitrary().bind { j in
				return Gen.pure(ArbitraryFoo(x: i, y: j))
			}
		}
	}
	
	public static func shrink(x : ArbitraryFoo) -> [ArbitraryFoo] {
		return shrinkNone(x)
	}
}


class SimpleSpec : XCTestCase {
	func testAll() {
		assertProperty["Integer Equality is Reflexive"] = forAll { (i : Int8) in
			return i == i
		}

		assertProperty["Unsigned Integer Equality is Reflexive"] = forAll { (i : UInt8) in
			return i == i
		}

		assertProperty["Float Equality is Reflexive"] = forAll { (i : Float) in
			return i == i
		}

		assertProperty["Double Equality is Reflexive"] = forAll { (i : Double) in
			return i == i
		}
		
		assertProperty["String Equality is Reflexive"] = forAll { (s : String) in
			return s == s
		}
		
		assertProperty["ArbitraryFoo Properties are Reflexive"] = forAll { (i : ArbitraryFoo) in
			return i.x == i.x && i.y == i.y
		}
	}
}
