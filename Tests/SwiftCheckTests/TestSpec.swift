//
//  TestSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 6/23/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

import SwiftCheck
import XCTest

class TestSpec : XCTestCase {
	func testAll() {
		let dictionaryGen: Gen<Dictionary<String, Int>> = Gen<(String, Int)>.zip(String.arbitrary, Int.arbitrary).proliferate.map { _ -> Dictionary<String, Int> in [:] } 
		XCTAssert(fileCheckOutput {
			// CHECK: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Dictionaries behave") <- forAllNoShrink(dictionaryGen) { (xs : Dictionary<String, Int>) in
				return true
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Optionals behave") <- forAll { (xs : Int?) in
				return true
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Sets behave") <- forAll { (xs : Set<Int>) in
				return true
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: (100%, {{Right|Left}} identity, {{Right|Left}} identity)
			// CHECK: Failed: (Bad Sort Right)
			// CHECK-NEXT: Pass the seed values {{[0-9]+}} {{[0-9]+}} to replay the test.
			property("The reverse of the reverse of an array is that array") <- forAll { (xs : Array<Int>) in
				return
					(xs.reversed().reversed() == xs) <?> "Left identity"
						^&&^
					(xs == xs.reversed().reversed()) <?> "Right identity"
			}

			/// CHECK: +++ OK, failed as expected. Proposition: Failing conjunctions print labelled properties
			/// CHECK-NEXT: Falsifiable (after 1 test):
			/// CHECK-NEXT: []
			/// CHECK-NEXT: .
			property("Failing conjunctions print labelled properties") <- forAll { (xs : Array<Int>) in
				return (xs.sorted().sorted() == xs.sorted()).verbose <?> "Sort Left"
					^&&^
					((xs.sorted() != xs.sorted().sorted()).verbose <?> "Bad Sort Right")
				}.expectFailure

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("map behaves") <- forAll { (xs : Array<Int>) in
				return forAll { (f : ArrowOf<Int, Int>) in
					return xs.map(f.getArrow) == xs.map(f.getArrow)
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("filter behaves") <- forAll { (xs : Array<Int>) in
				return forAll { (pred : ArrowOf<Int, Bool>) in
					let f = pred.getArrow
					return (xs.filter(f).reduce(true, { (acc, val) in acc && f(val) }) as Bool)
				}
			}
		})
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testAll", testAll),
	])
	#endif
}
