//
//  State.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

public struct CheckerState {
	let name				: String
	let maxSuccessTests		: Int
	let maxDiscardedTests	: Int
	let computeSize			: Int -> Int -> Int
	let numSuccessTests		: Int
	let numDiscardedTests	: Int
	let labels				: Dictionary<String, Int>
	let collected			: [Set<String>]
	let expectedFailure		: Bool
	let randomSeed			: StdGen
	let numSuccessShrinks	: Int
	let numTryShrinks		: Int
	let numTotTryShrinks	: Int
	let shouldAbort			: Bool

	public init(name : String, maxSuccessTests : Int, maxDiscardedTests : Int, computeSize : Int -> Int -> Int, numSuccessTests : Int, numDiscardedTests : Int, labels : Dictionary<String, Int>, collected : [Set<String>], expectedFailure : Bool, randomSeed : StdGen, numSuccessShrinks : Int, numTryShrinks : Int, numTotTryShrinks : Int, shouldAbort : Bool) {
		self.name = name
		self.maxSuccessTests = maxSuccessTests
		self.maxDiscardedTests = maxDiscardedTests
		self.computeSize = computeSize
		self.numSuccessTests = numSuccessTests
		self.numDiscardedTests = numDiscardedTests
		self.labels = labels
		self.collected = collected
		self.expectedFailure = expectedFailure
		self.randomSeed = randomSeed
		self.numSuccessShrinks = numSuccessShrinks
		self.numTryShrinks = numTryShrinks
		self.numTotTryShrinks = numTotTryShrinks
		self.shouldAbort = shouldAbort
	}
}
