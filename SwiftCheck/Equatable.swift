//
//  Equatable.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/29/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

public func == <T : protocol<Arbitrary, Equatable>>(lhs : Blind<T>, rhs : Blind<T>) -> Bool {
	return lhs.getBlind == rhs.getBlind
}

public func == <T : protocol<Arbitrary, Equatable>>(lhs : Static<T>, rhs : Static<T>) -> Bool {
	return lhs.getStatic == rhs.getStatic
}

public func == <T : protocol<Arbitrary, Equatable>>(lhs : ArrayOf<T>, rhs : ArrayOf<T>) -> Bool {
	return lhs.getArray == rhs.getArray
}

public func == <K : protocol<Arbitrary, Equatable, Hashable>, V : protocol<Equatable, Arbitrary>>(lhs : DictionaryOf<K, V>, rhs : DictionaryOf<K, V>) -> Bool {
	return lhs.getDictionary == rhs.getDictionary
}

public func == <T : protocol<Arbitrary, Equatable>>(lhs : OptionalOf<T>, rhs : OptionalOf<T>) -> Bool {
	return lhs.getOptional == rhs.getOptional
}

public func == <T : protocol<Arbitrary, Equatable, Hashable>>(lhs : SetOf<T>, rhs : SetOf<T>) -> Bool {
	return lhs.getSet == rhs.getSet
}

public func == <T : protocol<Arbitrary, SignedNumberType>>(lhs : Positive<T>, rhs : Positive<T>) -> Bool {
	return lhs.getPositive == rhs.getPositive
}

public func == <T : protocol<Arbitrary, IntegerType>>(lhs : NonZero<T>, rhs : NonZero<T>) -> Bool {
	return lhs.getNonZero == rhs.getNonZero
}

public func == <T : protocol<Arbitrary, IntegerType>>(lhs : NonNegative<T>, rhs : NonNegative<T>) -> Bool {
	return lhs.getNonNegative == rhs.getNonNegative
}
