//
//  Gen.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public struct Gen<A> {
	var unGen: StdGen -> Int -> A
}

extension Gen : Functor {
	typealias B = Any
	public func fmap<B>(f: (A -> B)) -> Gen<B> {
		return Gen<B>(unGen: { (let r) in
			return { (let n) in
				return f(self.unGen(r)(n))
			}
		})
	}
}

extension Gen : Applicative {
	public static func pure(a: A) -> Gen<A> {
		return Gen<A>(unGen: { (_) in
			return { (_) in
				return a
			}
		})
	}

	public func ap<B>(fn: Gen<A -> B>) -> Gen<B> {
		return Gen<B>(unGen: { (let r) in
			return { (let n) in
				return fn.unGen(r)(n)(self.unGen(r)(n))
			}
		})
	}
}

extension Gen : Monad {
	public func bind<B>(fn: A -> Gen<B>) -> Gen<B> {
		return Gen<B>(unGen: { (let r) in
			return { (let n) in
				let (r1, r2) = r.split()
				let m = fn(self.unGen(r1)(n))
				return m.unGen(r2)(n)
			}
		})
	}
}

public func sequence<A>(ms: [Gen<A>]) -> Gen<[A]> {
	return foldr({ (let x) in
		return { (let y) in
			return x >>= { (let x) in
				return y >>= { (let xs) in
					return Gen<[A]>.pure(x +> xs)
				}
			}
		}
	})(z: Gen<[A]>.pure([]))(lst: ms)
}

@infix public func >>=<A, B>(x : Gen<A>, f : A -> Gen<B>) -> Gen<B> {
	return x.bind(f)
}

@infix public func >><A, B>(x : Gen<A>, y : Gen<B>) -> Gen<B> {
	return x.bind({ (_) in
		return y
	})
}

public func join<A>(rs: Gen<Gen<A>>) -> Gen<A> {
	return rs >>= { (let x) in
		return x
	}
}

public func liftM<A, R>(f: A -> R)(m1 : Gen<A>) -> Gen<R> {
	return m1 >>= { (let x1) in
		return Gen.pure(f(x1))
	}
}





