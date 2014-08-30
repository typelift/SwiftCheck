//
//  Arbitrary.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public protocol Arbitrary {
	typealias A : Arbitrary
	class func arbitrary() -> Gen<A>
	class func shrink(A) -> [A]
}

extension Bool : Arbitrary {
	typealias A = Bool
	public static func arbitrary() -> Gen<Bool> {
		return choose((false, true))
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
		return arbitrarySizedInteger()
	}

	public static func shrink(x : Int) -> [Int] {
		return shrinkIntegral(x)
	}
}

extension Int8 : Arbitrary {
	typealias A = Int8
	public static func arbitrary() -> Gen<Int8> {
		return arbitrarySizedBoundedInteger()
	}

	public static func shrink(x : Int8) -> [Int8] {
		return shrinkIntegral(x)
	}
}

extension Int16 : Arbitrary {
	typealias A = Int16
	public static func arbitrary() -> Gen<Int16> {
		return arbitrarySizedBoundedInteger()
	}

	public static func shrink(x : Int16) -> [Int16] {
		return shrinkIntegral(x)
	}
}

extension Int32 : Arbitrary {
	typealias A = Int32
	public static func arbitrary() -> Gen<Int32> {
		return arbitrarySizedBoundedInteger()
	}

	public static func shrink(x : Int32) -> [Int32] {
		return shrinkIntegral(x)
	}
}

extension Int64 : Arbitrary {
	typealias A = Int64
	public static func arbitrary() -> Gen<Int64> {
		return arbitrarySizedBoundedInteger()
	}

	public static func shrink(x : Int64) -> [Int64] {
		return shrinkIntegral(x)
	}
}

extension UInt : Arbitrary {
	typealias A = UInt
	public static func arbitrary() -> Gen<UInt> {
		return arbitrarySizedInteger()
	}

	public static func shrink(x : UInt) -> [UInt] {
		return shrinkIntegral(x)
	}
}

extension UInt8 : Arbitrary {
	typealias A = UInt8
	public static func arbitrary() -> Gen<UInt8> {
		return arbitrarySizedBoundedInteger()
	}

	public static func shrink(x : UInt8) -> [UInt8] {
		return shrinkIntegral(x)
	}
}

extension UInt16 : Arbitrary {
	typealias A = UInt16
	public static func arbitrary() -> Gen<UInt16> {
		return arbitrarySizedBoundedInteger()
	}

	public static func shrink(x : UInt16) -> [UInt16] {
		return shrinkIntegral(x)
	}
}

extension UInt32 : Arbitrary {
	typealias A = UInt32
	public static func arbitrary() -> Gen<UInt32> {
		return arbitrarySizedBoundedInteger()
	}

	public static func shrink(x : UInt32) -> [UInt32] {
		return shrinkIntegral(x)
	}
}

extension UInt64 : Arbitrary {
	typealias A = UInt64
	public static func arbitrary() -> Gen<UInt64> {
		return arbitrarySizedBoundedInteger()
	}

	public static func shrink(x : UInt64) -> [UInt64] {
		return shrinkIntegral(x)
	}
}

extension Float : Arbitrary {
	typealias A = Float
	public static func arbitrary() -> Gen<Float> {
		return arbitrarySizedFloating()
	}

	public static func shrink(x : Float) -> [Float] {
		return shrinkFloat(x)
	}
}

extension Double : Arbitrary {
	typealias A = Double
	public static func arbitrary() -> Gen<Double> {
		return arbitrarySizedFloating()
	}

	public static func shrink(x : Double) -> [Double] {
		return shrinkDouble(x)
	}
}

public func withBounds<A : Bounded>(f : A -> A -> Gen<A>) -> Gen<A> {
	return f(A.minBound())(A.maxBound())
}

public func arbitraryBoundedIntegral<A : Bounded where A : IntegerType>() -> Gen<A> {
	return withBounds({ (let mn : A) -> A -> Gen<A> in
		return { (let mx : A) -> Gen<A> in
			return choose((A.convertFromIntegerLiteral(unsafeCoerce(mn)), A.convertFromIntegerLiteral(unsafeCoerce(mx)))) >>= { (let n) in
				return Gen<A>.pure(n)
			}
		}
	})
}

private func bits<N : IntegerType>(n : N) -> Int {
	if n / 2 == 0 {
		return 0
	}
	return 1 + bits(n / 2)
}

public func arbitrarySizedBoundedInteger<A : Bounded where A : IntegerType>() -> Gen<A> {
	return withBounds({ (let mn) in
		return { (let mx) in
			return sized({ (let s) in
				let k = 2 ^ (s * (max(bits(mn), max(bits(mx), 40))) / 100)
				return choose((max(mn as Int, (0 - k)), min(mx as Int, k))).bind({ (let n) in
					return Gen.pure(A.convertFromIntegerLiteral(unsafeCoerce(n)))
				})
			})
		}
	})
}

private func inBounds<A : IntegerType>(fi : (Int -> A)) -> Gen<Int> -> Gen<A> {
	return { (let g) in
		return suchThat(g)({ (let x) in
			return (fi(x) as Int) == x
		}).fmap(fi)
	}
}

public func arbitrarySizedInteger<A : IntegerType where A : IntegerLiteralConvertible>() -> Gen<A> {
	return sized({ (let n : Int) -> Gen<A> in
		return inBounds({ (let m) in
			return A.convertFromIntegerLiteral(unsafeCoerce(m))
		})(choose((0 - n, n)))
	})
}

public func arbitrarySizedFloating<A : FloatingPointType>() -> Gen<A> {
	let precision : Int = 9999999999999
	return sized({ (let n) in
		let m = Int(n)
		return choose((-m * precision, m * precision)) >>= { (let a) in
			return choose((1, precision)) >>= { (let b) in
				return Gen.pure(A(a % b))
			}
		}
	})
}

public func shrinkNothing<A>(_ : A) -> [A] {
	return []
}

private func shrinkOne<A>(shr : A -> [A])(lst : [A]) -> [[[A]]] {
	switch destructure(lst) {
		case .Empty():
			return []
		case .Destructure(let x, let xs):
			return (shr(x) >>= { (let x_) in
				return [[x_ +> xs]]
			}) ++ (shrinkOne(shr)(lst: xs) >>= { (let xs_) in
				return [[x] +> xs_]
			})
	}
	
}

private func removes<A>(k : Int)(n : Int)(xs : [A]) -> [[A]] {
	if k > n {
		return []
	}
	let xs1 = take(k)(xs: xs)
	let xs2 = drop(k)(lst: xs)
	if xs2.count == 0 {
		return [[]]
	}
	return xs2 +> removes(k)(n: n - k)(xs: xs2).map({ (let lst) in
		return xs1 ++ lst
	})
}

public func shrinkList<A>(shr : A -> [A]) -> [A] -> [[A]] {
	return { (let xs) in
		let n = xs.count
		return concat((takeWhile({ (let x) in
			return x > 0
		})(iterate({ (let x) in
			return x / 2
		})(n)) >>= { (let k) in
			return [removes(k)(n: n)(xs: xs)]
		}) ++ (shrinkOne(shr)(lst: xs)))
	}
}

public func shrinkIntegral<A : IntegerType>(x: A) -> [A] {
	let z = (x >= 0) ? x : (0 - x)
	return nub([z] ++ (takeWhile({ (let y) in
		return moralAbs(y, z)
	})(tail(iterate({ (let n) in
		return n / 2
	})(x)) >>= { (let i) in
		return 0 +> [z - 1]
	})))
}

private func moralAbs<A : IntegerType>(a : A, b : A) -> Bool {
	switch (a >= 0, b >= 0) {
		case (true, true):
			return a < b
		case (false, false):
			return a > b
		case (true, false):
			return (a + b) < 0
		case (false, true):
			return (a + b) > 0
		default:
			assert(false, "Non-exhaustive pattern match performed.")
	}
}

public func shrinkFloatToInteger(x : Float) -> [Float] {
	let y = (x < 0) ? -x : x
	return nub([y] ++ shrinkIntegral(Int64(y)).map({ (let n) in
		return Float(n)
	}))
}

public func shrinkDoubleToInteger(x : Double) -> [Double] {
	let y = (x < 0) ? -x : x
	return nub([y] ++ shrinkIntegral(Int64(y)).map({ (let n) in
		return Double(n)
	}))
}

public func shrinkFloat(x : Float) -> [Float] {
	return nub(shrinkFloatToInteger(x) ++ take(20)(xs: iterate({ (let n) in
		return n / 2.0
	})(x)).filter({ (let x_) in
		return abs(x - x_) < abs(x)
	}))
}

public func shrinkDouble(x : Double) -> [Double] {
	return nub(shrinkDoubleToInteger(x) ++ take(20)(xs: iterate({ (let n) in
		return n / 2.0
	})(x)).filter({ (let x_) in
		return abs(x - x_) < abs(x)
	}))
}

//struct MaybeArbitrary<A : Arbitrary> : Arbitrary {
//	typealias A = Maybe<A>
//
//	public let m : Maybe<A>
//
//	public init(_ m: Maybe<A>) {
//		self.m = m
//	}
//
//	static func arbitrary() -> Gen<Maybe<A>> {
//		return frequency([(1, Gen<Maybe<A>>.pure(Maybe.Nothing)), (3, liftM({ (let x) in return Just(x.arbitrary()) }))])
//	}
//
//	func shrink() -> [Maybe<A>] {
//		switch self.m {
//			case .Just(let x):
//				return .Nothing +> x.shrink().map() { Just($0) }
//			default:
//				return []
//		}
//	}
//}



protocol CoArbitrary {
	class func coarbitrary<C>(x: Self) -> Gen<C> -> Gen<C>
}

public func coarbitraryIntegral<A : IntegerType, B>(x : A) -> Gen<B> -> Gen<B> {
	return variant(x)
}

extension Bool : CoArbitrary {
	public static func coarbitrary<C>(x: Bool) -> Gen<C> -> Gen<C> {
		if x {
			return variant(1)
		}
		return variant(0)
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

infix operator ^ {}

private func ^(ba : Int, ex : Int) -> Int {
	var base = ba
	var exp = ex
	var result : Int = 1;
	while exp >= 0 {
		if (exp & 1) != 0 {
			result *= base;
		}
		exp >>= 1;
		base *= base;
	}

	return result;
}
