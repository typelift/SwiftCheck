//
//  ST.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/2/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

struct ST<S, A> {
	private var apply:(s: World<RealWorld>) -> (World<RealWorld>, A)

	func runST() -> A {
		let (_, x) = self.apply(s: realWorld)
		return x
	}
}

extension ST : Functor {
	typealias B = S
	func fmap<B>(f: (A -> B)) -> ST<S, B> {
		return ST<S, B>(apply: { (let s) in
			let (nw, x) = self.apply(s: s)
			return (nw, f(x))
		})
	}
}

extension ST : Applicative {
	static func pure<S, A>(a: A) -> ST<S, A>{
		return ST<S, A>(apply: { (let s) in
			return (s, a)
		})
	}

	func ap(fn: ST<S, A -> B>) -> ST<S, B> {
		return ST<S, B>(apply: { (let s) in
			let (nw, f) = fn.apply(s: s)
			return (nw, f(self.runST()))
		})
	}
}

struct STRef<S, A> {
	private var value: A

	init(a: A) {
		self.value = a
	}

	func readSTRef() -> ST<S, A> {
		return .pure(self.value)
	}

	mutating func writeSTRef(a: A) -> ST<S, STRef<S, A>> {
		return ST(apply: { (let s) in
			self.value = a
			return (s, self)
		})
	}

	mutating func modifySTRef(f: A -> A) -> ST<S, STRef<S, A>> {
		return ST(apply: { (let s) in
			self.value = f(self.value)
			return (s, self)
		})
	}
}

