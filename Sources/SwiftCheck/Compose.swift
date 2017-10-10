//
//  Compose.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/25/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

extension Gen {
	/// Construct a `Gen`erator suitable for initializing an aggregate value.
	///
	/// When using SwiftCheck with most classes and structures that contain more
	/// than one field that conforms to `Arbitrary`, the monadic and applicative
	/// syntax can be unwieldy.  `Gen.compose` simplifies the construction of
	/// these values by exposing a simple, natural, and imperative interface to
	/// instance generation.  For example:
	///
	///     public static var arbitrary : Gen<MyClass> {
	///         return Gen<MyClass>.compose { c in
	///             return MyClass(
	///                 // Use the nullary method to get an `arbitrary` value.
	///                 a: c.generate(),
	///
	///                 // or pass a custom generator
	///                 b: c.generate(Bool.arbitrary.suchThat { $0 == false }),
	///
	///                 // ... and so on, for as many values & types as you need
	///                 c: c.generate(), ...
	///             )
	///         }
	///     }
	///
	/// - parameter build: A closure with a `GenComposer` that uses an
	///   underlying `Gen`erator to construct arbitrary values.
	///
	/// - returns: A generator which uses the `build` function to build 
	///   instances of `A`.
	public static func compose(build: @escaping (GenComposer) -> A) -> Gen<A> {
		return Gen(unGen: { (stdgen, size) -> A in
			let composer = GenComposer(stdgen, size)
			return build(composer)
		})
	}
}

/// `GenComposer` presents an imperative interface over top of `Gen`.  
///
/// - Important: Instances of this class may not be constructed manually.
///   Use `Gen.compose` instead.
///
/// - seealso: Gen.compose
public final class GenComposer {
	private var stdgen : StdGen
	private var size : Int
	
	fileprivate init(_ stdgen : StdGen, _ size : Int) {
		self.stdgen = stdgen
		self.size = size
	}
	
	
	/// Generate a new value of type `T` with a specific generator.
	///
	/// - parameter gen: The generator used to create a random value.
	///
	/// - returns: A random value of type `T` using the given `Gen`erator 
	///   for that type.
	public func generate<T>(using gen : Gen<T>) -> T {
		return gen.unGen(self.split, size)
	}
	
	/// Generate a new value of type `T` with the default `Gen`erator 
	/// for that type.
	///
	/// - returns: An arbitrary value of type `T`.
	///
	/// - seealso: generate<T>(using:)
	public func generate<T>() -> T
		where T: Arbitrary
	{
		return generate(using: T.arbitrary)
	}
	
	private var split : StdGen {
		let old = stdgen
		stdgen = old.split.0
		return old
	}
}
