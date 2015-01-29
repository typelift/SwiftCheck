//
//  Modifiers.swift
//  SwiftCheck-iOS
//
//  Created by Robert Widmann on 1/29/15.
//  Copyright (c) 2015 CodaFi. All rights reserved.
//

import Swiftz

public struct Blind<A : Arbitrary> : Arbitrary, Printable {
	let getBlind : A
	
	public init(_ blind : A) {
		self.getBlind = blind
	}
	
	public var description : String {
		return "(*)"
	}
	
	private static func create(blind : A) -> Blind<A> {
		return Blind(blind)
	}
	
	public static func arbitrary() -> Gen<Blind<A>> {
		return Blind.create <^> A.arbitrary()
	}
	
	public static func shrink(bl : Blind<A>) -> [Blind<A>] {
		return Blind.create <^> A.shrink(bl.getBlind)
	}
}

public func <^><A : Arbitrary, B : Arbitrary>(f: A -> B, ar : Blind<A>) -> Blind<B> {
	return Blind<B>(f(ar.getBlind))
}

public struct Fixed<A : Arbitrary> : Arbitrary {
	let getFixed : A
	
	public init(_ fixed : A) {
		self.getFixed = fixed
	}
	
	private static func create(blind : A) -> Fixed<A> {
		return Fixed(blind)
	}
	
	public static func arbitrary() -> Gen<Fixed<A>> {
		return Fixed.create <^> A.arbitrary()
	}
	
	public static func shrink(bl : Fixed<A>) -> [Fixed<A>] {
		return []
	}
}

public func <^><A : Arbitrary, B : Arbitrary>(f: A -> B, ar : Fixed<A>) -> Fixed<B> {
	return Fixed<B>(f(ar.getFixed))
}

public struct Positive<A : protocol<Arbitrary, SignedNumberType>> : Arbitrary {
	let getPositive : A
	
	public init(_ pos : A) {
		self.getPositive = pos
	}
	
	private static func create(blind : A) -> Positive<A> {
		return Positive(blind)
	}
	
	public static func arbitrary() -> Gen<Positive<A>> {
		return ((Positive.create • abs) <^> A.arbitrary().suchThat(!=0)).suchThat({ $0.getPositive > 0 })
	}
	
	public static func shrink(bl : Positive<A>) -> [Positive<A>] {
		return A.shrink(bl.getPositive).filter(>0).map({ Positive($0) })
	}
}

public func <^><A : protocol<Arbitrary, SignedNumberType>, B : protocol<Arbitrary, SignedNumberType>>(f: A -> B, ar : Positive<A>) -> Positive<B> {
	return Positive<B>(f(ar.getPositive))
}

public struct NonZero<A : protocol<Arbitrary, IntegerType>> : Arbitrary {
	let getNonZero : A
	
	public init(_ non : A) {
		self.getNonZero = non
	}
	
	private static func create(blind : A) -> NonZero<A> {
		return NonZero(blind)
	}
	
	public static func arbitrary() -> Gen<NonZero<A>> {
		return NonZero.create <^> A.arbitrary().suchThat(!=0)
	}
	
	public static func shrink(bl : NonZero<A>) -> [NonZero<A>] {
		return A.shrink(bl.getNonZero).filter(!=0).map({ NonZero($0) })
	}
}

public func <^><A : protocol<Arbitrary, IntegerType>, B : protocol<Arbitrary, IntegerType>>(f: A -> B, ar : NonZero<A>) -> NonZero<B> {
	return NonZero<B>(f(ar.getNonZero))
}

