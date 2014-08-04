//
//  Combinators.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

private func vary(k : Int)(r: StdGen) -> StdGen {
	let s = r.split()
	var gen = ((k % 2) == 0) ? s.0 : s.1
	return (k == (k / 2)) ? gen : vary(k / 2)(r: r)
}

public func variant<A>(k0: Int)(m: Gen<A>) -> Gen<A> {
	return Gen<A>(unGen: { (let r) in
		return { (let n) in
			return m.unGen(vary(k0)(r: r))(n)
		}
	})
}

public func sized<A>(f: Int -> Gen<A>) -> Gen<A> {
	return Gen<A>(unGen:{ (let r) in
		return { (let n) in
			let m = f(n)
			return m.unGen(r)(n)
		}
	})
}

public func resize<A>(n : Int)(m: Gen<A>) -> Gen<A> {
	return Gen<A>(unGen: { (let r) in
		return { (_) in
			return m.unGen(r)(n)
		}
	})
}

public func choose<A>(rng: (A, A)) -> Gen<A> {
	return Gen<A>(unGen: { (let s) in
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

public func promote<A, M : Monad, N : Monad where M.A == Gen<A>, N.A == A>(m: M) -> Gen<M> {
	return Gen<M>(unGen: { (let r) in
		return { (let n) in
			return liftM({ (let mm) in
				return mm.unGen(r)(n)
			})(m)
		}
	})
}

public func suchThat<A>(gen: Gen<A>)(p: (A -> Bool)) -> Gen<A> {
	return suchThatMaybe(gen)(p).bind({ (let mx) in
		switch mx {
			case .Just(let x):
				return Gen<A>.pure(x)
		case .Nothing:
			return sized({ (let n) in
				return resize(n + 1)(m: suchThat(gen)(p))
			})
		}
	})
}

public func suchThatMaybe<A>(gen: Gen<A>)(p: A -> Bool) -> Gen<Maybe<A>> {
	func try(k: Int, n : Int) -> Gen<Maybe<A>> {
		if n == 0 {
			return Gen<Maybe<A>>.pure(Maybe<A>.Nothing)
		}
		return resize(2 * k + n)(m: gen).bind({ (let x : A) -> Gen<Maybe<A>> in
			if p(x) {
				Gen<Maybe<A>>.pure(Maybe.Just(x))
			}
			return try(k + 1, n - 1)
		})
	}
	return sized({ (let n) in
		return try(0, max(n, 1))
	})
}

public func oneOf<A>(gs : [Gen<A>]) -> Gen<A> {
	assert(gs.count != 0, "oneOf used with empty list")

	return choose((0, gs.count - 1)).bind({ (let x) in
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


	let tot = sum(xs.map() { $0.0 })

	return choose((1, tot)) >>= { (let l) in
		return pick(l)(lst: xs)
	}
}

public func elements<A>(xs: [A]) -> Gen<A> {
	assert(xs.count != 0, "elements used with empty list")

	return choose((0, xs.count - 1)).fmap({ (let i) in
		return xs[i]
	})
}

public func growingElements<A>(xs: [A]) -> Gen<A> {
	assert(xs.count != 0, "growingElements used with empty list")

	let k = Double(xs.count)
	func size(m : Int) -> Int {
		let n = Double(m)
		return Int((log(n + 1)) * k / log(100))
	}

	return sized({ (let n) in
		return elements(take(max(1, size(n)))(xs: xs))
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

