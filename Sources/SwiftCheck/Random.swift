//
//  Random.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// Provides a standard interface to an underlying Random Value Generator of any
/// type.  It is analogous to `GeneratorType`, but rather than consume a
/// sequence it uses sources of randomness to generate values indefinitely.
public protocol RandomGeneneratorType {
	/// Returns an `Int` that is uniformly distributed in the range returned by
	/// `genRange` (including both end points), and a new random value generator.
	var next : (Int, Self) { get }
	/// Yields the range of values returned by the generator.
	///
	/// This property must return integers in ascending order.
	var genRange : (Int, Int) { get }
	/// Splits the current random value generator into two distinct random value
	/// generators.
	var split : (Self, Self) { get }
}

/// `StdGen` represents a pseudo-random number generator. The library makes it
/// possible to generate repeatable results, by starting with a specified
/// initial random number generator, or to get different results on each run by
/// using the system-initialised generator or by supplying a seed from some
/// other source.
public struct StdGen : RandomGeneneratorType {
	let seed1 : Int
	let seed2 : Int

	/// Creates a `StdGen` initialized at the given seeds that is suitable for
	/// replaying of tests.
	public init(_ replaySeed1 : Int, _ replaySeed2 : Int) {
		self.seed1 = replaySeed1
		self.seed2 = replaySeed2
	}

	/// Convenience to create a `StdGen` from a given integer.
	public init(_ o : Int) {
		func mkStdGen32(_ sMaybeNegative : Int) -> StdGen {
			let s       = sMaybeNegative & Int.max
			let (q, s1) = (s / 2147483562, s % 2147483562)
			let s2      = q % 2147483398
			return StdGen((s1 + 1), (s2 + 1))
		}
		self = mkStdGen32(o)
	}

	/// Returns an `Int` generated uniformly within the bounds of the generator
	/// and a new distinct random number generator.
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

	/// Splits the random number generator and returns two distinct random 
	/// number generators.
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

extension StdGen : Equatable, CustomStringConvertible {
	public var description : String {
		return "\(self.seed1) \(self.seed2)"
	}
}

/// Equality over random number generators.
///
/// Two `StdGen`s are equal iff their seeds match.
public func == (l : StdGen, r : StdGen) -> Bool {
	return l.seed1 == r.seed1 && l.seed2 == r.seed2
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
	/// Takes a range `(lo, hi)` and a random number generator `G`, and returns
	/// a random value uniformly distributed in the closed interval `[lo,hi]`,
	/// together with a new generator. It is unspecified what happens if lo>hi.
	///
	/// For continuous types there is no requirement that the values `lo` and
	/// `hi` are ever produced, but they may be, depending on the implementation
	/// and the interval.
	static func randomInRange<G : RandomGeneneratorType>(_ range : (Self, Self), gen : G) -> (Self, G)
}

/// Generates a random value from a LatticeType random type.
public func randomBound<A : LatticeType & RandomType, G : RandomGeneneratorType>(_ gen : G) -> (A, G) {
	return A.randomInRange((A.min, A.max), gen: gen)
}

extension Bool : RandomType {
	/// Returns a random `Bool`ean value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (Bool, Bool), gen: G) -> (Bool, G) {
		let (x, gg) = Int.randomInRange((range.0 ? 1 : 0, range.1 ? 1 : 0), gen: gen)
		return (x == 1, gg)
	}
}

extension Character : RandomType {
	/// Returns a random `Character` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (Character, Character), gen : G) -> (Character, G) {
		let (min, max) = range
		let minc = String(min).unicodeScalars.first!
		let maxc = String(max).unicodeScalars.first!

		let (val, gg) = UnicodeScalar.randomInRange((minc, maxc), gen: gen)
		return (Character(val), gg)
	}
}

extension UnicodeScalar : RandomType {
	/// Returns a random `UnicodeScalar` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (UnicodeScalar, UnicodeScalar), gen : G) -> (UnicodeScalar, G) {
		let (val, gg) = UInt32.randomInRange((range.0.value, range.1.value), gen: gen)
		return (UnicodeScalar(val)!, gg)
	}
}

extension Int : RandomType {
	/// Returns a random `Int` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (Int, Int), gen : G) -> (Int, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (Int(truncatingIfNeeded: bb), gg)
	}
}

extension Int8 : RandomType {
	/// Returns a random `Int8` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (Int8, Int8), gen : G) -> (Int8, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (Int8(truncatingIfNeeded: bb), gg)
	}
}

extension Int16 : RandomType {
	/// Returns a random `Int16` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (Int16, Int16), gen : G) -> (Int16, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (Int16(truncatingIfNeeded: bb), gg)
	}
}

extension Int32 : RandomType {
	/// Returns a random `Int32` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (Int32, Int32), gen : G) -> (Int32, G) {
		let (minl, maxl) = range
		let (bb, gg) = Int64.randomInRange((Int64(minl), Int64(maxl)), gen: gen)
		return (Int32(truncatingIfNeeded: bb), gg)
	}
}

extension Int64 : RandomType {
	/// Returns a random `Int64` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (Int64, Int64), gen : G) -> (Int64, G) {
		let (l, h) = range
		if l > h {
			return Int64.randomInRange((h, l), gen: gen)
		} else {
			let (genlo, genhi) : (Int64, Int64) = (1, 2147483562)
			let b = Double(genhi - genlo + 1)
			let q : Double = 1000
			let k = Double(h) - Double(l) +  1
			let magtgt = k * q

			func entropize(_ mag : Double, _ v : Double, _ g : G) -> (Double, G) {
				if mag >= magtgt {
					return (v, g)
				} else {
					let (x, g_) = g.next
					let v_ = (v * b + (Double(x) - Double(genlo)))
					return entropize(mag * b, v_, g_)
				}
			}

			let (v, rng_) = entropize(1, 0, gen)
			let ret = Double(l) + v.truncatingRemainder(dividingBy: k)
			// HACK: There exist the following 512 integers that cannot be 
			// safely converted by `Builtin.fptosi_FPIEEE64_Int64`.  Instead we 
			// calculate their distance from `max` and perform the calculation
			// in integer-land by hand.
			if Double(Int64.max - 512) <= ret && ret <= Double(Int64.max) {
				let deviation = Int64(Double(Int64.max) - ret)
				return (Int64.max - deviation, rng_)
			}
			return (Int64(ret), rng_)
		}
	}
}

extension UInt : RandomType {
	/// Returns a random `UInt` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (UInt, UInt), gen : G) -> (UInt, G) {
		let (minl, maxl) = range
		let (bb, gg) = UInt64.randomInRange((UInt64(minl), UInt64(maxl)), gen: gen)
		return (UInt(truncatingIfNeeded: bb), gg)
	}
}

extension UInt8 : RandomType {
	/// Returns a random `UInt8` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (UInt8, UInt8), gen : G) -> (UInt8, G) {
		let (minl, maxl) = range
		let (bb, gg) = UInt64.randomInRange((UInt64(minl), UInt64(maxl)), gen: gen)
		return (UInt8(truncatingIfNeeded: bb), gg)
	}
}

extension UInt16 : RandomType {
	/// Returns a random `UInt16` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (UInt16, UInt16), gen : G) -> (UInt16, G) {
		let (minl, maxl) = range
		let (bb, gg) = UInt64.randomInRange((UInt64(minl), UInt64(maxl)), gen: gen)
		return (UInt16(truncatingIfNeeded: bb), gg)
	}
}

extension UInt32 : RandomType {
	/// Returns a random `UInt32` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (UInt32, UInt32), gen : G) -> (UInt32, G) {
		let (minl, maxl) = range
		let (bb, gg) = UInt64.randomInRange((UInt64(minl), UInt64(maxl)), gen: gen)
		return (UInt32(truncatingIfNeeded: bb), gg)
	}
}

extension UInt64 : RandomType {
	/// Returns a random `UInt64` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (UInt64, UInt64), gen : G) -> (UInt64, G) {
		let (l, h) = range
		if l > h {
			return UInt64.randomInRange((h, l), gen: gen)
		} else {
			let (genlo, genhi) : (Int64, Int64) = (1, 2147483562)
			let b = Double(genhi - genlo + 1)
			let q : Double = 1000
			let k = Double(h) - Double(l) +  1
			let magtgt = k * q
			
			func entropize(_ mag : Double, _ v : Double, _ g : G) -> (Double, G) {
				if mag >= magtgt {
					return (v, g)
				} else {
					let (x, g_) = g.next
					let v_ = (v * b + (Double(x) - Double(genlo)))
					return entropize(mag * b, v_, g_)
				}
			}
			
			let (v, rng_) = entropize(1, 0, gen)
			return (UInt64(Double(l) + (v.truncatingRemainder(dividingBy: k))), rng_)
		}
	}
}

extension Float : RandomType {
	/// Produces a random `Float` value in the range `[Float.min, Float.max]`.
	public static func random<G : RandomGeneneratorType>(_ rng : G) -> (Float, G) {
		let (x, rng_) : (Int32, G) = randomBound(rng)
		let twoto24 = Int32(2) ^ Int32(24)
		let mask24 = twoto24 - 1

		return (Float(mask24 & (x)) / Float(twoto24), rng_)
	}

	/// Returns a random `Float` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (Float, Float), gen : G) -> (Float, G) {
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
	/// Produces a random `Float` value in the range `[Double.min, Double.max]`.
	public static func random<G : RandomGeneneratorType>(_ rng : G) -> (Double, G) {
		let (x, rng_) : (Int64, G) = randomBound(rng)
		let twoto53 = Int64(2) ^ Int64(53)
		let mask53 = twoto53 - 1

		return (Double(mask53 & (x)) / Double(twoto53), rng_)
	}

	/// Returns a random `Double` value using the given range and generator.
	public static func randomInRange<G : RandomGeneneratorType>(_ range : (Double, Double), gen : G) -> (Double, G) {
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
private enum ClockTimeResult {
	case success
	case failure(Int)
}

private func mkStdRNG(_ o : Int) -> StdGen {
	func mkStdGen32(_ sMaybeNegative : Int) -> StdGen {
		let s       = sMaybeNegative & Int.max
		let (q, s1) = (s / 2147483562, s % 2147483562)
		let s2      = q % 2147483398
		return StdGen(s1 + 1, s2 + 1)
	}

	let ct = Int(clock())
	var tt = timespec()
	switch clock_gettime(0, &tt) {
	case .success:
		break
	case let .failure(error):
		fatalError("call to `clock_gettime` failed. error: \(error)")
	}

	let (sec, psec) = (tt.tv_sec, tt.tv_nsec)
	let (ll, _) = Int(sec).multipliedReportingOverflow(by: 12345)
	return mkStdGen32(ll.addingReportingOverflow(psec.addingReportingOverflow(ct.addingReportingOverflow(o).0).0).0)
}

private func clock_gettime(_ : Int, _ t : UnsafeMutablePointer<timespec>) -> ClockTimeResult {
	var now : timeval = timeval()
	let rv = gettimeofday(&now, nil)
	if rv != 0 {
		return .failure(Int(rv))
	}
	t.pointee.tv_sec  = now.tv_sec
	t.pointee.tv_nsec = Int(now.tv_usec) * 1000

	return .success
}

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif
