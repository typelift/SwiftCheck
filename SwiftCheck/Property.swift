//
//  Property.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Basis

public protocol Testable {
	func property() -> Property
	var exhaustive : Bool { get }
}

public func unProperty(x : Property) -> Gen<Prop> {
	return x.unProperty
}

func result(ok: Bool?) -> TestResult {
	return .MkResult(ok: ok, expect: true, reason: "", interrupted: false, stamp: [], callbacks: [])
}

public func protectResults(rs: Rose<TestResult>) -> Rose<TestResult> {
	return onRose({ x in
		return { rs in
			let y = !protectResult(IO.pure(x))
			return .MkRose(Box(y), rs.map(protectResults))
		}
	})(rs: rs)
}

public func exception(msg: String) -> Exception -> TestResult {
	return { e in failed() }
}

public func protectResult(res: IO<TestResult>) -> IO<TestResult> {
	return protect({ e in exception("Exception")(e) })(res)
}

private func tryEvaluateIO<A>(m : IO<A>) -> IO<Either<Exception, A>> {
	return IO.fmap({ Either.right($0) })(m)
}

public func protect<A>(f : Exception -> A) -> IO<A> -> IO<A> {
	return { x in either(f)(id) <%> tryEvaluateIO(x) }
}

func succeeded() -> TestResult {
	return result(Optional.Some(true))
}

func failed() -> TestResult {
	return result(Optional.Some(false))
}

func rejected() -> TestResult {
	return result(Optional.None)
}


func liftBool(b: Bool) -> TestResult {
	if b {
		return succeeded()
	}
	return failed()
}

func mapResult(f: TestResult -> TestResult)(p: Testable) -> Property {
	return mapRoseResult({ rs in
		return protectResults(Rose.fmap(f)(rs))
	})(p: p)
}

func mapTotalResult(f: TestResult -> TestResult)(p: Testable) -> Property {
	return mapRoseResult({ rs in
		return Rose.fmap(f)(rs)
	})(p: p)
}

func mapRoseResult(f: Rose<TestResult> -> Rose<TestResult>)(p: Testable) -> Property {
	return mapProp({ t in
		return Prop(unProp: f(t.unProp))
	})(p: p)
}

func mapProp(f: Prop -> Prop)(p: Testable) -> Property {
	return Property(Gen.fmap(f)(p.property().unProperty))
}

public func mapSize (f: Int -> Int)(p: Testable) -> Property {
	return Property(sized({ n in
		return resize(f(n))(m: p.property().unProperty)
	}))
}

private func props<A>(shrinker: A -> [A])(x : A)(pf: A -> Testable) -> Rose<Gen<Prop>> {
	return .MkRose(Box(pf(x).property().unProperty), shrinker(x).map({ x1 in
		return props(shrinker)(x: x1)(pf: pf)
	}))
}

public func shrinking<A> (shrinker: A -> [A])(x0: A)(pf: A -> Testable) -> Property {
	return Property(Gen.fmap({ (let rs : Rose<Prop>) in
		return Prop(unProp: joinRose(Rose.fmap({ (let x : Prop) in
			return x.unProp
		})(rs)))
	})(promote(props(shrinker)(x: x0)(pf: pf))))
}

public func noShrinking(p: Testable) -> Property {
	return mapRoseResult({ rs in
		return onRose({ res in
			return { (_) in
				.MkRose(Box(res), [])
			}
		})(rs: rs)
	})(p: p)
}

public func callback(cb: Callback) -> Testable -> Property {
	return { p in 
		mapTotalResult({ (var res) in
			switch res {
				case .MkResult(let ok, let expect, let reason, let interrupted, let stamp, let callbacks):
					return .MkResult(ok: ok, expect: expect, reason: reason, interrupted: interrupted, stamp: stamp, callbacks: [cb] + callbacks)
			}
		})(p: p)
	}
}

public func counterexample(s : String)(p: Testable) -> Property {
	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { st in
		return { _ in
			return putStrLn(s)
		}
	}))(p)
}

//public func counterexample(s : String)(p: Testable) -> Testable {
//	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { st in
//		return { _res in
//			println(s)
//			return IO.pure(())
//		}
//	}))(p)
//}

public func printTestCase(s: String)(p: Testable) -> Property {
	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { st in
		return { _ in
			return putStrLn(s)
		}
	}))(p)
}

public func whenFail(m: IO<()>)(p: Testable) -> Property {
	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { st in
		return { (_) in
			return m
		}
	}))(p)
}

//public func verbose(p : Testable) -> Property {
//
//}

public func expectFailure(p : Testable) -> Property {
	return mapTotalResult({ res in
		switch res {
			case .MkResult(let ok, let expect, let reason, let interrupted, let stamp, let callbacks):
				return TestResult.MkResult(ok: ok, expect: false, reason: reason, interrupted: interrupted, stamp: stamp, callbacks: callbacks)
		}
	})(p: p)
}

public func once(p : Testable) -> Property {
	return mapTotalResult({ res in
		switch res {
			case .MkResult(let ok, let expect, let reason, let interrupted, let stamp, let callbacks):
				return TestResult.MkResult(ok: ok, expect: expect, reason: reason, interrupted: true, stamp: stamp, callbacks: callbacks)
		}
	})(p: p)
}

public func label(s: String)(p : Testable) -> Property {
	return classify(true)(s: s)(p: p)
}

public func collect<A : Printable>(x : A)(p : Testable) -> Property {
	return label(x.description)(p: p)
}

public func classify(b : Bool)(s : String)(p : Testable) -> Property {
	return cover(b)(n: 0)(s: s)(p:p)
}

public func cover(b : Bool)(n : Int)(s : String)(p : Testable) -> Property {
	if b {
		return mapTotalResult({ res in
			switch res {
				case .MkResult(let ok, let expect, let reason, let interrupted, let stamp, let callbacks):
					return TestResult.MkResult(ok: ok, expect: expect, reason: reason, interrupted: interrupted, stamp: [(s, n)] + stamp, callbacks: callbacks)
			}
		})(p:p)
	}
	return p.property()
}

infix operator ==> {}

public func ==>(b: Bool, p : Testable) -> Property {
	if b {
		return p.property()
	}
	return rejected().property()
}

//public func within(n : Int)(p : Testable) -> Property {
//	return mapRoseResult({ rose in
//		return ioRose(do_({
//			let rs = reduce(rose)
//
//		}))
//	})
//}


infix operator ^&^ {}
infix operator ^&&^ {}

public func ^&^(p1 : Testable, p2 : Testable) -> Property {
	return Property(Bool.arbitrary() >>- { b in
		return printTestCase(b ? "LHS" : "RHS")(p: b ? p1 : p2).unProperty
	})
}
//
//public func ^&&^(p1 : Testable, p2 : Testable) -> Property {
//	return conjoin([ p1.property(), p2.property() ])
//}
//
//private func conj<Testable : Testable, A>(ps: [TestResult], rs : [Rose<Prop>]) -> Rose<TestResult> {
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
//					case .Some(true):
//						return Rose.pure(conj(cbs +> result.callbacks))
//					case .Some(false):
//						return Rose.pure(rose)
//					case None:
//
//				}
//			}
//
//		}
//	}))
//}
//
//public func conjoin(ps : [Testable]) -> Property {
//	return Property(Gen<Prop>.pure(Prop(conj([])(mapM({ p in
//		return unProperty(p.property()).fmap { x in
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
	ok : Optional<Bool>,
	expect : Bool,
	reason : String,
	interrupted : Bool,
	stamp : [(String,Int)],
	callbacks : [Callback])
}

public struct Property : Testable {
	let unProperty : Gen<Prop>
	public var exhaustive : Bool { return false }

	public init(_ val: Gen<Prop>) {
		self.unProperty = val;
	}

	public func property() -> Property {
		return Property(self.unProperty)
	}
}


public struct Prop : Testable {
	var unProp: Rose<TestResult>
	public var exhaustive : Bool { return false }

	public func property() -> Property {
		return Property(Gen.pure(Prop(unProp: ioRose(IO.pure(self.unProp)))))
	}
}

extension TestResult : Testable {
	public var exhaustive : Bool { return false }

	public func property() -> Property {
		return Property(Gen.pure(Prop(unProp: protectResults(Rose.pure(self)))))
	}
}

extension Bool : Testable {
	public var exhaustive : Bool { return false }

	public func property() -> Property {
		return liftBool(self).property()
	}
}
