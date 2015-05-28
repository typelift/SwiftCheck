//
//  Property.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

infix operator • {
	precedence 190
	associativity right
}

public func conjoin(ps : [Testable]) -> Property {
	return Property(sequence(ps.map({ (p : Testable) in
		return p.property().unProperty.fmap({ $0.unProp })
	})).bind({ roses in
		return Gen.pure(Prop(unProp: conj(id, roses)))
	}))
}

public func disjoin(ps : [Testable]) -> Property {
	return Property(sequence(ps.map({ (p : Testable) in
		return p.property().unProperty.fmap({ $0.unProp })
	})).bind({ roses in
		return Gen.pure(Prop(unProp: roses.reduce(.MkRose({ failed() }, { [] }), combine: disj)))
	}))
}

public func protectResults(rs : Rose<TestResult>) -> Rose<TestResult> {
	return onRose({ x in
		return { rs in
			return .MkRose({ x }, { rs.map(protectResults) })
		}
	})(rs: rs)
}

public func exception(msg : String) -> Printable -> TestResult {
	return { e in failed() }
}

public func succeeded() -> TestResult {
	return result(Optional.Some(true))
}

public func failed(reason : String = "") -> TestResult {
	return result(Optional.Some(false), reason: reason)
}

public func rejected() -> TestResult {
	return result(Optional.None)
}

public func liftBool(b : Bool) -> TestResult {
	if b {
		return succeeded()
	}
	return result(Optional.Some(false), reason: "Falsifiable")
}

public func mapResult(f : TestResult -> TestResult)(p: Testable) -> Property {
	return mapRoseResult({ rs in
		return protectResults(rs.fmap(f))
	})(p: p)
}

public func mapTotalResult(f : TestResult -> TestResult)(p : Testable) -> Property {
	return mapRoseResult({ rs in
		return rs.fmap(f)
	})(p: p)
}

public func mapRoseResult(f : Rose<TestResult> -> Rose<TestResult>)(p : Testable) -> Property {
	return mapProp({ t in
		return Prop(unProp: f(t.unProp))
	})(p: p)
}

public func mapProp(f : Prop -> Prop)(p : Testable) -> Property {
	return Property(p.property().unProperty.fmap(f))
}

public func mapSize(f : Int -> Int)(p : Testable) -> Property {
	return Property(sized({ n in
		return p.property().unProperty.resize(f(n))
	}))
}

private func props<A>(shrinker : A -> [A], #original : A, #pf: A -> Testable) -> Rose<Gen<Prop>> {
	return .MkRose({ pf(original).property().unProperty }, { shrinker(original).map { x1 in
		return props(shrinker, original: x1, pf: pf)
	}})
}

public func shrinking<A> (shrinker : A -> [A])(x0 : A)(pf : A -> Testable) -> Property {
	return Property(promote(props(shrinker, original: x0, pf: pf)).fmap { (let rs : Rose<Prop>) in
		return Prop(unProp: joinRose(rs.fmap { (let x : Prop) in
			return x.unProp
		}))
	})
}

public func noShrinking(p : Testable) -> Property {
	return mapRoseResult({ rs in
		return onRose({ res in
			return { (_) in
				return .MkRose({ res }, { [] })
			}
		})(rs: rs)
	})(p: p)
}

public func callback(cb : Callback) -> Testable -> Property {
	return { p in 
		mapTotalResult({ (var res) in
			return TestResult(ok: res.ok,
				expect: res.expect,
				reason: res.reason,
				theException: res.theException,
				interrupted: res.interrupted,
				labels: res.labels,
				stamp: res.stamp,
				callbacks: [cb] + res.callbacks)
		})(p: p)
	}
}

public func counterexample(s : String)(p : Testable) -> Property {
	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { st in
		return { _ in
			return println(s)
		}
	}))(p)
}

public func printTestCase(s : String)(p : Testable) -> Property {
	return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { st in
		return { _ in
			return println(s)
		}
	}))(p)
}

public func whenFail(m : () -> ())(p : Testable) -> Property {
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
		return TestResult(ok: res.ok,
			expect: false,
			reason: res.reason,
			theException: res.theException,
			interrupted: res.interrupted,
			labels: res.labels,
			stamp: res.stamp,
			callbacks: res.callbacks)
	})(p: p)
}

public func once(p : Testable) -> Property {
	return mapTotalResult({ res in
		return TestResult(ok: res.ok,
			expect: res.expect,
			reason: res.reason,
			theException: res.theException,
			interrupted: true,
			labels: res.labels,
			stamp: res.stamp,
			callbacks: res.callbacks)
	})(p: p)
}

public func label(s : String)(p : Testable) -> Property {
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
			return TestResult(ok: res.ok,
				expect: res.expect,
				reason: res.reason,
				theException: res.theException,
				interrupted: res.interrupted,
				labels: insertWith(max, s, n, res.labels),
				stamp: res.stamp.union([s]),
				callbacks: res.callbacks)
		})(p: p)
	}
	return p.property()
}

private func id<A>(x : A) -> A {
	return x
}

private func • <A, B, C>(f : B -> C, g : A -> B) -> A -> C {
	return { f(g($0)) }
}

internal func insertWith<K : Hashable, V>(f : (V, V) -> V, k : K, v : V, var m : Dictionary<K, V>) -> Dictionary<K, V> {
	let oldV = m[k]
	if let existV = oldV {
		m[k] = f(existV, v)
	} else {
		m[k] = v
	}
	return m
}

internal func unionWith<K : Hashable, V>(f : (V, V) -> V, l : Dictionary<K, V>, r : Dictionary<K, V>) -> Dictionary<K, V> {
	var map = l
	for (k, v) in l {
		map.updateValue(v, forKey: k)
	}
	for (k, v) in r {
		map.updateValue(v, forKey: k)
	}
	return map
}

private func addCallbacks(result : TestResult) -> TestResult -> TestResult {
	return { res in
		return TestResult(ok: res.ok,
			expect: res.expect,
			reason: res.reason,
			theException: res.theException,
			interrupted: res.interrupted,
			labels: res.labels,
			stamp: res.stamp,
			callbacks: result.callbacks + res.callbacks)
	}
}

private func addLabels(result : TestResult) -> TestResult -> TestResult {
	return { res in
		return TestResult(ok: res.ok,
			expect: res.expect,
			reason: res.reason,
			theException: res.theException,
			interrupted: res.interrupted,
			labels: unionWith(max, res.labels, result.labels),
			stamp: res.stamp.union(result.stamp),
			callbacks: res.callbacks)
	}
}

private func conj(k : TestResult -> TestResult, xs : [Rose<TestResult>]) -> Rose<TestResult> {
	if xs.isEmpty {
		return Rose.MkRose({ k(succeeded()) }, { [] })
	} else if let p = xs.first {
		return Rose.IORose({
			let rose = reduce(p)
			switch rose {
			case .MkRose(let result, _):
				if !result().expect {
					return Rose.pure(failed(reason: "expectFailure may not occur inside a conjunction"))
				}

				switch result().ok {
				case .Some(true):
					return conj(addLabels(result()) • addCallbacks(result()) • k, [Rose<TestResult>](xs[1..<xs.endIndex]))
				case .Some(false):
					return rose
				case .None:
					let rose2 = reduce(conj(addCallbacks(result()) • k, [Rose<TestResult>](xs[1..<xs.endIndex])))
					switch rose2 {
					case .MkRose(let result2, _):
						switch result2().ok {
						case .Some(true):
							return Rose.MkRose({ rejected() }, { [] })
						case .Some(false):
							return rose2
						case .None:
							return rose2
						default:
							fatalError("Non-exhaustive switch performed")
						}
					default:
						fatalError("Rose should not have reduced to IORose")
					}
				default:
					fatalError("Non-exhaustive switch performed")
				}
			default:
				fatalError("Rose should not have reduced to IORose")
			}
		})
	}
	fatalError("Non-exhaustive if-else statement reached")
}

private func disj(p : Rose<TestResult>, q : Rose<TestResult>) -> Rose<TestResult> {
	func sep(l : String, r : String) -> String {
		if l.isEmpty {
			return r
		}

		if r.isEmpty {
			return l
		}
		return l + ", " + r
	}

	func mplus(l : Optional<String>, r : Optional<String>) -> Optional<String> {
		if let ls = l, rs = r {
			return .Some(ls + rs)
		}

		if l == nil {
			return r
		}

		return l
	}

	return p.bind({ result1 in
		if !result1.expect {
			return Rose.pure(failed(reason: "expectFailure may not occur inside a disjunction"))
		}
		switch result1.ok {
		case .Some(true):
			return Rose.pure(result1)
		case .Some(false):
			return q.bind({ result2 in
				if !result2.expect {
					return Rose.pure(failed(reason: "expectFailure may not occur inside a disjunction"))
				}
				switch result2.ok {
				case .Some(true):
					return Rose.pure(result2)
				case .Some(false):
					return Rose.pure(TestResult(ok: .Some(false),
						expect: true,
						reason: sep(result1.reason, result2.reason),
						theException: mplus(result1.theException, result2.theException),
						interrupted: false,
						labels: [:],
						stamp: Set(),
						callbacks: result1.callbacks + [Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { st_res in
							return { _ in
								return println("")
							}
						})] + result2.callbacks))
				case .None:
					return Rose.pure(result2)
				default:
					fatalError("Non-exhaustive if-else statement reached")
				}
			})
		case .None:
			return q.bind({ result2 in
				if !result2.expect {
					return Rose.pure(failed(reason: "expectFailure may not occur inside a disjunction"))
				}
				switch result2.ok {
				case .Some(true):
					return Rose.pure(result2)
				default:
					return Rose.pure(result1)
				}
			})
		default:
			fatalError("Non-exhaustive if-else statement reached")
		}
	})
}

public enum Callback {
	case PostTest(kind: CallbackKind, f: State -> TestResult -> ())
	case PostFinalFailure(kind: CallbackKind, f: State -> TestResult -> ())
}

public enum CallbackKind {
	case Counterexample
	case NotCounterexample
}

public enum TestResultMatcher {
	case MkResult(ok : Optional<Bool>,
			expect : Bool,
			reason : String,
			theException : Optional<String>,
			interrupted : Bool,
			labels : Dictionary<String, Int>,
			stamp : Set<String>,
			callbacks : [Callback])
}

public struct TestResult {
	let ok : Optional<Bool>
	let expect : Bool
	let reason : String
	let theException : Optional<String>
	let interrupted : Bool
	let labels : Dictionary<String, Int>
	let stamp : Set<String>
	let callbacks : [Callback]
	
	public func match() -> TestResultMatcher {
		return TestResultMatcher.MkResult(ok: ok, expect: expect, reason: reason, theException: theException, interrupted: interrupted, labels: labels, stamp: stamp, callbacks: callbacks)
	}

	public init(ok : Optional<Bool>, expect : Bool, reason : String, theException : Optional<String>, interrupted : Bool, labels : Dictionary<String, Int>, stamp : Set<String>, callbacks : [Callback]) {
		self.ok = ok
		self.expect = expect
		self.reason = reason
		self.theException = theException
		self.interrupted = interrupted
		self.labels = labels
		self.stamp = stamp
		self.callbacks = callbacks
	}
}

func result(ok: Bool?, reason : String = "") -> TestResult {
	return TestResult(ok: ok, expect: true, reason: reason, theException: .None, interrupted: false, labels: [:], stamp: Set(), callbacks: [])
}
