//
//  ReplaySpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 11/18/15.
//  Copyright © 2016 Typelift. All rights reserved.
//

import SwiftCheck
import XCTest

class ReplaySpec : XCTestCase {
	func testAll() {
		property("Test is replayed at specific args") <- forAll { (seedl : Int, seedr : Int, size : Int) in
			let replayArgs = CheckerArguments(replay: .some(StdGen(seedl, seedr), size))
			var foundArgs : [Int] = []
			property("Replay at \(seedl), \(seedr)", arguments: replayArgs) <- forAll { (x : Int) in
				foundArgs.append(x)
				return true
			}

			var foundArgs2 : [Int] = []
			property("Replay at \(seedl), \(seedr)", arguments: replayArgs) <- forAll { (x : Int) in
				foundArgs2.append(x)
				return foundArgs.contains(x)
			}

			return foundArgs == foundArgs2
		}
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testAll", testAll),
	])
	#endif
}
