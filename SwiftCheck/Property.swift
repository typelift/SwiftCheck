//
//  Property.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Swiftz

public func protectResults(rs: Rose<TestResult>) -> Rose<TestResult> {
	return onRose({ x in
		return { rs in
			let y = protectResult(x)
			return .MkRose(Box(y), rs.map(protectResults))
		}
	})(rs: rs)
}

public func exception(msg: String) -> Printable -> TestResult {
	return { e in failed() }
}

public func protectResult(res: TestResult) -> TestResult {
	return protect({ e in exception("Exception")(e) })(res)
}

private func tryEvaluateIO<A>(m : @autoclosure() -> A) -> Either<Printable, A> {
	return Either.right(m())
}

public func protect<A>(f : Printable -> A) -> A -> A {
	return { x in tryEvaluateIO(x).either(f, { identity($0)  }) }
}

public func succeeded() -> TestResult {
	return result(Optional.Some(true))
}

public func failed() -> TestResult {
	return result(Optional.Some(false))
}

public func rejected() -> TestResult {
	return result(Optional.None)
}

public func liftBool(b: Bool) -> TestResult {
	if b {
		return succeeded()
	}
	return failed()
}

public func mapResult(f: TestResult -> TestResult)(p: Testable) -> Property {
	return mapRoseResult({ rs in
		return protectResults(rs.fmap(f))
	})(p: p)
}

public func mapTotalResult(f: TestResult -> TestResult)(p: Testable) -> Property {
	return mapRoseResult({ rs in
		return rs.fmap(f)
	})(p: p)
}

public func mapRoseResult(f: Rose<TestResult> -> Rose<TestResult>)(p: Testable) -> Property {
	return mapProp({ t in
		return Prop(unProp: f(t.unProp))
	})(p: p)
}

public func mapProp(f: Prop -> Prop)(p: Testable) -> Property {
	return Property(p.property().unProperty.fmap(f))
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
	return Property(promote(props(shrinker)(x: x0)(pf: pf)).fmap({ (let rs : Rose<Prop>) in
		return Prop(unProp: joinRose(rs.fmap({ (let x : Prop) in
			return x.unProp
		})))
	}))
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
			return println(s)
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
			return println(s)
		}
	}))(p)
}

public func whenFail(m: () -> ())(p: Testable) -> Property {
	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { st in
		return { (_) in
			return m()
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
	case PostTest(kind: CallbackKind, f: State -> Result -> ())
	case PostFinalFailure(kind: CallbackKind, f: State -> Result -> ())
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

func result(ok: Bool?) -> TestResult {
	return .MkResult(ok: ok, expect: true, reason: "", interrupted: false, stamp: [], callbacks: [])
}
