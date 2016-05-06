//
//  SimpleSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import SwiftCheck
import XCTest

public struct ArbitraryFoo {
	let x : Int
	let y : Int

	public var description : String {
		return "Arbitrary Foo!"
	}
}

extension ArbitraryFoo : Arbitrary {
	public static var arbitrary : Gen<ArbitraryFoo> {
		return Gen<(Int, Int)>.zip(Int.arbitrary, Int.arbitrary).map(ArbitraryFoo.init)
	}
}

public struct ArbitraryLargeFoo {
	let a : Int8
	let b : Int16
	let c : Int32
	let d : Int64
	let e : UInt8
	let f : UInt16
	let g : UInt32
	let h : UInt64
	let i : Int
	let j : UInt
	let k : Bool
	let l : (Bool, Bool)
	let m : (Bool, Bool, Bool)
	let n : (Bool, Bool, Bool, Bool)
}

extension ArbitraryLargeFoo : Arbitrary {
	public static var arbitrary : Gen<ArbitraryLargeFoo> {
		return Gen<(Int8, Int16, Int32, Int64
				  , UInt8, UInt16, UInt32, UInt64
				  , Int , UInt)>
			.zip( Int8.arbitrary, Int16.arbitrary, Int32.arbitrary, Int64.arbitrary
				, UInt8.arbitrary, UInt16.arbitrary, UInt32.arbitrary, UInt64.arbitrary
				, Int.arbitrary, UInt.arbitrary)
			.flatMap { t in
				return Gen<(Bool, (Bool, Bool), (Bool, Bool, Bool), (Bool, Bool, Bool, Bool))>
					.zip( Bool.arbitrary
						, Gen<(Bool, Bool)>.zip(Bool.arbitrary, Bool.arbitrary)
						, Gen<(Bool, Bool, Bool)>.zip(Bool.arbitrary, Bool.arbitrary, Bool.arbitrary)
						, Gen<(Bool, Bool, Bool, Bool)>.zip(Bool.arbitrary, Bool.arbitrary, Bool.arbitrary, Bool.arbitrary))
					.map({ t2 in
						return (t.0, t.1, t.2, t.3, t.4, t.5, t.6, t.7, t.8, t.9, t2.0, t2.1, t2.2, t2.3)
					}).map(ArbitraryLargeFoo.init)
		}
	}
}

class SimpleSpec : XCTestCase {
	func testAll() {
		property("Integer Equality is Reflexive") <- forAll { (i : Int8) in
			return i == i
		}

		property("Unsigned Integer Equality is Reflexive") <- forAll { (i : UInt8) in
			return i == i
		}

		property("Float Equality is Reflexive") <- forAll { (i : Float) in
			return i == i
		}

		property("Double Equality is Reflexive") <- forAll { (i : Double) in
			return i == i
		}

		property("String Equality is Reflexive") <- forAll { (s : String) in
			return s == s
		}

		property("ArbitraryFoo Properties are Reflexive") <- forAll { (i : ArbitraryFoo) in
			return i.x == i.x && i.y == i.y
		}
		
		property("ArbitraryLargeFoo Properties are Reflexive") <- forAll { (i : ArbitraryLargeFoo) in
			return i.a == i.a
				&& i.b == i.b
				&& i.c == i.c
				&& i.d == i.d
				&& i.e == i.e
				&& i.f == i.f
				&& i.g == i.g
				&& i.h == i.h
				&& i.i == i.i
				&& i.j == i.j
				&& i.k == i.k
				&& i.l == i.l
				&& i.m == i.m
				&& i.n == i.n
		}
		
		property("All generated Charaters are valid Unicode") <- forAll { (c : Character) in
			return 
				(c >= ("\u{0000}" as Character) && c <= ("\u{D7FF}" as Character))
				||
				(c >= ("\u{E000}" as Character) && c <= ("\u{10FFFF}" as Character))
		}
		
		let inverses = Gen<((UInt8, UInt8) -> Bool, (UInt8, UInt8) -> Bool)>.fromElementsOf([
			((>), (<=)),
			((<), (>=)),
			((==), (!=)),
		])
		
		property("Inverses work") <- forAllNoShrink(inverses) { (op, iop) in
			return forAll { (x : UInt8, y : UInt8) in
				return op(x, y) ==== !iop(x, y)
			}
		}
	}
}

