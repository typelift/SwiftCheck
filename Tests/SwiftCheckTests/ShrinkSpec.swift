//
//  ShrinkSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/28/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import SwiftCheck
import XCTest

class ShrinkSpec : XCTestCase {
	func shrinkArbitrary<A : Arbitrary>(_ x : A) -> [A] {
		let xs = A.shrink(x)
		if let x = xs.first {
			return xs + [x].flatMap(self.shrinkArbitrary)
		}
		return xs
	}

	func testAll() {
		property("Shrink of an integer does not contain that integer") <- forAll { (n : Int) in
			return !Set(Int.shrink(n)).contains(n)
		}

		property("Shrinking a non-zero integer always gives 0") <- forAll { (n : Int) in
			return (n != 0) ==> Set(self.shrinkArbitrary(n)).contains(0)
		}

		property("Shrinking an array never gives back the original") <- forAll { (l : Array<Int8>) in
			return Array.shrink(l).filter({ $0 == l }).isEmpty
		}

		property("Shrunken arrays of integers always contain [] or [0]") <- forAll { (l : ArrayOf<Int>) in
			return (!l.getArray.isEmpty && l.getArray != [0]) ==> {
				let ls = self.shrinkArbitrary(l).map { $0.getArray }
				return (ls.filter({ $0 == [] || $0 == [0] }).count >= 1)
			}
		}
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testAll", testAll),
	])
	#endif
}
