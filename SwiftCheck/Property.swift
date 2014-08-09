//
//  Property.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public typealias Property = Gen<Prop>

public protocol Testable {
	func property() -> Property
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

extension TestResult : Testable {
	public func property() -> Property {
		return Property.pure(Prop(unProp: protectResults(Rose<TestResult>.pure(self))))
	}

}

func result(ok: Maybe<Bool>) -> TestResult {
	return TestResult.MkResult(ok: ok, expect: true, reason: "", interrupted: false, stamp: [], callbacks: [])
}

public struct Prop {
	var unProp: Rose<TestResult>
}


public func protectResults(rs: Rose<TestResult>) -> Rose<TestResult> {
	return on({ (let x) in
		return { (let rs) in
			return Rose.IORose(protectResult(IO<TestResult>.pure(x)) >>= { (let y) in
				return IO<Rose<TestResult>>.pure(Rose.MkRose(y, rs.map(protectResults)))
			})
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
	return p.property().fmap(f)
}

public func mapSize<PROP : Testable> (f: Int -> Int)(p: PROP) -> Property {
	return sized({ (let n) in
		resize(f(n))(m: p.property())
	})
}

//public func shrinking<A, PROP : Testable> (shrinker: A -> [A])(x0: A)(pf: A -> PROP) -> Property {
//
//}

public func noShrinking<PROP : Testable>(p: PROP) -> Property {
	return mapRoseResult({ (let rs) in
		return on({ (let res) in
			return { (_) in
				return Rose.MkRose(res, [])
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

public func printTestCase<PROP : Testable>(s: String)(p: PROP) -> Property {
	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { (let st) in
		return { (_) in
			return IO<()>.pure(println(s))
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
//	return mapRoseResult(<#f: Rose<TestResult> -> Rose<TestResult>#>)
//}

public func forAll<A : Printable, PROP : Testable>(gen : Gen<A>)(pf : (A -> PROP)) -> Property {
	return gen >>= { (let x) in
		return printTestCase(x.description)(p: pf(x))
	}
}

infix operator ^&^ {}
infix operator ^&&^ {}

public func ^&^<PROP : Testable>(p1 : PROP, p2 : PROP) -> Property {
	return Bool.arbitrary() >>= { (let b) in
		printTestCase(b ? "LHS" : "RHS")(p: b ? p1 : p2)
	}
}

//infix public func ^&&^<PROP : Testable>(p1 : PROP, p2 : PROP) -> Property {
//	return conjoin [ p1.property(), p2.property() ]
//}
//





