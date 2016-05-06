//
//  RoseSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/24/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

import SwiftCheck
import XCTest

class RoseSpec : XCTestCase {
	private static func intRoseTree(v : Int) -> Rose<Int> {
		return .MkRose({ v }, { Int.shrink(v).map(intRoseTree) })
	}
	
	private static func depthOneChildren<A>(rose : Rose<A>) -> [A] {
		return rose.children.map { $0.root }
	}
	
	private static func depthOneAndTwoChildren<A>(rose : Rose<A>) -> [A] {
		let topChildren = rose.children
		let vs = topChildren.map { $0.root }
		let cs = topChildren.flatMap({ $0.children }).map({ $0.root })
		return vs + cs
	}
	
	func testAll() {
		property("Collapse brings up one level of rose tree depth") <- forAll { (i : Int) in
			let tree = RoseSpec.intRoseTree(i)
			return RoseSpec.depthOneChildren(tree.collapse) == RoseSpec.depthOneAndTwoChildren(tree)
		}
	}
	
	func testLaws() {
		let smallArgs = CheckerArguments(maxTestCaseSize: 5)
		property("Rose obeys the Functor identity law", arguments: smallArgs) <- forAll { (x : RoseTreeOf<Int>) in
			return (x.getRose.map(id)) == id(x.getRose)
		}
		
		property("Rose obeys the Functor composition law", arguments: smallArgs) <- forAll { (f : ArrowOf<Int, Int>, g : ArrowOf<Int, Int>) in
			return forAll { (x : RoseTreeOf<Int>) in
				return ((f.getArrow • g.getArrow) <^> x.getRose) == (x.getRose.map(g.getArrow).map(f.getArrow))
			}
		}
		
		property("Rose obeys the Applicative identity law", arguments: smallArgs) <- forAll { (x : RoseTreeOf<Int>) in
			return (Rose.pure(id) <*> x.getRose) == x.getRose
		}
		
		property("Rose obeys the first Applicative composition law", arguments: smallArgs) <- forAll{ (fl : RoseTreeOf<ArrowOf<Int, Int>>, gl : RoseTreeOf<ArrowOf<Int, Int>>, x : RoseTreeOf<Int>) in
			let f = fl.getRose.map({ $0.getArrow })
			let g = gl.getRose.map({ $0.getArrow })
			return (curry(•) <^> f <*> g <*> x.getRose) == (f <*> (g <*> x.getRose))
		}
		
		property("Rose obeys the second Applicative composition law", arguments: smallArgs) <- forAll { (fl : RoseTreeOf<ArrowOf<Int, Int>>, gl : RoseTreeOf<ArrowOf<Int, Int>>, x : RoseTreeOf<Int>) in
			let f = fl.getRose.map({ $0.getArrow })
			let g = gl.getRose.map({ $0.getArrow })
			return (Rose.pure(curry(•)) <*> f <*> g <*> x.getRose) == (f <*> (g <*> x.getRose))
		}
		
		property("Rose obeys the Monad left identity law", arguments: smallArgs) <- forAll { (a : Int, f : ArrowOf<Int, RoseTreeOf<Int>>) in
			return (Rose<Int>.pure(a) >>- { f.getArrow($0).getRose }) == f.getArrow(a).getRose
		}
		
		property("Rose obeys the Monad right identity law", arguments: smallArgs) <- forAll { (m : RoseTreeOf<Int>) in
			return (m.getRose >>- Rose.pure) == m.getRose
		}
		
		property("Rose obeys the Monad associativity law", arguments: smallArgs) <- forAll { (f : ArrowOf<Int, RoseTreeOf<Int>>, g : ArrowOf<Int, RoseTreeOf<Int>>) in
			return forAll { (m : RoseTreeOf<Int>) in
				return 
					((m.getRose >>- { f.getArrow($0).getRose }) >>- { g.getArrow($0).getRose }) 
					== 
					(m.getRose >>- { x in f.getArrow(x).getRose >>- { g.getArrow($0).getRose } })
			}
		}
	}
}

struct RoseTreeOf<A : Arbitrary> : Arbitrary {
	let getRose : Rose<A>
	
	init(_ rose : Rose<A>) {
		self.getRose = rose
	}
	
	static var arbitrary : Gen<RoseTreeOf<A>> {
		return Gen.sized { n in
			return arbTree(n)
		}
	}
}

private func arbTree<A>(n : Int) -> Gen<RoseTreeOf<A>> {
	if n == 0 {
		return A.arbitrary >>- { Gen.pure(RoseTreeOf(Rose.pure($0))) }
	}
	return Positive<Int>.arbitrary.flatMap { m in
		let n2 = n / (m.getPositive + 1)
		return Gen<(A, [A])>.zip(A.arbitrary, arbTree(n2).proliferateSized(m.getPositive)).flatMap { (a, f) in
			return Gen.pure(RoseTreeOf(.MkRose({ a }, { f.map { $0.getRose } })))
		}
	}
}

private func == <T : Equatable>(l : Rose<T>, r : Rose<T>) -> Bool {
	switch (l, r) {
	case let (.MkRose(l1, r1), .MkRose(l2, r2)):
		return l1() == l2() && zip(r1(), r2()).reduce(true) { (a, t) in a && (t.0 == t.1) }
	case (.IORose(_), .IORose(_)):
		return true
	default:
		return false
	}
}

extension Rose {
	var root : A {
		switch self.reduce {
		case let .MkRose(root, _):
			return root()
		default:
			fatalError("Rose should not have reduced to .IORose")
		}
	}
	
	var children : [Rose<A>] {
		switch self.reduce {
		case let .MkRose(_, children):
			return children()
		default:
			fatalError("Rose should not have reduced to .IORose")
		}
	}
	
	var collapse : Rose<A> {
		let children = self.children
		
		let vs = children.map { $0.collapse }
		let cs = children.flatMap({ $0.children }).map { $0.collapse }
		
		return .MkRose({ self.root }, { vs + cs })
	}
}
