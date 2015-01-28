//
//  Rose.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Swiftz

public enum Rose<A> {
	case MkRose(Box<A>, @autoclosure() -> [Rose<A>])
	case IORose(@autoclosure() -> Rose<A>)
}

extension Rose : Functor {
	typealias B = Swift.Any
	typealias FB = Rose<B>

	public func fmap<B>(f : (A -> B)) -> Rose<B> {
		switch self {
			case .MkRose(let root, let children):
				return .MkRose(Box(f(root.value)), children().map() { $0.fmap(f) })
			case .IORose(let rs):
				return .IORose(rs().fmap(f))
		}
	}
}

public func <^><A, B>(f: A -> B, ar : Rose<A>) -> Rose<B> {
	return ar.fmap(f)
}


extension Rose : Applicative {
	typealias FAB = Rose<A -> B>

	public static func pure(a : A) -> Rose<A> {
		return .MkRose(Box(a), [])
	}

	public func ap<B>(fn : Rose<A -> B>) -> Rose<B> {
		switch fn {
			case .MkRose(let f, _):
				return self.fmap(f.value)
			case .IORose(let rs):
				return self.ap(rs()) ///EEWW, EW, EW, EW, EW, EW
		}
	}
}

public func <*><A, B>(a : Rose<A -> B> , l : Rose<A>) -> Rose<B> {
	return l.ap(a)
}

extension Rose : Monad {
	public func bind<B>(fn: A -> Rose<B>) -> Rose<B> {
		return joinRose(self.fmap(fn))
	}
}

public func >>-<A, B>(x : Rose<A>, f : A -> Rose<B>) -> Rose<B> {
	return x.bind(f)
}

public func >><A, B>(x : Rose<A>, y : Rose<B>) -> Rose<B> {
	return x.bind({ (_) in
		return y
	})
}

public func ioRose(x: @autoclosure() -> Rose<TestResult>) -> Rose<TestResult> {
	return .IORose(protectRose(x))
}

public func liftM<A, R>(f: A -> R)(m1 : Rose<A>) -> Rose<R> {
	return m1 >>- { x1 in
		return Rose.pure(f(x1))
	}
}

public func joinRose<A>(rs: Rose<Rose<A>>) -> Rose<A> {
	switch rs {
		case .IORose(var rs):
			return .IORose(joinRose(rs()))
		case .MkRose(let bx , let rs):
			switch bx.value {
				case .IORose(let rm):
					return .IORose(joinRose(.MkRose(Box(rm()), rs)))
				case .MkRose(let x, let ts):
					return .MkRose(x, rs().map(joinRose) + ts())
			}
			
	}
}

public func reduce(rs: Rose<TestResult>) -> Rose<TestResult> {
	switch rs {
		case .MkRose(_, _):
			return rs
		case .IORose(let m):
			return reduce(m())
	}
}

public func onRose<A>(f: (A -> [Rose<A>] -> Rose<A>))(rs: Rose<A>) -> Rose<A> {
	switch rs {
		case .MkRose(let x, let rs):
			return f(x.value)(rs())
		case .IORose(let m):
			return .IORose(onRose(f)(rs: m()))
	}
}

public func protectRose(x: @autoclosure () -> Rose<TestResult>) -> Rose<TestResult> {
	return protect(Rose.pure • exception("Exception"))(x())
}

public func do_<A>(fn: () -> Rose<A>) -> Rose<A> {
	return fn()
}

public func sequence<A>(ms : [Rose<A>]) -> Rose<[A]> {
	return ms.reduce(Rose<[A]>.pure([]), combine: { n, m in
		return m >>- { x in
			return n >>- { xs in
				return Rose<[A]>.pure([x] + xs)
			}
		}
	})
}

public func mapM<A, B>(f: A -> Rose<B>, xs: [A]) -> Rose<[B]> {
	return sequence(xs.map(f))
}
