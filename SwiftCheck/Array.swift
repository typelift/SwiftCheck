//
//  Array.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

infix operator ++ { associativity left }
infix operator +> { associativity left }

public enum Destructure<A> {
	case Empty()
	case Destructure(A, [A])
}

func +><T>(lhs : T, rhs : [T]) -> [T] {
	var arr = rhs
	arr.insert(lhs, atIndex: 0)
	return arr
}

func ++<T>(var lhs : [T], rhs : [T]) -> [T] {
	lhs += rhs
	return lhs
}

public func foldl<A, B>(f: B -> A -> B) (z0: B)(xs0: [A]) -> B {
	var xs = z0
	for x in xs0 {
		xs = f(xs)(x)
	}
	return xs
}

public func foldl1<A>(f: A -> A -> A)(xs0: [A]) -> A {
	let hd = xs0[0]
	let tl = Array<A>(xs0[1..<xs0.count])
	return foldl(f)(z0: hd)(xs0: tl)
}

public func foldr<A, B>(k: (A -> B -> B))(z: B)(lst: [A]) -> B {
	var xs = z
	for x in lst.reverse() {
		xs = k(x)(z)
	}
	return xs
}

public func foldr1<A>(f: (A -> A -> A))(lst: [A]) -> A {
	switch destructure(lst) {
		case .Destructure(let x, let xs) where xs.count == 0:
			return x
		case .Destructure(let x, let xs):
			return f(x)(foldr1(f)(lst: xs))
		case .Empty():
			assert(false, "Cannot invoke foldr1 with an empty list.")
	}
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

public func drop<A>(n : Int)(lst : [A]) -> [A] {
	if n <= 0 {
		return lst
	}
	switch destructure(lst) {
	case .Empty():
		return []
	case .Destructure(_, let xs):
		return drop(n - 1)(lst: xs)
	}
}

public func sum(n: [Int]) -> Int {
	return foldl1({ (let r) in
		return { (let l) in
			return l + r
		}
	})(xs0: n)
}

public func sum(n: [UInt]) -> UInt {
	return foldl1({ (let r) in
		return { (let l) in
			return l + r
		}
	})(xs0: n)
}

public func concat<A>(xss : [[A]]) -> [A] {
	return foldr({ (let l) in
		return { (let r) in
			return l ++ r
		}
	})(z: [])(lst: xss)
}

public func concatMap<A, B>(f : A -> [B]) -> [A] -> [B] {
	return { (let xs) in
		return foldr({ (let x) in
			return { (let y) in
				return f(x) ++ y
			}
		})(z: [])(lst: xs)
	}
}

public func takeWhile<A>(p : A -> Bool) -> [A] -> [A] {
	return { (let lst) in
		switch destructure(lst) {
			case .Empty():
				return []
			case .Destructure(let x, let xs):
				if p(x) {
					return x +> takeWhile(p)(xs)
				}
				return []
		}
	}
}

public func iterate<A>(f : A -> A) -> A -> [A] {
	return { (let x) in
		return x +> iterate(f)(f(x))
	}
}

public func destructure<A>(x : [A]) -> Destructure<A> {
	if x.count == 0 {
		return .Empty()
	} else if x.count == 1 {
		return .Destructure(x[0], [])
	}
	let hd = x[0]
	let tl = Array<A>(x[1..<x.count])
	return .Destructure(hd, tl)
}

func quicksort<T : Comparable>(l : [T]) -> [T] {
	if l.count == 0 { return [] }
	let p = l[0]
	let xs = Array<T>(l[1..<l.count])
	return quicksort(xs.filter { $0 < p }) ++ [p] ++ quicksort(xs.filter { $0 >= p })
}

public func >>=<A, B>(xs : [A], f : A -> [B]) -> [B] {
	return concatMap(f)(xs)
}

public func >><A, B>(x : [A], y : [B]) -> [B] {
	return x >>= { (_) in
		return y
	}
}
