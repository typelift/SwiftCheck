//
//  RawRepresentable+ArbitrarySpec.swift
//  SwiftCheck
//
//  Created by Brian Gerstle on 5/4/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

import XCTest
import SwiftCheck

enum ImplicitRawValues : Int {
	case foo
	case bar
	case baz
}

extension ImplicitRawValues : Arbitrary {}

enum ExplicitRawIntValues : Int {
	case zero = 0
	case one = 1
	case two = 2
}

class RawRepresentableSpec : XCTestCase {
	func testAll() {
		property("only generates Foo, Bar, or Baz") <- forAll { (e: ImplicitRawValues) in
			return [.foo, .bar, .baz].contains(e)
		}

		property("only generates Zero, One, or Two") <- forAllNoShrink(ExplicitRawIntValues.arbitrary) { e in
			return [.zero, .one, .two].contains(e)
		}
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testAll", testAll),
	])
	#endif
}
