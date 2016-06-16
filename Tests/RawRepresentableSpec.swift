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

// Declaring the extension allows Swift to know this particular enum can be Arbitrary
// ...but it doesn't need to be implemented since the protocol extension gives us a default implementation!
extension ImplicitRawValues: Arbitrary {}

enum ExplicitRawValues : Int {
	case zero = 0
	case one = 1
	case two = 2
}

class RawRepresentable_ArbitrarySpec: XCTestCase {
	func testDefaultRawRepresentableGeneratorWithImplicitRawValues() {
		property("only generates Foo, Bar, or Baz") <- forAll { (e: ImplicitRawValues) in
			return [.foo, .bar, .baz].contains(e)
		}
	}
	
	func testDeafultRawRepresentableGeneratorWithExplicitRawValues() {
		// when no extension is given, the user has to call `forAllNoShrink` since the compiler doesn't automatically
		// infer protocol conformance
		property("only generates Zero, One, or Two") <- forAllNoShrink(ExplicitRawValues.arbitrary) { e in
			return [.zero, .one, .two].contains(e)
		}       
	}
}
