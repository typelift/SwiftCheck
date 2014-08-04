//
//  Array.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

operator infix ++ { associativity left }
operator infix +> { associativity left }


@infix func +><T>(lhs : T, rhs : [T]) -> [T] {
	var arr = rhs
	arr.insert(lhs, atIndex: 0)
	return arr
}

@infix func ++<T>(var lhs : [T], rhs : [T]) -> [T] {
	lhs += rhs
	return lhs
}

public func foldl<A, B>(f: B -> A -> B) (z0: B)(xs0: [A]) -> B {
	func lgo(z: B)(xs: [A]) -> B {
		if xs.count == 0 {
			return z
		}
		let hd = xs[0]
		let tl = Array<A>(xs[1..<xs.count])
		return lgo(f(z)(hd))(xs: tl)
	}
	return lgo(z0)(xs: xs0)
}

public func foldl1<A>(f: A -> A -> A)(xs0: [A]) -> A {
	let hd = xs0[0]
	let tl = Array<A>(xs0[1..<xs0.count])
	return foldl(f)(z0: hd)(xs0: tl)
}

public func foldr<A, B>(k: (A -> B -> B))(z: B)(lst: [A]) -> B {
	func go(xs: [A]) -> B {
		if xs.count == 0 {
			return z
		}
		let hd = lst[0]
		let tl = Array<A>(lst[1..<xs.count])
		return k(hd)(go(tl))
	}
	return go(lst)
}

public func take<A>(n: Int)(xs: [A]) -> [A] {
	if n <= 0 {
		return []
	}
	if xs.count == 0 {
		return []
	}

	let hd = xs[0]
	let tl = Array<A>(xs[1..<xs.count])
	return hd +> take(n - 1)(xs: xs)
}

public func sum(n: [Int]) -> Int {
	return foldl1({ $0 + $1 })(n)
}

public func sum(n: [UInt]) -> UInt {
	return foldl1({ $0 + $1 })(n)
}


func quicksort<T : Comparable>(l : [T]) -> [T] {
	if l.count == 0 { return [] }
	let p = l[0]
	let xs = Array<T>(l[1..<l.count])
	return quicksort(xs.filter { $0 < p }) ++ [p] ++ quicksort(xs.filter { $0 >= p })
}