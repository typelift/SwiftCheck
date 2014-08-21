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
    func arbitrary() -> Gen<A>
	func shrink() -> [A]
}

extension Bool : Arbitrary {
	typealias A = Bool
	public func arbitrary() -> Gen<Bool> {
		return choose((false, true))
	}

	public func shrink() -> [Bool] {
		if self {
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
	public func arbitrary() -> Gen<Int> {
		return sized({ (let n) in
            return choose((-n, n))
        })
	}

	public func shrink() -> [Int] {
		return []
	}
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
