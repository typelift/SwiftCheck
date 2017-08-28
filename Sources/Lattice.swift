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
	/// The lower limit of the `Bool` type.
	public static var min : Bool {
		return false
	}

	/// The upper limit of the `Bool` type.
	public static var max : Bool {
		return true
	}
}

extension Character : LatticeType {
	/// The lower limit of the `Character` type.
	public static var min : Character {
		return "\0"
	}

	/// The upper limit of the `Character` type.
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
	/// The lower limit of the `Float` type.
	public static var min : Float {
		return Float.leastNormalMagnitude
	}

	/// The upper limit of the `Float` type.
	public static var max : Float {
		return Float.greatestFiniteMagnitude
	}
}

extension Double : LatticeType {
	/// The lower limit of the `Double` type.
	public static var min : Double {
		return Double.leastNormalMagnitude
	}

	/// The upper limit of the `Double` type.
	public static var max : Double {
		return Double.greatestFiniteMagnitude
	}
}

extension AnyIndex : LatticeType {
	/// The lower limit of the `AnyIndex` type.
	public static var min : AnyIndex {
		return AnyIndex(Int64.min)
	}

	/// The upper limit of the `AnyIndex` type.
	public static var max : AnyIndex {
		return AnyIndex(Int64.max)
	}
}

/// float.h does not export Float80's limits, nor does the Swift Standard Library.
// rdar://18404510
//extension Swift.Float80 : LatticeType {
//    public static var min : Swift.Float80 {
//        return LDBL_MIN
//    }
//
//    public static var min : Swift.Float80 {
//        return LDBL_MAX
//    }
//}

#if os(Linux)
	import Glibc

	// Matches http://www.opensource.apple.com/source/gcc/gcc-934.3/float.h

	/// Maximum value of `Float`.
	public var FLT_MAX: Float = 3.40282347e+38
	/// Minimum value of `Float`.
	public var FLT_MIN: Float = 1.17549435e-38

	/// Maximum value of `Double`.
	public var DBL_MAX: Double = 1.7976931348623157e+308
	/// Minimum value of `Double`.
	public var DBL_MIN: Double = 2.2250738585072014e-308
#else
	import Darwin
#endif
