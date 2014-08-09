//
//  Rose.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public enum Rose<A> {
	case MkRose(A, [Rose<A>])
	case IORose(IO<Rose<A>>)
}

extension Rose : Functor {
	typealias B = Any
	public func fmap<B>(f: (A -> B)) -> Rose<B> {
		switch self {
			case .MkRose(let root, let children):
				return Rose<B>.MkRose(f(root), children.map() { $0.fmap(f) })
			case .IORose(var rs):
				return Rose<B>.IORose(rs.fmap() { $0.fmap(f) })
		}
	}
}

extension Rose : Applicative {
	public static func pure(a: A) -> Rose<A> {
		return Rose.MkRose(a, [])
	}

	public func ap<B>(fn: Rose<A -> B>) -> Rose<B> {
		switch fn {
		case .MkRose(let f, _):
			return self.fmap(f)
		case .IORose(let rs):
			return self.ap(rs.unsafePerformIO()) ///EEWW, EW, EW, EW, EW
		}
	}
}

extension Rose : Monad {
	public func bind<B>(fn: A -> Rose<B>) -> Rose<B> {
		return join(self.fmap(fn))
	}
}

public func >>=<A, B>(x : Rose<A>, f : A -> Rose<B>) -> Rose<B> {
	return x.bind(f)
}

public func >><A, B>(x : Rose<A>, y : Rose<B>) -> Rose<B> {
	return x.bind({ (_) in
		return y
	})
}

public func ioRose(x: IO<Rose<TestResult>>) -> Rose<TestResult> {
	return Rose.IORose(protectRose(x))
}

public func join<A>(rs: Rose<Rose<A>>) -> Rose<A> {
	switch rs {
		case .IORose(var rs):
			return Rose.IORose(rs.fmap(join))
		case .MkRose(.IORose(let rm) , let rs):
			return Rose.IORose(IO<Rose<A>>.pure(join(Rose.MkRose(rm.unsafePerformIO(), rs))))
		case .MkRose(.MkRose(let x, let ts) , let tts):
			return Rose.MkRose(x, tts.map(join) ++ ts)
	}
}

public func reduce(rs: Rose<TestResult>) -> IO<Rose<TestResult>> {
	switch rs {
		case .MkRose(_, _):
			return IO.pure(rs)
		case .IORose(let m):
			return m >>= reduce
	}
}

public func on<A>(f: (A -> [Rose<A>] -> Rose<A>))(rs: Rose<A>) -> Rose<A> {
	switch rs {
		case .MkRose(let x, let rs):
			return f(x)(rs)
		case .IORose(let m):
			return Rose.IORose(m.fmap(on(f)))
	}
}

public func protectRose(x: IO<Rose<TestResult>>) -> IO<Rose<TestResult>> {
	return protect(IO<Rose<TestResult>>.pure(Rose<TestResult>.pure(exception("Exception"))))
}
