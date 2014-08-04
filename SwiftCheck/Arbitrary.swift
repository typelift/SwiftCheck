//
//  Arbitrary.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

protocol Arbitrary {
	typealias A : Arbitrary
	class func arbitrary() -> Gen<A>
	func shrink() -> [A]
}

extension Bool : Arbitrary {
	typealias A = Bool
	static func arbitrary() -> Gen<Bool> {
		return choose((false, true))
	}

	func shrink() -> [Bool] {
		if self {
			return [false]
		}
		return []
	}
}

struct MaybeArbitrary<A : Arbitrary> : Arbitrary {
	typealias A = Maybe<A>

	public let m : Maybe<A>

	public init(_ m: Maybe<A>) {
		self.m = m
	}

	static func arbitrary() -> Gen<Maybe<A>> {
		return frequency([(1, Gen<Maybe<A>>.pure(Maybe.Nothing)), (3, liftM({ (let x) in return Just(x.arbitrary()) }))])
	}

	func shrink() -> [Maybe<A>] {
		switch self.m {
			case .Just(let x):
				return .Nothing +> x.shrink().map() { Just($0) }
			default:
				return []
		}
	}
}



protocol CoArbitrary {
	class func coarbitrary<C>(x: Self) -> Gen<C> -> Gen<C>
}
