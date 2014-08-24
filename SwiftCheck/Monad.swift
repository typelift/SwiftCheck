//
//  Monad.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

infix operator >> {
	associativity left
}

infix operator >>= {
	associativity left
}

infix operator <- { }

public protocol Monad : Applicative {
	typealias AFB = A -> F<B>
	func bind(fn: AFB) -> FB
}

/// Be a dear and also implement

/// join<A>(rs: M<M<A>>) -> M<A>
