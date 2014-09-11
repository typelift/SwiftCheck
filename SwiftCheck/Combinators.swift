//
//  Combinators.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

private func vary<S : IntegerType>(k : S)(r: StdGen) -> StdGen {
	let s = r.split()
	var gen = ((k % 2) == 0) ? s.0 : s.1
	return (k == (k / 2)) ? gen : vary(k / 2)(r: r)
}

public func variant<A, S : IntegerType>(seed: S)(m: Gen<A>) -> Gen<A> {
	return Gen(unGen: { (let r) in
		return { (let n) in
			return m.unGen(vary(seed)(r: r))(n)
		}
	})
}

public func sized<A>(f: Int -> Gen<A>) -> Gen<A> {
	return Gen(unGen:{ (let r) in
		return { (let n) in
			return f(n).unGen(r)(n)
		}
	})
}

public func resize<A>(n : Int)(m: Gen<A>) -> Gen<A> {
	return Gen(unGen: { (let r) in
		return { (_) in
			return m.unGen(r)(n)
		}
	})
}

public func choose<A>(rng: (A, A)) -> Gen<A> {
	return Gen(unGen: { (let s) in
		return { (_) in
			let x = rng.0
			let y = rng.1
			if (rand() / RAND_MAX) == 0 {
				return x
			}
			return y
		}
	})
}

public func suchThat<A>(gen: Gen<A>)(p: (A -> Bool)) -> Gen<A> {
	return suchThatOptional(gen)(p) >>= ({ (let mx) in
		switch mx {
			case .Just(let x):
				return Gen.pure(x)
			case .Nothing:
				return sized({ (let n) in
					return resize(n + 1)(m: suchThat(gen)(p))
				})
		}
	})
}

private func try<A>(gen: Gen<A>, k: Int, n : Int, p: A -> Bool) -> Gen<Optional<A>> {
	if n == 0 {
		return Gen.pure(.Nothing)
	}
	return resize(2 * k + n)(m: gen) >>= ({ (let x : A) -> Gen<Optional<A>> in
		if p(x) {
			Gen<Optional<A>>.pure(.Just(x))
		}
		return try(gen, k + 1, n - 1, p)
	})
}

public func suchThatOptional<A>(gen: Gen<A>)(p: A -> Bool) -> Gen<Optional<A>> {
	return sized({ (let n) in
		return try(gen, 0, max(n, 1), p)
	})
}

public func oneOf<A>(gs : [Gen<A>]) -> Gen<A> {
	assert(gs.count != 0, "oneOf used with empty list")

	return choose((0, gs.count - 1)) >>= ({ (let x) in
		return gs[x]
	})
}

private func pick<A>(n: Int)(lst: [(Int, Gen<A>)]) -> Gen<A> {
	let (k, x) = lst[0]
	let tl = Array<(Int, Gen<A>)>(lst[1..<lst.count])
	if n <= k {
		return x
	}
	return pick(n - k)(lst: tl)
}

public func frequency<A>(xs: [(Int, Gen<A>)]) -> Gen<A> {
	assert(xs.count != 0, "frequency used with empty list")
	
	return choose((1, sum(xs.map() { $0.0 }))) >>= { (let l) in
		return pick(l)(lst: xs)
	}
}

public func elements<A>(xs: [A]) -> Gen<A> {
	assert(xs.count != 0, "elements used with empty list")

	return choose((0, xs.count - 1)).fmap({ (let i) in
		return xs[i]
	})
}

func size(k : Double)(m : Int) -> Int {
	let n = Double(m)
	return Int((log(n + 1)) * k / log(100))
}

public func growingElements<A>(xs: [A]) -> Gen<A> {
	assert(xs.count != 0, "growingElements used with empty list")

	let k = Double(xs.count)
	return sized({ (let n) in
		return elements(take(max(1, size(k)(m: n)))(xs: xs))
	})
}

public func listOf<A>(gen: Gen<A>) -> Gen<[A]> {
	return sized({ (let n) in
		return choose((0, n)) >>= { (let k) in
			return vectorOf(k)(gen: gen)
		}
	})
}

public func listOf1<A>(gen: Gen<A>) -> Gen<[A]> {
	return sized({ (let n) in
		return choose((1, max(1, n))) >>= { (let k) in
			return vectorOf(k)(gen: gen)
		}
	})
}

public func vectorOf<A>(k: Int)(gen : Gen<A>) -> Gen<[A]> {
	return sequence(Array<Gen<A>>(count: k, repeatedValue: gen))
}
