//
//  State.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// The internal state of the testing system.
public struct CheckerState {
	/// The name bound to the current property (not labels).
	let name                         : String
	/// The maximum number of successful tests before SwiftCheck gives up.
	/// Defaults to 100.
	let maxAllowableSuccessfulTests  : Int
	/// The maximum number of discarded tests before SwiftCheck gives up.
	let maxAllowableDiscardedTests   : Int
	/// The function that generates the sizes fed to the generators for each
	/// test case.
	let computeSize                  : (Int, Int) -> Int
	/// The count of the number of successful test cases seen so far.
	let successfulTestCount          : Int
	/// The count of the number of discarded test cases seen so far.
	let discardedTestCount           : Int
	/// A dictionary of labels collected inside the test case.  Each maps to an
	/// integer describing the number of passed tests.  It is used in
	/// conjunction with the number of successful tests to print a coverage
	/// percentage.
	let labels                       : Dictionary<String, Int>
	/// A uniqued collection of all the labels collected during the test case.
	let collected                    : [Set<String>]
	/// Returns whether the test case has fulfilled its expected failure
	/// outcome.  If the test case fails and it was expected this property
	/// returns true.  If the test case doesn't fail and it was not expected to
	/// fail this property returns true.  Only when the test case's outcome and
	/// its failure fulfillment expectation do not match does this property
	/// return false.
	let hasFulfilledExpectedFailure  : Bool
	/// The Random Number Generator backing the testing session.
	let randomSeedGenerator          : StdGen
	/// Returns the number of successful shrinking steps performed so far.
	let successfulShrinkCount        : Int
	/// Returns the number of failed shrinking steps since the last successful
	/// shrink.
	let failedShrinkStepDistance     : Int
	/// Returns the number of failed shrink steps.
	let failedShrinkStepCount        : Int
	/// Returns whether the testing system should cease testing altogether.
	let shouldAbort                  : Bool
	/// The quantifier being applied to this test case.
	let quantifier                   : Quantification
	/// The arguments currently being applied to the testing driver.
	let arguments                    : CheckerArguments

	let silence                      : Bool

	public init(  
		name                         : String,
		maxAllowableSuccessfulTests  : Int,
		maxAllowableDiscardedTests   : Int,
		computeSize                  : @escaping (Int, Int) -> Int,
		successfulTestCount          : Int,
		discardedTestCount           : Int,
		labels                       : Dictionary<String, Int>,
		collected                    : [Set<String>],
		hasFulfilledExpectedFailure  : Bool,
		randomSeedGenerator          : StdGen,
		successfulShrinkCount        : Int,
		failedShrinkStepDistance     : Int,
		failedShrinkStepCount        : Int,
		shouldAbort                  : Bool,
		quantifier                   : Quantification,
		arguments                    : CheckerArguments,
		silence                      : Bool
	) {
		self.name = name
		self.maxAllowableSuccessfulTests = maxAllowableSuccessfulTests
		self.maxAllowableDiscardedTests = maxAllowableDiscardedTests
		self.computeSize = computeSize
		self.successfulTestCount = successfulTestCount
		self.discardedTestCount = discardedTestCount
		self.labels = labels
		self.collected = collected
		self.hasFulfilledExpectedFailure = hasFulfilledExpectedFailure
		self.randomSeedGenerator = randomSeedGenerator
		self.successfulShrinkCount = successfulShrinkCount
		self.failedShrinkStepDistance = failedShrinkStepDistance
		self.failedShrinkStepCount = failedShrinkStepCount
		self.shouldAbort = shouldAbort
		self.quantifier = quantifier
		self.arguments = arguments
		self.silence = silence
	}
}
