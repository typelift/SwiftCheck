//
//  Copointed.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public protocol Copointed : Functor {
	typealias FA = F<A>
	class func copure(a: FA) -> A
}
