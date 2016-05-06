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
	case Foo
	case Bar
	case Baz
}

// Declaring the extension allows Swift to know this particular enum can be Arbitrary
// ...but it doesn't need to be implemented since the protocol extension gives us a default implementation!
extension ImplicitRawValues: Arbitrary {}

enum ExplicitRawValues : Int {
	case Zero = 0
	case One = 1
	case Two = 2
}

class RawRepresentable_ArbitrarySpec: XCTestCase {
	func testDefaultRawRepresentableGeneratorWithImplicitRawValues() {
		property("only generates Foo, Bar, or Baz") <- forAll { (e: ImplicitRawValues) in
			return [.Foo, .Bar, .Baz].contains(e)
		}
	}
	
	func testDeafultRawRepresentableGeneratorWithExplicitRawValues() {
		// when no extension is given, the user has to call `forAllNoShrink` since the compiler doesn't automatically
		// infer protocol conformance
		property("only generates Zero, One, or Two") <- forAllNoShrink(ExplicitRawValues.arbitrary) { e in
			return [.Zero, .One, .Two].contains(e)
		}       
	}
}
