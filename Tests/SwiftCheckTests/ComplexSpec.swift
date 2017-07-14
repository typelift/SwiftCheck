//
//  ComplexSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 9/2/15.
//  Copyright © 2016 Typelift. All rights reserved.
//

import SwiftCheck
import XCTest

let upper : Gen<Character> = Gen<Character>.fromElements(in: "A"..."Z")
let lower : Gen<Character> = Gen<Character>.fromElements(in: "a"..."z")
let numeric : Gen<Character> = Gen<Character>.fromElements(in: "0"..."9")
let special : Gen<Character> = Gen<Character>.fromElements(of: ["!", "#", "$", "%", "&", "'", "*", "+", "-", "/", "=", "?", "^", "_", "`", "{", "|", "}", "~", "."])
let hexDigits = Gen<Character>.one(of: [
	Gen<Character>.fromElements(in: "A"..."F"),
	numeric,
])

class ComplexSpec : XCTestCase {
	func testEmailAddressProperties() {
		XCTAssert(fileCheckOutput(withPrefixes: ["CHECKEMAIL"]) {
			let localEmail = Gen<Character>.one(of: [
				upper,
				lower,
				numeric,
				special,
				]).proliferateNonEmpty.suchThat({ $0[($0.endIndex - 1)] != "." }).map(String.init(stringInterpolationSegment:))

			let hostname = Gen<Character>.one(of: [
				lower,
				numeric,
				Gen.pure("-"),
				]).proliferateNonEmpty.map(String.init(stringInterpolationSegment:))

			let tld = lower.proliferateNonEmpty.suchThat({ $0.count > 1 }).map(String.init(stringInterpolationSegment:))

			let emailGen = glue([localEmail, Gen.pure("@"), hostname, Gen.pure("."), tld])

			let args = CheckerArguments(maxTestCaseSize: 10)

			/// CHECKEMAIL: *** Passed 1 test
			/// CHECKEMAIL-NEXT: .
			property("Generated email addresses contain 1 @", arguments: args) <- forAll(emailGen) { (e : String) in
				return e.filter({ $0 == "@" }).characters.count == 1
			}.once
		})
	}

	func testIPv6Properties() {
		XCTAssert(fileCheckOutput(withPrefixes: ["CHECKIPV6"]) {
			let gen1 : Gen<String> = hexDigits.proliferate(withSize: 1).map{ String.init($0) + ":" }
			let gen2 : Gen<String> = hexDigits.proliferate(withSize: 2).map{ String.init($0) + ":" }
			let gen3 : Gen<String> = hexDigits.proliferate(withSize: 3).map{ String.init($0) + ":" }
			let gen4 : Gen<String> = hexDigits.proliferate(withSize: 4).map{ String.init($0) + ":" }

			let ipHexDigits = Gen<String>.one(of: [
				gen1,
				gen2,
				gen3,
				gen4
			])

			let ipGen = glue([ipHexDigits, ipHexDigits, ipHexDigits, ipHexDigits]).map { $0.initial }

			/// CHECKIPV6: *** Passed 100 tests
			/// CHECKIPV6-NEXT: .
			property("Generated IPs contain 3 sections") <- forAll(ipGen) { (e : String) in
				return e.filter({ $0 == ":" }).characters.count == 3
			}
		})
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testEmailAddressProperties", testEmailAddressProperties),
		("testIPv6Properties", testIPv6Properties),
	])
	#endif
}

// MARK: String Conveniences

func glue(_ parts : [Gen<String>]) -> Gen<String> {
	return sequence(parts).map { $0.reduce("", +) }
}

extension String {
	fileprivate var initial : String {
		return self.substring(with: self.startIndex..<self.characters.index(before: self.endIndex))
	}
}
