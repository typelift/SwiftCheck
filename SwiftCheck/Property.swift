//
//  Property.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public protocol Testable {
	func property() -> Property
}

public func unProperty(x : Property) -> Gen<Prop> {
	return x.unProperty
}

func result(ok: Maybe<Bool>) -> TestResult {
	return TestResult.MkResult(ok: ok, expect: true, reason: "", interrupted: false, stamp: [], callbacks: [])
}

public func protectResults(rs: Rose<TestResult>) -> Rose<TestResult> {
	return onRose({ (let x) in
		return { (let rs) in
			let y = protectResult(IO.pure(x)).unsafePerformIO()
			return Rose.MkRose(Box(y), rs.map(protectResults))
		}
	})(rs: rs)
}

public func exception(msg: String) -> TestResult {
	return failed()
}

public func protectResult(res: IO<TestResult>) -> IO<TestResult> {
	return protect(res)
}

public func protect<A>(x: IO<A>) -> IO<A> {
	return x
}

func succeeded() -> TestResult {
	return result(Maybe.Just(true))
}

func failed() -> TestResult {
	return result(Maybe.Just(false))
}

func rejected() -> TestResult {
	return result(Maybe.Nothing)
}


func liftBool(b: Bool) -> TestResult {
	if b {
		return succeeded()
	}
	return failed()
}

func mapResult<PROP : Testable>(f: TestResult -> TestResult)(p: PROP) -> Property {
	return mapRoseResult({ (let rs) in
		return protectResults(rs.fmap(f))
	})(p: p)
}

func mapTotalResult<PROP : Testable>(f: TestResult -> TestResult)(p: PROP) -> Property {
	return mapRoseResult({ (let rs) in
		return rs.fmap(f)
	})(p: p)
}

func mapRoseResult<PROP : Testable>(f: Rose<TestResult> -> Rose<TestResult>)(p: PROP) -> Property {
	return mapProp({ (let t) in
		return Prop(unProp: f(t.unProp))
	})(p: p)
}

func mapProp<PROP : Testable>(f: Prop -> Prop)(p: PROP) -> Property {
	return Property(p.property().unProperty.fmap(f))
}

public func mapSize<PROP : Testable> (f: Int -> Int)(p: PROP) -> Property {
	return Property(sized({ (let n) in
		return resize(f(n))(m: p.property().unProperty)
	}))
}

private func props<A, PROP : Testable>(shrinker: A -> [A])(x : A)(pf: A -> PROP) -> Rose<Gen<Prop>> {
	return Rose.MkRose(Box(pf(x).property().unProperty), shrinker(x).map({ (let x1) in
		return props(shrinker)(x: x)(pf: pf)
	}))
}

public func shrinking<A, PROP : Testable> (shrinker: A -> [A])(x0: A)(pf: A -> PROP) -> Property {
	return Property(promote(props(shrinker)(x: x0)(pf: pf)).fmap({ (let rs) in
		return Prop(unProp: join(rs.fmap({ (let x) in
			return x.unProp
		})))
	}))
}

public func noShrinking<PROP : Testable>(p: PROP) -> Property {
	return mapRoseResult({ (let rs) in
		return onRose({ (let res) in
			return { (_) in
				return Rose.MkRose(Box(res), [])
			}
		})(rs: rs)
	})(p: p)
}

public func callback<PROP : Testable>(cb: Callback)(p: PROP) -> Property {
	return mapTotalResult({ (var res) in
		switch res {
			case .MkResult(let ok, let expect, let reason, let interrupted, let stamp, let callbacks):
				return TestResult.MkResult(ok: ok, expect: expect, reason: reason, interrupted: interrupted, stamp: stamp, callbacks: cb +> callbacks)
		}
	})(p: p)
}

public func counterexample<PROP : Testable>(s : String)(p: PROP) -> Property {
	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { (let st) in
		return { (let _res) in
			println(s)
			return IO.pure(())
		}
	}))(p: p)
}

public func counterexample<PROP : Testable>(s : String)(p: PROP) -> Testable {
	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { (let st) in
		return { (let _res) in
			println(s)
			return IO.pure(())
		}
	}))(p: p)
}

public func printTestCase<PROP : Testable>(s: String)(p: PROP) -> Property {
	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { (let st) in
		return { (_) in
			return IO.pure(println(s))
		}
	}))(p: p)
}

public func whenFail<PROP : Testable>(m: IO<()>)(p: PROP) -> Property {
	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { (let st) in
		return { (_) in
			return m
		}
	}))(p: p)
}

//public func verbose<PROP : Testable>(p : PROP) -> Property {
//
//}

public func expectFailure<PROP : Testable>(p : PROP) -> Property {
	return mapTotalResult({ (let res) in
		switch res {
			case .MkResult(let ok, let expect, let reason, let interrupted, let stamp, let callbacks):
				return TestResult.MkResult(ok: ok, expect: false, reason: reason, interrupted: interrupted, stamp: stamp, callbacks: callbacks)
		}
	})(p: p)
}

public func label<PROP : Testable>(s: String)(p : PROP) -> Property {
	return classify(true)(s: s)(p: p)
}

public func collect<A : Printable, PROP : Testable>(x : A)(p : PROP) -> Property {
	return label(x.description)(p: p)
}

public func classify<PROP : Testable>(b : Bool)(s : String)(p : PROP) -> Property {
	return cover(b)(n: 0)(s: s)(p:p)
}

public func cover<PROP : Testable>(b : Bool)(n : Int)(s : String)(p : PROP) -> Property {
	if b {
		return mapTotalResult({ (let res) in
			switch res {
				case .MkResult(let ok, let expect, let reason, let interrupted, let stamp, let callbacks):
					return TestResult.MkResult(ok: ok, expect: false, reason: reason, interrupted: interrupted, stamp: (s, n) +> stamp, callbacks: callbacks)
			}
		})(p:p)
	}
	return p.property()
}

infix operator ==> {}

public func ==><PROP : Testable>(b: Bool, p : PROP) -> Property {
	if b {
		return p.property()
	}
	return rejected().property()
}

//public func within<PROP : Testable>(n : Int)(p : PROP) -> Property {
//	return mapRoseResult({ (let rose) in
//		return ioRose(do_({
//			let rs = reduce(rose)
//			
//		}))
//	})
//}

public func forAll<A : Printable, PROP : Testable>(gen : Gen<A>)(pf : (A -> PROP)) -> Property {
	return Property(gen >>= { (let x) in
		return printTestCase(x.description)(p: pf(x)).unProperty
	})
}

public func forAllShrink<A : Printable, PROP : Testable>(gen : Gen<A>)(shrinker: A -> [A])(f : A -> PROP) -> Property {
	return Property(gen.bindWitness({ (let x : A) -> WitnessTestableGen in
		return WitnessTestableGen(unProperty(shrinking(shrinker)(x0: x)({ (let xs : A) -> Testable in
			return unsafeCoerce(counterexample(xs.description)(p: f(xs)))
		})))
	}))
}

infix operator ^&^ {}
infix operator ^&&^ {}

//public func ^&^<PROP : Testable>(p1 : PROP, p2 : PROP) -> Property {
//	return Property(true.arbitrary() >>= { (let b) in
//		return printTestCase(b ? "LHS" : "RHS")(p: b ? p1 : p2).unProperty
//	})
//}
//
//public func ^&&^<PROP : Testable>(p1 : PROP, p2 : PROP) -> Property {
//	return conjoin([ p1.property(), p2.property() ])
//}
//
//private func conj<PROP : Testable, A>(ps: [TestResult], rs : [Rose<Prop>]) -> Rose<TestResult> {
//	if rs.count == 0 {
//		return Rose.MkRose(Box(succeeded()), [])
//	}
//	return Rose.IORose(do_({
//		let rose = reduce(rs[0])
//		switch rose {
//			case .MkRose(let result, _): {
////				if !result.expect {
////					return (return failed { reason = "expectFailure may not occur inside a conjunction" })
////				}
//				switch result.ok {
//					case .Just(true):
//						return Rose.pure(conj(cbs +> result.callbacks))
//					case .Just(false):
//						return Rose.pure(rose)
//					case Nothing:
//
//				}
//			}
//
//		}
//	}))
//}
//
//public func conjoin<PROP : Testable>(ps : [PROP]) -> Property {
//	return Property(Gen<Prop>.pure(Prop(conj([])(mapM({ (let p) in
//		return unProperty(p.property()).fmap { (let x) in
//			return x.unProp
//		}
//	}, ps)))))
//}

infix operator === {}

public func ===<A where A : Equatable, A : Printable>(x : A, y : A) -> Property {
	return counterexample(x.description + "/=" + y.description)(p: x == y)
}

public enum Callback {
	case PostTest(kind: CallbackKind, f: State -> Result -> IO<()>)
	case PostFinalFailure(kind: CallbackKind, f: State -> Result -> IO<()>)
}

public enum CallbackKind {
	case Counterexample
	case NotCounterexample
}

public enum TestResult {
	case MkResult(
	ok : Maybe<Bool>,
	expect : Bool,
	reason : String,
	interrupted : Bool,
	stamp : [(String,Int)],
	callbacks : [Callback])
}

public struct Property {
	let unProperty : Gen<Prop>

	public init(_ val: Gen<Prop>) {
		self.unProperty = val;
	}

	public init(_ val: WitnessTestableGen) {
		self.unProperty = mkGen(val);
	}

}


public struct Prop {
	var unProp: Rose<TestResult>
}

extension Property : Testable {
	public func property() -> Property {
		return Property(self.unProperty)
	}
}

extension Prop : Testable {
	public func property() -> Property {
		return Property(Gen.pure(Prop(unProp: ioRose(IO.pure(self.unProp)))))
	}
}

extension TestResult : Testable {
	public func property() -> Property {
		return Property(Gen.pure(Prop(unProp: protectResults(Rose.pure(self)))))
	}
}

extension Bool : Testable {
	public func property() -> Property {
		return liftBool(self).property()
	}
}



