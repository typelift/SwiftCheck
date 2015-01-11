//
//  Arbitrary.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Basis
import Darwin

public protocol Arbitrary : Printable {
//	typealias A : Arbitrary
	class func arbitrary() -> Gen<Self>
	class func shrink(Self) -> [Self]
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
		return sized({ n in Gen<UInt>.pure(UInt(arc4random() &% UInt32(abs(n)))) })
	}

	public static func shrink(x : UInt) -> [UInt] {
		return shrinkIntegral(x)
	}
}

extension UInt8 : Arbitrary {
	typealias A = UInt8
	public static func arbitrary() -> Gen<UInt8> {
		return sized({ n in Gen<UInt8>.pure(UInt8(arc4random() &% UInt32(abs(n)))) })
	}

	public static func shrink(x : UInt8) -> [UInt8] {
		return shrinkIntegral(x)
	}
}

extension UInt16 : Arbitrary {
	typealias A = UInt16
	public static func arbitrary() -> Gen<UInt16> {
		return sized({ n in Gen<UInt16>.pure(UInt16(arc4random() &% UInt32(abs(n)))) })
	}

	public static func shrink(x : UInt16) -> [UInt16] {
		return shrinkIntegral(x)
	}
}

extension UInt32 : Arbitrary {
	typealias A = UInt32
	public static func arbitrary() -> Gen<UInt32> {
		return sized({ n in Gen<UInt32>.pure(UInt32(arc4random() &% UInt32(abs(n)))) })
	}

	public static func shrink(x : UInt32) -> [UInt32] {
		return shrinkIntegral(x)
	}
}

extension UInt64 : Arbitrary {
	typealias A = UInt64
	public static func arbitrary() -> Gen<UInt64> {
		return sized({ n in Gen<UInt64>.pure(UInt64(arc4random() &% UInt32(abs(n)))) })
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

public func arbitraryArray<A : Arbitrary>() -> Gen<[A]> {
	return sized({ n in
		return choose((0, n)) >>- { k in
			return sequence(Array(1...k).map({ _ in A.arbitrary() }))
		}
	})
}

public func withBounds<A : Bounded>(f : A -> A -> Gen<A>) -> Gen<A> {
	return f(A.minBound())(A.maxBound())
}

public func arbitraryBoundedIntegral<A : Bounded where A : SignedIntegerType>() -> Gen<A> {
	return withBounds({ (let mn : A) -> A -> Gen<A> in
		return { (let mx : A) -> Gen<A> in
			return choose((A(integerLiteral: unsafeCoerce(mn)), A(integerLiteral: unsafeCoerce(mx)))) >>- { n in
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

private func inBounds<A : IntegerType>(fi : (Int -> A)) -> Gen<Int> -> Gen<A> {
	return { g in
		return Gen.fmap(fi)(suchThat(g)({ x in
			return (fi(x) as Int) == x
		}))
	}
}

public func shrinkNone<A>(_ : A) -> [A] {
	return []
}

private func shrinkOne<A>(shr : A -> [A])(lst : [A]) -> [[[A]]] {
	switch destruct(lst) {
		case .Empty():
			return []
		case .Cons(let x, let xs):
			return concatMap({ x_ in
				return [[ (x_ <| xs) ]]
			})(shr(x)) + concatMap({ xs_ in
				return [ ([x] <| xs_) ]
			})(shrinkOne(shr)(lst: xs))
	}
}

private func removes<A>(k : Int)(n : Int)(xs : [A]) -> [[A]] {
	if k > n {
		return []
	}
	let xs1 = take(k)(xs)
	let xs2 = drop(k)(xs)
	if xs2.count == 0 {
		return [[]]
	}
	return [xs2] + removes(k)(n: n - k)(xs: xs2).map({ lst in
		return xs1 + lst
	})
}

public func shrinkList<A>(shr : A -> [A]) -> [A] -> [[A]] {
	return { xs in
		let n = xs.count
		return concat((concatMap({ k in
			return [removes(k)(n: n)(xs: xs)]
		})(takeWhile({ x in
			return x > 0
		})(iterate({ x in
			return x / 2
		})(n))) + (shrinkOne(shr)(lst: xs))))
	}
}

public func shrinkIntegral<A : IntegerType>(x: A) -> [A] {
	let z = (x < 0) ? (0 - x) : x
	let l = [z] + (takeWhile({ y in
		return moralAbs(y, x)
	})(tail(iterate({ n in
		return n / 2
	})(x))))
	return nub(l)
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
	return nub([y] + shrinkIntegral(Int64(y)).map({ n in
		return Float(n)
	}))
}

public func shrinkDoubleToInteger(x : Double) -> [Double] {
	let y = (x < 0) ? -x : x
	return nub([y] + shrinkIntegral(Int64(y)).map({ n in
		return Double(n)
	}))
}

public func shrinkFloat(x : Float) -> [Float] {
	let xss = take(20)(iterate({ n in
		return n / 2.0
	})(x)).filter({ x2 in
		return abs(x - x2) < abs(x)
	})
	return nub(shrinkFloatToInteger(x) + xss)
}

public func shrinkDouble(x : Double) -> [Double] {
	return nub(shrinkDoubleToInteger(x) + take(20)(iterate({ n in
		return n / 2.0
	})(x)).filter({ x_ in
		return abs(x - x_) < abs(x)
	}))
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

