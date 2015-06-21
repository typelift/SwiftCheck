//
//  Property.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

infix operator • {
	precedence 190
	associativity right
}

/// Takes the conjunction of multiple properties and reports all successes and failures as one
/// combined property.  That is, this property holds when all sub-properties hold and fails when one
/// or more sub-properties fail.
///
/// Conjoined properties are each tested normally but are collected and labelled together.  This can
/// mean multiple failures in distinct sub-properties are masked.  If fine-grained error reporting
/// is needed, use a combination of `disjoin(_:)` and `verbose(_:)`.
///
/// When conjoining properties all calls to `expectFailure` will fail.
public func conjoin(ps : Testable...) -> Property {
	return Property(sequence(ps.map({ (p : Testable) in
		return p.property().unProperty.fmap({ $0.unProp })
	})).bind({ roses in
		return Gen.pure(Prop(unProp: conj(id, xs: roses)))
	}))
}

/// Takes the disjunction of multiple properties and reports all successes and failures of each
/// sub-property distinctly.  That is, this property holds when any one of its sub-properties holds
/// and fails when all of its sub-properties fail simultaneously.
///
/// Disjoined properties, when used in conjunction with labelling, cause SwiftCheck to print a
/// distribution map of the success rate of each sub-property.
///
/// When disjoining properties all calls to `expectFailure` will fail.
public func disjoin(ps : Testable...) -> Property {
	return Property(sequence(ps.map({ (p : Testable) in
		return p.property().unProperty.fmap({ $0.unProp })
	})).bind({ roses in
		return Gen.pure(Prop(unProp: roses.reduce(.MkRose({ TestResult.failed() }, { [] }), combine: disj)))
	}))
}

extension Testable {
	/// Applies a function that modifies the property generator's inner `Prop`.
	public func mapProp(f : Prop -> Prop) -> Property {
		return Property(self.property().unProperty.fmap(f))
	}

	/// Applies a function that modifies the property generator's size.
	public func mapSize(f : Int -> Int) -> Property {
		return Property(Gen.sized({ n in
			return self.property().unProperty.resize(f(n))
		}))
	}

	/// Applies a function that modifies the result of a test case.
//	public func mapTotalResult(f : TestResult -> TestResult) -> Property {
//		return self.mapRoseResult({ rs in
//			return protectResults(rs.fmap(f))
//		})
//	}

	/// Applies a function that modifies the result of a test case.
	public func mapResult(f : TestResult -> TestResult) -> Property {
		return self.mapRoseResult({ rs in
			return rs.fmap(f)
		})
	}

	/// Applies a function that modifies the underlying Rose Tree that a test case has generated.
	public func mapRoseResult(f : Rose<TestResult> -> Rose<TestResult>) -> Property {
		return self.mapProp({ t in
			return Prop(unProp: f(t.unProp))
		})
	}

	/// Modifies a property so it will not shrink when it fails.
	public var noShrinking : Property {
		return self.mapRoseResult({ rs in
			return onRose({ res in
				return { (_) in
					return .MkRose({ res }, { [] })
				}
			})(rs: rs)
		})
	}

	/// Modifies a property by requiring it to complete before a timeout (in nanoseconds).
	///
	/// Long-running operations that do not complete are subject to cancellation any time after the
	/// timeout period.
	public func within(n : Int64) -> Property {
		func withinF(n : Int64)(rose : Rose<TestResult>) -> Rose<TestResult> {
			return .IORose({
				if let res = timeout(n, block: reduce(rose)) {
					switch res {
					case .IORose(_):
						fatalError("Rose should not have reduced to .IORose")
					case let .MkRose(res, roses):
						return .MkRose(res, { roses().map(withinF(n)) })
					}
				}
				return Rose.pure(TestResult.failed("Property did not complete before timeout (\(n) ns)"))
			})
		}

		return self.mapRoseResult(withinF(n))
	}

	/// Modifies a property so that it only will be tested once.
	public var once : Property {
		return self.mapResult({ res in
			return TestResult(ok: res.ok,
							expect: res.expect,
							reason: res.reason,
							theException: res.theException,
							labels: res.labels,
							stamp: res.stamp,
							callbacks: res.callbacks,
							abort: true)
		})
	}

	/// Attaches a callback to a test case.
	public func withCallback(cb : Callback) -> Property {
		return self.mapResult({ (res) in
			return TestResult(ok: res.ok,
							expect: res.expect,
							reason: res.reason,
							theException: res.theException,
							labels: res.labels,
							stamp: res.stamp,
							callbacks: [cb] + res.callbacks,
							abort: res.abort)
		})
	}

	/// Adds the given string to the counterexamples of a failing property.
	public func counterexample(s : String) -> Property {
		return self.withCallback(Callback.AfterFinalFailure(kind: .Counterexample, f: { _ in
			return print(s)
		}))
	}

	/// Executes an action after the last failure of the property.
	public func whenFail(m : () -> ()) -> Property {
		return self.withCallback(Callback.AfterFinalFailure(kind: .NotCounterexample, f: { _ in
			return m()
		}))
	}

	/// Executes an action after the every failure of the property.
	///
	/// Because the action is executed after every failing test it can be used to track the list of
	/// failures generated by the shrinking mechanism.
	public func whenEachFail(m : () -> ()) -> Property {
		return self.withCallback(Callback.AfterFinalFailure(kind: .NotCounterexample, f: { (st, res) in
			if res.ok == .Some(false) {
				m()
			}
		}))
	}

	/// Modifies a property so it prints out every generated test case and the result of the property
	/// every time it is tested.
	///
	/// This function maps AfterFinalFailure callbacks that have the .Counterexample kind to AfterTest
	/// callbacks.
	public var verbose : Property {
		func chattyCallbacks(cbs : [Callback]) -> [Callback] {
			let c = Callback.AfterTest(kind: .Counterexample, f: { (st, res) in
				switch res.ok {
				case .Some(true):
					print("Passed:")
				case .Some(false):
					print("Failed:")
				default:
					print("Discarded:")
				}
			})

			return [c] + cbs.map { (c : Callback) -> Callback in
				switch c {
				case let .AfterFinalFailure(.Counterexample, f):
					return .AfterTest(kind: .Counterexample, f: f)
				default:
					return c
				}
			}
		}

		return self.mapResult({ res in
			return TestResult(ok: res.ok,
						expect: res.expect,
						reason: res.reason,
						theException: res.theException,
						labels: res.labels,
						stamp: res.stamp,
						callbacks: res.callbacks + chattyCallbacks(res.callbacks),
						abort: res.abort)
		})
	}

	/// Modifies a property to indicate that it is expected to fail.
	///
	/// If the property does not fail, SwiftCheck will report an error.
	public var expectFailure : Property {
		// return self.mapTotalResult({ res in
		return self.mapResult({ res in
			return TestResult(ok: res.ok,
						expect: false,
						reason: res.reason,
						theException: res.theException,
						labels: res.labels,
						stamp: res.stamp,
						callbacks: res.callbacks,
						abort: res.abort)
		})
	}

	/// Attaches a label to a property.
	///
	/// Labelled properties aid in testing conjunctions and disjunctions, or any other cases where
	/// test cases need to be distinct from one another.  In addition to shrunken test cases, upon
	/// failure SwiftCheck will print a distribution map for the property that shows a percentage
	/// success rate for the property.
	public func label(s : String) -> Property {
		return self.classify(true)(s: s)
	}

	/// Labels a property with a printable value.
	public func collect<A>(x : A) -> Property {
		return self.label(String(x))
	}

	/// Conditionally labels a property with a value.
	public func classify(b : Bool)(s : String) -> Property {
		return self.cover(b)(n: 0)(s: s)
	}

	/// Checks that at least the given proportion of successful test cases belong to the given class.
	///
	/// Discarded tests (i.e. ones with a false precondition) do not affect coverage.
	public func cover(b : Bool)(n : Int)(s : String) -> Property {
		if b {
			return self.mapResult({ res in
				return TestResult(ok: res.ok,
							expect: res.expect,
							reason: res.reason,
							theException: res.theException,
							labels: insertWith(max, k: s, v: n, m: res.labels),
							stamp: res.stamp.union([s]),
							callbacks: res.callbacks,
							abort: res.abort)
			})
		}
		return self.property()
	}
}

/// Using a shrinking function, shrinks a given argument to a property if it fails.
///
/// Shrinking is handled automatically by SwiftCheck.  Invoking this function is only necessary
/// when you must override the default behavior.
public func shrinking<A>(shrinker : A -> [A], initial : A, prop : A -> Testable) -> Property {
	return Property(promote(props(shrinker, original: initial, pf: prop)).fmap { (let rs : Rose<Prop>) in
		return Prop(unProp: joinRose(rs.fmap { (let x : Prop) in
			return x.unProp
		}))
	})
}

/// A `Callback` is a block of code that can be run after a test case has finished.  They consist
/// of a kind and the callback block itself, which is given the state SwiftCheck ran the test case
/// with and the result of the test to do with as it sees fit.
public enum Callback {
	/// A callback that is posted after a test case has completed.
	case AfterTest(kind : CallbackKind, f : (State, TestResult) -> ())
	/// The callback is posted after all cases in the test have failed.
	case AfterFinalFailure(kind : CallbackKind, f : (State, TestResult) -> ())
}

/// The type of callbacks SwiftCheck can dispatch.
public enum CallbackKind {
	///
	case Counterexample
	case NotCounterexample
}

public enum TestResultMatcher {
	case MatchResult( ok : Optional<Bool>
					, expect : Bool
					, reason : String
					, theException : Optional<String>
					, labels : Dictionary<String, Int>
					, stamp : Set<String>
					, callbacks : [Callback]
					, abort : Bool
					)
}

/// A `TestResult` represents the result of performing a single test.
public struct TestResult {
	/// The result of executing the test case.  For Discarded test cases the value of this property 
	/// is .None.
	let ok				: Optional<Bool>
	/// Indicates what the expected result of the property is.
	let expect			: Bool
	/// A message indicating the reason a test case failed.
	let reason			: String
	/// The exception that was thrown if one occured during testing.
	let theException	: Optional<String>
	/// All the labels used during the test case.
	let labels			: Dictionary<String, Int>
	/// The collected values for the test case.
	let stamp			: Set<String>
	/// Callbacks attached to the test case.
	let callbacks		: [Callback]
	/// Indicates that any further testing of the property should cease.
	let abort			: Bool

	/// Destructures a test case into a matcher that can be used in switch statement.
	public func match() -> TestResultMatcher {
		return .MatchResult(ok: ok, expect: expect, reason: reason, theException: theException, labels: labels, stamp: stamp, callbacks: callbacks, abort: abort)
	}

	public init(ok : Optional<Bool>, expect : Bool, reason : String, theException : Optional<String>, labels : Dictionary<String, Int>, stamp : Set<String>, callbacks : [Callback], abort : Bool) {
		self.ok = ok
		self.expect = expect
		self.reason = reason
		self.theException = theException
		self.labels = labels
		self.stamp = stamp
		self.callbacks = callbacks
		self.abort = abort
	}

	/// Convenience constructor for a passing `TestResult`.
	public static var succeeded : TestResult {
		return result(Optional.Some(true))
	}

	/// Convenience constructor for a failing `TestResult`.
	public static func failed(reason : String = "") -> TestResult {
		return result(Optional.Some(false), reason: reason)
	}

	/// Convenience constructor for a discarded `TestResult`.
	public static var rejected : TestResult {
		return result(Optional.None)
	}

	/// Lifts a `Bool`ean value to a TestResult by mapping true to `TestResult.suceeded` and false
	/// to `TestResult.failed`.
	public static func liftBool(b : Bool) -> TestResult {
		if b {
			return TestResult.succeeded
		}
		return result(Optional.Some(false), reason: "Falsifiable")
	}
}

/// MARK: Implementation Details

private func exception(msg : String) -> ErrorType -> TestResult {
	return { e in TestResult.failed(String(e)) }
}

private func props<A>(shrinker : A -> [A], original : A, pf: A -> Testable) -> Rose<Gen<Prop>> {
	return .MkRose({ pf(original).property().unProperty }, { shrinker(original).map { x1 in
		return props(shrinker, original: x1, pf: pf)
	}})
}

private func result(ok : Bool?, reason : String = "") -> TestResult {
	return TestResult(ok: ok, expect: true, reason: reason, theException: .None, labels: [:], stamp: Set(), callbacks: [], abort: false)
}

//private func protectResults(rs : Rose<TestResult>) -> Rose<TestResult> {
//	return onRose({ x in
//		return { rs in
//			return .IORose({
//				return .MkRose(protectResult({ x }), { rs.map(protectResults) })
//			})
//		}
//	})(rs: rs)
//}
//
//internal func protectRose(f : () throws -> Rose<TestResult>) -> (() -> Rose<TestResult>) {
//	return { protect(Rose.pure • exception("Exception"))(x: f) }
//}
//
//internal func protect<A>(f : ErrorType -> A)(x : () throws -> A) -> A {
//	do {
//		return try x()
//	} catch let e {
//		return f(e)
//	}
//}
//
//private func protectResult(r : () throws -> TestResult) -> (() -> TestResult) {
//	return { protect(exception("Exception"))(x: r) }
//}

private let swiftCheckTimeoutQueue : NSOperationQueue = {
	let queue = NSOperationQueue()
	queue.name = "com.typelift.SwiftCheck.TimeoutQueue"
	return queue
}()

private func timeout<A>(t : Int64, @autoclosure(escaping) block : () -> A) -> Optional<A> {
	let semaphore = dispatch_semaphore_create(0);
	var val : A? = nil

	swiftCheckTimeoutQueue.addOperationWithBlock({
		val = block()
		dispatch_semaphore_signal(semaphore);
	})

	let timeoutTime = dispatch_time(DISPATCH_TIME_NOW, t);
	if dispatch_semaphore_wait(semaphore, timeoutTime) != 0 {
		swiftCheckTimeoutQueue.cancelAllOperations()
		return nil
	}
	return val
}

private func id<A>(x : A) -> A {
	return x
}

internal func • <A, B, C>(f : B -> C, g : A -> B) -> A -> C {
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
			labels: res.labels,
			stamp: res.stamp,
			callbacks: result.callbacks + res.callbacks,
			abort: res.abort)
	}
}

private func addLabels(result : TestResult) -> TestResult -> TestResult {
	return { res in
		return TestResult(ok: res.ok,
			expect: res.expect,
			reason: res.reason,
			theException: res.theException,
			labels: unionWith(max, l: res.labels, r: result.labels),
			stamp: res.stamp.union(result.stamp),
			callbacks: res.callbacks,
			abort: res.abort)
	}
}

private func conj(k : TestResult -> TestResult, xs : [Rose<TestResult>]) -> Rose<TestResult> {
	if xs.isEmpty {
		return Rose.MkRose({ k(TestResult.succeeded) }, { [] })
	} else if let p = xs.first {
		return .IORose(/*protectRose*/({
			let rose = reduce(p)
			switch rose {
			case .MkRose(let result, _):
				if !result().expect {
					return Rose.pure(TestResult.failed("expectFailure may not occur inside a conjunction"))
				}

				switch result().ok {
				case .Some(true):
					return conj(addLabels(result()) • addCallbacks(result()) • k, xs: [Rose<TestResult>](xs[1..<xs.endIndex]))
				case .Some(false):
					return rose
				case .None:
					let rose2 = reduce(conj(addCallbacks(result()) • k, xs: [Rose<TestResult>](xs[1..<xs.endIndex])))
					switch rose2 {
					case .MkRose(let result2, _):
						switch result2().ok {
						case .Some(true):
							return Rose.MkRose({ TestResult.rejected }, { [] })
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
		}))
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
			return Rose.pure(TestResult.failed("expectFailure may not occur inside a disjunction"))
		}
		switch result1.ok {
		case .Some(true):
			return Rose.pure(result1)
		case .Some(false):
			return q.bind({ result2 in
				if !result2.expect {
					return Rose.pure(TestResult.failed("expectFailure may not occur inside a disjunction"))
				}
				switch result2.ok {
				case .Some(true):
					return Rose.pure(result2)
				case .Some(false):
					return Rose.pure(TestResult(ok: .Some(false),
						expect: true,
						reason: sep(result1.reason, r: result2.reason),
						theException: mplus(result1.theException, r: result2.theException),
						labels: [:],
						stamp: Set(),
						callbacks: result1.callbacks + [.AfterFinalFailure(kind: .Counterexample, f: { _ in
							return print("")
						})] + result2.callbacks,
						abort: false))
				case .None:
					return Rose.pure(result2)
				default:
					fatalError("Non-exhaustive if-else statement reached")
				}
			})
		case .None:
			return q.bind({ result2 in
				if !result2.expect {
					return Rose.pure(TestResult.failed("expectFailure may not occur inside a disjunction"))
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
