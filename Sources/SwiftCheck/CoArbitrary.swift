//
//  CoArbitrary.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 12/15/15.
//  Copyright © 2016 Typelift. All rights reserved.
//

/// `CoArbitrary is the dual to the `Arbitrary` protocol.  Where `Arbitrary`
/// allows generating random values, `CoArbitrary` allows observance of random
/// values passing through as input to random functions.  A `CoArbitrary` type
/// is thus able to influence the flow of values in the function.
///
/// `CoArbitrary` types must take an arbitrary value of their type and yield a
/// function that transforms a given generator by returning a new generator that
/// depends on the input value.  Put simply, the function should perturb the
/// given generator (more than likely using `Gen.variant()`) based on the value
/// it observes.
public protocol CoArbitrary {
	/// Uses an instance of this type to return a function that perturbs a
	/// generator.
	static func coarbitrary<C>(_ x : Self) -> ((Gen<C>) -> Gen<C>)
}

extension BinaryInteger {
	/// A coarbitrary implementation for any IntegerType
	public func coarbitraryIntegral<C>() -> (Gen<C>) -> Gen<C> {
		return { $0.variant(self) }
	}
}

/// A coarbitrary implementation for any Printable type.  Avoid using this
/// function if you can, it can be quite an expensive operation given a detailed
/// enough description.
public func coarbitraryPrintable<A, B>(_ x : A) -> (Gen<B>) -> Gen<B> {
	return String.coarbitrary(String(describing: x))
}

extension Bool : CoArbitrary {
	/// The default coarbitrary implementation for `Bool` values.
	public static func coarbitrary<C>(_ x : Bool) -> (Gen<C>) -> Gen<C> {
		return { g in
			if x {
				return g.variant(1)
			}
			return g.variant(0)
		}
	}
}

extension UnicodeScalar : CoArbitrary {
	/// The default coarbitrary implementation for `UnicodeScalar` values.
	public static func coarbitrary<C>(_ x : UnicodeScalar) -> (Gen<C>) -> Gen<C> {
		return UInt32.coarbitrary(x.value)
	}
}

extension Character : CoArbitrary {
	/// The default coarbitrary implementation for `Character` values.
	public static func coarbitrary<C>(_ x : Character) -> ((Gen<C>) -> Gen<C>) {
		let ss = String(x).unicodeScalars
		return UnicodeScalar.coarbitrary(ss[ss.startIndex])
	}
}

extension String : CoArbitrary {
	/// The default coarbitrary implementation for `String` values.
	public static func coarbitrary<C>(_ x : String) -> ((Gen<C>) -> Gen<C>) {
		if x.isEmpty {
			return { $0.variant(0) }
		}
		return comp(
			Character.coarbitrary(x[x.startIndex]), 
			String.coarbitrary(String(x[x.characters.index(after: x.startIndex)..<x.endIndex]))
		)
	}
}

extension Int : CoArbitrary {
	/// The default coarbitrary implementation for `Int` values.
	public static func coarbitrary<C>(_ x : Int) -> (Gen<C>) -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension Int8 : CoArbitrary {
	/// The default coarbitrary implementation for `Int8` values.
	public static func coarbitrary<C>(_ x : Int8) -> (Gen<C>) -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension Int16 : CoArbitrary {
	/// The default coarbitrary implementation for `Int16` values.
	public static func coarbitrary<C>(_ x : Int16) -> (Gen<C>) -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension Int32 : CoArbitrary {
	/// The default coarbitrary implementation for `Int32` values.
	public static func coarbitrary<C>(_ x : Int32) -> (Gen<C>) -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension Int64 : CoArbitrary {
	/// The default coarbitrary implementation for `Int64` values.
	public static func coarbitrary<C>(_ x : Int64) -> (Gen<C>) -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension UInt : CoArbitrary {
	/// The default coarbitrary implementation for `UInt` values.
	public static func coarbitrary<C>(_ x : UInt) -> (Gen<C>) -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension UInt8 : CoArbitrary {
	/// The default coarbitrary implementation for `UInt8` values.
	public static func coarbitrary<C>(_ x : UInt8) -> (Gen<C>) -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension UInt16 : CoArbitrary {
	/// The default coarbitrary implementation for `UInt16` values.
	public static func coarbitrary<C>(_ x : UInt16) -> (Gen<C>) -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension UInt32 : CoArbitrary {
	/// The default coarbitrary implementation for `UInt32` values.
	public static func coarbitrary<C>(_ x : UInt32) -> (Gen<C>) -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension UInt64 : CoArbitrary {
	/// The default coarbitrary implementation for `UInt64` values.
	public static func coarbitrary<C>(_ x : UInt64) -> (Gen<C>) -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

// In future, implement these with Ratios like QuickCheck.
extension Float : CoArbitrary {
	/// The default coarbitrary implementation for `Float` values.
	public static func coarbitrary<C>(_ x : Float) -> ((Gen<C>) -> Gen<C>) {
		return Int64(x).coarbitraryIntegral()
	}
}

extension Double : CoArbitrary {
	/// The default coarbitrary implementation for `Double` values.
	public static func coarbitrary<C>(_ x : Double) -> ((Gen<C>) -> Gen<C>) {
		return Int64(x).coarbitraryIntegral()
	}
}

extension Array : CoArbitrary {
	/// The default coarbitrary implementation for an `Array` of values.
	public static func coarbitrary<C>(_ a : [Element]) -> ((Gen<C>) -> Gen<C>) {
		if a.isEmpty {
			return { $0.variant(0) }
		}
		return comp({ $0.variant(1) }, [Element].coarbitrary([Element](a[1..<a.endIndex])))
	}
}

extension Dictionary : CoArbitrary {
	/// The default coarbitrary implementation for a `Dictionary` of values.
	public static func coarbitrary<C>(_ x : Dictionary<Key, Value>) -> ((Gen<C>) -> Gen<C>) {
		if x.isEmpty {
			return { $0.variant(0) }
		}
		return { $0.variant(1) }
	}
}

extension Optional : CoArbitrary {
	/// The default coarbitrary implementation for `Optional` values.
	public static func coarbitrary<C>(_ x : Optional<Wrapped>) -> ((Gen<C>) -> Gen<C>) {
		if let _ = x {
			return { $0.variant(0) }
		}
		return { $0.variant(1) }
	}
}

extension Set : CoArbitrary {
	/// The default coarbitrary implementation for `Set`s of values.
	public static func coarbitrary<C>(_ x : Set<Element>) -> ((Gen<C>) -> Gen<C>) {
		if x.isEmpty {
			return { $0.variant(0) }
		}
		return { $0.variant(1) }
	}
}
