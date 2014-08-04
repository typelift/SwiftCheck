//
//  Either.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public enum Either<A, B> {
	case Left(A)
	case Right(B)
}


extension Either : Functor {
	public func fmap<C>(f: (B -> C)) -> Either<A, C> {
		switch self {
			case .Left(let x):
				return .Left(x)
			case .Right(let y):
				return .Right(f(y))
		}
	}
}

extension Either : Applicative {
	public static func pure(a: A) -> Either<A, B> {
		return .Right(a)
	}

	public func ap<C>(fn: Either<A, B -> C>) -> Either<A, C> {
		switch self {
			case .Left(let x):
				return .Left(x)
			case .Right(let y):
				switch fn {
					case .Left(let x):
						return .Left(x)
					case .Right(let f):
						return .Right(f(y))
				}
		}
	}
}

extension Either : Monad {
	public func bind<C>(fn: B -> Either<A, C>) -> Either<A, C> {
		switch self {
			case .Left(let x):
				return .Left(x)
			case .Right(let y):
				return fn(y)
		}
	}
}
