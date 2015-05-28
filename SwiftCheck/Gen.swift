//
//  Gen.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
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

	/// TODO: File Radar; These must be in here or we get linker errors.

	/// Shakes up the internal Random Number generator for a given Generator with a seed.
	public func variant<S : IntegerType>(seed: S) -> Gen<A> {
		return Gen(unGen: { r in
			return { n in
				return self.unGen(vary(seed)(r: r))(n)
			}
		})
	}

	/// Constructs a generator that always uses a given size.
	public func resize(n : Int) -> Gen<A> {
		return Gen(unGen: { r in
			return { (_) in
				return self.unGen(r)(n)
			}
		})
	}

	/// Constructs a Generator that only returns values that satisfy a predicate.
	public func suchThat(p : (A -> Bool)) -> Gen<A> {
		return self.suchThatOptional(p).bind { mx in
			switch mx {
			case .Some(let x):
				return Gen.pure(x)
			case .None:
				return Gen.sized { n in
					return self.suchThat(p).resize(n + 1)
				}
			}
		}
	}

	/// Constructs a Generator that attempts to generate a values that satisfy a predicate.
	///
	/// Passing values are wrapped in `.Some`.  Failing values are `.None`.
	public func suchThatOptional(p : A -> Bool) -> Gen<Optional<A>> {
		return Gen<Optional<A>>.sized({ n in
			return try(self, 0, max(n, 1), p)
		})
	}

	/// Generates a list of random length.
	public func listOf() -> Gen<[A]> {
		return Gen<[A]>.sized({ n in
			return Gen.choose((0, n)).bind { k in
				return self.vectorOf(k)
			}
		})
	}

	/// Generates a non-empty list of random length.
	public func listOf1() -> Gen<[A]> {
		return Gen<[A]>.sized({ n in
			return Gen.choose((1, max(1, n))).bind { k in
				return self.vectorOf(k)
			}
		})
	}

	/// Generates a list of a given length.
	public func vectorOf(k : Int) -> Gen<[A]> {
		return sequence(Array<Gen<A>>(count: k, repeatedValue: self))
	}

	/// Selects a random value from a list and constructs a Generator that returns only that value.
	public static func elements(xs : [A]) -> Gen<A> {
		assert(xs.count != 0, "elements used with empty list")

		return choose((0, xs.count - 1)).fmap { i in
			return xs[i]
		}
	}

	/// Takes a list of elements of increasing size, and chooses among an initial segment of the list.
	/// The size of this initial segment increases with the size parameter.
	public static func growingElements(xs : [A]) -> Gen<A> {
		assert(xs.count != 0, "growingElements used with empty list")

		let k = Double(xs.count)
		return sized({ n in
			let m = max(1, size(k)(m: n))
			return Gen.elements(Array(xs[0 ..< m]))
		})
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

/// Promotes a function returning generators to a generator of functions.
public func promote<A, B>(m : A -> Gen<B>) -> Gen<A -> B> {
	return delay().bind { (let eval : Gen<B> -> B) in
		return Gen<A -> B>.pure({ x in eval(m(x)) })
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

/// Implementation Details Follow

private func vary<S : IntegerType>(k : S)(r: StdGen) -> StdGen {
	let s = r.split()
	var gen = ((k % 2) == 0) ? s.0 : s.1
	return (k == (k / 2)) ? gen : vary(k / 2)(r: r)
}

private func try<A>(gen: Gen<A>, k: Int, n : Int, p: A -> Bool) -> Gen<Optional<A>> {
	if n == 0 {
		return Gen.pure(.None)
	}
	return gen.resize(2 * k + n).bind { (let x : A) -> Gen<Optional<A>> in
		if p(x) {
			return Gen.pure(.Some(x))
		}
		return try(gen, k + 1, n - 1, p)
	}
}

private func size(k : Double)(m : Int) -> Int {
	let n = Double(m)
	return Int((log(n + 1)) * k / log(100))
}
