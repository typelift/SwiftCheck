//
//  FormatterSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 11/30/16.
//  Copyright © 2016 Typelift. All rights reserved.
//
// Spec due to broomburgo (https://github.com/broomburgo) meant to test lifetime
// issues in ArrowOf and IsoOf

import SwiftCheck
import XCTest
#if SWIFT_PACKAGE
import FileCheck
#endif

struct Formatter<Value> {
	let lengthLimit : UInt
	let makeString : (Value) -> String
	let makeValue : (String) -> Value

	init(lengthLimit : UInt, makeString : @escaping (Value) -> String, makeValue : @escaping (String) -> Value) {
		self.lengthLimit = lengthLimit
		self.makeString = makeString
		self.makeValue = makeValue
	}

	func format(_ value : Value) -> String {
		let formatted = makeString(value)
		let maxIndex = formatted.index(formatted.startIndex, offsetBy: Int(lengthLimit))
		if maxIndex >= formatted.endIndex {
			return formatted
		} else {
			return String(formatted[..<maxIndex])
		}
	}

	func unFormat(_ string : String) -> Value {
		let value = makeValue(string)
		return value
	}
}

struct ArbitraryFormatter<Value : Arbitrary & CoArbitrary & Hashable> : Arbitrary {
	private let formatter : Formatter<Value>
	init(_ formatter : Formatter<Value>) {
		self.formatter = formatter
	}

	var get : Formatter<Value> {
		return formatter
	}

	static var arbitrary : Gen<ArbitraryFormatter<Value>> {
		return Gen.one(of: [
			Gen<(UInt, ArrowOf<Value, String>, ArrowOf<String, Value>)>
				.zip(UInt.arbitrary, ArrowOf<Value,String>.arbitrary, ArrowOf<String,Value>.arbitrary)
				.map { t in Formatter<Value>(lengthLimit: t.0, makeString: t.1.getArrow, makeValue: t.2.getArrow) }
				.map(ArbitraryFormatter.init),
			Gen<(UInt, IsoOf<Value, String>)>
				.zip(UInt.arbitrary, IsoOf<Value, String>.arbitrary)
				.map { t in Formatter<Value>(lengthLimit: t.0, makeString: t.1.getTo, makeValue: t.1.getFrom) }
				.map(ArbitraryFormatter.init)
		])
	}
}

class FormatterSpec : XCTestCase {
	func testAlwaysCorrectLength() {
		XCTAssert(fileCheckOutput {
			/// CHECK: *** Passed 100 tests
			/// CHECK-NEXT: .
			property(
				"Any formatted string is shorter or equal than the provided length"
			) <- forAll { (x: Int, af: ArbitraryFormatter<Int>) in
				let formatter = af.get
				let string = formatter.format(x)
				_ = formatter.unFormat(string)
				return string.distance(from: string.startIndex, to: string.endIndex) <= Int(formatter.lengthLimit)
			}

		})
	}


	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testAlwaysCorrectLength", testAlwaysCorrectLength),
	])
	#endif
}
