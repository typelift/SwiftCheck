//
//  Random.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import func Darwin.time
import func Darwin.rand

public protocol RandomGen {
	func next() -> (Int, Self)
	
	func genRange() -> (Int, Int)
	func split() -> (Self, Self)
}

/// A library-provided standard random number generator.
let standardRNG : StdGen = StdGen(time(nil))

public struct StdGen : RandomGen {
	let seed: Int
	
	init(_ seed : Int) {
		self.seed = seed
	}
	
	public func next() -> (Int, StdGen) {
		let s = Int(time(nil))
		return (Int(rand()), StdGen(s))
	}
	
	public func split() -> (StdGen, StdGen) {
		let (s1, g) = self.next()
		let (s2, _) = g.next()
		return (StdGen(s1), StdGen(s2))
	}
	
	public func genRange() -> (Int, Int) {
		return (Int.min, Int.max)
	}
}

public func newStdGen() -> StdGen {
	return standardRNG.split().1
}

private func mkStdRNG(seed : Int) -> StdGen {
	return StdGen(seed)
}

/// Types that can generate random versions of themselves. 
public protocol RandomType {
	static func randomInRange<G : RandomGen>(range : (Self, Self), gen : G) -> (Self, G)
}

/// Generates a random value from a LatticeType random type.
public func random<A : protocol<LatticeType, RandomType>, G : RandomGen>(gen : G) -> (A, G) {
	return A.randomInRange((A.min, A.max), gen: gen)
}

extension Int : RandomType {
	public static func randomInRange<G : RandomGen>(range : (Int, Int), gen : G) -> (Int, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let result = (r % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}

extension Int8 : RandomType {
	public static func randomInRange<G : RandomGen>(range : (Int8, Int8), gen : G) -> (Int8, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let result = (r % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}

extension Int16 : RandomType {
	public static func randomInRange<G : RandomGen>(range : (Int16, Int16), gen : G) -> (Int16, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let result = (r % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}

extension Int32 : RandomType {
	public static func randomInRange<G : RandomGen>(range : (Int32, Int32), gen : G) -> (Int32, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let result = (r % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}

extension Int64 : RandomType {
	public static func randomInRange<G : RandomGen>(range : (Int64, Int64), gen : G) -> (Int64, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let result = (r % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}

extension UInt : RandomType {
	public static func randomInRange<G : RandomGen>(range : (UInt, UInt), gen : G) -> (UInt, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let result = (UInt(r) % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}

extension UInt8 : RandomType {
	public static func randomInRange<G : RandomGen>(range : (UInt8, UInt8), gen : G) -> (UInt8, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let result = (UInt8(r) % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}

extension UInt16 : RandomType {
	public static func randomInRange<G : RandomGen>(range : (UInt16, UInt16), gen : G) -> (UInt16, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let result = (UInt16(r) % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}

extension UInt32 : RandomType {
	public static func randomInRange<G : RandomGen>(range : (UInt32, UInt32), gen : G) -> (UInt32, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let result = (UInt32(r) % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}

extension UInt64 : RandomType {
	public static func randomInRange<G : RandomGen>(range : (UInt64, UInt64), gen : G) -> (UInt64, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let result = (UInt64(r) % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}

extension Float : RandomType {
	public static func randomInRange<G : RandomGen>(range : (Float, Float), gen : G) -> (Float, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let fr = Float(r)
		let result = (fr % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}

extension Double : RandomType {
	public static func randomInRange<G : RandomGen>(range : (Double, Double), gen : G) -> (Double, G) {
		let (min, max) = range
		let (r, g) = gen.next()
		let dr = Double(r)
		let result = (dr % ((max + 1) - min)) + min;
		
		return (result, g);
	}
}
