//
//  Property.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// Takes the conjunction of multiple properties and reports all successes and
/// failures as one combined property.  That is, this property holds when all
/// sub-properties hold and fails when one or more sub-properties fail.
///
/// Conjoined properties are each tested normally but are collected and labelled
/// together.  This can mean multiple failures in distinct sub-properties are
/// masked.  If fine-grained error reporting is needed, use a combination of
/// `disjoin(_:)` and `verbose(_:)`.
///
/// - note: When conjoining properties all calls to `expectFailure` will fail.
///
/// - parameter ps: A variadic list of properties to be conjoined.
///
/// - returns: A `Property` that evaluates to the result of conjoining each
///   of the given `Testable` expressions.
public func conjoin(_ ps : Testable...) -> Property {
	return Property(sequence(ps.map({ (p : Testable) in
		return p.property.unProperty.map { $0.unProp }
	})).flatMap({ roses in
		return Gen.pure(Prop(unProp: conj({ $0 }, xs: roses)))
	})).again
}

/// Takes the disjunction of multiple properties and reports all successes and
/// failures of each sub-property distinctly.  That is, this property holds when
/// any one of its sub-properties holds and fails when all of its sub-properties
/// fail simultaneously.
///
/// Disjoined properties, when used in conjunction with labelling, cause
/// SwiftCheck to print a distribution map of the success rate of each sub-
/// property.
///
/// - note: When disjoining properties all calls to `expectFailure` will fail.
///   You may `invert` the property instead.
///
/// - parameter ps: A variadic list of properties to be disjoined.
///
/// - returns: A `Property` that evaluates to the result of disjoining each
///   of the given `Testable` expressions.
public func disjoin(_ ps : Testable...) -> Property {
	return Property(sequence(ps.map({ (p : Testable) in
		return p.property.unProperty.map { $0.unProp }
	})).flatMap({ roses in
		return Gen.pure(Prop(unProp: roses.reduce(.mkRose({ TestResult.failed() }, { [] }), disj)))
	})).again
}

/// Takes the nondeterministic conjunction of multiple properties and treats
/// them as a single large property.
///
/// The resulting property makes 100 random choices to test any of the given
/// properties.  Thus, running multiple test cases will result in distinct
/// arbitrary sequences of each property being tested.
///
/// - parameter ps: A variadic list of properties to be randomly conjoined.
///
/// - returns: A `Property` that evaluates to the result of randomly conjoining
///   any of the given `Testable` expressions.
public func conjamb(_ ps : () -> Testable...) -> Property {
	let ls = ps.lazy.map { $0().property.unProperty }
	return Property(Gen.one(of: ls)).again
}

extension Testable {
	/// Modifies a property so it will not shrink when it fails.
	public var noShrinking : Property {
		return self.mapRoseResult { rs in
			return rs.onRose { res, _ in
				return .mkRose({ res }, { [] })
			}
		}
	}

	/// Inverts the result of a test.  That is, test cases that would pass now
	/// fail and vice versa.
	///
	/// Discarded tests remain discarded under inversion.
	public var invert : Property {
		return self.mapResult { res in
			return TestResult(
				ok:            res.ok.map(!),
				expect:        res.expect,
				reason:        res.reason,
				theException:  res.theException,
				labels:        res.labels,
				stamp:         res.stamp,
				callbacks:     res.callbacks,
				abort:         res.abort,
				quantifier:    res.quantifier
			)
		}
	}

	/// Modifies a property so that it only will be tested once.
	///
	/// Undoes the effect of `.again`.
	public var once : Property {
		return self.mapResult { res in
			return TestResult(
				ok:            res.ok,
				expect:        res.expect,
				reason:        res.reason,
				theException:  res.theException,
				labels:        res.labels,
				stamp:         res.stamp,
				callbacks:     res.callbacks,
				abort:         true,
				quantifier:    res.quantifier
			)
		}
	}
	
	/// Modifies a property so that it will be tested many times.
	///
	/// Undoes the effect of `.once`.
	public var again : Property {
		return self.mapResult { res in
			return TestResult(
				ok:            res.ok,
				expect:        res.expect,
				reason:        res.reason,
				theException:  res.theException,
				labels:        res.labels,
				stamp:         res.stamp,
				callbacks:     res.callbacks,
				abort:         false,
				quantifier:    res.quantifier
			)
		}
	}

	/// Attaches a callback to a test case.
	public func withCallback(_ cb : Callback) -> Property {
		return self.mapResult { (res) in
			return TestResult(
				ok:            res.ok,
				expect:        res.expect,
				reason:        res.reason,
				theException:  res.theException,
				labels:        res.labels,
				stamp:         res.stamp,
				callbacks:     [cb] + res.callbacks,
				abort:         res.abort,
				quantifier:    res.quantifier
			)
		}
	}

	/// Adds the given string to the counterexamples of a failing property.
	///
	/// - parameter example: A string describing a counteraxmple that causes
	///   this property to fail.
	///
	/// - returns: A `Property` that prints the counterexample value on failure.
	public func counterexample(_ example : String) -> Property {
		return self.withCallback(Callback.afterFinalFailure(kind: .counterexample) { (_,_) in
			return print(example)
		})
	}

	/// Executes an action after the last failure of the property.
	///
	/// - parameter callback: A callback block to be executed after all failures
	///   have been processed.
	///
	/// - returns: A `Property` that executes the given callback block on
	///   failure.
	public func whenFail(_ callback : @escaping () -> ()) -> Property {
		return self.withCallback(Callback.afterFinalFailure(kind: .notCounterexample) { (_,_) in
			return callback()
		})
	}

	/// Executes an action after the every failure of the property.
	///
	/// Because the action is executed after every failing test it can be used
	/// to track the list of failures generated by the shrinking mechanism.
	///
	/// - parameter callback: A callback block to be executed after each 
	///   failing case of the property has been processed.
	public func whenEachFail(_ callback : @escaping () -> ()) -> Property {
		return self.withCallback(Callback.afterFinalFailure(kind: .notCounterexample) { (st, res) in
			if res.ok == .some(false) {
				callback()
			}
		})
	}

	/// Modifies a property so it prints out every generated test case and the
	/// result of the property every time it is tested.
	///
	/// This function maps AfterFinalFailure callbacks that have the
	/// `.counterexample` kind to `.afterTest` callbacks.
	public var verbose : Property {
		func chattyCallbacks(_ cbs : [Callback]) -> [Callback] {
			let c = Callback.afterTest(kind: .counterexample) { (st, res) in
				switch res.ok {
				case .some(true):
					print("\nPassed: ", terminator: "")
					printLabels(res)
				case .some(false):
					print("\nFailed: ", terminator: "")
					printLabels(res)
					print("Pass the seed values \(st.randomSeedGenerator) to replay the test.", terminator: "\n\n")
				default:
					print("\nDiscarded: ", terminator: "")
					printLabels(res)
				}
			}

			return [c] + cbs.map { (c : Callback) -> Callback in
				switch c {
				case let .afterFinalFailure(.counterexample, f):
					return .afterTest(kind: .counterexample, f)
				default:
					return c
				}
			}
		}

		return self.mapResult { res in
			return TestResult(
				ok:            res.ok,
				expect:        res.expect,
				reason:        res.reason,
				theException:  res.theException,
				labels:        res.labels,
				stamp:         res.stamp,
				callbacks:     res.callbacks + chattyCallbacks(res.callbacks),
				abort:         res.abort,
				quantifier:    res.quantifier
			)
		}
	}

	/// Modifies a property to indicate that it is expected to fail.
	///
	/// If the property does not fail, SwiftCheck will report an error.
	public var expectFailure : Property {
		return self.mapTotalResult { res in
			return TestResult(
				ok:            res.ok,
				expect:        false,
				reason:        res.reason,
				theException:  res.theException,
				labels:        res.labels,
				stamp:         res.stamp,
				callbacks:     res.callbacks,
				abort:         res.abort,
				quantifier:    res.quantifier
			)
		}
	}

	/// Attaches a label to a property.
	///
	/// Labelled properties aid in testing conjunctions and disjunctions, or any
	/// other cases where test cases need to be distinct from one another.  In
	/// addition to shrunken test cases, upon failure SwiftCheck will print a
	/// distribution map for the property that shows a percentage success rate
	/// for the property.
	///
	/// - parameter label: The label to apply to the property.
	///
	/// - returns: A `Property` with the given label attached.
	public func label(_ label : String) -> Property {
		return self.classify(true, label: label)
	}

	/// Labels a property with a printable value.
	///
	/// - parameter value: The value whose reflected representation will label
	///   the property.
	///
	/// - returns: A `Property` labelled with the reflected representation of 
	///   the given value.
	public func collect<A>(_ value : A) -> Property {
		return self.label(String(describing: value))
	}

	/// Conditionally labels a property with a value.
	///
	/// - parameter condition: The condition to evaluate.
	/// - parameter label: The label to apply to the property if the given 
	///   condition evaluates to true.
	///
	/// - returns: A property that carries a label dependent upon the condition.
	public func classify(_ condition : Bool, label : String) -> Property {
		return self.cover(condition, percentage: 0, label: label)
	}

	/// Checks that at least the given proportion of successful test cases
	/// belong to the given class.
	///
	/// Discarded tests (i.e. ones with a false precondition) do not affect
	/// coverage.
	///
	/// - parameter condition: The condition to evaluate.
	/// - parameter percentage: A value from 0-100 inclusive that describes
	///   the expected percentage the given condition will evaluate to true.
	/// - parameter label: The label to apply to the property if the given 
	///   condition evaluates to true.
	///
	/// - returns: A property that carries a label dependent upon the condition.
	public func cover(_ condition : Bool, percentage : Int, label : String) -> Property {
		if condition {
			return self.mapResult { res in
				return TestResult(
					ok:            res.ok,
					expect:        res.expect,
					reason:        res.reason,
					theException:  res.theException,
					labels:        insertWith(max, k: label, v: percentage, m: res.labels),
					stamp:         res.stamp.union([label]),
					callbacks:     res.callbacks,
					abort:         res.abort,
					quantifier:    res.quantifier
				)
			}
		}
		return self.property
	}

	/// Applies a function that modifies the property generator's inner `Prop`.
	///
	/// This function can be used to completely change the evaluation schema of
	/// generated test cases by replacing the test's rose tree with a custom
	/// one.
	///
	/// - parameter transform: The transformation function to apply to the
	///   `Prop`s of this `Property`.
	///
	/// - returns: A `Property` that applies the given transformation upon
	///   evaluation.
	public func mapProp(_ transform : @escaping (Prop) -> Prop) -> Property {
		return Property(self.property.unProperty.map(transform))
	}

	/// Applies a function that modifies the test case generator's size.
	///
	/// - parameter transform: The transformation function to apply to the size
	///   of the generators underlying this `Property`.
	///
	/// - returns: A `Property` that applies the given transformation upon
	///   evaluation.
	public func mapSize(_ transform : @escaping (Int) -> Int) -> Property {
		return Property(Gen.sized { n in
			return self.property.unProperty.resize(transform(n))
		})
	}

	/// Applies a function that modifies the result of a test case.
	///
	/// - parameter transform: The transformation function to apply to the
	///   result of executing this `Property`.
	///
	/// - returns: A `Property` that modifies its final result by executing the
	///   given transformation block.
	public func mapTotalResult(_ transform : @escaping (TestResult) -> TestResult) -> Property {
		return self.mapRoseResult { rs in
			return protectResults(rs.map(transform))
		}
	}

	/// Applies a function that modifies the result of a test case.
	///
	/// - parameter transform: The transformation function to apply to the
	///   result of executing this `Property`.
	///
	/// - returns: A `Property` that modifies its final result by executing the
	///   given transformation block.
	public func mapResult(_ transform : @escaping (TestResult) -> TestResult) -> Property {
		return self.mapRoseResult { rs in
			return rs.map(transform)
		}
	}

	/// Applies a function that modifies the underlying Rose Tree that a test
	/// case has generated.
	///
	/// - parameter transform: The transformation function to apply to the 
	///   rose tree used to execute this `Property`.
	///
	/// - returns: A `Property` that modifies its evaluation strategy by
	///   executing the given transformation block.
	public func mapRoseResult(_ transform : @escaping (Rose<TestResult>) -> Rose<TestResult>) -> Property {
		return self.mapProp { t in
			return Prop(unProp: transform(t.unProp))
		}
	}
}

/// Using a shrinking function, shrinks a given argument to a property if it
/// fails.
///
/// Shrinking is handled automatically by SwiftCheck.  Invoking this function is
/// only necessary when you must override the default behavior.
///
/// - parameter shrinker: The custom shrinking function to use for this type.
/// - parameter initial: The initial value that kicks off the shrinking process.
/// - parameter prop: The property to be tested.
///
/// - returns: A `Property` that shrinks its arguments with the given function.
public func shrinking<A>(_ shrinker : @escaping (A) -> [A], initial : A, prop : @escaping (A) -> Testable) -> Property {
	return Property(promote(props(shrinker, original: initial, pf: prop)).map { rs in
		return Prop(unProp: joinRose(rs.map { x in
			return x.unProp
		}))
	})
}

/// A `Callback` is a block of code that can be run after a test case has
/// finished.  They consist of a kind and the callback block itself, which is
/// given the state SwiftCheck ran the test case with and the result of the test
/// to do with as it sees fit.
public enum Callback {
	/// A callback that is posted after a test case has completed.
	case afterTest(kind : CallbackKind, (CheckerState, TestResult) -> ())
	/// The callback is posted after all cases in the test have failed.
	case afterFinalFailure(kind : CallbackKind, (CheckerState, TestResult) -> ())
}

/// The type of callbacks SwiftCheck can dispatch.
public enum CallbackKind {
	/// Affected by the verbose combinator.
	case counterexample
	/// Not affected by the verbose combinator
	case notCounterexample
}

/// The types of quantification SwiftCheck can perform.
public enum Quantification {
	/// Universal Quantification ("for all").
	case universal
	/// Existential Quanfication ("there exists").
	case existential
	/// Uniqueness Quantification ("there exists one and only one")
//    case Uniqueness
	/// Counting Quantification ("there exist exactly k")
//    case Counting
}

/// A `TestResult` represents the result of performing a single test.
public struct TestResult {
	/// The result of executing the test case.  For Discarded test cases the
	/// value of this property is `.None`.
	let ok            : Optional<Bool>
	/// Indicates what the expected result of the property is.
	let expect        : Bool
	/// A message indicating the reason a test case failed.
	let reason        : String
	/// The exception that was thrown if one occured during testing.
	let theException  : Optional<String>
	/// All the labels used during the test case.
	let labels        : Dictionary<String, Int>
	/// The collected values for the test case.
	let stamp         : Set<String>
	/// Callbacks attached to the test case.
	let callbacks     : [Callback]
	/// Indicates that any further testing of the property should cease.
	let abort         : Bool
	/// The quantifier being applied to this test case.
	let quantifier    : Quantification

	/// Provides a pattern-match-friendly view of the current state of a test
	/// result.
	public enum TestResultMatcher {
		/// A case-able view of the current state of a test result.
		case matchResult(
			ok            : Optional<Bool>,
			expect        : Bool,
			reason        : String,
			theException  : Optional<String>,
			labels        : Dictionary<String, Int>,
			stamp         : Set<String>,
			callbacks     : Array<Callback>,
			abort         : Bool,
			quantifier    : Quantification
		)
	}

	/// Destructures a test case into a matcher that can be used in switch
	/// statement.
	public var match : TestResultMatcher {
		return .matchResult(ok: ok, expect: expect, reason: reason, theException: theException, labels: labels, stamp: stamp, callbacks: callbacks, abort: abort, quantifier: quantifier)
	}

	/// Creates and returns a new test result initialized with the given
	/// parameters.
	public init(
		ok : Optional<Bool>,
		expect : Bool,
		reason : String,
		theException : Optional<String>,
		labels : Dictionary<String, Int>,
		stamp : Set<String>,
		callbacks : [Callback],
		abort : Bool,
		quantifier : Quantification
	) {
		self.ok = ok
		self.expect = expect
		self.reason = reason
		self.theException = theException
		self.labels = labels
		self.stamp = stamp
		self.callbacks = callbacks
		self.abort = abort
		self.quantifier = quantifier
	}

	/// Convenience constructor for a passing `TestResult`.
	public static var succeeded : TestResult {
		return result(Optional.some(true))
	}

	/// Convenience constructor for a failing `TestResult`.
	public static func failed(_ reason : String = "") -> TestResult {
		return result(Optional.some(false), reason: reason)
	}

	/// Convenience constructor for a discarded `TestResult`.
	public static var rejected : TestResult {
		return result(Optional.none)
	}

	/// Lifts a `Bool`ean value to a TestResult by mapping true to
	/// `TestResult.suceeded` and false to `TestResult.failed`.
	public static func liftBool(_ b : Bool) -> TestResult {
		if b {
			return TestResult.succeeded
		}
		return result(Optional.some(false), reason: "Falsifiable")
	}
	
	private static func result(_ ok : Bool?, reason : String = "") -> TestResult {
		return TestResult(
			ok:            ok,
			expect:        true,
			reason:        reason,
			theException:  .none,
			labels:        [:],
			stamp:         Set(),
			callbacks:     [],
			abort:         false,
			quantifier:    .universal
		)
	}
}

// MARK: - Implementation Details

private func exception(_ msg : String) -> (Error) -> TestResult {
	return { e in TestResult.failed(String(describing: e)) }
}

private func props<A>(_ shrinker : @escaping (A) -> [A], original : A, pf : @escaping (A) -> Testable) -> Rose<Gen<Prop>> {
	return .mkRose({ pf(original).property.unProperty }, { shrinker(original).map { x1 in
		return props(shrinker, original: x1, pf: pf)
	}})
}

private func protectResults(_ rs : Rose<TestResult>) -> Rose<TestResult> {
	return rs.onRose { x, rs in
		return .ioRose({
			return .mkRose(protectResult({ x }), { rs.map(protectResults) })
		})
	}
}

//internal func protectRose(f : () throws -> Rose<TestResult>) -> (() -> Rose<TestResult>) {
//    return { protect(Rose.pure • exception("Exception"), x: f) }
//}

private func protect<A>(_ f : (Error) -> A, x : () throws -> A) -> A {
	do {
		return try x()
	} catch let e {
		return f(e)
	}
}

internal func comp<A, B, C>(_ f : @escaping (B) -> C, _ g : @escaping (A) -> B) -> (A) -> C {
	return { f(g($0)) }
}

private func protectResult(_ r : @escaping () throws -> TestResult) -> (() -> TestResult) {
	return { protect(exception("Exception"), x: r) }
}

internal func unionWith<K, V>(_ f : (V, V) -> V, l : Dictionary<K, V>, r : Dictionary<K, V>) -> Dictionary<K, V> {
	var map = l
	for (k, v) in r {
		if let val = map.updateValue(v, forKey: k) {
			map.updateValue(f(val, v), forKey: k)
		}
	}
	return map
}

private func insertWith<K, V>(_ f : (V, V) -> V, k : K, v : V, m : Dictionary<K, V>) -> Dictionary<K, V> {
	var res = m
	let oldV = res[k]
	if let existV = oldV {
		res[k] = f(existV, v)
	} else {
		res[k] = v
	}
	return res
}

private func mplus(_ l : Optional<String>, r : Optional<String>) -> Optional<String> {
	if let ls = l, let rs = r {
		return .some(ls + rs)
	}

	if l == nil {
		return r
	}

	return l
}

private func addCallbacks(_ result : TestResult) -> (TestResult) -> TestResult {
	return { res in
		return TestResult(
			ok:            res.ok,
			expect:        res.expect,
			reason:        res.reason,
			theException:  res.theException,
			labels:        res.labels,
			stamp:         res.stamp,
			callbacks:     result.callbacks + res.callbacks,
			abort:         res.abort,
			quantifier:    res.quantifier
		)
	}
}

private func addLabels(_ result : TestResult) -> (TestResult) -> TestResult {
	return { res in
		return TestResult(
			ok:            res.ok,
			expect:        res.expect,
			reason:        res.reason,
			theException:  res.theException,
			labels:        unionWith(max, l: res.labels, r: result.labels),
			stamp:         res.stamp.union(result.stamp),
			callbacks:     res.callbacks,
			abort:         res.abort,
			quantifier:    res.quantifier
		)
	}
}

private func printLabels(_ st : TestResult) {
	if st.labels.isEmpty {
		print("(.)")
	} else if st.labels.count == 1, let pt = st.labels.first {
		print("(\(pt.0))")
	} else {
		let gAllLabels = st.labels.map({ t in
			return t.0 + ", "
		}).reduce("", +)
		print("("  + gAllLabels[gAllLabels.startIndex..<gAllLabels.index(gAllLabels.endIndex, offsetBy: -2)] + ")")
	}
}

private func conj(_ k : @escaping (TestResult) -> TestResult, xs : [Rose<TestResult>]) -> Rose<TestResult> {
	guard let p = xs.first else {
		return Rose.mkRose({ k(TestResult.succeeded) }, { [] })
	}
	return .ioRose(/*protectRose*/({
		let rose = p.reduce
		switch rose {
		case .mkRose(let result, _):
			if !result().expect {
				return Rose.pure(TestResult.failed("expectFailure may not occur inside a conjunction"))
			}

			switch result().ok {
			case .some(true):
				return conj(comp(addLabels(result()), comp(addCallbacks(result()), k)), xs: [Rose<TestResult>](xs[1..<xs.endIndex]))
			case .some(false):
				return rose
			case .none:
				let rose2 = conj(comp(addCallbacks(result()), k), xs: [Rose<TestResult>](xs[1..<xs.endIndex])).reduce
				switch rose2 {
				case .mkRose(let result2, _):
					switch result2().ok {
					case .some(true):
						return Rose.mkRose({ TestResult.rejected }, { [] })
					case .some(false):
						return rose2
					case .none:
						return rose2
					}
				default:
					fatalError("Rose should not have reduced to IORose")
				}
			}
		default:
			fatalError("Rose should not have reduced to IORose")
		}
		fatalError()
	}))
}

private func disj(_ p : Rose<TestResult>, q : Rose<TestResult>) -> Rose<TestResult> {
	return p.flatMap { result1 in
		if !result1.expect {
			return Rose<TestResult>.pure(TestResult.failed("expectFailure may not occur inside a disjunction"))
		}
		switch result1.ok {
		case .some(true):
			return Rose<TestResult>.pure(result1)
		case .some(false):
			return q.flatMap { (result2 : TestResult) in
				if !result2.expect {
					return Rose<TestResult>.pure(TestResult.failed("expectFailure may not occur inside a disjunction"))
				}
				switch result2.ok {
				case .some(true):
					return Rose<TestResult>.pure(result2)
				case .some(false):
					let callbacks : [Callback] = [.afterFinalFailure(kind: .counterexample, { (_, _) in return print("") })]
					return Rose<TestResult>.pure(TestResult(
						ok:            .some(false),
						expect:        true,
						reason:        [result1.reason, result2.reason].joined(separator: ", "),
						theException:  mplus(result1.theException, r: result2.theException),
						labels:        [:],
						stamp:         Set(),
						callbacks:     result1.callbacks + callbacks + result2.callbacks,
						abort:         false,
						quantifier:    .universal
					))
				case .none:
					return Rose<TestResult>.pure(result2)
				}
			}
		case .none:
			return q.flatMap { (result2 : TestResult) in
				if !result2.expect {
					return Rose<TestResult>.pure(TestResult.failed("expectFailure may not occur inside a disjunction"))
				}
				switch result2.ok {
				case .some(true):
					return Rose<TestResult>.pure(result2)
				default:
					return Rose<TestResult>.pure(result1)
				}
			}
		}
	}
}
