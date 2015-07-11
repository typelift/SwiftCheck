//
//  Gen.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// A generator for values of type A.
///
/// `Gen` wraps a function that, when given a random number generator and a size, can be used to
/// control the distribution of resultant values.  A generator relies on its size to help control
/// aspects like the length of generated arrays and the magnitude of integral values.
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

	public static func zip<A, B>(gen1 : Gen<A>, _ gen2 : Gen<B>) -> Gen<(A, B)> {
		return gen1.bind { l in
			return gen2.bind { r in
				return Gen<(A, B)>.pure((l, r))
			}
		}
	}

	/// Constructs a Generator that selects a random value from the given list and produces only 
	/// that value.
	///
	/// The input array is required to be non-empty.
	public static func fromElementsOf(xs : [A]) -> Gen<A> {
		assert(xs.count != 0, "Gen.fromElementsOf used with empty list")

		return choose((0, xs.count - 1)).fmap { i in
			return xs[i]
		}
	}

	/// Constructs a Generator that uses a given array to produce smaller arrays composed of its 
	/// initial segments.  The size of each initial segment increases with the receiver's size 
	/// parameter.
	///
	/// The input array is required to be non-empty.
	public static func fromInitialSegmentsOf(xs : [A]) -> Gen<A> {
		assert(xs.count != 0, "Gen.fromInitialSegmentsOf used with empty list")

		let k = Double(xs.count)
		return sized({ n in
			let m = max(1, size(k)(m: n))
			return Gen.fromElementsOf(Array(xs[0 ..< m]))
		})
	}

	/// Constructs a Generator that produces permutations of a given array.
	public static func fromShufflingElementsOf(xs : [A]) -> Gen<[A]> {
		if xs.isEmpty {
			return Gen<[A]>.pure([])
		}

		return Gen<(A, [A])>.fromElementsOf(selectOne(xs)).bind { (y, ys) in
			return Gen.fromShufflingElementsOf(ys).fmap { [y] + $0 }
		}
	}

	/// Constructs a generator that depends on a size parameter.
	public static func sized(f : Int -> Gen<A>) -> Gen<A> {
		return Gen(unGen:{ r in
			return { n in
				return f(n).unGen(r)(n)
			}
		})
	}

	/// Constructs a random element in the range of two `RandomType`s.
	///
	/// When using this function, it is necessary to explicitly specialize the generic parameter
	/// `A`.  For example:
	///
	///     Gen<UInt32>.choose((32, 255)) >>- (Gen<Character>.pure • Character.init • UnicodeScalar.init)
	public static func choose<A : RandomType>(rng : (A, A)) -> Gen<A> {
		return Gen<A>(unGen: { s in
			return { (_) in
				let (x, _) = A.randomInRange(rng, gen: s)
				return x
			}
		})
	}

	/// Constructs a Generator that randomly selects and uses one of a number of given Generators.
	public static func oneOf<S : CollectionType where S.Generator.Element == Gen<A>, S.Index : protocol<RandomType, BidirectionalIndexType>>(gs : S) -> Gen<A> {
		assert(gs.count != 0, "oneOf used with empty list")

		return choose((gs.indices.startIndex, gs.indices.endIndex.predecessor())) >>- { x in
			return gs[x]
		}
	}

	/// Given a list of Generators and weights associated with them, this function randomly selects and
	/// uses a Generator.
	public static func frequency<S : SequenceType where S.Generator.Element == (Int, Gen<A>)>(xs : S) -> Gen<A> {
		let xs: [(Int, Gen<A>)] = Array(xs)
		assert(xs.count != 0, "frequency used with empty list")

		return choose((1, xs.map({ $0.0 }).reduce(0, combine: +))).bind { l in
			return pick(l)(lst: xs)
		}
	}

	/// Given a list of values and weights associated with them, this function randomly selects and
	/// uses a Generator wrapping one of the values.
	public static func weighted<S : SequenceType where S.Generator.Element == (Int, A)>(xs : S) -> Gen<A> {
		return frequency(xs.map { ($0, Gen.pure($1)) })
	}
}

/// MARK: Generator Modifiers

extension Gen {
	/// Shakes up the receiver's internal Random Number Generator with a seed.
	public func variant<S : IntegerType>(seed : S) -> Gen<A> {
		return Gen(unGen: { r in
			return { n in
				return self.unGen(vary(seed)(r: r))(n)
			}
		})
	}

	/// Modifies a Generator to always use a given size.
	public func resize(n : Int) -> Gen<A> {
		return Gen(unGen: { r in
			return { (_) in
				return self.unGen(r)(n)
			}
		})
	}

	/// Modifies a Generator such that it only returns values that satisfy a predicate.  When the
	/// predicate fails the test case is treated as though it never occured.
	///
	/// Because the Generator will spin until it reaches a non-failing case, executing a condition
	/// that fails more often than it succeeds may result in a space leak.  At that point, it is
	/// better to use `suchThatOptional` or `.invert` the test case.
	public func suchThat(p : A -> Bool) -> Gen<A> {
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

	/// Modifies a Generator such that it attempts to generate values that satisfy a predicate.  All
	/// attempts are encoded in the form of an `Optional` where values satisfying the predicate are
	/// wrapped in `.Some` and failing values are `.None`.
	public func suchThatOptional(p : A -> Bool) -> Gen<Optional<A>> {
		return Gen<Optional<A>>.sized({ n in
			return attemptBoundedTry(self, k: 0, n: max(n, 1), p: p)
		})
	}

	/// Modifies a Generator such that it produces arrays with a length determined by the receiver's
	/// size parameter.
	public func proliferate() -> Gen<[A]> {
		return Gen<[A]>.sized({ n in
			return Gen.choose((0, n)) >>- self.proliferateSized
		})
	}

	/// Modifies a Generator such that it produces non-empty arrays with a length determined by the
	/// receiver's size parameter.
	public func proliferateNonEmpty() -> Gen<[A]> {
		return Gen<[A]>.sized({ n in
			return Gen.choose((1, max(1, n))) >>- self.proliferateSized
		})
	}

	/// Modifies a Generator such that it only produces arrays of a given length.
	public func proliferateSized(k : Int) -> Gen<[A]> {
		return sequence(Array<Gen<A>>(count: k, repeatedValue: self))
	}
}

/// MARK: Instances

extension Gen /*: Functor*/ {
	typealias B = Swift.Any

	/// Returns a new generator that applies a given function to any outputs the receiver creates.
	public func fmap<B>(f : (A -> B)) -> Gen<B> {
		return f <^> self
	}
}

public func <^> <A, B>(f : A -> B, g : Gen<A>) -> Gen<B> {
	return Gen(unGen: { r in
		return { n in
			return f(g.unGen(r)(n))
		}
	})
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
		return fn <*> self
	}
}

public func <*> <A, B>(fn : Gen<A -> B>, g : Gen<A>) -> Gen<B> {
	return Gen(unGen: { r in
		return { n in
			return fn.unGen(r)(n)(g.unGen(r)(n))
		}
	})
}

extension Gen /*: Monad*/ {
	/// Applies the function to any generated values to yield a new generator.  This generator is
	/// then given a new random seed and returned.
	///
	/// Bind allows for the creation of Generators that depend on other generators.  One might, for
	/// example, use a Generator of integers to control the length of a Generator of strings, or use
	/// it to choose a random index into a Generator of arrays.
	public func bind<B>(fn : A -> Gen<B>) -> Gen<B> {
		return self >>- fn
	}
}

public func >>- <A, B>(m : Gen<A>, fn : A -> Gen<B>) -> Gen<B> {
	return Gen(unGen: { r in
		return { n in
			let (r1, r2) = r.split()
			let m2 = fn(m.unGen(r1)(n))
			return m2.unGen(r2)(n)
		}
	})
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

import func Darwin.log

private func vary<S : IntegerType>(k : S)(r: StdGen) -> StdGen {
	let s = r.split()
	let gen = ((k % 2) == 0) ? s.0 : s.1
	return (k == (k / 2)) ? gen : vary(k / 2)(r: r)
}

private func attemptBoundedTry<A>(gen: Gen<A>, k: Int, n : Int, p: A -> Bool) -> Gen<Optional<A>> {
	if n == 0 {
		return Gen.pure(.None)
	}
	return gen.resize(2 * k + n).bind { (let x : A) -> Gen<Optional<A>> in
		if p(x) {
			return Gen.pure(.Some(x))
		}
		return attemptBoundedTry(gen, k: k + 1, n: n - 1, p: p)
	}
}

private func size(k : Double)(m : Int) -> Int {
	let n = Double(m)
	return Int((log(n + 1)) * k / log(100))
}

private func selectOne<A>(xs : [A]) -> [(A, [A])] {
	if xs.isEmpty {
		return []
	}
	let y = xs.first!
	let ys = Array(xs[1..<xs.endIndex])
	return [(y, ys)] + selectOne(ys).map({ t in (t.0, [y] + t.1) })
}

private func pick<A>(n : Int)(lst : [(Int, Gen<A>)]) -> Gen<A> {
	let (k, x) = lst[0]
	let tl = Array<(Int, Gen<A>)>(lst[1..<lst.count])
	if n <= k {
		return x
	}
	return pick(n - k)(lst: tl)
}
