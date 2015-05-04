//
//  Gen.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

/// A generator for values of type A.
public struct Gen<A> {
	let unGen : StdGen -> Int -> A

	/// Generates a value.
	///
	/// This method exists as a convenience mostly to test generators.  It will always generate with
	/// size 30.
	public var generate : A {
		let r = newStdGen()
		return unGen(r)(30)
	}
}

extension Gen /*: Functor*/ {
	typealias B = Swift.Any

	/// Returns a new generator that applies a given function to any outputs the receiver creates.
	public func fmap<B>(f : (A -> B)) -> Gen<B> {
		return Gen<B>(unGen: { r in
			return { n in
				return f(self.unGen(r)(n))
			}
		}) 
	}
}

extension Gen /*: Applicative*/ {
	typealias FAB = Gen<A -> B>

	/// Lifts a value into a generator that will only generate that value.
	public static func pure(a : A) -> Gen<A> {
		return Gen(unGen: { (_) in
			return { (_) in
				return a
			}
		})
	}

	/// Given a generator of functions, applies any generated function to any outputs the receiver
	/// creates.
	public func ap<B>(fn : Gen<A -> B>) -> Gen<B> {
		return Gen<B>(unGen: { r in
			return { n in
				return fn.unGen(r)(n)(self.unGen(r)(n))
			}
		})
	}
}

extension Gen /*: Monad*/ {
	/// Applies the function to any generated values to yield a new generator.  This generator is
	/// then given a new random seed and returned.
	public func bind<B>(fn : A -> Gen<B>) -> Gen<B> {
		return Gen<B>(unGen: { r in
			return { n in
				let (r1, r2) = r.split()
				let m = fn(self.unGen(r1)(n))
				return m.unGen(r2)(n)
			}
		})
	}
}

/// Reduces an array of generators to a generator that returns arrays of the original generators
/// values in the order given.
public func sequence<A>(ms : [Gen<A>]) -> Gen<[A]> {
	return ms.reduce(Gen<[A]>.pure([]), combine: { y, x in
		return x.bind { x1 in
			return y.bind { xs in
				return Gen<[A]>.pure([x1] + xs)
			}
		}
	})
}

/// Flattens a generator of generators by one level.
public func join<A>(rs : Gen<Gen<A>>) -> Gen<A> {
	return rs.bind { x in
		return x
	}
}

/// Lifts a function from some A to some R to a function from generators of A to generators of R.
public func liftM<A, R>(f : A -> R)(m1 : Gen<A>) -> Gen<R> {
	return m1.bind{ x1 in
		return Gen.pure(f(x1))
	}
}


/// Promotes a rose of generators to a generator of rose values.
public func promote<A>(x : Rose<Gen<A>>) -> Gen<Rose<A>> {
	return delay().bind { (let eval : Gen<A> -> A) in
		return Gen<Rose<A>>.pure(liftM(eval)(m1: x))
	}
}

internal func delay<A>() -> Gen<Gen<A> -> A> {
	return Gen(unGen: { r in
		return { n in
			return { g in
				return g.unGen(r)(n)
			}
		}
	})
}
