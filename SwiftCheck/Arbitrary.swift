//
//  Arbitrary.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import Darwin

/// A type that implements random generation and shrinking of values.
///
/// While testing, SwiftCheck will invoke `arbitrary()` a given amount of times (usually 100 if the
/// default settings are used).  During that time, the receiver has an opportunity to call through 
/// to any data or sources of randomness it needs to return what it deems an "Arbitrary" value.
///
/// Shrinking is reduction in the complexity of a tested value to remove noise and present a minimal
/// counterexample when a property fails.  While it may seem counterintuitive, a shrink necessitates
/// returning a list of all possible "smaller" values for SwiftCheck to run through.  As long as
/// each individual value in the returned list is less than or equal to the size of the input value,
/// and is not a duplicate of the input value, a minimal case should be reached fairly efficiently.
///
/// As an example, take the `ArrayOf` implementation of shrink:
///
/// shrink(ArrayOf([1, 2, 3]))
///	> [[], [2,3], [1,3], [1,2], [0,2,3], [1,0,3], [1,1,3], [1,2,0], [1,2,2]]
///
/// SwiftCheck will search each case 1 by one and continue shrinking until it has reached a case
/// it deems minimal enough to present.
///
/// SwiftCheck implements a number of generators for common STL types for convenience.  If more fine-
/// grained testing is required see `Modifiers.swift` for an example of how to define a "Modifier"
/// type to implement it.
public protocol Arbitrary {
	static func arbitrary() -> Gen<Self>
	static func shrink(Self) -> [Self]
}

/// The implementation of a shrink that returns no alternatives.
public func shrinkNone<A>(_ : A) -> [A] {
	return []
}

/// Shrinks any IntegerType.
public func shrinkIntegral<A : IntegerType>(x : A) -> [A] {
	return unfoldr({ i in
		if i <= 0 {
			return .None
		}
		let n = i / 2
		return .Some((n, n))
	}, initial: x < 0 ? (x * -1) : x)
}


extension Bool : Arbitrary {
	public static func arbitrary() -> Gen<Bool> {
		return Gen.pure((arc4random() % 2) == 1)
	}

	public static func shrink(x : Bool) -> [Bool] {
		if x {
			return [false]
		}
		return []
	}
}

extension Int : Arbitrary {
	public static func arbitrary() -> Gen<Int> {
		let sign = ((arc4random() % 2) == 1)
		return Gen.sized { n in Gen.pure((sign ? 1 : -1) * Int(arc4random_uniform(UInt32(n)))) }
	}

	public static func shrink(x : Int) -> [Int] {
		return shrinkIntegral(x)
	}
}

extension Int8 : Arbitrary {
	public static func arbitrary() -> Gen<Int8> {
		let sign = ((arc4random() % 2) == 1)
		return Gen.sized { n in Gen.pure((sign ? 1 : -1) * Int8(arc4random_uniform(UInt32(n)))) }
	}

	public static func shrink(x : Int8) -> [Int8] {
		return shrinkIntegral(x)
	}
}

extension Int16 : Arbitrary {
	public static func arbitrary() -> Gen<Int16> {
		let sign = ((arc4random() % 2) == 1)
		return Gen.sized { n in Gen.pure((sign ? 1 : -1) * Int16(arc4random_uniform(UInt32(n)))) }
	}

	public static func shrink(x : Int16) -> [Int16] {
		return shrinkIntegral(x)
	}
}

extension Int32 : Arbitrary {
	public static func arbitrary() -> Gen<Int32> {
		let sign = ((arc4random() % 2) == 1)
		return Gen.sized { n in Gen.pure((sign ? 1 : -1) * Int32(arc4random_uniform(UInt32(n)))) }
	}

	public static func shrink(x : Int32) -> [Int32] {
		return shrinkIntegral(x)
	}
}

extension Int64 : Arbitrary {
	public static func arbitrary() -> Gen<Int64> {
		let sign = ((arc4random() % 2) == 1)
		return Gen.sized { n in Gen.pure((sign ? 1 : -1) * Int64(arc4random_uniform(UInt32(n)))) }
	}

	public static func shrink(x : Int64) -> [Int64] {
		return shrinkIntegral(x)
	}
}

extension UInt : Arbitrary {
	public static func arbitrary() -> Gen<UInt> {
		return Gen.sized { n in Gen<UInt>.pure(UInt(arc4random_uniform(UInt32(abs(n))))) }
	}

	public static func shrink(x : UInt) -> [UInt] {
		return shrinkIntegral(x)
	}
}

extension UInt8 : Arbitrary {
	public static func arbitrary() -> Gen<UInt8> {
		return Gen.sized({ n in
			return Gen.sized { n in Gen<UInt8>.pure(UInt8(arc4random_uniform(UInt32(abs(n))))) }
		})
	}

	public static func shrink(x : UInt8) -> [UInt8] {
		return shrinkIntegral(x)
	}
}

extension UInt16 : Arbitrary {
	public static func arbitrary() -> Gen<UInt16> {
		return Gen.sized { n in Gen<UInt16>.pure(UInt16(arc4random_uniform(UInt32(abs(n))))) }
	}

	public static func shrink(x : UInt16) -> [UInt16] {
		return shrinkIntegral(x)
	}
}

extension UInt32 : Arbitrary {
	public static func arbitrary() -> Gen<UInt32> {
		return Gen.sized { n in Gen<UInt32>.pure(arc4random_uniform(UInt32(abs(n)))) }
	}

	public static func shrink(x : UInt32) -> [UInt32] {
		return shrinkIntegral(x)
	}
}

extension UInt64 : Arbitrary {
	public static func arbitrary() -> Gen<UInt64> {
		return Gen.sized { n in Gen<UInt64>.pure(UInt64(arc4random_uniform(UInt32(abs(n))))) }
	}

	public static func shrink(x : UInt64) -> [UInt64] {
		return shrinkIntegral(x)
	}
}

extension Float : Arbitrary {
	public static func arbitrary() -> Gen<Float> {
		return Gen.sized({ n in
			if n == 0 {
				return Gen<Float>.pure(0.0)
			}
			return Gen<Float>.pure(Float(-n) + Float(arc4random()) / Float(UINT32_MAX / UInt32((n)*2)))
		})
	}

	public static func shrink(x : Float) -> [Float] {
		return unfoldr({ i in
			if i == 0.0 {
				return .None
			}
			let n = i / 2.0
			return .Some((n, n))
		}, initial: x)
	}
}

extension Double : Arbitrary {
	public static func arbitrary() -> Gen<Double> {
		return Gen.sized({ n in
			if n == 0 {
				return Gen<Double>.pure(0.0)
			}
			return Gen<Double>.pure(Double(-n) + Double(arc4random()) / Double(UINT32_MAX / UInt32(n*2)))
		})
	}

	public static func shrink(x : Double) -> [Double] {
		return unfoldr({ i in
			if i == 0.0 {
				return .None
			}
			let n = i / 2.0
			return .Some((n, n))
		}, initial: x)
	}
}

extension UnicodeScalar : Arbitrary {
	public static func arbitrary() -> Gen<UnicodeScalar> {
		return UInt32.arbitrary().bind { Gen.pure(UnicodeScalar($0)) }
	}

	public static func shrink(x : UnicodeScalar) -> [UnicodeScalar] {
		let s : UnicodeScalar = UnicodeScalar(UInt32(towlower(Int32(x.value))))
		return nub([ "a", "b", "c", s, "A", "B", "C", "1", "2", "3", "\n", " " ]).filter { $0 < x }
	}
}

extension String : Arbitrary {
	public static func arbitrary() -> Gen<String> {
		let chars = Gen.sized({ n in Character.arbitrary().vectorOf(n) })
		return chars.bind { ls in Gen<String>.pure(String(ls)) }
	}

	public static func shrink(s : String) -> [String] {
		return ArrayOf.shrink(ArrayOf([Character](s))).map({ String($0.getArray) })
	}
}

extension Character : Arbitrary {
	public static func arbitrary() -> Gen<Character> {
		return Gen<UInt32>.choose((32, 255)).bind { Gen.pure(Character(UnicodeScalar($0))) }
	}

	public static func shrink(x : Character) -> [Character] {
		let ss = String(x).unicodeScalars
		return UnicodeScalar.shrink(ss[ss.startIndex]).map { Character($0) }
	}
}

private func bits<N : IntegerType>(n : N) -> Int {
	if n / 2 == 0 {
		return 0
	}
	return 1 + bits(n / 2)
}

private func inBounds<A : IntegerType>(fi : (Int -> A)) -> Gen<Int> -> Gen<A> {
	return { g in
		return g.suchThat({ x in
			return (fi(x) as! Int) == x
		}).fmap(fi)
	}
}

private func nub<A : Hashable>(xs : [A]) -> [A] {
	return [A](Set(xs))
}

private func unfoldr<A, B>(f : B -> Optional<(A, B)>, #initial : B) -> [A] {
	var acc = [A]()
	var ini = initial
	while let next = f(ini) {
		acc.insert(next.0, atIndex: 0)
		ini = next.1
	}
	return acc
}


/// Coarbitrary types must take an arbitrary value of their type and yield a function that 
/// transforms a given generator by returning a new generator that depends on the input value.  Put
/// simply, the function should perturb the given generator (more than likely using `Gen.variant()`.
///
/// Using Coarbitrary types it is possible to write an Arbitrary instance for `->` (a type that
/// generates functions).
public protocol CoArbitrary {
	static func coarbitrary<C>(x : Self) -> (Gen<C> -> Gen<C>)
}

/// A corarbitrary implementation for any IntegerType
public func coarbitraryIntegral<A : IntegerType, B>(x : A) -> Gen<B> -> Gen<B> {
	return { $0.variant(x) }
}

/// A coarbitrary implementation for any Printable type.  Avoid using this function if you can, it
/// can be quite an expensive operation given a detailed enough description.
public func coarbitraryPrintable<A : Printable, B>(x : A) -> Gen<B> -> Gen<B> {
	return String.coarbitrary(x.description)
}

extension Bool : CoArbitrary {
	public static func coarbitrary<C>(x : Bool) -> Gen<C> -> Gen<C> {
		return { g in 
			if x {
				return g.variant(1)
			}
			return g.variant(0)
		}
	}
}

extension UnicodeScalar : CoArbitrary {
	public static func coarbitrary<C>(x : UnicodeScalar) -> Gen<C> -> Gen<C> {
		return UInt32.coarbitrary(x.value)
	}
}

extension Character : CoArbitrary {
	public static func coarbitrary<C>(x : Character) -> (Gen<C> -> Gen<C>) {
		let ss = String(x).unicodeScalars
		return UnicodeScalar.coarbitrary(ss[ss.startIndex])
	}
}

extension String : CoArbitrary {
	public static func coarbitrary<C>(x : String) -> (Gen<C> -> Gen<C>) {
		if x.isEmpty {
			return { $0.variant(0) }
		}
		return Character.coarbitrary(x[x.startIndex]) • String.coarbitrary(x[advance(x.startIndex, 1)..<x.endIndex])
	}
}

extension Int : CoArbitrary {
	public static func coarbitrary<C>(x : Int) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension Int8 : CoArbitrary {
	public static func coarbitrary<C>(x : Int8) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension Int16 : CoArbitrary {
	public static func coarbitrary<C>(x : Int16) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension Int32 : CoArbitrary {
	public static func coarbitrary<C>(x : Int32) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension Int64 : CoArbitrary {
	public static func coarbitrary<C>(x : Int64) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension UInt : CoArbitrary {
	public static func coarbitrary<C>(x : UInt) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension UInt8 : CoArbitrary {
	public static func coarbitrary<C>(x : UInt8) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension UInt16 : CoArbitrary {
	public static func coarbitrary<C>(x : UInt16) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension UInt32 : CoArbitrary {
	public static func coarbitrary<C>(x : UInt32) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension UInt64 : CoArbitrary {
	public static func coarbitrary<C>(x : UInt64) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

// In future, implement these with Ratios like QuickCheck.
extension Float : CoArbitrary {
	public static func coarbitrary<C>(x : Float) -> (Gen<C> -> Gen<C>) {
		return coarbitraryIntegral(Int64(x))
	}
}

extension Double : CoArbitrary {
	public static func coarbitrary<C>(x : Double) -> (Gen<C> -> Gen<C>) {
		return coarbitraryIntegral(Int64(x))
	}
}
