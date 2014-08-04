//
//  Functor.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

operator infix <^ {
	associativity left
	precedence 4
}

public class F<A> {
	public init() {

	}
}

public protocol Functor {
	typealias A
	typealias B
	typealias FB = F<B>
	func fmap(f: (A -> B)) -> FB
}

//@infix func <^<A, B, F : Functor, G : Functor where F.B == B, F.A == A>(x: A)(f: F) -> G {
//	return f.fmap(const(x, f))
//}
