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

		property("Dictionaries behave") <- forAllNoShrink(dictionaryGen) { (xs : Dictionary<String, Int>) in
			return true
		}

		property("Optionals behave") <- forAll { (xs : Int?) in
			return true
		}

		property("Sets behave") <- forAll { (xs : Set<Int>) in
			return true
		}

		property("The reverse of the reverse of an array is that array") <- forAll { (xs : Array<Int>) in
			return (xs.reversed().reversed() == xs) <?> "Left identity"
				^&&^
				(xs == xs.reversed().reversed()) <?> "Right identity"
		}

		property("Failing conjunctions print labelled properties") <- forAll { (xs : Array<Int>) in
			return (xs.sorted().sorted() == xs.sorted()).verbose <?> "Sort Left"
				^&&^
				((xs.sorted() != xs.sorted().sorted()).verbose <?> "Bad Sort Right")
			}.expectFailure

		property("map behaves") <- forAll { (xs : Array<Int>) in
			return forAll { (f : ArrowOf<Int, Int>) in
				return xs.map(f.getArrow) == xs.map(f.getArrow)
			}
		}

		property("filter behaves") <- forAll { (xs : Array<Int>) in
			return forAll { (pred : ArrowOf<Int, Bool>) in
				let f = pred.getArrow
				return (xs.filter(f).reduce(true, { $0.0 && f($0.1) }) as Bool)
			}
		}
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testAll", testAll),
	])
	#endif
}
