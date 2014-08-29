//
//  Bounded.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/28/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public protocol Bounded {
	class func minBound() -> Self
	class func maxBound() -> Self
}

//public struct BoundedEmptyTuple : Bounded {
//	typealias A = ()
//	
//	public static func minBound() -> A {
//		return ()
//	}
//	public static func maxBound() -> A {
//		return ()
//	}
//}

public enum List<T> {
    case Nil
    case Cons(T, List<T>)
}

extension Bool : Bounded {
	public static func minBound() -> Bool {
		return false
	}

	public static func maxBound() -> Bool {
		return true
	}
}

extension Character : Bounded {
	public static func minBound() -> Character {
		return "\0"
	}

	public static func maxBound() -> Character {
		return "\u{FFFF}"
	}
}

extension UInt : Bounded {
	public static func minBound() -> UInt {
		return UInt.min
	}

	public static func maxBound() -> UInt {
		return UInt.max
	}
}

extension UInt8 : Bounded {
	public static func minBound() -> UInt8 {
		return UInt8.min
	}

	public static func maxBound() -> UInt8 {
		return UInt8.max
	}
}

extension UInt16 : Bounded {
	public static func minBound() -> UInt16 {
		return UInt16.min
	}

	public static func maxBound() -> UInt16 {
		return UInt16.max
	}
}


extension UInt32 : Bounded {
	public static func minBound() -> UInt32 {
		return UInt32.min
	}

	public static func maxBound() -> UInt32 {
		return UInt32.max
	}
}


extension UInt64 : Bounded {
	public static func minBound() -> UInt64 {
		return UInt64.min
	}

	public static func maxBound() -> UInt64 {
		return UInt64.max
	}
}

extension Int : Bounded {
	public static func minBound() -> Int {
		return Int.min
	}

	public static func maxBound() -> Int {
		return Int.max
	}
}

extension Int8 : Bounded {
	public static func minBound() -> Int8 {
		return Int8.min
	}

	public static func maxBound() -> Int8 {
		return Int8.max
	}
}

extension Int16 : Bounded {
	public static func minBound() -> Int16 {
		return Int16.min
	}

	public static func maxBound() -> Int16 {
		return Int16.max
	}
}


extension Int32 : Bounded {
	public static func minBound() -> Int32 {
		return Int32.min
	}

	public static func maxBound() -> Int32 {
		return Int32.max
	}
}


extension Int64 : Bounded {
	public static func minBound() -> Int64 {
		return Int64.min
	}

	public static func maxBound() -> Int64 {
		return Int64.max
	}
}

