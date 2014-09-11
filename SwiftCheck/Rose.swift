//
//  Rose.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation
import Swift_Extras

public enum Rose<A> {
	case MkRose(Box<A>, [Rose<A>])
	case IORose(Box<IO<Rose<A>>>)
}

extension Rose : Functor {
	typealias B = Any
	public func fmap<B>(f: (A -> B)) -> Rose<B> {
		switch self {
			case .MkRose(let root, let children):
				return .MkRose(Box(f(root.value)), children.map() { $0.fmap(f) })
			case .IORose(let rs):
				return .IORose(Box(rs.value.fmap() { $0.fmap(f) }))
		}
	}

	public func bind<B>(fn: A -> Rose<B>) -> Rose<B> {
		return join(self.fmap(fn))
	}
}

extension Rose : Applicative {
	public static func pure(a: A) -> Rose<A> {
		return .MkRose(Box(a), [])
	}

	public func ap<B>(fn: Rose<A -> B>) -> Rose<B> {
		switch fn {
		case .MkRose(let f, _):
			return self.fmap(f.value)
		case .IORose(let rs):
			return self.ap(rs.value.unsafePerformIO()) ///EEWW, EW, EW, EW, EW
		}
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
	return .IORose(Box(protectRose(x)))
}

public func liftM<A, R>(f: A -> R)(m1 : Rose<A>) -> Rose<R> {
	return m1 >>= { (let x1) in
		return Rose.pure(f(x1))
	}
}

public func join<A>(rs: Rose<Rose<A>>) -> Rose<A> {
	switch rs {
		case .IORose(var rs):
			return .IORose(Box<IO<Rose<A>>>(rs.value.fmap(join)))
		case .MkRose(let bx , let rs):
			switch bx.value {
				case .IORose(let rm):
					return .IORose(Box(IO.pure(join(.MkRose(Box(rm.value.unsafePerformIO()), rs)))))
				case .MkRose(let x, let ts):
					return .MkRose(x, rs.map(join) ++ ts)
			}
			
	}
}

public func reduce(rs: Rose<TestResult>) -> IO<Rose<TestResult>> {
	switch rs {
		case .MkRose(_, _):
			return IO.pure(rs)
		case .IORose(let m):
			return m.value >>= reduce
	}
}

public func onRose<A>(f: (A -> [Rose<A>] -> Rose<A>))(rs: Rose<A>) -> Rose<A> {
	switch rs {
		case .MkRose(let x, let rs):
			return f(x.value)(rs)
		case .IORose(let m):
			return .IORose(Box(m.value.fmap(onRose(f))))
	}
}

public func protectRose(x: IO<Rose<TestResult>>) -> IO<Rose<TestResult>> {
	return protect(IO.pure(Rose.pure(exception("Exception"))))
}

public func do_<A>(fn: () -> Rose<A>) -> Rose<A> {
	return fn()
}

public func sequence<A>(ms : [Rose<A>]) -> Rose<[A]> {
	let sequenceF : Rose<A> -> Rose<[A]> -> Rose<[A]> = { (m: Rose<A>) in
		return { (n: Rose<[A]>) in
			return m >>= { (let x) in
				return n >>= { (let xs) in
					var arr = xs
					arr.insert(x, atIndex: 0)
					return Rose<[A]>.pure(arr)
				}
			}
		}
	}
	return foldr(sequenceF)(z: Rose<[A]>.pure([]))(lst: ms)
}

public func mapM<A, B>(f: A -> Rose<B>, xs: [A]) -> Rose<[B]> {
	return sequence(xs.map(f))
}
