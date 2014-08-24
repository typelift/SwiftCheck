//
//  Box.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/9/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public final class Box<T> {
	let val : () -> T

	public init(_ value : T) {
		self.val = { value }
	}

	public var value: T {
		return val()
	}

	public func map<U>(fn: T -> U) -> Box<U> {
		return Box<U>(fn(value))
	}
}
