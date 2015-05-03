//
//  Arbitrary.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Darwin

public protocol Arbitrary {
//	typealias A : Arbitrary
	static func arbitrary() -> Gen<Self>
	static func shrink(Self) -> [Self]
}

extension Bool : Arbitrary {
	typealias A = Bool
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
	typealias A = Int
	public static func arbitrary() -> Gen<Int> {
		return sized({ n in Gen.pure((Int(arc4random()) % (n + n + 1)) - n) })
	}

	public static func shrink(x : Int) -> [Int] {
		return shrinkIntegral(x)
	}
}

extension Int8 : Arbitrary {
	typealias A = Int8
	public static func arbitrary() -> Gen<Int8> {
		return sized({ n in Gen.pure((Int8(arc4random()) % (n + n + 1)) - n) })
	}

	public static func shrink(x : Int8) -> [Int8] {
		return shrinkIntegral(x)
	}
}

extension Int16 : Arbitrary {
	typealias A = Int16
	public static func arbitrary() -> Gen<Int16> {
		return sized({ n in Gen.pure((Int16(arc4random()) % (n + n + 1)) - n) })
	}

	public static func shrink(x : Int16) -> [Int16] {
		return shrinkIntegral(x)
	}
}

extension Int32 : Arbitrary {
	typealias A = Int32
	public static func arbitrary() -> Gen<Int32> {
		return sized({ n in Gen.pure((Int32(arc4random()) % (n + n + 1)) - n) })
	}

	public static func shrink(x : Int32) -> [Int32] {
		return shrinkIntegral(x)
	}
}

extension Int64 : Arbitrary {
	typealias A = Int64
	public static func arbitrary() -> Gen<Int64> {
		return sized({ n in Gen.pure((Int64(arc4random()) % (n + n + 1)) - n) })
	}

	public static func shrink(x : Int64) -> [Int64] {
		return shrinkIntegral(x)
	}
}

extension UInt : Arbitrary {
	typealias A = UInt
	public static func arbitrary() -> Gen<UInt> {
		return sized({ n in Gen<UInt>.pure(UInt(arc4random()) % UInt(abs(n))) })
	}

	public static func shrink(x : UInt) -> [UInt] {
		return shrinkIntegral(x)
	}
}

extension UInt8 : Arbitrary {
	typealias A = UInt8
	public static func arbitrary() -> Gen<UInt8> {
		return sized({ n in
			return Gen<UInt8>.pure(UInt8(truncatingBitPattern: arc4random()) % UInt8(truncatingBitPattern: abs(n)))
		})
	}

	public static func shrink(x : UInt8) -> [UInt8] {
		return shrinkIntegral(x)
	}
}

extension UInt16 : Arbitrary {
	typealias A = UInt16
	public static func arbitrary() -> Gen<UInt16> {
		return sized({ n in Gen<UInt16>.pure(UInt16(truncatingBitPattern: arc4random()) % UInt16(truncatingBitPattern: abs(n))) })
	}

	public static func shrink(x : UInt16) -> [UInt16] {
		return shrinkIntegral(x)
	}
}

extension UInt32 : Arbitrary {
	typealias A = UInt32
	public static func arbitrary() -> Gen<UInt32> {
		return sized({ n in Gen<UInt32>.pure(arc4random() % UInt32(truncatingBitPattern: abs(n))) })
	}

	public static func shrink(x : UInt32) -> [UInt32] {
		return shrinkIntegral(x)
	}
}

extension UInt64 : Arbitrary {
	typealias A = UInt64
	public static func arbitrary() -> Gen<UInt64> {
		return sized({ n in Gen<UInt64>.pure(UInt64(arc4random()) % UInt64(abs(n))) })
	}

	public static func shrink(x : UInt64) -> [UInt64] {
		return shrinkIntegral(x)
	}
}

extension Float : Arbitrary {
	typealias A = Float
	public static func arbitrary() -> Gen<Float> {
		return sized({ n in
			return n == 0 ? Gen<Float>.pure(0.0) : Gen<Float>.pure(Float(-n) + Float(arc4random()) / Float(UINT32_MAX / UInt32((n)*2)))
		})
	}

	public static func shrink(x : Float) -> [Float] {
		return shrinkFloat(x)
	}
}

extension Double : Arbitrary {
	typealias A = Double
	public static func arbitrary() -> Gen<Double> {
		return sized({ n in
			return n == 0 ? Gen<Double>.pure(0.0) : Gen<Double>.pure(Double(-n) + Double(arc4random()) / Double(UINT32_MAX / UInt32(n*2)))
		})
	}

	public static func shrink(x : Double) -> [Double] {
		return shrinkDouble(x)
	}
}

extension UnicodeScalar : Arbitrary {
	typealias A = UnicodeScalar
	public static func arbitrary() -> Gen<UnicodeScalar> {
		return UInt32.arbitrary().bind { Gen.pure(UnicodeScalar($0)) }
	}

	public static func shrink(x : UnicodeScalar) -> [UnicodeScalar] {
		return shrinkNone(x)
	}
}

extension String : Arbitrary {
	typealias A = String
	public static func arbitrary() -> Gen<String> {
		let chars = sized({ n in Character.arbitrary().vectorOf(n) })
		return chars.bind { ls in Gen<String>.pure(String(ls)) }
	}

	public static func shrink(x : String) -> [String] {
		return shrinkNone(x)
	}
}

extension Character : Arbitrary {
	typealias A = Character
	public static func arbitrary() -> Gen<Character> {
		return choose((32, 255)).bind { Gen.pure(Character(UnicodeScalar($0))) }
	}

	public static func shrink(x : Character) -> [Character] {
		return shrinkNone(x)
	}
}

public func arbitraryArray<A : Arbitrary>() -> Gen<[A]> {
	return sized({ n in
		return choose((0, n)).bind { k in
			return sequence(Array(1...k).map({ _ in A.arbitrary() }))
		}
	})
}

public func withBounds<A : LatticeType>(f : A -> A -> Gen<A>) -> Gen<A> {
	return f(A.min)(A.max)
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

public func shrinkNone<A>(_ : A) -> [A] {
	return []
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

public func shrinkIntegral<A : IntegerType>(x : A) -> [A] {
	return unfoldr({ i in
		if i <= 0 {
			return .None
		}
		let n = i / 2
		return .Some((n, n))
	}, initial: x)
}

public func shrinkFloat(x : Float) -> [Float] {
	return unfoldr({ i in
		if i == 0.0 {
			return .None
		}
		let n = i / 2.0
		return .Some((n, n))
	}, initial: x)
}

public func shrinkDouble(x : Double) -> [Double] {
	return unfoldr({ i in
		if i == 0.0 {
			return .None
		}
		let n = i / 2.0
		return .Some((n, n))
	}, initial: x)
}

//struct OptionalArbitrary<A : Arbitrary> : Arbitrary {
//	typealias A = Optional<A>
//
//	public let m : Optional<A>
//
//	public init(_ m: Optional<A>) {
//		self.m = m
//	}
//
//	static func arbitrary() -> Gen<Optional<A>> {
//		return frequency([(1, Gen<Optional<A>>.pure(Optional.None)), (3, liftM({ x in return Some(x.arbitrary()) }))])
//	}
//
//	func shrink() -> [Optional<A>] {
//		switch self.m {
//			case .Some(let x):
//				return .None +> x.shrink().map() { Some($0) }
//			default:
//				return []
//		}
//	}
//}



protocol CoArbitrary {
	static func coarbitrary<C>(x: Self) -> Gen<C> -> Gen<C>
}

public func coarbitraryIntegral<A : IntegerType, B>(x : A) -> Gen<B> -> Gen<B> {
	return { $0.variant(x) }
}

extension Bool : CoArbitrary {
	public static func coarbitrary<C>(x: Bool) -> Gen<C> -> Gen<C> {
		return { g in 
			if x {
				return g.variant(1)
			}
			return g.variant(0)
		}
	}
}

extension Int : CoArbitrary {
	public static func coarbitrary<C>(x: Int) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension Int8 : CoArbitrary {
	public static func coarbitrary<C>(x: Int8) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension Int16 : CoArbitrary {
	public static func coarbitrary<C>(x: Int16) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension Int32 : CoArbitrary {
	public static func coarbitrary<C>(x: Int32) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension Int64 : CoArbitrary {
	public static func coarbitrary<C>(x: Int64) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension UInt : CoArbitrary {
	public static func coarbitrary<C>(x: UInt) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension UInt8 : CoArbitrary {
	public static func coarbitrary<C>(x: UInt8) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension UInt16 : CoArbitrary {
	public static func coarbitrary<C>(x: UInt16) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension UInt32 : CoArbitrary {
	public static func coarbitrary<C>(x: UInt32) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}

extension UInt64 : CoArbitrary {
	public static func coarbitrary<C>(x: UInt64) -> Gen<C> -> Gen<C> {
		return coarbitraryIntegral(x)
	}
}


