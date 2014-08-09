//
//  Maybe.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public enum Maybe<A> {
	case Nothing
	case Just(A)
}

extension Maybe : Functor {
	typealias B = Any
	public func fmap<B>(f: (A -> B)) -> Maybe<B> {
		switch self {
			case .Nothing:
				return .Nothing
			case .Just(let a):
				return .Just(f(a))
		}
	}
}

extension Maybe : Applicative {
	public static func pure(a: A) -> Maybe<A> {
		return Maybe.Just(a)
	}

	public func ap<B>(fn: Maybe<A -> B>) -> Maybe<B> {
		switch fn {
			case .Nothing:
				return .Nothing
			case .Just(let f):
				return self.fmap(f)
		}
	}
}

extension Maybe : Monad {
	public func bind<B>(fn: A -> Maybe<B>) -> Maybe<B> {
		switch self {
			case .Nothing:
				return .Nothing
			case .Just(let x):
				return fn(x)
		}
	}
}

public func >>=<A, B>(x : Maybe<A>, f : A -> Maybe<B>) -> Maybe<B> {
	return x.bind(f)
}

public func >><A, B>(x : Maybe<A>, y : Maybe<B>) -> Maybe<B> {
	return x.bind({ (_) in
		return y
	})
}

public func join<A>(rs: Maybe<Maybe<A>>) -> Maybe<A> {
	switch rs {
		case .Nothing:
			return .Nothing
		case .Just(let x):
			return x
	}
}
