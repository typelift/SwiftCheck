//
//  ReplaySpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 11/18/15.
//  Copyright © 2015 Robert Widmann. All rights reserved.
//

import SwiftCheck

class ReplaySpec : XCTestCase {
	func testProperties() {
		property("Test is replayed at specific args") <- forAll { (seed : Int, size : Int) in
			let replayArgs = CheckerArguments(replay: .Some(StdGen(replaySeed: seed), size))
			var foundArgs : [Int] = []
			property("Replay at \(seed), \(size)", arguments: replayArgs) <- forAll { (x : Int) in
				foundArgs.append(x)
				return true
			}

			var foundArgs2 : [Int] = []
			property("Replay at \(seed), \(size)", arguments: replayArgs) <- forAll { (x : Int) in
				foundArgs2.append(x)
				return foundArgs.contains(x)
			}

			return foundArgs == foundArgs2
		}
	}
}
