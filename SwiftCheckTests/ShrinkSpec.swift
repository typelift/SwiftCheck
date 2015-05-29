//
//  ShrinkSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/28/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck

class ShrinkSpec : XCTestCase {
	func shrinkArbitrary<A : Arbitrary>(x : A) -> [A] {
		let xs = A.shrink(x)
		if let x = xs.first {
			return xs + [x].map({ self.shrinkArbitrary($0) }).reduce([], combine: +)
		}
		return xs
	}

	func testAll() {
		property["Shrink of an integer does not contain that integer"] = forAll { (n : Int) in
			return !Set(Int.shrink(n)).contains(n)
		}

		property["Shrinking a non-zero integer always gives 0"] = forAll { (n : Int) in
			return (n != 0) ==> Set(self.shrinkArbitrary(n)).contains(0)
		}

		/// TODO: These will hold when the shrinker is fixed.
//		property["list"] = verbose(forAll { (l : ArrayOf<Int8>) in
//			return ArrayOf.shrink(l).map({ $0.getArray }).filter({ $0 == l.getArray }).isEmpty
//		})

		reportProperty["Shrunken lists of integers always contain [] and [0]"] = forAll { (l : ArrayOf<Int>) in
			return (!l.getArray.isEmpty && l.getArray != [0]) ==> {
				let ls = self.shrinkArbitrary(l).map { $0.getArray }
				return (ls.filter({ $0 == [] || $0 == [0] }).count == 2) <?> "\(ls)"
			}()
		}
	}
}
