//
//  Comonad.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public protocol Comonad : Applicative {
	typealias FBA = F<B> -> A
	func extend(fn: FBA) -> FB
}


/// Be a dear and also implement

/// duplicate<A>(rs: M<A>) -> M<M<A>>
