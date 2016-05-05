//
//  LambdaSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/6/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

import SwiftCheck
import XCTest

struct Name : Arbitrary, Equatable, Hashable, CustomStringConvertible {
	let unName : String

	static var arbitrary : Gen<Name> {
		let gc : Gen<Character> = Gen<Character>.fromElementsIn("a"..."z")
		return gc.map { Name(unName: String($0)) }
	}

	var description : String {
		return self.unName
	}

	var hashValue : Int {
		return self.unName.hashValue
	}
}

func == (l : Name, r : Name) -> Bool {
	return l.unName == r.unName
}

private func liftM2<A, B, C>(f : (A, B) -> C, _ m1 : Gen<A>, _ m2 : Gen<B>) -> Gen<C> {
	return m1.flatMap { x1 in
		return m2.flatMap { x2 in
			return Gen.pure(f(x1, x2))
		}
	}
}

indirect enum Exp : Equatable {
	case Lam(Name, Exp)
	case App(Exp, Exp)
	case Var(Name)
}

func == (l : Exp, r : Exp) -> Bool {
	switch (l, r) {
	case let (.Lam(ln, le), .Lam(rn, re)):
		return ln == rn && le == re
	case let (.App(ln, le), .App(rn, re)):
		return ln == rn && le == re
	case let (.Var(n1), .Var(n2)):
		return n1 == n2
	default:
		return false
	}
}

extension Exp : Arbitrary {
	private static func arbExpr(n : Int) -> Gen<Exp> {
		return Gen<Exp>.frequency([
			(2, liftM(Exp.Var, Name.arbitrary)),
		] + ((n <= 0) ? [] : [
			(5, liftM2(Exp.Lam, Name.arbitrary, arbExpr(n.predecessor()))),
			(5, liftM2(Exp.App, arbExpr(n/2), arbExpr(n/2))),
		]))
	}

	static var arbitrary : Gen<Exp> {
		return Gen<Exp>.sized(self.arbExpr)
	}

	static func shrink(e : Exp) -> [Exp] {
		switch e {
		case .Var(_):
			return []
		case let .Lam(x, a):
			return [a] + Exp.shrink(a).map { .Lam(x, $0) }
		case let .App(a, b):
			let part1 : [Exp] = [a, b]
				+ [a].flatMap({ (expr : Exp) -> Exp? in
					if case let .Lam(x, a) = expr {
						return a.subst(x, b)
					}
					return nil
				})

			let part2 : [Exp] = Exp.shrink(a).map { App($0, b) }
				+ Exp.shrink(b).map { App(a, $0) }
			return part1 + part2
		}
	}

	var free : Set<Name> {
		switch self {
		case let .Var(x):
			return Set([x])
		case let .Lam(x, a):
			return a.free.subtract([x])
		case let .App(a, b):
			return a.free.union(b.free)
		}
	}

	func rename(x : Name, _ y : Name) -> Exp {
		if x == y {
			return self
		}
		return self.subst(x, .Var(y))
	}

	func subst(x : Name, _ c : Exp) -> Exp {
		switch self {
		case let .Var(y) where x == y :
			return c
		case let .Lam(y, a) where x != y:
			return .Lam(y, a.subst(x, c))
		case let .App(a, b):
			return .App(a.subst(x, c), b.subst(x, c))
		default:
			return self
		}
	}

	var eval : Exp {
		switch self {
		case .Var(_):
			fatalError("Cannot evaluate free variable!")
		case let .App(a, b):
			switch a.eval {
			case let .Lam(x, aPrime):
				return aPrime.subst(x, b)
			default:
				return .App(a.eval, b.eval)
			}
		default:
			return self
		}
	}
}

extension Exp : CustomStringConvertible {
	var description : String {
		switch self {
		case let .Var(x):
			return "$" + x.description
		case let .Lam(x, t):
			return "(λ $\(x.description).\(t.description))"
		case let .App(a, b):
			return "(\(a.description) \(b.description))"
		}
	}
}

extension Name {
	func fresh(ys : Set<Name>) -> Name {
		let zz = "abcdefghijklmnopqrstuvwxyz".unicodeScalars.map { Name(unName: String($0)) }
		return Set(zz).subtract(ys).first ?? self
	}
}

private func showResult<A>(x : A, f : A -> Testable) -> Property {
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
					==> subst_x_b_a.free == a.free.subtract([x]).union(b.free)
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
}
