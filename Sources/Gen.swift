//
//  Gen.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// `Gen` represents a generator for random arbitrary values of type `A`.
///
/// `Gen` wraps a function that, when given a random number generator and a
/// size, can be used to control the distribution of resultant values.  A
/// generator relies on its size to help control aspects like the length of
/// generated arrays and the magnitude of integral values.
public struct Gen<A> {
	/// The function underlying the receiver.
	///
	///          +--- An RNG
	///          |       +--- The size of generated values.
	///          |       |
	///          v       v
	let unGen : (StdGen, Int) -> A

	/// Generates a value.
	///
	/// This property exists as a convenience mostly to test generators.  In
	/// practice, you should never use this property because it hinders the
	/// replay functionality and the robustness of tests in general.
	public var generate : A {
		let r = newStdGen()
		return unGen(r, 30)
	}

	/// Generates some example values.
	///
	/// This property exists as a convenience mostly to test generators.  In
	/// practice, you should never use this property because it hinders the
	/// replay functionality and the robustness of tests in general.
	public var sample : [A] {
		return sequence((2...20).map(self.resize)).generate
	}

	/// Constructs a Generator that selects a random value from the given
	/// collection and produces only that value.
	///
	/// The input collection is required to be non-empty.
	public static func fromElementsOf<S : Collection>(_ xs : S) -> Gen<S._Element>
		where S.Index : Comparable & RandomType
	{
		return Gen.fromElementsIn(xs.startIndex...xs.index(xs.endIndex, offsetBy: -1)).map { i in
			return xs[i]
		}
	}

	/// Constructs a Generator that selects a random value from the given
	/// interval and produces only that value.
	///
	/// The input interval is required to be non-empty.
	public static func fromElementsIn<R : RandomType>(_ xs : ClosedRange<R>) -> Gen<R> {
		assert(!xs.isEmpty, "Gen.fromElementsOf used with empty interval")

		return choose((xs.lowerBound, xs.upperBound))
	}

	/// Constructs a Generator that uses a given array to produce smaller arrays
	/// composed of its initial segments.  The size of each initial segment
	/// increases with the receiver's size parameter.
	///
	/// The input array is required to be non-empty.
	public static func fromInitialSegmentsOf<S>(_ xs : [S]) -> Gen<[S]> {
		assert(!xs.isEmpty, "Gen.fromInitialSegmentsOf used with empty list")

		return Gen<[S]>.sized { n in
			let ss = xs[xs.startIndex..<max((xs.startIndex + 1), size(xs.endIndex, n))]
			return Gen<[S]>.pure([S](ss))
		}
	}

	/// Constructs a Generator that produces permutations of a given array.
	public static func fromShufflingElementsOf<S>(_ xs : [S]) -> Gen<[S]> {
		return choose((Int.min + 1, Int.max)).proliferateSized(xs.count).flatMap { ns in
			return Gen<[S]>.pure(Swift.zip(ns, xs).sorted(by: { l, r in l.0 < r.0 }).map { $0.1 })
		}
	}

	/// Constructs a generator that depends on a size parameter.
	public static func sized(_ f : @escaping (Int) -> Gen<A>) -> Gen<A> {
		return Gen(unGen: { r, n in
			return f(n).unGen(r, n)
		})
	}

	/// Constructs a random element in the inclusive range of two `RandomType`s.
	///
	/// When using this function, it is necessary to explicitly specialize the
	/// generic parameter `A`.  For example:
	///
	///     Gen<UInt32>.choose((32, 255)).flatMap(Gen<Character>.pure • Character.init • UnicodeScalar.init)
	public static func choose<A : RandomType>(_ rng : (A, A)) -> Gen<A> {
		return Gen<A>(unGen: { s, _ in
			return A.randomInRange(rng, gen: s).0
		})
	}
	
	/// Constructs a random element in the range of a bounded `RandomType`.
	///
	/// When using this function, it is necessary to explicitly specialize the
	/// generic parameter `A`.  For example:
	///
	///     Gen<UInt32>.chooseAny().flatMap(Gen<Character>.pure • Character.init • UnicodeScalar.init)
	public static func chooseAny<A : RandomType & LatticeType>() -> Gen<A> {
		return Gen<A>(unGen: { (s, _) in
			return randomBound(s).0
		})
	}

	/// Constructs a Generator that randomly selects and uses a particular
	/// generator from the given sequence of Generators.
	///
	/// If control over the distribution of generators is needed, see
	/// `Gen.frequency` or `Gen.weighted`.
	public static func oneOf<S : BidirectionalCollection>(_ gs : S) -> Gen<A>
		where S.Iterator.Element == Gen<A>, S.Index : RandomType & Comparable
	{
		assert(gs.count != 0, "oneOf used with empty list")

		return choose((gs.startIndex, gs.index(before: gs.endIndex))).flatMap { x in
			return gs[x]
		}
	}

	/// Given a sequence of Generators and weights associated with them, this
	/// function randomly selects and uses a Generator.
	///
	/// Only use this function when you need to assign uneven "weights" to each
	/// generator.  If all generators need to have an equal chance of being
	/// selected, use `Gen.oneOf`.
	public static func frequency<S : Sequence>(_ xs : S) -> Gen<A>
		where S.Iterator.Element == (Int, Gen<A>)
	{
		let xs: [(Int, Gen<A>)] = Array(xs)
		assert(xs.count != 0, "frequency used with empty list")

		return choose((1, xs.map({ $0.0 }).reduce(0, +))).flatMap { l in
			return pick(l, xs)
		}
	}

	/// Given a list of values and weights associated with them, this function
	/// randomly selects and uses a Generator wrapping one of the values.
	///
	/// This function operates in exactly the same manner as `Gen.frequency`,
	/// `Gen.fromElementsOf`, and `Gen.fromElementsIn` but for any type rather
	/// than only Generators.  It can help in cases where your `Gen.from*` call
	/// contains only `Gen.pure` calls by allowing you to remove every
	/// `Gen.pure` in favor of a direct list of values.
	public static func weighted<S : Sequence>(_ xs : S) -> Gen<A>
		where S.Iterator.Element == (Int, A)
	{
		return frequency(xs.map { ($0, Gen.pure($1)) })
	}
}

extension Gen /*: Cartesian*/ {
	/// Zips together 2 generators of type `A` and `B` into a generator of pairs.
	public static func zip<A, B>(_ gen1 : Gen<A>, _ gen2 : Gen<B>) -> Gen<(A, B)> {
		return Gen<(A, B)>(unGen: { r, n in
			let (r1, r2) = r.split
			return (gen1.unGen(r1, n), gen2.unGen(r2, n))
		})
	}

	/// Zips together 3 generators of type `A`, `B`, and `C` into a generator of
	/// triples.
	public static func zip<A, B, C>(_ gen1 : Gen<A>, _ gen2 : Gen<B>, _ gen3 : Gen<C>) -> Gen<(A, B, C)> {
		return Gen<(A, B, C)>(unGen: { r, n in
			let (r1, r2_) = r.split
			let (r2, r3) = r2_.split
			return (gen1.unGen(r1, n), gen2.unGen(r2, n), gen3.unGen(r3, n))
		})
	}

	/// Zips together 4 generators of type `A`, `B`, `C`, and `D` into a
	/// generator of quadruples.
	public static func zip<A, B, C, D>(_ gen1 : Gen<A>, _ gen2 : Gen<B>, _ gen3 : Gen<C>, _ gen4 : Gen<D>) -> Gen<(A, B, C, D)> {
		return Gen<(A, B, C, D)>(unGen: { r, n in
			let (r1_, r2_) = r.split
			let (r1, r2) = r1_.split
			let (r3, r4) = r2_.split
			return (gen1.unGen(r1, n), gen2.unGen(r2, n), gen3.unGen(r3, n), gen4.unGen(r4, n))
		})
	}

	/// Zips together 5 generators of type `A`, `B`, `C`, `D`, and `E` into a
	/// generator of quintuples.
	public static func zip<A, B, C, D, E>(_ gen1 : Gen<A>, _ gen2 : Gen<B>, _ gen3 : Gen<C>, _ gen4 : Gen<D>, _ gen5 : Gen<E>) -> Gen<(A, B, C, D, E)> {
		return Gen<(A, B, C, D, E)>(unGen: { r, n in
			let (r1_, r2_) = r.split
			let (r1__, r1) = r1_.split
			let (r2, r3) = r2_.split
			let (r4, r5) = r1__.split
			return (gen1.unGen(r1, n), gen2.unGen(r2, n), gen3.unGen(r3, n), gen4.unGen(r4, n), gen5.unGen(r5, n))
		})
	}

	/// Zips together 6 generators of type `A`, `B`, `C`, `D` `E`, and `F` into
	/// a generator of sextuples.
	public static func zip<A, B, C, D, E, F>(_ gen1 : Gen<A>, _ gen2 : Gen<B>, _ gen3 : Gen<C>, _ gen4 : Gen<D>, _ gen5 : Gen<E>, _ gen6 : Gen<F>) -> Gen<(A, B, C, D, E, F)> {
		return Gen<(A, B, C, D, E, F)>(unGen: { r, n in
			let (r1_, r2_) = r.split
			let (r1__, r2__) = r1_.split
			let (r1, r2) = r2_.split
			let (r3, r4) = r1__.split
			let (r5, r6) = r2__.split
			return (gen1.unGen(r1, n), gen2.unGen(r2, n), gen3.unGen(r3, n), gen4.unGen(r4, n), gen5.unGen(r5, n), gen6.unGen(r6, n))
		})
	}

	/// Zips together 7 generators of type `A`, `B`, `C`, `D` `E`, `F`, and `G`
	/// into a generator of septuples.
	public static func zip<A, B, C, D, E, F, G>(_ gen1 : Gen<A>, _ gen2 : Gen<B>, _ gen3 : Gen<C>, _ gen4 : Gen<D>, _ gen5 : Gen<E>, _ gen6 : Gen<F>, _ gen7 : Gen<G>) -> Gen<(A, B, C, D, E, F, G)> {
		return Gen<(A, B, C, D, E, F, G)>(unGen: { r, n in
			let (r1_, r2_) = r.split
			let (r1__, r2__) = r1_.split
			let (r1___, r1) = r2_.split
			let (r2, r3) = r1__.split
			let (r4, r5) = r2__.split
			let (r6, r7) = r1___.split
			return (gen1.unGen(r1, n), gen2.unGen(r2, n), gen3.unGen(r3, n), gen4.unGen(r4, n), gen5.unGen(r5, n), gen6.unGen(r6, n), gen7.unGen(r7, n))
		})
	}

	/// Zips together 8 generators of type `A`, `B`, `C`, `D` `E`, `F`, `G`, and
	/// `H` into a generator of octuples.
	public static func zip<A, B, C, D, E, F, G, H>(_ gen1 : Gen<A>, _ gen2 : Gen<B>, _ gen3 : Gen<C>, _ gen4 : Gen<D>, _ gen5 : Gen<E>, _ gen6 : Gen<F>, _ gen7 : Gen<G>, _ gen8 : Gen<H>) -> Gen<(A, B, C, D, E, F, G, H)> {
		return Gen<(A, B, C, D, E, F, G, H)>(unGen: { r, n in
			let (r1_, r2_) = r.split
			let (r1__, r2__) = r1_.split
			let (r1___, r2___) = r2_.split
			let (r1, r2) = r1__.split
			let (r3, r4) = r2__.split
			let (r5, r6) = r1___.split
			let (r7, r8) = r2___.split
			return (gen1.unGen(r1, n), gen2.unGen(r2, n), gen3.unGen(r3, n), gen4.unGen(r4, n), gen5.unGen(r5, n), gen6.unGen(r6, n), gen7.unGen(r7, n), gen8.unGen(r8, n))
		})
	}

	/// Zips together 9 generators of type `A`, `B`, `C`, `D` `E`, `F`, `G`,
	/// `H`, and `I` into a generator of nonuples.
	public static func zip<A, B, C, D, E, F, G, H, I>(_ gen1 : Gen<A>, _ gen2 : Gen<B>, _ gen3 : Gen<C>, _ gen4 : Gen<D>, _ gen5 : Gen<E>, _ gen6 : Gen<F>, _ gen7 : Gen<G>, _ gen8 : Gen<H>, _ gen9 : Gen<I>) -> Gen<(A, B, C, D, E, F, G, H, I)> {
		return Gen<(A, B, C, D, E, F, G, H, I)>(unGen: { r, n in
			let (r1_, r2_) = r.split
			let (r1__, r2__) = r1_.split
			let (r1___, r2___) = r2_.split
			let (r1____, r1) = r1__.split
			let (r2, r3) = r2__.split
			let (r4, r5) = r1___.split
			let (r6, r7) = r2___.split
			let (r8, r9) = r1____.split
			return (gen1.unGen(r1, n), gen2.unGen(r2, n), gen3.unGen(r3, n), gen4.unGen(r4, n), gen5.unGen(r5, n), gen6.unGen(r6, n), gen7.unGen(r7, n), gen8.unGen(r8, n), gen9.unGen(r9, n))
		})
	}

	/// Zips together 10 generators of type `A`, `B`, `C`, `D` `E`, `F`, `G`,
	/// `H`, `I`, and `J` into a generator of decuples.
	public static func zip<A, B, C, D, E, F, G, H, I, J>(_ gen1 : Gen<A>, _ gen2 : Gen<B>, _ gen3 : Gen<C>, _ gen4 : Gen<D>, _ gen5 : Gen<E>, _ gen6 : Gen<F>, _ gen7 : Gen<G>, _ gen8 : Gen<H>, _ gen9 : Gen<I>, _ gen10 : Gen<J>) -> Gen<(A, B, C, D, E, F, G, H, I, J)> {
		return Gen<(A, B, C, D, E, F, G, H, I, J)>(unGen: { r, n in
			let (r1_, r2_) = r.split
			let (r1__, r2__) = r1_.split
			let (r1___, r2___) = r2_.split
			let (r1____, r2____) = r1__.split
			let (r1, r2) = r2__.split
			let (r3, r4) = r1___.split
			let (r5, r6) = r2___.split
			let (r7, r8) = r1____.split
			let (r9, r10) = r2____.split
			return (gen1.unGen(r1, n), gen2.unGen(r2, n), gen3.unGen(r3, n), gen4.unGen(r4, n), gen5.unGen(r5, n), gen6.unGen(r6, n), gen7.unGen(r7, n), gen8.unGen(r8, n), gen9.unGen(r9, n), gen10.unGen(r10, n))
		})
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// two receivers create.
	public static func map<A1, A2, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, transform: @escaping (A1, A2) -> R) -> Gen<R> {
		return zip(ga1, ga2).map(transform)
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// three receivers create.
	public static func map<A1, A2, A3, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, transform: @escaping (A1, A2, A3) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3).map(transform)
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// four receivers create.
	public static func map<A1, A2, A3, A4, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4 : Gen<A4>, transform: @escaping (A1, A2, A3, A4) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4).map(transform)
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// five receivers create.
	public static func map<A1, A2, A3, A4, A5, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4: Gen<A4>, _ ga5 : Gen<A5>, transform: @escaping (A1, A2, A3, A4, A5) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5).map(transform)
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// six receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4: Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>, transform: @escaping (A1, A2, A3, A4, A5, A6) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6).map(transform)
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// seven receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4: Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>,  _ ga7 : Gen<A7>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7).map(transform)
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// eight receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4: Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>,  _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8).map(transform)
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// nine receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4: Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>,  _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9).map(transform)
	}

	/// Returns a new generator that applies a given function to any outputs the
	/// ten receivers create.
	public static func map<A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, R>(_ ga1 : Gen<A1>, _ ga2 : Gen<A2>, _ ga3 : Gen<A3>, _ ga4: Gen<A4>, _ ga5 : Gen<A5>, _ ga6 : Gen<A6>,  _ ga7 : Gen<A7>, _ ga8 : Gen<A8>, _ ga9 : Gen<A9>, _ ga10 : Gen<A10>, transform: @escaping (A1, A2, A3, A4, A5, A6, A7, A8, A9, A10) -> R) -> Gen<R> {
		return zip(ga1, ga2, ga3, ga4, ga5, ga6, ga7, ga8, ga9, ga10).map(transform)
	}
}

// MARK: Generator Modifiers

extension Gen {
	/// Shakes up the receiver's internal Random Number Generator with a seed.
	public func variant<S : Integer>(_ seed : S) -> Gen<A> {
		return Gen(unGen: { rng, n in
			return self.unGen(vary(seed, rng), n)
		})
	}

	/// Modifies a Generator to always use a given size.
	public func resize(_ n : Int) -> Gen<A> {
		return Gen(unGen: { r, _ in
			return self.unGen(r, n)
		})
	}

	/// Modifiers a Generator's size parameter by transforming it with the given
	/// function.
	public func scale(_ f : @escaping (Int) -> Int) -> Gen<A> {
		return Gen.sized { n in
			return self.resize(f(n))
		}
	}

	/// Modifies a Generator such that it only returns values that satisfy a
	/// predicate.  When the predicate fails the test case is treated as though
	/// it never occured.
	///
	/// Because the Generator will spin until it reaches a non-failing case,
	/// executing a condition that fails more often than it succeeds may result
	/// in a space leak.  At that point, it is better to use `suchThatOptional`
	/// or `.invert` the test case.
	public func suchThat(_ p : @escaping (A) -> Bool) -> Gen<A> {
		return self.suchThatOptional(p).flatMap { mx in
			switch mx {
			case .some(let x):
				return Gen.pure(x)
			case .none:
				return Gen.sized { n in
					return self.suchThat(p).resize((n + 1))
				}
			}
		}
	}

	/// Modifies a Generator such that it attempts to generate values that
	/// satisfy a predicate.  All attempts are encoded in the form of an
	/// `Optional` where values satisfying the predicate are wrapped in `.Some`
	/// and failing values are `.None`.
	public func suchThatOptional(_ p : @escaping (A) -> Bool) -> Gen<Optional<A>> {
		return Gen<Optional<A>>.sized { n in
			return attemptBoundedTry(self, 0, max(n, 1), p)
		}
	}

	/// Modifies a Generator such that it produces arrays with a length
	/// determined by the receiver's size parameter.
	public var proliferate : Gen<[A]> {
		return Gen<[A]>.sized { n in
			return Gen.choose((0, n)).flatMap(self.proliferateSized)
		}
	}

	/// Modifies a Generator such that it produces non-empty arrays with a
	/// length determined by the receiver's size parameter.
	public var proliferateNonEmpty : Gen<[A]> {
		return Gen<[A]>.sized { n in
			return Gen.choose((1, max(1, n))).flatMap(self.proliferateSized)
		}
	}

	/// Modifies a Generator such that it only produces arrays of a given length.
	public func proliferateSized(_ k : Int) -> Gen<[A]> {
		return sequence(Array<Gen<A>>(repeating: self, count: k))
	}
}

// MARK: Instances

extension Gen /*: Functor*/ {
	/// Returns a new generator that applies a given function to any outputs the
	/// receiver creates.
	///
	/// This function is most useful for converting between generators of inter-
	/// related types.  For example, you might have a Generator of `Character`
	/// values that you then `.proliferate` into an `Array` of `Character`s.  You
	/// can then use `fmap` to convert that generator of `Array`s to a generator of
	/// `String`s.
	public func map<B>(_ f : @escaping (A) -> B) -> Gen<B> {
		return Gen<B>(unGen: { r, n in
			return f(self.unGen(r, n))
		})
	}
}

extension Gen /*: Applicative*/ {
	/// Lifts a value into a generator that will only generate that value.
	public static func pure(_ a : A) -> Gen<A> {
		return Gen(unGen: { _ in
			return a
		})
	}

	/// Given a generator of functions, applies any generated function to any
	/// outputs the receiver creates.
	public func ap<B>(_ fn : Gen<(A) -> B>) -> Gen<B> {
		return Gen<B>(unGen: { r, n in
			let (r1, r2) = r.split
			return fn.unGen(r1, n)(self.unGen(r2, n))
		})
	}
}

extension Gen /*: Monad*/ {
	/// Applies the function to any generated values to yield a new generator.
	/// This generator is then given a new random seed and returned.
	///
	/// `flatMap` allows for the creation of Generators that depend on other
	/// generators.  One might, for example, use a Generator of integers to
	/// control the length of a Generator of strings, or use it to choose a
	/// random index into a Generator of arrays.
	public func flatMap<B>(_ fn : @escaping (A) -> Gen<B>) -> Gen<B> {
		return Gen<B>(unGen: { r, n in
			let (r1, r2) = r.split
			let m2 = fn(self.unGen(r1, n))
			return m2.unGen(r2, n)
		})
	}
}

/// Creates and returns a Generator of arrays of values drawn from each
/// generator in the given array.
///
/// The array that is created is guaranteed to use each of the given Generators
/// in the order they were given to the function exactly once.  Thus all arrays
/// generated are of the same rank as the array that was given.
public func sequence<A>(_ ms : [Gen<A>]) -> Gen<[A]> {
	return ms.reduce(Gen<[A]>.pure([]), { n, m in
		return m.flatMap { x in
			return n.flatMap { xs in
				return Gen<[A]>.pure(xs + [x])
			}
		}
	})
}

/// Flattens a generator of generators by one level.
public func join<A>(_ rs : Gen<Gen<A>>) -> Gen<A> {
	return rs.flatMap { x in
		return x
	}
}

/// Lifts a function from some A to some R to a function from generators of A to
/// generators of R.
public func liftM<A, R>(_ f : @escaping (A) -> R, _ m1 : Gen<A>) -> Gen<R> {
	return m1.flatMap{ x1 in
		return Gen.pure(f(x1))
	}
}

/// Promotes a rose of generators to a generator of rose values.
public func promote<A>(_ x : Rose<Gen<A>>) -> Gen<Rose<A>> {
	return delay().flatMap { eval in
		return Gen<Rose<A>>.pure(liftM(eval, x))
	}
}

/// Promotes a function returning generators to a generator of functions.
public func promote<A, B>(_ m : @escaping (A) -> Gen<B>) -> Gen<(A) -> B> {
	return delay().flatMap { eval in
		return Gen<(A) -> B>.pure(comp(eval, m))
	}
}

// MARK: - Implementation Details

private func delay<A>() -> Gen<(Gen<A>) -> A> {
	return Gen(unGen: { r, n in
		return { g in
			return g.unGen(r, n)
		}
	})
}

private func vary<S : Integer>(_ k : S, _ rng : StdGen) -> StdGen {
	let s = rng.split
	let gen = ((k % 2) == 0) ? s.0 : s.1
	return (k == (k / 2)) ? gen : vary(k / 2, rng)
}

private func attemptBoundedTry<A>(_ gen : Gen<A>, _ k : Int, _ bound : Int, _ pred : @escaping (A) -> Bool) -> Gen<Optional<A>> {
	if bound == 0 {
		return Gen.pure(.none)
	}
	return gen.resize(2 * k + bound).flatMap { x in
		if pred(x) {
			return Gen.pure(.some(x))
		}
		return attemptBoundedTry(gen, (k + 1), bound - 1, pred)
	}
}

private func size<S : Integer>(_ k : S, _ m : Int) -> Int {
	let n = Double(m)
	return Int((log(n + 1)) * Double(k.toIntMax()) / log(100))
}

private func selectOne<A>(_ xs : [A]) -> [(A, [A])] {
	guard let y = xs.first else { return [] }

	let ys = Array(xs[1..<xs.endIndex])
	let rec : [(A, Array<A>)] = selectOne(ys).map({ t in (t.0, [y] + t.1) })
	return [(y, ys)] + rec
}

private func pick<A>(_ n : Int, _ lst : [(Int, Gen<A>)]) -> Gen<A> {
	let (k, x) = lst[0]
	let tl = Array<(Int, Gen<A>)>(lst[1..<lst.count])
	if n <= k {
		return x
	}
	return pick(n - k, tl)
}

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

