//
//  LambdaSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/6/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

import SwiftCheck
import XCTest
#if SWIFT_PACKAGE
import FileCheck
#endif

struct Name : Arbitrary, Equatable, Hashable, CustomStringConvertible {
	let unName : String

	static var arbitrary : Gen<Name> {
		let gc : Gen<Character> = Gen<Character>.fromElements(in: "a"..."z")
		return gc.map { Name(unName: String($0)) }
	}

	var description : String {
		return self.unName
	}

	var hashValue : Int {
		return self.unName.hashValue
	}

	static func == (l : Name, r : Name) -> Bool {
		return l.unName == r.unName
	}
}

private func liftM2<A, B, C>(_ f : @escaping (A, B) -> C, _ m1 : Gen<A>, _ m2 : Gen<B>) -> Gen<C> {
	return m1.flatMap { x1 in
		return m2.flatMap { x2 in
			return Gen.pure(f(x1, x2))
		}
	}
}

indirect enum Exp : Equatable {
	case lam(Name, Exp)
	case app(Exp, Exp)
	case `var`(Name)

	static func == (l : Exp, r : Exp) -> Bool {
		switch (l, r) {
		case let (.lam(ln, le), .lam(rn, re)):
			return ln == rn && le == re
		case let (.app(ln, le), .app(rn, re)):
			return ln == rn && le == re
		case let (.var(n1), .var(n2)):
			return n1 == n2
		default:
			return false
		}
	}
}

extension Exp : Arbitrary {
	private static func arbExpr(_ n : Int) -> Gen<Exp> {
		return Gen<Exp>.frequency([
			(2, liftM(Exp.var, Name.arbitrary)),
			] + ((n <= 0) ? [] : [
				(5, liftM2(Exp.lam, Name.arbitrary, arbExpr((n - 1)))),
				(5, liftM2(Exp.app, arbExpr(n/2), arbExpr(n/2))),
			]))
	}

	static var arbitrary : Gen<Exp> {
		return Gen<Exp>.sized(self.arbExpr)
	}

	static func shrink(_ e : Exp) -> [Exp] {
		switch e {
		case .var(_):
			return []
		case let .lam(x, a):
			return [a] + Exp.shrink(a).map { .lam(x, $0) }
		case let .app(a, b):
			let part1 : [Exp] = [a, b]
				+ [a].compactMap({ (expr : Exp) -> Exp? in
					if case let .lam(x, a) = expr {
						return a.subst(x, b)
					}
					return nil
				})

			let part2 : [Exp] = Exp.shrink(a).map { app($0, b) }
				+ Exp.shrink(b).map { app(a, $0) }
			return part1 + part2
		}
	}

	var free : Set<Name> {
		switch self {
		case let .var(x):
			return Set([x])
		case let .lam(x, a):
			return a.free.subtracting([x])
		case let .app(a, b):
			return a.free.union(b.free)
		}
	}

	func rename(_ x : Name, _ y : Name) -> Exp {
		if x == y {
			return self
		}
		return self.subst(x, .var(y))
	}

	func subst(_ x : Name, _ c : Exp) -> Exp {
		switch self {
		case let .var(y) where x == y :
			return c
		case let .lam(y, a) where x != y:
			return .lam(y, a.subst(x, c))
		case let .app(a, b):
			return .app(a.subst(x, c), b.subst(x, c))
		default:
			return self
		}
	}

	var eval : Exp {
		switch self {
		case .var(_):
			fatalError("Cannot evaluate free variable!")
		case let .app(a, b):
			switch a.eval {
			case let .lam(x, aPrime):
				return aPrime.subst(x, b)
			default:
				return .app(a.eval, b.eval)
			}
		default:
			return self
		}
	}
}

extension Exp : CustomStringConvertible {
	var description : String {
		switch self {
		case let .var(x):
			return "$" + x.description
		case let .lam(x, t):
			return "(λ $\(x.description).\(t.description))"
		case let .app(a, b):
			return "(\(a.description) \(b.description))"
		}
	}
}

extension Name {
	func fresh(_ ys : Set<Name>) -> Name {
		let zz = "abcdefghijklmnopqrstuvwxyz".unicodeScalars.map { Name(unName: String($0)) }
		return Set(zz).subtracting(ys).first ?? self
	}
}

private func showResult<A>(_ x : A, f : (A) -> Testable) -> Property {
	return f(x).whenFail {
		print("Result: \(x)")
	}
}

class LambdaSpec : XCTestCase {
	func testAll() {
		let tiny = CheckerArguments(maxTestCaseSize: 10)

		property("Free variable capture occurs", arguments: tiny) <- forAll { (a : Exp, x : Name, b : Exp) in
			return showResult(a.subst(x, b)) { subst_x_b_a in
				return a.free.contains(x)
					==> subst_x_b_a.free == a.free.subtracting([x]).union(b.free)
			}
		}.expectFailure

		property("Substitution of a free variable into a fresh expr is idempotent", arguments: tiny) <- forAll { (a : Exp, x : Name, b : Exp) in
			return showResult(a.subst(x, b)) { subst_x_b_a in
				return !a.free.contains(x) ==> subst_x_b_a == a
			}
		}

		property("Substitution of a free variable into a fresh expr is idempotent", arguments: tiny) <- forAll { (a : Exp, x : Name, b : Exp) in
			return showResult(a.subst(x, b)) { subst_x_b_a in
				return !a.free.contains(x) ==> subst_x_b_a.free == a.free
			}
		}
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testAll", testAll),
	])
	#endif
}

