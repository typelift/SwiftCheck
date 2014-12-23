//
//  Rose.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Basis

public enum Rose<A> {
	case MkRose(Box<A>, [Rose<A>])
	case IORose(IO<Rose<A>>)
}

extension Rose : Functor {
	typealias B = Swift.Any
	public static func fmap<B>(f : (A -> B)) -> Rose<A> -> Rose<B> {
		return {
			switch $0 {
				case .MkRose(let root, let children):
					return .MkRose(Box(f(root.unBox())), children.map() { Rose.fmap(f)($0) })
				case .IORose(let rs):
					return .IORose(IO.fmap({ Rose.fmap(f)($0) })(rs))
			}
		}
	}
}

public func <%><A, B>(f: A -> B, rs : Rose<A>) -> Rose<B> {
	return Rose.fmap(f)(rs)
}

public func <%<A, B>(x : A, rs : Rose<B>) -> Rose<A> {
	return Rose.fmap(const(x))(rs)
}

extension Rose : Applicative {
	public static func pure(a: A) -> Rose<A> {
		return .MkRose(Box(a), [])
	}

	public func ap<B>(fn: Rose<A -> B>) -> Rose<B> {
		switch fn {
			case .MkRose(let f, _):
				return Rose.fmap(f.unBox())(self)
			case .IORose(let rs):
				return self.ap(!rs) ///EEWW, EW, EW, EW, EW, EW
		}
	}
}

public func <*><A, B>(a : Rose<A -> B> , l : Rose<A>) -> Rose<B> {
	return l.ap(a)
}

public func *><A, B>(a : Rose<A>, b : Rose<B>) -> Rose<B> {
	return const(id) <%> a <*> b
}

public func <*<A, B>(a : Rose<A>, b : Rose<B>) -> Rose<A> {
	return const <%> a <*> b
}

extension Rose : Monad {
	public func bind<B>(fn: A -> Rose<B>) -> Rose<B> {
		return joinRose(Rose.fmap(fn)(self))
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

public func ioRose(x: IO<Rose<TestResult>>) -> Rose<TestResult> {
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
			return .IORose(IO.fmap(joinRose)(rs))
		case .MkRose(let bx , let rs):
			switch bx.unBox() {
				case .IORose(let rm):
					return .IORose(IO.pure(joinRose(.MkRose(Box(!rm), rs))))
				case .MkRose(let x, let ts):
					return .MkRose(x, rs.map(joinRose) + ts)
			}
			
	}
}

public func reduce(rs: Rose<TestResult>) -> IO<Rose<TestResult>> {
	switch rs {
		case .MkRose(_, _):
			return IO.pure(rs)
		case .IORose(let m):
			return m >>- reduce
	}
}

public func onRose<A>(f: (A -> [Rose<A>] -> Rose<A>))(rs: Rose<A>) -> Rose<A> {
	switch rs {
		case .MkRose(let x, let rs):
			return f(x.unBox())(rs)
		case .IORose(let m):
			return .IORose(IO.fmap(onRose(f))(m))
	}
}

public func protectRose(x: IO<Rose<TestResult>>) -> IO<Rose<TestResult>> {
	return protect(Rose.pure • exception("Exception"))(x)
}

public func do_<A>(fn: () -> Rose<A>) -> Rose<A> {
	return fn()
}

public func sequence<A>(ms : [Rose<A>]) -> Rose<[A]> {
	let sequenceF : Rose<A> -> Rose<[A]> -> Rose<[A]> = { (m: Rose<A>) in
		return { (n: Rose<[A]>) in
			return m >>- { x in
				return n >>- { xs in
					var arr = xs
					arr.insert(x, atIndex: 0)
					return Rose<[A]>.pure(arr)
				}
			}
		}
	}
	return foldr(sequenceF)(Rose<[A]>.pure([]))(ms)
}

public func mapM<A, B>(f: A -> Rose<B>, xs: [A]) -> Rose<[B]> {
	return sequence(xs.map(f))
}
