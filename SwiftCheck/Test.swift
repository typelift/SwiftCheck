//
//  Test.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for that type.
public func forAll<A : Arbitrary>(pf : (A -> Testable)) -> Property {
	return forAllShrink(A.arbitrary(), { A.shrink($0) }, pf)
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 2 types.
public func forAll<A : Arbitrary, B : Arbitrary>(pf : (A, B) -> Testable) -> Property {
	return forAll({ t in forAll({ b in pf(t, b) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 3 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary>(pf : (A, B, C) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c in pf(t, b, c) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 4 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary>(pf : (A, B, C, D) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d in pf(t, b, c, d) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 5 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary>(pf : (A, B, C, D, E) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e in pf(t, b, c, d, e) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 6 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary>(pf : (A, B, C, D, E, F) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f in pf(t, b, c, d, e, f) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 7 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary>(pf : (A, B, C, D, E, F, G) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f, g in pf(t, b, c, d, e, f, g) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 8 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary, H : Arbitrary>(pf : (A, B, C, D, E, F, G, H) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f, g, h in pf(t, b, c, d, e, f, g, h) }) })
}

/// Given an explicit generator, converts a function to a universally quantified property using the
/// default shrinker for that type.
public func forAll<A : Arbitrary>(gen : Gen<A>, pf : (A -> Testable)) -> Property {
	return forAllShrink(gen, { A.shrink($0) }, pf)
}

/// Given 2 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 2 types.
public func forAll<A : Arbitrary, B : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(pf : (A, B) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB, { b in pf(t, b) }) })
}

/// Given 3 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 3 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(pf : (A, B, C) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(pf: { b, c in pf(t, b, c) }) })
}

/// Given 4 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 4 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(pf : (A, B, C, D) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(pf: { b, c, d in pf(t, b, c, d) }) })
}

/// Given 5 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 5 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(pf : (A, B, C, D, E) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)(pf: { b, c, d, e in pf(t, b, c, d, e) }) })
}

/// Given 6 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 6 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(genF : Gen<F>)(pf : (A, B, C, D, E, F) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)(genE: genF)(pf: { b, c, d, e, f in pf(t, b, c, d, e, f) }) })
}

/// Given 7 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 7 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(genF : Gen<F>)(genG : Gen<G>)(pf : (A, B, C, D, E, F, G) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)(genE: genF)(genF : genG)(pf: { b, c, d, e, f, g in pf(t, b, c, d, e, f, g) }) })
}

/// Given 8 explicit generators, converts a function to a universally quantified property using the
/// default shrinkers for those 8 types.
public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary, H : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(genF : Gen<F>)(genG : Gen<G>)(genH : Gen<H>)(pf : (A, B, C, D, E, F, G, H) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)(genE: genF)(genF : genG)(genG : genH)(pf: { b, c, d, e, f, g, h in pf(t, b, c, d, e, f, g, h) }) })
}

/// Converts a function into an existentially quantified property using the default shrinker and
/// generator for that type.
public func exists<A : Arbitrary>(pf : A -> Testable) -> Property {
	return invert(forAllShrink(A.arbitrary(), { A.shrink($0) }, { (invert • pf)($0) }))
}

/// Given an explicit generator, converts a function to an existentially quantified property using 
/// the default shrinker for that type.
public func exists<A : Arbitrary>(gen : Gen<A>, pf : A -> Testable) -> Property {
	return invert(forAllShrink(gen, { A.shrink($0) }, { (invert • pf)($0) }))
}

/// Given an explicit generator and shrinker, converts a function to a universally quantified
/// property.
public func forAllShrink<A>(gen : Gen<A>, shrinker: A -> [A], f : A -> Testable) -> Property {
	return Property(gen.bind { x in
		return shrinking(shrinker, x, { xs  in
			return counterexample("\(xs)")(p: f(xs))
		}).unProperty
	})
}

//public func forAll<A : Arbitrary>(pf : ([A] -> Testable)) -> Property {
//	return forAllShrink(ArrayOf<A>.arbitrary().fmap({ $0.getArray }), { (x : [A]) -> [[A]] in
//		return ArrayOf<A>.shrink(ArrayOf<A>(x)).map({ $0.getArray })
//	}, pf)
//}

public func quickCheck(prop : Testable, name : String = "") {
	quickCheckWithResult(stdArgs(name: name), prop)
}

/// MARK: Implementation Details

internal enum Result {
	case Success(numTests: Int
		, labels: [(String, Int)]
		, output: String
	)
	case GaveUp(numTests: Int
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

internal class Box<T> {
	let value : T
	internal init(_ x : T) { self.value = x }
}

internal enum Either<L, R> {
	case Left(Box<L>)
	case Right(Box<R>)
}

internal struct Arguments {
	let name			: String
	let replay			: Optional<(StdGen, Int)>
	let maxSuccess		: Int
	let maxDiscard		: Int
	let maxSize			: Int
	let chatty			: Bool
}

internal func stdArgs(name : String = "") -> Arguments{
	return Arguments(name: name, replay: .None, maxSuccess: 100, maxDiscard: 500, maxSize: 100, chatty: true)
}

internal func quickCheckWithResult(args : Arguments, p : Testable) -> Result {
	func roundTo(n : Int)(m : Int) -> Int {
		return (m / m) * m
	}

	func rnd() -> StdGen {
		switch args.replay {
			case Optional.None:
				return newStdGen()
			case Optional.Some(let (rnd, _)):
				return rnd
		}
	}
	
	let computeSize_ : Int -> Int -> Int  = { x in 
		return { y in 
			if	roundTo(x)(m: args.maxSize) + args.maxSize <= args.maxSuccess ||
				x >= args.maxSuccess ||
				args.maxSuccess % args.maxSize == 0 {
				return min(x % args.maxSize + (y / 10), args.maxSize)	
			} else {
				return min((x % args.maxSize) * args.maxSize / (args.maxSuccess % args.maxSize) + y / 10, args.maxSize)
			}
		}
	}
	
	func at0(f : Int -> Int -> Int)(s : Int)(n : Int)(d : Int) -> Int {
		if n == 0 && d == 0 {
			return s
		} else {
			return f(n)(d)
		}
	}

	let computeSize : Int -> Int -> Int = { x in
		return { y in
			return (args.replay == nil) ? computeSize_(x)(y) : at0(computeSize_)(s: args.replay!.1)(n: x)(d: y)
		}
	}
	
	
	let state = State(name:					args.name
					, maxSuccessTests:		args.maxSuccess
					, maxDiscardedTests:	args.maxDiscard
					, computeSize:			computeSize
					, numSuccessTests:		0
					, numDiscardedTests:	0
					, labels:				[:]
					, collected:			[]
					, expectedFailure:		false
					, randomSeed:			rnd()
					, numSuccessShrinks:	0
					, numTryShrinks:		0
					, numTotTryShrinks:		0)
	return test(state, p.property().unProperty.unGen)
}

// Main Testing Loop:
//
// Given an initial state and the inner function that runs the property begins turning a runloop 
// that starts firing off individual test cases.  Only 3 functions get dispatched from this loop:
//
// - runATest: Does what it says; .Left indicates failure, .Right indicates continuation.
// - doneTesting: Invoked when testing the property fails or succeeds once and for all.
// - giveUp: When the number of discarded tests exceeds the number given in the arguments we just
//           give up turning the run loop to prevent excessive generation.
internal func test(st : State, f : (StdGen -> Int -> Prop)) -> Result {
	var state = st
	while true {
		switch runATest(state)(f: f) {
			case let .Left(fail):
				switch (fail.value.0, doneTesting(fail.value.1)(f: f)) {
				case let (.Success(_, _, _), _):
					return fail.value.0
				case let (_, .NoExpectedFailure(numTests, labels, output)):
					return .NoExpectedFailure(numTests: numTests, labels: labels, output: output)
				default:
					return fail.value.0
				}
			case let .Right(sta):
				if sta.value.numSuccessTests >= sta.value.maxSuccessTests {
					return doneTesting(sta.value)(f: f)
				}
				if sta.value.numDiscardedTests >= sta.value.maxDiscardedTests {
					return giveUp(sta.value)(f: f)
				}
				state = sta.value
		}
	}
}

// Executes a single test of the property given an initial state and the generator function.
//
// On success the next state is returned.  On failure the final result and state are returned.
internal func runATest(st : State)(f : (StdGen -> Int -> Prop)) -> Either<(Result, State), State> {
	let size = st.computeSize(st.numSuccessTests)(st.numDiscardedTests)
	let (rnd1, rnd2) = st.randomSeed.split()

	// Execute the Rose Tree for the test and reduce to .MkRose.
	switch reduce(f(rnd1)(size).unProp) {
		case .MkRose(let resC, let ts):
			let res = resC() // Force the result only once.
			dispatchAfterTestCallbacks(st, res) // Then invoke the post-test callbacks

			switch res.match() {
				// Success
				case .MatchResult(.Some(true), let expect, _, _, let labels, let stamp, _):
					let state = State(name: st.name
									, maxSuccessTests: st.maxSuccessTests
									, maxDiscardedTests: st.maxDiscardedTests
									, computeSize: st.computeSize
									, numSuccessTests: st.numSuccessTests + 1
									, numDiscardedTests: st.numDiscardedTests
									, labels: unionWith(max, st.labels, labels)
									, collected: [stamp] + st.collected
									, expectedFailure: expect
									, randomSeed: st.randomSeed
									, numSuccessShrinks: st.numSuccessShrinks
									, numTryShrinks: st.numTryShrinks
									, numTotTryShrinks: st.numTotTryShrinks)
					return .Right(Box(state))
				// Discard
				case .MatchResult(.None, let expect, _, _, let labels, _, _):
					let state = State(name: st.name
									, maxSuccessTests: st.maxSuccessTests
									, maxDiscardedTests: st.maxDiscardedTests
									, computeSize: st.computeSize
									, numSuccessTests: st.numSuccessTests
									, numDiscardedTests: st.numDiscardedTests + 1
									, labels: unionWith(max, st.labels, labels)
									, collected: st.collected
									, expectedFailure: expect
									, randomSeed: rnd2
									, numSuccessShrinks: st.numSuccessShrinks
									, numTryShrinks: st.numTryShrinks
									, numTotTryShrinks: st.numTotTryShrinks)
					return .Right(Box(state))
				// Fail
				case .MatchResult(.Some(false), let expect, _, _, _, _, _):
					if !expect {
						print("+++ OK, failed as expected. ")
					} else {
						print("*** Failed! ")
					}

					// Attempt a shrink.
					let (numShrinks, totFailed, lastFailed) = findMinimalFailingTestCase(st, res, ts())

					if !expect {
						let s = Result.Success(numTests: st.numSuccessTests + 1, labels: summary(st), output: "+++ OK, failed as expected. ")
						return .Left(Box((s, st)))
					}

					let stat = Result.Failure(numTests: st.numSuccessTests + 1
											, numShrinks: numShrinks
											, usedSeed: st.randomSeed
											, usedSize: st.computeSize(st.numSuccessTests)(st.numDiscardedTests)
											, reason: res.reason
											, labels: summary(st)
											, output: "*** Failed! ")

					let state = State(name: st.name
									, maxSuccessTests: st.maxSuccessTests
									, maxDiscardedTests: st.maxDiscardedTests
									, computeSize: st.computeSize
									, numSuccessTests: st.numSuccessTests
									, numDiscardedTests: st.numDiscardedTests + 1
									, labels: st.labels
									, collected: st.collected
									, expectedFailure: res.expect
									, randomSeed: rnd2
									, numSuccessShrinks: st.numSuccessShrinks
									, numTryShrinks: st.numTryShrinks
									, numTotTryShrinks: st.numTotTryShrinks)

					return .Left(Box((stat, state)))
			default:
				fatalError("Pattern Match Failed: switch on a Result was inexhaustive.")
				break
			}
		default:
			fatalError("Pattern Match Failed: Rose should have been reduced to MkRose, not IORose.")
			break
	}
}

internal func doneTesting(st : State)(f : (StdGen -> Int -> Prop)) -> Result {
	if st.expectedFailure {
		println("*** Passed " + "\(st.numSuccessTests)" + " tests")
		printDistributionGraph(st)
		return .Success(numTests: st.numSuccessTests, labels: summary(st), output: "")
	} else {
		printDistributionGraph(st)
		return .NoExpectedFailure(numTests: st.numSuccessTests, labels: summary(st), output: "")
	}
}

internal func giveUp(st: State)(f : (StdGen -> Int -> Prop)) -> Result {
	printDistributionGraph(st)
	return Result.GaveUp(numTests: st.numSuccessTests, labels: summary(st), output: "")
}

// Interface to shrinking loop.  Returns (number of shrinks performed, number of failed shrinks, 
// total number of shrinks performed).
//
// This ridiculously stateful looping nonsense is due to limitations of the Swift unroller and, more
// importantly, ARC.  This has been written with recursion in the past, and it was fabulous and
// beautiful, but it generated useless objects that ARC couldn't release on the order of Gigabytes
// for complex shrinks (much like `split` in the Swift STL), and was slow as hell.  This way we stay
// in one stack frame no matter what and give ARC a chance to cleanup after us.  Plus we get to
// stay within a reasonable ~50-100 megabytes for truly horrendous tests that used to eat 8 gigs.
internal func findMinimalFailingTestCase(st : State, res : TestResult, ts : [Rose<TestResult>]) -> (Int, Int, Int) {
	if let e = res.theException {
		fatalError("Test failed due to exception: \(e)")
	}

	var lastResult = res
	var branches = ts
	var numSuccessShrinks = st.numSuccessShrinks
	var numTryShrinks = st.numTryShrinks + 1
	var numTotTryShrinks = st.numTotTryShrinks

	// cont is a sanity check so we don't fall into an infinite loop.  It is set to false at each
	// new iteration and true when we select a new set of branches to test.  If the branch
	// selection doesn't change then we have exhausted our possibilities and so must have reached a
	// minimal case.
	var cont = true
	while cont {
		/// If we're out of branches we're out of options.
		if branches.isEmpty {
			break;
		}

		cont = false
		numTryShrinks = 0

		// Try all possible courses of action in this Rose Tree
		for r in branches {
			switch reduce(r) {
			case .MkRose(let resC, let ts1):
				let res1 = resC()
				dispatchAfterTestCallbacks(st, res1)

				// Did we fail?  Good!  Failure is healthy.  
				// Try the next set of branches.
				if res1.ok == .Some(false) {
					lastResult = res1
					branches = ts1()
					cont = true
					break;
				}

				// Otherwise increment the tried shrink counter and the failed shrink counter.
				numTryShrinks++
				numTotTryShrinks++
			default:
				fatalError("Rose should not have reduced to IO")
			}
		}

		numSuccessShrinks++
	}

	let state = State(name: st.name
					, maxSuccessTests: st.maxSuccessTests
					, maxDiscardedTests: st.maxDiscardedTests
					, computeSize: st.computeSize
					, numSuccessTests: st.numSuccessTests
					, numDiscardedTests: st.numDiscardedTests
					, labels: st.labels
					, collected: st.collected
					, expectedFailure: st.expectedFailure
					, randomSeed: st.randomSeed
					, numSuccessShrinks: numSuccessShrinks
					, numTryShrinks: numTryShrinks
					, numTotTryShrinks: numTotTryShrinks)
	return reportMinimumCaseFound(state, lastResult)
}

internal func reportMinimumCaseFound(st : State, res : TestResult) -> (Int, Int, Int) {
	let testMsg = " (after \(st.numSuccessTests + 1) test"
	let shrinkMsg = st.numSuccessShrinks > 1 ? (" and \(st.numSuccessShrinks) shrink") : ""
	
	func pluralize(s : String, i : Int) -> String {
		if i > 1 {
			return s + "s"
		}
		return s
	}
	
	println("Proposition: " + st.name)
	println(res.reason + pluralize(testMsg, st.numSuccessTests + 1) + pluralize(shrinkMsg, st.numSuccessShrinks) + "):")
	dispatchAfterFinalFailureCallbacks(st, res)
	return (st.numSuccessShrinks, st.numTotTryShrinks - st.numTryShrinks, st.numTryShrinks)
}

internal func dispatchAfterTestCallbacks(st : State, res : TestResult) {
	for c in res.callbacks {
		switch c {
		case let .AfterTest(_, f):
			f(st, res)
		default:
			continue
		}
	}
}

internal func dispatchAfterFinalFailureCallbacks(st : State, res : TestResult) {
	for c in res.callbacks {
		switch c {
		case let .AfterFinalFailure(_, f):
			f(st, res)
		default:
			continue
		}
	}
}

internal func summary(s : State) -> [(String, Int)] {
	let strings = s.collected.flatMap({ l in Array(l).map({ "," + $0.0 }).filter({ !$0.isEmpty }) })
	let l =  groupBy(sorted(strings), ==)
	return l.map({ ss in (ss[0], ss.count * 100 / s.numSuccessTests) })
}

internal func labelPercentage(l : String, st : State) -> Int {
	let occur = st.collected.flatMap({ Array($0) }).filter({ $0 == l }).count
	return (100 * occur) / st.maxSuccessTests
}

internal func printDistributionGraph(st : State) {
	func showP(n : Int) -> String {
		return (n < 10 ? " " : "") + "\(n)" + "% "
	}

	let gAllLabels = st.collected.map({ (s : Set<String>) in
		return Array(s).filter({ t in st.labels[t] == .Some(0) }).reduce("", combine: { (l : String, r : String) in l + ", " + r })
	})
	let gAll = groupBy(sorted(gAllLabels.filter({ !$0.isEmpty })), ==)
	let gPrint = gAll.map({ ss in showP((ss.count * 100) / st.numSuccessTests) + ss.first! })
	let allLabels = sorted(gPrint).reverse()

	var covers = [String]()
	for (l, reqP) in st.labels {
		let p = labelPercentage(l, st)
		if p < reqP {
			covers += ["only \(p)% " + l + ", not \(reqP)%"]
		}
	}

	let all = covers + allLabels
	if all.isEmpty {
		println(".")
	} else if all.count == 1, let pt = all.first {
		println("(\(pt))")
	} else {
		println(":")
		for pt in all {
			println(pt)
		}
	}

	let cs = allLabels
}

internal func cons<T>(lhs : T, var rhs : [T]) -> [T] {
	rhs.insert(lhs, atIndex: 0)
	return rhs
}

internal func span<A>(list : [A], p : (A -> Bool)) -> ([A], [A]) {
	if list.isEmpty {
		return ([], [])
	} else if let x = list.first {
		if p (x) {
			let (ys, zs) = span([A](list[1..<list.endIndex]), p)
			return (cons(x, ys), zs)
		}
		return ([], list)
	}
	fatalError("span reached a non-empty list that could not produce a first element")
}

internal func groupBy<A>(list : [A], p : (A , A) -> Bool) -> [[A]] {
	if list.isEmpty {
		return []
	} else if let x = list.first {
		let (ys, zs) = span([A](list[1..<list.endIndex]), { p(x, $0) })
		let l = cons(x, ys)
		return cons(l, groupBy(zs, p))
	}
	fatalError("groupBy reached a non-empty list that could not produce a first element")
}
