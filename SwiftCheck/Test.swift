//
//  Test.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

internal class Box<T> {
	let value : T
	internal init(_ x : T) { self.value = x }
}

internal enum Either<L, R> {
	case Left(Box<L>)
	case Right(Box<R>)
}

public struct Arguments {
	let name : String
	let replay : Optional<(StdGen, Int)>
	let maxSuccess : Int
	let maxDiscard : Int
	let maxSize : Int
	let chatty : Bool
}

public enum Result {
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

public func isSuccess(r: Result) -> Bool {
	switch r {
		case .Success:
			return true
		default:
			return false
	}
}

public func stdArgs(name : String = "") -> Arguments{
	return Arguments(name: name, replay: .None, maxSuccess: 100, maxDiscard: 500, maxSize: 100, chatty: true)
}

public func forAll<A : Arbitrary>(gen : Gen<A>, pf : (A -> Testable)) -> Property {
	return forAllShrink(gen, { A.shrink($0) }, pf)
}

public func forAll<A : Arbitrary, B : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(pf : (A, B) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB, { b in pf(t, b) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(pf : (A, B, C) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(pf: { b, c in pf(t, b, c) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(pf : (A, B, C, D) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(pf: { b, c, d in pf(t, b, c, d) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(pf : (A, B, C, D, E) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)(pf: { b, c, d, e in pf(t, b, c, d, e) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(genF : Gen<F>)(pf : (A, B, C, D, E, F) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)(genE: genF)(pf: { b, c, d, e, f in pf(t, b, c, d, e, f) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(genF : Gen<F>)(genG : Gen<G>)(pf : (A, B, C, D, E, F, G) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)(genE: genF)(genF : genG)(pf: { b, c, d, e, f, g in pf(t, b, c, d, e, f, g) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary, H : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(genF : Gen<F>)(genG : Gen<G>)(genH : Gen<H>)(pf : (A, B, C, D, E, F, G, H) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)(genE: genF)(genF : genG)(genG : genH)(pf: { b, c, d, e, f, g, h in pf(t, b, c, d, e, f, g, h) }) })
}

public func forAll<A : Arbitrary>(pf : (A -> Testable)) -> Property {
	return forAllShrink(A.arbitrary(), { A.shrink($0) }, pf)
}

public func forAll<A : Arbitrary, B : Arbitrary>(pf : (A, B) -> Testable) -> Property {
	return forAll({ t in forAll({ b in pf(t, b) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary>(pf : (A, B, C) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c in pf(t, b, c) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary>(pf : (A, B, C, D) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d in pf(t, b, c, d) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary>(pf : (A, B, C, D, E) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e in pf(t, b, c, d, e) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary>(pf : (A, B, C, D, E, F) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f in pf(t, b, c, d, e, f) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary>(pf : (A, B, C, D, E, F, G) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f, g in pf(t, b, c, d, e, f, g) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary, H : Arbitrary>(pf : (A, B, C, D, E, F, G, H) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f, g, h in pf(t, b, c, d, e, f, g, h) }) })
}

//public func forAll<A : Arbitrary>(pf : ([A] -> Testable)) -> Property {
//	return forAllShrink(arbitraryArray(), shrinkList({ A.shrink($0) }), pf)
//}
//
//public func forAll<A : Arbitrary, B : Arbitrary>(pf : ([A], [B]) -> Testable) -> Property {
//	return forAll({ t in forAll({ b in pf(t, b) }) })
//}
//
//public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary>(pf : ([A], [B], [C]) -> Testable) -> Property {
//	return forAll({ t in forAll({ b, c in pf(t, b, c) }) })
//}

public func forAllShrink<A : Arbitrary>(gen : Gen<A>, shrinker: A -> [A], f : A -> Testable) -> Property {
	return Property(gen.bind { x in
		return shrinking(shrinker)(x0: x)(pf: { xs  in
			return counterexample("\(xs)")(p: f(xs))
		}).unProperty
	})
}

public func quickCheck(prop : Testable, name : String = "") {
	quickCheckWithResult(stdArgs(name: name), prop)
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
					, collected:			[]
					, expectedFailure:		false
					, randomSeed:			rnd()
					, numSuccessShrinks:	0
					, numTryShrinks:		0
					, numTotTryShrinks:		0)
	return test(state, p.exhaustive ? once(p.property()).unProperty.unGen : p.property().unProperty.unGen)
}

internal func test(st: State, f: (StdGen -> Int -> Prop)) -> Result {
	var state = st
	while true {
		switch runATest(state)(f: f) {
			case let .Left(fail):
				return fail.value
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

internal func doneTesting(st : State)(f : (StdGen -> Int -> Prop)) -> Result {
	if st.expectedFailure {
		println("*** Passed " + "\(st.numSuccessTests)" + " tests")
		return Result.Success(numTests: st.numSuccessTests, labels: summary(st), output: "")
	} else {
		println("*** Failed! ")
		println("*** Passed " + "\(st.numSuccessTests)" + " tests")
		return Result.NoExpectedFailure(numTests: st.numSuccessTests, labels: summary(st), output: "")
	}
}

internal func giveUp(st: State)(f : (StdGen -> Int -> Prop)) -> Result {
	return Result.GaveUp(numTests: st.numSuccessTests, labels: summary(st), output: "")
}

internal func runATest(st : State)(f : (StdGen -> Int -> Prop)) -> Either<Result, State> {
	let size = st.computeSize(st.numSuccessTests)(st.numDiscardedTests)
	let (rnd1,rnd2) = st.randomSeed.split()
	let rose : Rose<TestResult> = reduce(f(rnd1)(size).unProp)

	switch rose {
		case .MkRose(let res, let ts):
			switch res().match() {
				case .MkResult(.Some(true), let expect, _, _, _, let stamp, _):
					var st2 = st
					st2.numSuccessTests += 1
					st2.randomSeed = rnd2
					st2.collected = [stamp] + st.collected
					st2.expectedFailure = expect
					return .Right(Box(st2))
				case .MkResult(.None, let expect, _, _, _, _, _):
					var st2 = st
					st2.numDiscardedTests += 1
					st2.randomSeed = rnd2
					st2.expectedFailure = expect
					return .Right(Box(st2))
				case .MkResult(.Some(false), let expect, _, _, _, _, _):
					if !expect {
						print("+++ OK, failed as expected. ")
						let s = Result.Success(numTests: st.numSuccessTests + 1, labels: summary(st), output: "+++ OK, failed as expected. ")
						return .Left(Box(s))
					}
					print("*** Failed! ")
					let (numShrinks, totFailed, lastFailed) = foundFailure(st, res(), ts())
					let s = Result.Failure(numTests: st.numSuccessTests + 1, 
						numShrinks: numShrinks, 
						usedSeed: st.randomSeed, 
						usedSize: st.computeSize(st.numSuccessTests)(st.numDiscardedTests), 
						reason: res().reason, 
						labels: summary(st), 
						output: "*** Failed! ")
					return .Left(Box(s))
			default:
				fatalError("Pattern Match Failed: switch on a Result was inexhaustive.")
				break
			}
		default:
			fatalError("Pattern Match Failed: Rose should have been reduced to MkRose, not IORose.")
			break
	}
}

internal func foundFailure(st : State, res : TestResult, ts : [Rose<TestResult>]) -> (Int, Int, Int) {
	var st2 = st
	st2.numTryShrinks = 0
	return localMin(st2, res, res, ts)
}

internal func localMin(st : State, res : TestResult, res2 : TestResult, ts : [Rose<TestResult>]) -> (Int, Int, Int) {
	if let e = res2.theException {
		fatalError("Test failed due to exception: \(e)")
	}
	return localMinimum(st, res, ts)
}

internal func callbackPostTest(st : State, res : TestResult) {
	let _ : [()] = res.callbacks.map({ c in
		switch c {
			case let .PostTest(_, f):
				f(st)(res)
				return ()
			default:
				return ()
		}
	})
}

internal func callbackPostFinalFailure(st : State, res : TestResult) {
	let _ : [()] = res.callbacks.map({ c in
		switch c {
		case let .PostFinalFailure(_, f):
			f(st)(res)
			return ()
		default:
			return ()
		}
	})
}

internal func localMinimum(st : State, res : TestResult, ts : [Rose<TestResult>]) -> (Int, Int, Int) {
	if ts.isEmpty {
		return localMinFound(st, res)
	}
	let rose = reduce(ts[0])
	switch rose {
	case .IORose(_):
		fatalError("Rose should not have reduced to IO")
	case .MkRose(let res1, let ts1):
		callbackPostTest(st, res1())
		if res1().ok == .Some(false) {
			var sta = st
			sta.numSuccessTests = st.numSuccessTests + 1
			sta.numTryShrinks = 0
			return localMin(sta, res1(), res, ts1())
		} else {
			var sta = st
			sta.numSuccessTests = st.numSuccessTests + 1
			sta.numTotTryShrinks = st.numTotTryShrinks + 1
			return localMin(sta, res, res, Array(ts[1..<ts.count]))
		}
	}
}

internal func localMinFound(st : State, res : TestResult) -> (Int, Int, Int) {
	let testMsg = " (after \(st.numSuccessTests + 1) test"
	let shrinkMsg = st.numSuccessShrinks > 1 ? ("and \(st.numSuccessShrinks) shrink") : ""
	
	func pluralize(s : String, i : Int) -> String {
		if i > 1 {
			return s + "s"
		}
		return s
	}
	
	println("Proposition: " + st.name)
	println(res.reason + pluralize(testMsg, st.numSuccessTests) + pluralize(shrinkMsg, st.numSuccessShrinks) + "):")
	callbackPostFinalFailure(st, res)
	return (st.numSuccessShrinks, st.numTotTryShrinks - st.numTryShrinks, st.numTryShrinks)
}
	
internal func summary(s : State) -> [(String, Int)] {
	let strings = s.collected.map({ l in l.map({ "," + $0.0 }).filter({ !$0.isEmpty }) }).reduce([], combine: +)
	let l =  groupBy(sorted(strings), ==)
	return l.map({ ss in (ss[0], ss.count * 100 / s.numSuccessTests) })
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
			let (ys, zs) = span([A](list[1...list.endIndex]), p)
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
		let (ys, zs) = span([A](list[1...list.endIndex]), { p(x, $0) })
		let l = cons(x, ys)
		return cons(l, groupBy(zs, p))
	}
	fatalError("groupBy reached a non-empty list that could not produce a first element")
}
