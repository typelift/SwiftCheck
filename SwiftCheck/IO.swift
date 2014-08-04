//
//  IO.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public struct World<A> {}
public protocol RealWorld {}

public let realWorld = World<RealWorld>()

public struct IO<A> {
	var apply: (rw: World<RealWorld>) -> (World<RealWorld>, A)

	func unsafePerformIO() -> A  {
		return self.apply(rw: realWorld).1
	}

	public func flatMap<B>(f: A -> IO<B>) -> IO<B> {
		return IO<B>(apply: { (let rw) in
			let (nw, a) = self.apply(rw: rw)
			return f(a).apply(rw: nw)
		})
	}

	public func map<B>(f : A -> B) -> IO<B> {
		return IO<B>(apply: { (let rw) in
			let (nw, a) = self.apply(rw: rw)
			return (nw, f(a))
		})
	}
}


extension IO : Functor {
	typealias B = Any
	public func fmap<B>(f: (A -> B)) -> IO<B> {
		return self.map(f)
	}
}

extension IO : Applicative {
	public static func pure(a: A) -> IO<A> {
		return IO<A>({ (let rw) in
			return (rw, a)
		})
	}

	public func ap<B>(fn: IO<A -> B>) -> IO<B> {
		return IO<B>(apply: { (let rw) in
			let f = fn.unsafePerformIO()
			let (nw, x) = self.apply(rw: rw)
			return (nw, f(x))
		})
	}
}

extension IO : Monad {
	public func bind<B>(fn: A -> IO<B>) -> IO<B> {
		return self.flatMap(fn)
	}
}

@infix public func >>=<A, B>(x : IO<A>, f : A -> IO<B>) -> IO<B> {
	return x.bind(f)
}

@infix public func >><A, B>(x : IO<A>, y : IO<B>) -> IO<B> {
	return x.bind({ (_) in
		return y
	})
}
//
//@prefix public func <-<A, B>(x : IO<A>) -> A{
//	return x.unsafePerformIO()
//}