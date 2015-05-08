//
//  Rose.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//


public enum Rose<A> {
	case MkRose(() -> A, () -> [Rose<A>])
	case IORose(() -> Rose<A>)
}

extension Rose /*: Functor*/ {
	typealias B = Swift.Any
	typealias FB = Rose<B>

	public func fmap<B>(f : (A -> B)) -> Rose<B> {
		switch self {
			case .MkRose(let root, let children):
				return .MkRose({ f(root()) }, { children().map() { $0.fmap(f) } })
			case .IORose(let rs):
				return .IORose({ rs().fmap(f) })
		}
	}
}

extension Rose /*: Applicative*/ {
	typealias FAB = Rose<A -> B>

	public static func pure(a : A) -> Rose<A> {
		return .MkRose({ a }, { [] })
	}

	public func ap<B>(fn : Rose<A -> B>) -> Rose<B> {
		switch fn {
			case .MkRose(let f, _):
				return self.fmap(f())
			case .IORose(let rs):
				return self.ap(rs()) ///EEWW, EW, EW, EW, EW, EW
		}
	}
}

extension Rose /*: Monad*/ {
	public func bind<B>(fn : A -> Rose<B>) -> Rose<B> {
		return joinRose(self.fmap(fn))
	}
}

public func ioRose(@autoclosure(escaping) x : () -> Rose<TestResult>) -> Rose<TestResult> {
	return .IORose(x)
}

public func liftM<A, R>(f : A -> R)(m1 : Rose<A>) -> Rose<R> {
	return m1.bind { x1 in
		return Rose.pure(f(x1))
	}
}

public func joinRose<A>(rs : Rose<Rose<A>>) -> Rose<A> {
	switch rs {
		case .IORose(var rs):
			return .IORose({ joinRose(rs()) })
		case .MkRose(let bx , let rs):
			switch bx() {
				case .IORose(let rm):
					return .IORose({ joinRose(.MkRose(rm, rs)) })
				case .MkRose(let x, let ts):
					return .MkRose(x, { rs().map(joinRose) + ts() })
			}
			
	}
}

public func reduce(rs : Rose<TestResult>) -> Rose<TestResult> {
	switch rs {
		case .MkRose(_, _):
			return rs
		case .IORose(let m):
			return reduce(m())
	}
}

public func onRose<A>(f : (A -> [Rose<A>] -> Rose<A>))(rs : Rose<A>) -> Rose<A> {
	switch rs {
		case .MkRose(let x, let rs):
			return f(x())(rs())
		case .IORose(let m):
			return .IORose({ onRose(f)(rs: m()) })
	}
}

public func sequence<A>(ms : [Rose<A>]) -> Rose<[A]> {
	return ms.reduce(Rose<[A]>.pure([]), combine: { n, m in
		return m.bind { x in
			return n.bind { xs in
				return Rose<[A]>.pure([x] + xs)
			}
		}
	})
}

public func mapM<A, B>(f: A -> Rose<B>, xs: [A]) -> Rose<[B]> {
	return sequence(xs.map(f))
}
