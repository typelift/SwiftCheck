//
//  Fun.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/14/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

internal class FunProxy<A : protocol<Arbitrary, CoArbitrary>, B, C : Arbitrary> { }

internal class Pair<A, B, C> : FunProxy<A, B, C> {
	typealias FunType = Fun<(A, B), C>

	let p : Fun<A, Fun<B, C>>
	internal init(p : Fun<A, Fun<B, C>>) {
		self.p = p
	}
}

internal class Sum<A, B, C> : FunProxy<A, B, C> {
	typealias FunType = Fun<Either<A, B>, C>

	let p : Fun<A, C>
	let q : Fun<B, C>

	internal init(p : Fun<A, C>, q : Fun<B, C>) {
		self.p = p
		self.q = q
	}
}


internal class Unit<A, B, C> : FunProxy<A, B, C> {
	typealias FunType = Fun<(), C>

	let c : C

	internal init(c : C) {
		self.c = c
	}
}

internal class Nil<A, B, C> : FunProxy<A, B, C> {
	typealias FunType = Fun<A, C>

	let a : A

	internal init(a : A) {
		self.a = a
	}
}

internal class Table<A : Equatable, B, C> : FunProxy<A, B, C> {
	typealias FunType = Fun<A, C>

	let tbl : [(A, C)]

	internal init(tbl : [(A, C)]) {
		self.tbl = tbl
	}
}

internal class Map<A, B, C> : FunProxy<A, B, C> {
	typealias FunType = Fun<A, C>

	let g : A -> B
	let h : B -> A
	let p : Fun<B, C>

	internal init(g : A -> B, h : B -> A, p : Fun<B, C>) {
		self.g = g
		self.h = h
		self.p = p
	}
}

struct Fun<A : protocol<Arbitrary, CoArbitrary>, C : Arbitrary> {
	let p : FunProxy<A, Any, C>


	internal init(r : FunProxy<A, Any, C>) {
		self.p = r
	}

}

extension Fun : Arbitrary {
	internal static func arbitrary() -> Gen<Fun<A, C>> {

	}
}

extension Fun /*: Functor*/ {
	typealias B = Swift.Any


}

/// Generates a Swift function from T to U.
public struct ArrowOf<T : protocol<Arbitrary, CoArbitrary>, U : Arbitrary> : Arbitrary, Printable {
	public let getArrow : T -> U
	private let getFun : (Fun<T, U>, U)

	private init(_ p : Fun<T, U>, _ d : U) {
		self.init((p, d), abstract(p, d))
	}

	private init(_ fun : (Fun<T, U>, U), _ arr : (T -> U)) {
		self.getArrow = arr
		self.getFun = fun
	}

	public var description : String {
		return "\(self.getArrow)"
	}

	public static func arbitrary() -> Gen<ArrowOf<T, U>> {
		return Fun<T, U>.arbitrary().bind { p in
			return U.arbitrary().bind { d in
				return ArrowOf(p, d)
			}
		}
	}

	public static func shrink(bl : ArrowOf<T, U>) -> [ArrowOf<T, U>] {
		return []
	}
}
