//
//  Compose.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/25/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

extension Gen {
	/// Create a generator by procedurally composing generated values from other generators.
	///
	/// This is useful in cases where it's cumbersome to functionally compose multiple
	/// generators using `zip` and `map`. For example:
	///
	///     public static var arbitrary: Gen<ArbitraryLargeFoo> {
	///         return Gen<ArbitraryLargeFoo>.compose { c in
	///             return ArbitraryLargeFoo(
	///                 // use the nullary method to get an `arbitrary` value
	///                 a: c.generate(),
	///
	///                 // or pass a custom generator
	///                 b: c.generate(Bool.suchThat { $0 == false }),
	///
	///                 // .. and so on, for as many values & types as you need
	///                 c: c.generate(), ...
	///             )
	///         }
	///     }
	///
	/// - parameter build: Function which is passed a GenComposer which can be used
	///
	/// - returns: A generator which uses the `build` function to create arbitrary instances of `A`.
	public static func compose(build: @escaping (GenComposer) -> A) -> Gen<A> {
		return Gen(unGen: { (stdgen, size) -> A in
			let composer = GenComposer(stdgen: stdgen, size: size)
			return build(composer)
		})
	}
}

/// Class used to generate values from mulitple `Gen` instances.
///
/// Given a StdGen and size, generate values from other generators, splitting the StdGen
/// after each call to `generate`, ensuring sufficient entropy across generators.
///
/// - seealso: Gen.compose
public final class GenComposer {
	private var stdgen: StdGen
	private var size: Int
	
	init(stdgen: StdGen, size: Int) {
		self.stdgen = stdgen
		self.size = size
	}
	
	// Split internal StdGen to ensure sufficient entropy over multiple `generate` calls.
	private func split() -> StdGen {
		let old = stdgen
		stdgen = old.split.0
		return old
	}
	
	/// Generate a new `T` with a specific generator.
	///
	/// - parameter gen: The generator used to create a random value.
	///
	/// - returns: A random `T` using the receiver's stdgen and size.
	public func generate<T>(using gen: Gen<T>) -> T {
		return gen.unGen(split(), size)
	}
	
	///  Generate a new `T` with its default `arbitrary` generator.
	///
	///  - returns: A random `T`.
	///
	///  - seealso: generate\<T\>(gen:)
	public func generate<T>() -> T
		where T: Arbitrary
	{
		return generate(using: T.arbitrary)
	}
}
