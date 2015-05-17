//
//  Fun.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/14/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

internal class FunProxy<A, B, C> { }

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

struct Fun<A, C> {
	let p : FunProxy<A, Any, C>


	internal init(r : FunProxy<A, Any, C>) {
		self.p = r
	}

}

extension Fun /*: Functor*/ {
	typealias B = Swift.Any


}

/// Generates a Swift function from T to U.
public struct ArrowOf<T : CoArbitrary, U : Arbitrary> : Arbitrary, Printable {
	public let getArrow : T -> U

	public init(_ arr : (T -> U)) {
		self.getArrow = arr
	}

	public var description : String {
		return "\(self.getArrow)"
	}

	private static func create(arr : (T -> U)) -> ArrowOf<T, U> {
		return ArrowOf(arr)
	}

	public static func arbitrary() -> Gen<ArrowOf<T, U>> {
		return promote({ T.coarbitrary($0)(U.arbitrary()) }).fmap { ArrowOf($0) }
	}

	public static func shrink(bl : ArrowOf<T, U>) -> [ArrowOf<T, U>] {
		return []
	}
}
