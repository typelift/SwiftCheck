//
//  Combinators.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
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
	public static func frequency(xs : [(Int, Gen<A>)]) -> Gen<A> {
		assert(xs.count != 0, "frequency used with empty list")

		return choose((1, xs.map({ $0.0 }).reduce(0, combine: +))).bind { l in
			return pick(l)(lst: xs)
		}
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

private func pick<A>(n: Int)(lst: [(Int, Gen<A>)]) -> Gen<A> {
	let (k, x) = lst[0]
	let tl = Array<(Int, Gen<A>)>(lst[1..<lst.count])
	if n <= k {
		return x
	}
	return pick(n - k)(lst: tl)
}

private func size(k : Double)(m : Int) -> Int {
	let n = Double(m)
	return Int((log(n + 1)) * k / log(100))
}

