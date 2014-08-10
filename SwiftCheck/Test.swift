//
//  Test.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public enum Arguments {
	case Arguments(
	  replay : Maybe<(StdGen, Int)>
	, maxSuccess : Int
	, maxDiscard : Int
	, maxSize : Int
	, chatty : Bool
	)
}

public enum Result {
	case Success( numTests: Int
				, labels: [(String, Int)]
				, output: String
				)
	case GaveUp( numTests: Int
				, labels: [(String,Int)]
				, output: String
				)
	case Failure(numTests: Int
				, numShrinks: Int
				, usedSeed: StdGen
				, usedSize: Int
				, reason: String
				, labels: [(String,Int)]
				, output: String
				)
	case  NoExpectedFailure(numTests: Int
							, labels: [(String,Int)]
							, output: String
							)
}

public func isSuccess(r: Result) -> Bool {
	switch r {
		case .Success:
			return true
		default:
			return false
	}
}

public func stdArgs() -> Arguments{
	return Arguments.Arguments(replay: Maybe.Nothing, maxSuccess: 100, maxDiscard: 500, maxSize: 100, chatty: true)
}

public func quickCheck<P : Testable>(prop: P) -> IO<()> {
	return quickCheckWith(stdArgs(), prop)
}

public func quickCheckWith<P : Testable>(args: Arguments, p : P) -> IO<()> {
	return quickCheckWithResult(args, p) >> IO<()>.pure(())
}

public func quickCheckResult<P : Testable>(p : P) -> IO<Result> {
	return quickCheckWithResult(stdArgs(), p)
}

private func computeSize_(n: Int)(d: Int) -> Int {
	return 0 //
}

public func quickCheckWithResult<P : Testable>(args : Arguments, p : P) -> IO<Result> {
	func rnd() -> IO<StdGen> {
		switch args {
		case .Arguments(Maybe.Nothing, _, _, _, _):
			return newStdGen()
		case .Arguments(Maybe.Just(let (rnd, _)), _, _, _, _):
			return IO<StdGen>.pure(rnd)
		}
	}

	func computeSize(x: Int)(y: Int) -> Int {
		switch args {
			case .Arguments(Maybe.Nothing, _, _, _, _):
				return computeSize_(x)(d: y)
			case .Arguments(Maybe.Just(let (_, s)), _, _, _, _):
				return s
		}
	}

	switch args {
		case .Arguments(let replay, let maxSuccess, let maxDiscard, let maxSize, let chatty):
			return test(State(terminal: Terminal(),
				maxSuccessTests: maxSuccess,
				maxDiscardedTests: maxDiscard,
				computeSize: computeSize,
				numSuccessTests: 0,
				numDiscardedTests: 0,
				collected: [],
				expectedFailure: false,
				randomSeed: rnd().unsafePerformIO(),
				numSuccessShrinks: 0,
				numTryShrinks: 0))(p.property().unGen)
	}
	assert(false, "")
}

public func test(st: State)(f: (StdGen -> Int -> Prop)) -> IO<Result> {
	if st.numSuccessTests >= st.maxSuccessTests {
		return doneTesting(st)(f)
	} else if st.numDiscardedTests >= st.maxDiscardedTests {
		return giveUp(st)(f)
	} else {
		return runATest(st)(f)
	}
}

public func doneTesting(st: State)(f: (StdGen -> Int -> Prop)) -> IO<Result> {
	if st.expectedFailure {
		// Passed
	} else {
		// Failed
	}

	if st.expectedFailure {
		return IO<Result>.pure(Result.Success(numTests: st.numSuccessTests, labels: summary(st), output: ""))
	} else {
		return IO<Result>.pure(Result.NoExpectedFailure(numTests: st.numSuccessTests, labels: summary(st), output: ""))
	}
}

public func giveUp(st: State)(f: (StdGen -> Int -> Prop)) -> IO<Result> {
	// Gave up

	return IO<Result>.pure(Result.GaveUp(numTests: st.numSuccessTests, labels: summary(st), output: ""))
}

public func runATest(st: State)(f: (StdGen -> Int -> Prop)) -> IO<Result> {
	let size = st.computeSize(st.numSuccessTests)(st.numDiscardedTests)
	let (rnd1,rnd2) = st.randomSeed.split()
	var rose : Rose<TestResult> = protectRose(reduce(f(rnd1)(size).unProp)).unsafePerformIO()

	switch rose {
		case .MkRose(let res, _):
			switch res.value {
				case .MkResult(Maybe.Just(true), let expect, _, _, let stamp, _):
					var st2 = st
					st2.numSuccessTests += 1
					st2.randomSeed = rnd2
					st2.collected = stamp +> st.collected
					st2.expectedFailure = expect
					return test(st2)(f)
				case .MkResult(Maybe.Nothing, let expect, _, _, _, _):
					var st2 = st
					st2.numSuccessTests += 1
					st2.randomSeed = rnd2
					st2.expectedFailure = expect
					return test(st)(f)
				case .MkResult(Maybe.Just(false), let expect, _, _, _, _):
					if expect {
						print("*** Failed! ")
					} else {
						print("+++ OK, failed as expected. ")
					}
//					let numShrinks = st.
					return test(st)(f)
			}
	}
}

public func summary(s: State) -> [(String, Int)] { return [] }


