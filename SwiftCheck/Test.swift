//
//  Test.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation
import Swift_Extras

public enum Arguments {
	case Arguments(
		replay : Optional<(StdGen, Int)>
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
	return Arguments.Arguments(replay: .None, maxSuccess: 100, maxDiscard: 500, maxSize: 100, chatty: true)
}

public func quickCheck<P : Testable>(prop: P) -> IO<()> {
	return quickCheckWith(stdArgs(), prop)
}

public func quickCheck<A, PROP : Testable where A : Arbitrary, A : Printable>(prop: A -> PROP) -> IO<()> {
	return quickCheckWith(stdArgs(), WitnessTestableFunction(prop))
}

//public func quickCheck<A, PROP : Testable where A : Arbitrary, A : Printable>(prop: [A] -> PROP) -> IO<()> {
//  return quickCheckWith(stdArgs(), WitnessTestableFunction(prop))
//}

public func quickCheckWith<P : Testable>(args: Arguments, p : P) -> IO<()> {
	return quickCheckWithResult(args, p) >> IO<()>.pure(())
}

public func quickCheckResult<P : Testable>(p : P) -> IO<Result> {
	return quickCheckWithResult(stdArgs(), p)
}

private func computeSize(args : Arguments)(x: Int)(y: Int) -> Int {
	switch args {
	case .Arguments(Optional.None, _, _, _, _):
		return computeSize_(x)(d: y)
	case .Arguments(Optional.Some(let (_, s)), _, _, _, _):
		return s
	}
}

private func computeSize_(n: Int)(d: Int) -> Int {
	return 0 //
}

private func rnd(args : Arguments) -> IO<StdGen> {
	switch args {
	case .Arguments(Optional.None, _, _, _, _):
		return newStdGen()
	case .Arguments(Optional.Some(let (rnd, _)), _, _, _, _):
		return IO<StdGen>.pure(rnd)
	}
}

public func quickCheckWithResult<P : Testable>(args : Arguments, p : P) -> IO<Result> {
	switch args {
	case .Arguments(let replay, let maxSuccess, let maxDiscard, let maxSize, let chatty):
		return test(State(terminal: Terminal(),
			maxSuccessTests: maxSuccess,
			maxDiscardedTests: maxDiscard,
			computeSize: computeSize(args),
			numSuccessTests: 0,
			numDiscardedTests: 0,
			collected: [],
			expectedFailure: false,
			randomSeed: rnd(args).unsafePerformIO(),
			numSuccessShrinks: 0,
			numTryShrinks: 0))(p.property().unProperty.unGen)
	}
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
		switch res.unBox() {
			case .MkResult(Optional.Some(true), let expect, _, _, let stamp, _):
				var st2 = st
				st2.numSuccessTests += 1
				st2.randomSeed = rnd2
				st2.collected = [stamp] + st.collected
				st2.expectedFailure = expect
				return test(st2)(f)
			case .MkResult(Optional.None, let expect, _, _, _, _):
				var st2 = st
				st2.numSuccessTests += 1
				st2.randomSeed = rnd2
				st2.expectedFailure = expect
				return test(st)(f)
			case .MkResult(Optional.Some(false), let expect, _, _, _, _):
				if expect {
					print("*** Failed! ")
				} else {
					print("+++ OK, failed as expected. ")
				}
				//					let numShrinks = st.
				return test(st)(f)
			default:
				break
		}
	default:
		break
	}
	assert(false, "")
}

public func summary(s: State) -> [(String, Int)] { return [] }


