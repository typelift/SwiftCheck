//
//  Test.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Basis

public struct Arguments {
	let replay : Optional<(StdGen, Int)>
	let maxSuccess : Int
	let maxDiscard : Int
	let maxSize : Int
	let chatty : Bool
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
	return Arguments(replay: .None, maxSuccess: 100, maxDiscard: 500, maxSize: 100, chatty: true)
}

public func forAll<A : Arbitrary>(gen : Gen<A>, pf : (A -> Testable)) -> Property {
	return forAllShrink(gen, { A.shrink($0) }, pf)
}

public func forAll<A : Arbitrary, B : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(pf : (A, B) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB, { b in pf(t, b) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(pf : (A, B, C) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)({ b, c in pf(t, b, c) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(pf : (A, B, C, D) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)({ b, c, d in pf(t, b, c, d) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(pf : (A, B, C, D, E) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)({ b, c, d, e in pf(t, b, c, d, e) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(genF : Gen<F>)(pf : (A, B, C, D, E, F) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)(genE: genF)({ b, c, d, e, f in pf(t, b, c, d, e, f) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(genF : Gen<F>)(genG : Gen<G>)(pf : (A, B, C, D, E, F, G) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)(genE: genF)(genF : genG)({ b, c, d, e, f, g in pf(t, b, c, d, e, f, g) }) })
}

public func forAll<A : Arbitrary, B : Arbitrary, C : Arbitrary, D : Arbitrary, E : Arbitrary, F : Arbitrary, G : Arbitrary, H : Arbitrary>(genA : Gen<A>)(genB : Gen<B>)(genC : Gen<C>)(genD : Gen<D>)(genE : Gen<E>)(genF : Gen<F>)(genG : Gen<G>)(genH : Gen<H>)(pf : (A, B, C, D, E, F, G, H) -> Testable) -> Property {
	return forAll(genA, { t in forAll(genB)(genB: genC)(genC: genD)(genD: genE)(genE: genF)(genF : genG)(genG : genH)({ b, c, d, e, f, g, h in pf(t, b, c, d, e, f, g, h) }) })
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

//public func forAll<A : Printable>(pf : (A -> Testable)) -> Property {
//	return Property(gen >>- { x in
//		return printTestCase(x.description)(p: pf(x)).unProperty
//	})
//}

//public func forAllShrink<A : Arbitrary>(gen : Gen<A>)(shrinker: A -> [A])(f : A -> Testable) -> Property {
//	return Property(gen >>- { (let x : A) in
//		return unProperty(shrinking(shrinker)(x0: x)({ (let xs : A) -> Testable  in
//			return counterexample(xs.description)(p: f(xs))
//		}))
//	})
//}

public func forAllShrink<A : Arbitrary>(gen : Gen<A>, shrinker: A -> [A], f : A -> Testable) -> Property {
	return Property(gen >>- { (let x : A) in
		return unProperty(shrinking(shrinker)(x0: x)({ (let xs : A) -> Testable  in
			return counterexample(xs.description)(p: f(xs))
		}))
	})
}

public func quickCheck(prop : Testable) -> IO<()> {
	return quickCheckWithResult(stdArgs(), prop) >> IO.pure(())
}

public func quickCheckWithResult(args : Arguments, p : Testable) -> IO<Result> {
	func roundTo(n : Int)(m : Int) -> Int {
		return (m / m) * m
	}

	func rnd() -> IO<StdGen> {
		switch args.replay {
			case Optional.None:
				return newStdGen()
			case Optional.Some(let (rnd, _)):
				return IO<StdGen>.pure(rnd)
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
	
	
	let state = State(terminal:				Terminal()
					, maxSuccessTests:		args.maxSuccess
					, maxDiscardedTests:	args.maxDiscard
					, computeSize:			computeSize
					, numSuccessTests:		0
					, numDiscardedTests:	0
					, collected:			[]
					, expectedFailure:		false
					, randomSeed:			!rnd()
					, numSuccessShrinks:	0
					, numTryShrinks:		0)
	return test(state)(p.exhaustive ? once(p.property()).unProperty.unGen : p.property().unProperty.unGen)
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
	let rose : Rose<TestResult> = !protectRose(reduce(f(rnd1)(size).unProp))
	
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

public func summary(s: State) -> [(String, Int)] { 
	return map({ ss in (head(ss), ss.count * 100 / s.numSuccessTests) }) • group • sort <| [ ]
}


