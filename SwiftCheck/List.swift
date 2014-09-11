//
//  List.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 9/10/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

infix operator ++ { associativity left }
infix operator +> { associativity left }

func +><T>(lhs : T, rhs : [T]) -> [T] {
	var arr = rhs
	arr.insert(lhs, atIndex: 0)
	return arr
}

func ++<T>(var lhs : [T], rhs : [T]) -> [T] {
	lhs += rhs
	return lhs
}

public func tail<A>(lst : [A]) -> [A] {
	switch lst.destruct() {
		case .Destructure(_, let xs):
			return xs
		case .Empty():
			assert(false, "Cannot take the tail of an empty list.")
	}
}

public func nub<A : Equatable>(xs : [A]) -> [A] {
	return nubBy({ (let x) in
		return { (let y) in
			return x == y
		}
	})(xs)
}

public func nubBy<A>(eq : A -> A -> Bool) -> [A] -> [A] {
	return { (let lst) in
		switch lst.destruct() {
			case .Empty():
				return []
			case .Destructure(let x, let xs):
				return [x] + nubBy(eq)(xs.filter({ (let y) in
					return !(eq(x)(y))
				}))
		}
	}
}

public func iterate<A>(f : A -> A) -> A -> [A] {
	return { (let x) in
		return [x] + iterate(f)(f(x))
	}
}
