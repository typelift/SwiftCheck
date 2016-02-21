//
//  Lattice.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/2/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//  Released under the MIT license.
//

/// Lattice types are types that have definable upper and lower limits.  For 
/// types like the `Int` and `Float`, their limits are the minimum and maximum 
/// possible values representable in their bit- width.  While the definition of 
/// a "limit" is flexible, generally custom types that wish to conform to 
/// `LatticeType` must come with some kind of supremum or infimum.
public protocol LatticeType {
	/// The lower limit of the type.
	static var min : Self { get }
	/// The upper limit of the type.
	static var max : Self { get }
}

extension Bool : LatticeType {
	public static var min : Bool {
		return false
	}

	public static var max : Bool {
		return true
	}
}

extension Character : LatticeType {
	public static var min : Character {
		return "\0"
	}

	public static var max : Character {
		return "\u{FFFFF}"
	}
}

extension UInt : LatticeType {}
extension UInt8 : LatticeType {}
extension UInt16 : LatticeType {}
extension UInt32 : LatticeType {}
extension UInt64 : LatticeType {}
extension Int : LatticeType {}
extension Int8 : LatticeType {}
extension Int16 : LatticeType {}
extension Int32 : LatticeType {}
extension Int64 : LatticeType {}

extension Float : LatticeType {
	public static var min : Float {
		return FLT_MIN
	}

	public static var max : Float {
		return FLT_MAX
	}
}

extension Double : LatticeType {
	public static var min : Double {
		return DBL_MIN
	}

	public static var max : Double {
		return DBL_MAX
	}
}

extension AnyForwardIndex : LatticeType {
	public static var min : AnyForwardIndex {
		return AnyForwardIndex(Int64.min)
	}

	public static var max : AnyForwardIndex {
		return AnyForwardIndex(Int64.max)
	}
}

extension AnyRandomAccessIndex : LatticeType {
	public static var min : AnyRandomAccessIndex {
		return AnyRandomAccessIndex(Int64.min)
	}

	public static var max : AnyRandomAccessIndex {
		return AnyRandomAccessIndex(Int64.max)
	}
}

/// float.h does not export Float80's limits, nor does the Swift Standard Library.
// rdar://18404510
//extension Swift.Float80 : LatticeType {
//	public static var min : Swift.Float80 {
//		return LDBL_MIN
//	}
//
//	public static var min : Swift.Float80 {
//		return LDBL_MAX
//	}
//}

#if os(Linux)
	import Glibc
	
	/// Matches http://www.opensource.apple.com/source/gcc/gcc-934.3/float.h
	public var FLT_MAX: Float = 3.40282347e+38
	public var FLT_MIN: Float = 1.17549435e-38

	public var DBL_MAX: Double = 1.7976931348623157e+308
	public var DBL_MIN: Double = 2.2250738585072014e-308
#else
	import Darwin
#endif
