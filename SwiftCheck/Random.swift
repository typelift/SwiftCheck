//
//  Random.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import func Darwin.time
import func Darwin.clock

/// Provides a standard interface to an underlying Random Value Generator of any type.  It is
/// analogous to `GeneratorType`, but rather than consume a sequence it uses sources of randomness
/// to generate values indefinitely.
public protocol RandomGeneneratorType {
	/// The next operation returns an Int that is uniformly distributed in the range returned by 
	/// `genRange` (including both end points), and a new generator.
	var next : (Int, Self) { get }
	/// The genRange operation yields the range of values returned by the generator.
	///
	/// This property must return integers in ascending order.
	var genRange : (Int, Int) { get }
	/// Splits the receiver into two distinct random value generators.
	var split : (Self, Self) { get }
}

/// `StdGen` represents a pseudo-random number generator. The library makes it possible to generate
/// repeatable results, by starting with a specified initial random number generator, or to get 
/// different results on each run by using the system-initialised generator or by supplying a seed 
/// from some other source.
public struct StdGen : RandomGeneneratorType, CustomStringConvertible {
	let seed1 : Int
	let seed2 : Int

	/// Creates a `StdGen` initialized at the given seeds that is suitable for replaying of tests.
	public init(_ replaySeed1 : Int, _ replaySeed2 : Int) {
		self.seed1 = replaySeed1
		self.seed2 = replaySeed2
	}

	/// Convenience to create a `StdGen` from a given integer.
	public init(_ o : Int) {
		func mkStdGen32(sMaybeNegative : Int) -> StdGen {
			let s       = sMaybeNegative & Int.max
			let (q, s1) = (s / 2147483562, s % 2147483562)
			let s2      = q % 2147483398
			return StdGen((s1 + 1), (s2 + 1))
		}
		self = mkStdGen32(o)
	}

	public var description : String {
		return "\(self.seed1) \(self.seed2)"
	}

	public var next : (Int, StdGen) {
		let s1 = self.seed1
		let s2 = self.seed2

		let k    = s1 / 53668
		let s1_  = 40014 * (s1 - k * 53668) - k * 12211
		let s1__ = s1_ < 0 ? s1_ + 2147483563 : s1_

		let k_   = s2 / 52774
		let s2_  = 40692 * (s2 - k_ * 52774) - k_ * 3791
		let s2__ = s2_ < 0 ? s2_ + 2147483399 : s2_

		let z    = s1__ - s2__
		let z_ = z < 1 ? z + 2147483562 : z
		return (z_, StdGen(s1__, s2__))
	}

	public var split : (StdGen, StdGen) {
		let s1 = self.seed1
		let s2 = self.seed2
		let std = self.next.1
		return (StdGen(s1 == 2147483562 ? 1 : s1 + 1, std.seed2), StdGen(std.seed1, s2 == 1 ? 2147483398 : s2 - 1))
	}

	public var genRange : (Int, Int) {
		return (Int.min, Int.max)
	}
}

private var theStdGen : StdGen = mkStdRNG(0)

/// A library-provided standard random number generator.
public func newStdGen() -> StdGen {
	let (left, right) = theStdGen.split
	theStdGen = left
	return right
}

/// Types that can generate random versions of themselves.
public protocol RandomType {
	static func randomInRange<G : RandomGeneneratorType>(range : (Self, Self), gen : G) -> (Self, G)
}

/// Generates a random value from a LatticeType random type.
public func randomBound<A : protocol<LatticeType, RandomType>, G : RandomGeneneratorType>(gen : G) -> (A, G) {
	return A.randomInRange((A.min, A.max), gen: gen)
}

extension Bool : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range: (Bool, Bool), gen: G) -> (Bool, G) {
		let (x, gg) = Int.randomInRange((range.0 ? 1 : 0, range.1 ? 1 : 0), gen: gen)
		return (x == 1, gg)
	}
}

extension Character : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Character, Character), gen : G) -> (Character, G) {
		let (min, max) = range
		let minc = String(min).unicodeScalars.first!
		let maxc = String(max).unicodeScalars.first!

		let (val, gg) = UnicodeScalar.randomInRange((minc, maxc), gen: gen)
		return (Character(val), gg)
	}
}

extension UnicodeScalar : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (UnicodeScalar, UnicodeScalar), gen : G) -> (UnicodeScalar, G) {
		let (val, gg) = UInt32.randomInRange((range.0.value, range.1.value), gen: gen)
		return (UnicodeScalar(val), gg)
	}
}

extension Int : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Int, Int), gen : G) -> (Int, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (Int(truncatingBitPattern: bb), gg)
	}
}

extension Int8 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Int8, Int8), gen : G) -> (Int8, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (Int8(truncatingBitPattern: bb), gg)
	}
}

extension Int16 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Int16, Int16), gen : G) -> (Int16, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (Int16(truncatingBitPattern: bb), gg)
	}
}

extension Int32 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Int32, Int32), gen : G) -> (Int32, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (Int32(truncatingBitPattern: bb), gg)
	}
}

extension Int64 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Int64, Int64), gen : G) -> (Int64, G) {
		let (l, h) = range
		if l > h {
			return Int64.randomInRange((h, l), gen: gen)
		} else {
			let (genlo, genhi) : (Int64, Int64) = (1, 2147483562)
			let b = genhi - genlo + 1

			let q : Int64 = 1000
			let k = h - l + 1
			let magtgt = k * q

			func entropize(mag : Int64, _ v : Int64, _ g : G) -> (Int64, G) {
				if mag >= magtgt {
					return (v, g)
				} else {
					let (x, g_) = g.next
					let v_ = (v * b + (Int64(x) - genlo))
					return entropize(mag * b, v_, g_)
				}
			}

			let (v, rng_) = entropize(1, 0, gen)
			return (l + (v % k), rng_)
		}
	}
}

extension UInt : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (UInt, UInt), gen : G) -> (UInt, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (UInt(truncatingBitPattern: bb), gg)
	}
}

extension UInt8 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (UInt8, UInt8), gen : G) -> (UInt8, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (UInt8(truncatingBitPattern: bb), gg)
	}
}

extension UInt16 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (UInt16, UInt16), gen : G) -> (UInt16, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (UInt16(truncatingBitPattern: bb), gg)
	}
}

extension UInt32 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (UInt32, UInt32), gen : G) -> (UInt32, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (UInt32(truncatingBitPattern: bb), gg)
	}
}

extension UInt64 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (UInt64, UInt64), gen : G) -> (UInt64, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (UInt64(bb), gg)
	}
}

extension Float : RandomType {
	public static func random<G : RandomGeneneratorType>(rng : G) -> (Float, G) {
		let (x, rng_) : (Int32, G) = randomBound(rng)
		let twoto24 = Int32(2) ^ Int32(24)
		let mask24 = twoto24 - 1

		return (Float(mask24 & (x)) / Float(twoto24), rng_)
	}

	public static func randomInRange<G : RandomGeneneratorType>(range : (Float, Float), gen : G) -> (Float, G) {
		let (l, h) = range
		if l > h {
			return Float.randomInRange((h , l), gen: gen)
		} else {
			let (coef, g_) = Float.random(gen)
			return (2.0 * (0.5 * l + coef * (0.5 * h - 0.5 * l)), g_)
		}
	}
}

extension Double : RandomType {
	public static func random<G : RandomGeneneratorType>(rng : G) -> (Double, G) {
		let (x, rng_) : (Int64, G) = randomBound(rng)
		let twoto53 = Int64(2) ^ Int64(53)
		let mask53 = twoto53 - 1

		return (Double(mask53 & (x)) / Double(twoto53), rng_)
	}

	public static func randomInRange<G : RandomGeneneratorType>(range : (Double, Double), gen : G) -> (Double, G) {
		let (l, h) = range
		if l > h {
			return Double.randomInRange((h , l), gen: gen)
		} else {
			let (coef, g_) = Double.random(gen)
			return (2.0 * (0.5 * l + coef * (0.5 * h - 0.5 * l)), g_)
		}
	}
}

/// Implementation Details Follow

private func mkStdRNG(o : Int) -> StdGen {
	func mkStdGen32(sMaybeNegative : Int) -> StdGen {
		let s       = sMaybeNegative & Int.max
		let (q, s1) = (s / 2147483562, s % 2147483562)
		let s2      = q % 2147483398
		return StdGen(s1+1, s2+1)
	}

	let ct = Int(clock())
	var tt = timespec()
	clock_gettime(0, &tt)
	let (sec, psec) = (tt.tv_sec, tt.tv_nsec)
	let (ll, _) = Int.multiplyWithOverflow(Int(sec), 12345)
	return mkStdGen32(ll + psec + ct + o)
}

private func clock_gettime(_ : Int, _ t : UnsafeMutablePointer<timespec>) -> Int {
	var now : timeval = timeval()
	let rv = gettimeofday(&now, nil)
	if rv != 0 {
		return Int(rv)
	}
	t.memory.tv_sec  = now.tv_sec
	t.memory.tv_nsec = Int(now.tv_usec) * 1000

	return 0
}
