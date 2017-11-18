//
//  ShrinkSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/28/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import SwiftCheck
import XCTest
#if SWIFT_PACKAGE
import FileCheck
#endif

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

class ShrinkSpec : XCTestCase {
	func shrinkArbitrary<A : Arbitrary>(_ x : A) -> [A] {
		let xs = A.shrink(x)
		if let x = xs.first {
			return xs + [x].flatMap(self.shrinkArbitrary)
		}
		return xs
	}

	func testAll() {
		XCTAssert(fileCheckOutput {
			// CHECK: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Shrink of an integer does not contain that integer") <- forAll { (n : Int) in
				return !Set(Int.shrink(n)).contains(n)
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Shrinking a non-zero integer always gives 0") <- forAll { (n : Int) in
				return (n != 0) ==> Set(self.shrinkArbitrary(n)).contains(0)
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Shrinking an array never gives back the original") <- forAll { (l : Array<Int8>) in
				return Array.shrink(l).filter({ $0 == l }).isEmpty
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Shrunken arrays of integers always contain [] or [0]") <- forAll { (l : [Int]) in
				return (!l.isEmpty && l != [0]) ==> {
					let ls = self.shrinkArbitrary(l)
					return (ls.filter({ $0 == [] || $0 == [0] }).count >= 1)
				}
			}

			// CHECK-NEXT: +++ OK, failed as expected. Proposition: Shrinking Double values does not loop
			// CHECK-NEXT: Falsifiable (after {{[0-9]+}} test{{[s]*}}):
			// CHECK-NEXT: {{[+-]?([0-9]*[.])?[0-9]+}}
			// CHECK-NEXT: .
			property("Shrinking Double values does not loop") <- forAll { (n : Double) in
				let left = pow(n, 0.5)
				let right = sqrt(n)
				return left == right
			}.expectFailure
		})
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testAll", testAll),
	])
	#endif
}
