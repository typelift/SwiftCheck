//
//  List.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 9/10/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation
import Swift_Extras

infix operator ++ { associativity left }
infix operator +> { associativity left }

func +><T>(lhs : T, rhs : [T]) -> [T] {
	var arr = rhs
	arr.insert(lhs, atIndex: 0)
	return arr
}

func ++<T>(var lhs : [T], rhs : [T]) -> [T] {
	lhs += rhs
	return lhs
}

public func iterate<A>(f : A -> A) -> A -> [A] {
	return { (let x) in
		return [x] + iterate(f)(f(x))
	}
}

public func sum<N : IntegerType>(l : [N]) -> N {
	return foldl({ $0 + $1 })(z: 0)(l: l)
}
