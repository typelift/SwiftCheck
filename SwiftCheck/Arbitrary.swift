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

extension Bool : CoArbitrary {
	public static func coarbitrary<C>(x: Bool) -> Gen<C> -> Gen<C> {
		if x {
			return variant(1)
		}
		return variant(0)
	}
}

extension Int : Arbitrary {
	typealias A = Int
	public static func arbitrary() -> Gen<Int> {
		return arbitrarySizedInteger()
	}

	public static func shrink(_ : Int) -> [Int] {
		return []
	}
}

public func withBounds<A : Bounded>(f : A -> A -> Gen<A>) -> Gen<A> {
	return f(A.minBound())(A.maxBound())
}

public func arbitraryBoundedIntegral<A : Bounded where A : IntegerLiteralConvertible>() -> Gen<A> {
	return withBounds({ (let mn : A) -> A -> Gen<A> in
		return { (let mx : A) -> Gen<A> in
			return choose((A.convertFromIntegerLiteral(unsafeCoerce(mn)), A.convertFromIntegerLiteral(unsafeCoerce(mx)))) >>= { (let n) in
				return Gen<A>.pure(n)
			}
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
		})(choose((n, n)))
	})
}

public func shrinkNothing<A>(_ : A) -> [A] {
	return []
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
