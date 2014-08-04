//
//  Applicative.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public protocol Applicative : Functor {
	typealias FA = F<A>
	typealias FAB = F<A -> B>
	class func pure(a: A) -> FA
	func ap(fn: FAB) -> FB
}
