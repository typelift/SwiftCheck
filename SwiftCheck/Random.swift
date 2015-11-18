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

/// A library-provided standard random number generator.
public let standardRNG : StdGen = mkStdRNG(time(nil))

/// 
public struct StdGen : RandomGeneneratorType {
	let seed1 : Int
	let seed2 : Int

	/// Creates a
	public init(replaySeed : Int) {
		func mkStdGen32(sMaybeNegative : Int) -> StdGen {
			let s       = sMaybeNegative & Int.max
			let (q, s1) = (s / 2147483562, s % 2147483562)
			let s2      = q % 2147483398
			return StdGen((s1+1), (s2+1))
		}
		self = mkStdGen32(replaySeed)
	}

	init(_ seed1 : Int, _ seed2 : Int) {
		self.seed1 = seed1
		self.seed2 = seed2
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

public func newStdGen() -> StdGen {
	return standardRNG.split.1
}

/// Types that can generate random versions of themselves.
public protocol RandomType {
	static func randomInRange<G : RandomGeneneratorType>(range : (Self, Self), gen : G) -> (Self, G)
}

/// Generates a random value from a LatticeType random type.
public func random<A : protocol<LatticeType, RandomType>, G : RandomGeneneratorType>(gen : G) -> (A, G) {
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
		let (min, max) = (Int64(minl), Int64(maxl))
		let (r, g) = gen.next
		let result = (Int64(r) % ((max + 1) - min)) + min

		return (Int(truncatingBitPattern: result), g)
	}
}

extension Int8 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Int8, Int8), gen : G) -> (Int8, G) {
		let (minl, maxl) = range
		let (min, max) = (Int64(minl), Int64(maxl))
		let (r, g) = gen.next
		let result = (Int64(r) % ((max + 1) - min)) + min

		return (Int8(truncatingBitPattern: result), g)
	}
}

extension Int16 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Int16, Int16), gen : G) -> (Int16, G) {
		let (minl, maxl) = range
		let (min, max) = (Int64(minl), Int64(maxl))
		let (r, g) = gen.next
		let result = (Int64(r) % ((max + 1) - min)) + min

		return (Int16(truncatingBitPattern: result), g)
	}
}

extension Int32 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Int32, Int32), gen : G) -> (Int32, G) {
		let (minl, maxl) = range
		let (min, max) = (Int64(minl), Int64(maxl))
		let (r, g) = gen.next
		let result = (Int64(r) % ((max + 1) - min)) + min

		return (Int32(truncatingBitPattern: result), g)
	}
}

extension Int64 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Int64, Int64), gen : G) -> (Int64, G) {
		let (minl, maxl) = range
		let (min, max) = (Int64(minl), Int64(maxl))
		let (r, g) = gen.next
		let result = (Int64(r) % ((max + 1) - min)) + min

		return (result, g)
	}
}

extension UInt : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (UInt, UInt), gen : G) -> (UInt, G) {
		let (min, max) = range
		let (r, g) = gen.next
		let result = (UInt(r) % ((max + 1) - min)) + min

		return (result, g)
	}
}

extension UInt8 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (UInt8, UInt8), gen : G) -> (UInt8, G) {
		let (min, max) = range
		let (r, g) = gen.next
		let result = (UInt8(truncatingBitPattern: r) % ((max + 1) - min)) + min

		return (result, g)
	}
}

extension UInt16 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (UInt16, UInt16), gen : G) -> (UInt16, G) {
		let (min, max) = range
		let (r, g) = gen.next
		let result = (UInt16(truncatingBitPattern: r) % ((max + 1) - min)) + min

		return (result, g)
	}
}

extension UInt32 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (UInt32, UInt32), gen : G) -> (UInt32, G) {
		let (min, max) = range
		let (r, g) = gen.next
		let result = (UInt32(truncatingBitPattern: r) % ((max + 1) - min)) + min

		return (result, g)
	}
}

extension UInt64 : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (UInt64, UInt64), gen : G) -> (UInt64, G) {
		let (min, max) = range
		let (r, g) = gen.next
		let result = (UInt64(r) % ((max + 1) - min)) + min

		return (result, g)
	}
}

extension Float : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Float, Float), gen : G) -> (Float, G) {
		let (min, max) = range
		let (r, g) = gen.next
		let fr = Float(r)
		let result = (fr % ((max + 1) - min)) + min

		return (result, g)
	}
}

extension Double : RandomType {
	public static func randomInRange<G : RandomGeneneratorType>(range : (Double, Double), gen : G) -> (Double, G) {
		let (min, max) = range
		let (r, g) = gen.next
		let dr = Double(r)
		let result = (dr % ((max + 1) - min)) + min

		return (result, g)
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
