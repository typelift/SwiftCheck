//
//  Combinators.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import func Darwin.log

extension Gen {
	/// Constructs a generator that depends on a size parameter.
	public static func sized(f : Int -> Gen<A>) -> Gen<A> {
		return Gen(unGen:{ r in
			return { n in
				return f(n).unGen(r)(n)
			}
		})
	}

	/// Constructs a random element in the range of two Integer Types.
	///
	/// When using this function, it is necessary to explicitly specialize the generic parameter
	/// `A`.  For example:
	///
	///	    Gen<UInt32>.choose((32, 255)).bind { Gen.pure(Character(UnicodeScalar($0))) }
	public static func choose<A : RandomType>(rng : (A, A)) -> Gen<A> {
		return Gen<A>(unGen: { s in
			return { (_) in
				let (x, _) = A.randomInRange(rng, gen: s)
				return x
			}
		})
	}

	/// Randomly selects and uses one of a number of given Generators.
	public static func oneOf(gs : [Gen<A>]) -> Gen<A> {
		assert(gs.count != 0, "oneOf used with empty list")

		return choose((0, gs.count - 1)).bind { x in
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
		return frequency(map(xs, { ($0, Gen.pure($1)) }))
	}
}

/// Implementation Details Follow

private func pick<A>(n: Int)(lst: [(Int, Gen<A>)]) -> Gen<A> {
	let (k, x) = lst[0]
	let tl = Array<(Int, Gen<A>)>(lst[1..<lst.count])
	if n <= k {
		return x
	}
	return pick(n - k)(lst: tl)
}

