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

public struct ArbitraryMutableFoo : Arbitrary {
	var a: Int8
	var b: Int16
	
	public init() {
		a = 0
		b = 0
	}
	
	public static var arbitrary: Gen<ArbitraryMutableFoo> {
		return Gen.compose { c in
			var foo = ArbitraryMutableFoo()
			foo.a = c.generate()
			foo.b = c.generate()
			return foo
		}
	}
}

extension ArbitraryMutableFoo: Equatable {}

public func == (lhs: ArbitraryMutableFoo, rhs: ArbitraryMutableFoo) -> Bool {
	return lhs.a == rhs.a && lhs.b == rhs.b
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

extension ArbitraryLargeFoo: Equatable {}

public func ==(i: ArbitraryLargeFoo, j: ArbitraryLargeFoo) -> Bool {
	return i.a == j.a
		&& i.b == j.b
		&& i.c == j.c
		&& i.d == j.d
		&& i.e == j.e
		&& i.f == j.f
		&& i.g == j.g
		&& i.h == j.h
		&& i.i == j.i
		&& i.j == j.j
		&& i.k == j.k
		&& i.l == j.l
		&& i.m == j.m
		&& i.n == j.n
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
					.map(
						Bool.arbitrary,
						Gen<(Bool, Bool)>.zip(Bool.arbitrary, Bool.arbitrary),
						Gen<(Bool, Bool, Bool)>.zip(Bool.arbitrary, Bool.arbitrary, Bool.arbitrary),
						Gen<(Bool, Bool, Bool, Bool)>.zip(Bool.arbitrary, Bool.arbitrary, Bool.arbitrary, Bool.arbitrary)
					) { t2 in
						(t.0, t.1, t.2, t.3, t.4, t.5, t.6, t.7, t.8, t.9, t2.0, t2.1, t2.2, t2.3)
					}.map(ArbitraryLargeFoo.init)
		}
	}
}

let composedArbitraryLargeFoo = Gen<ArbitraryLargeFoo>.compose { c in
	let evenInt16 = Int16.arbitrary.suchThat { $0 % 2 == 0 }
	return ArbitraryLargeFoo(
		a: c.generate(),
		b: c.generate(using: evenInt16),
		c: c.generate(),
		d: c.generate(),
		e: c.generate(),
		f: c.generate(),
		g: c.generate(),
		h: c.generate(),
		i: c.generate(),
		j: c.generate(),
		k: c.generate(),
		l: (c.generate(), c.generate()),
		m: (c.generate(), c.generate(), c.generate()),
		n: (c.generate(), c.generate(), c.generate(), c.generate())
	)
}

class SimpleSpec : XCTestCase {
	func testAll() {
		XCTAssert(fileCheckOutput {
			// CHECK: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Integer Equality is Reflexive") <- forAll { (i : Int8) in
				return i == i
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Unsigned Integer Equality is Reflexive") <- forAll { (i : UInt8) in
				return i == i
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Float Equality is Reflexive") <- forAll { (i : Float) in
				return i == i
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Double Equality is Reflexive") <- forAll { (i : Double) in
				return i == i
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("String Equality is Reflexive") <- forAll { (s : String) in
				return s == s
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("ArbitraryFoo Properties are Reflexive") <- forAll { (i : ArbitraryFoo) in
				return i.x == i.x && i.y == i.y
			}
			
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
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
			
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("All generated Charaters are valid Unicode") <- forAll { (c : Character) in
				return 
					(c >= ("\u{0000}" as Character) && c <= ("\u{D7FF}" as Character))
					||
					(c >= ("\u{E000}" as Character) && c <= ("\u{10FFFF}" as Character))
			}

			let greaterThan_lessThanEqualTo: ((UInt8, UInt8) -> Bool, (UInt8, UInt8) -> Bool) = ((>), (<=))
			let lessThan_greaterThanEqualTo: ((UInt8, UInt8) -> Bool, (UInt8, UInt8) -> Bool) = ((<), (>=))
			let equalTo_notEqualTo: ((UInt8, UInt8) -> Bool, (UInt8, UInt8) -> Bool) = ((==), (!=))
			let inverses = Gen<((UInt8, UInt8) -> Bool, (UInt8, UInt8) -> Bool)>.fromElements(of: [
				greaterThan_lessThanEqualTo,
				lessThan_greaterThanEqualTo,
				equalTo_notEqualTo,
			])
			
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Inverses work") <- forAllNoShrink(inverses) { (op, iop) in
				return forAll { (x : UInt8, y : UInt8) in
					return op(x, y) ==== !iop(x, y)
				}
			}
			
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("composition generates high-entropy, arbitrary values") <- forAll(
				composedArbitraryLargeFoo,
				composedArbitraryLargeFoo
			) { a, b in
				return a != b
			}
		})
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testAll", testAll),
	])
	#endif
}
