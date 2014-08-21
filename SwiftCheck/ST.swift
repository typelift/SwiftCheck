//
//  ST.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/2/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public struct ST<S, A> {
	private var apply:(s: World<RealWorld>) -> (World<RealWorld>, A)

    public init(apply:(s: World<RealWorld>) -> (World<RealWorld>, A)) {
        self.apply = apply
    }

	public func runST() -> A {
		let (_, x) = self.apply(s: realWorld)
		return x
	}

    public static func pure<S, A>(a: A) -> ST<S, A> {
		return ST<S, A>(apply: { (let s) in
			return (s, a)
		})
	}

	public func ap(fn: ST<S, A -> B>) -> ST<S, B> {
		return ST<S, B>(apply: { (let s) in
			let (nw, f) = fn.apply(s: s)
			return (nw, f(self.runST()))
		})
	}
}

extension ST : Functor {
	typealias B = S
	public func fmap<B>(f: (A -> B)) -> ST<S, B> {
		return ST<S, B>(apply: { (let s) in
			let (nw, x) = self.apply(s: s)
			return (nw, f(x))
		})
	}
}
