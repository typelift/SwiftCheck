//
//  Witness.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/26/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

/// Provides a way for higher-order types to implement the `Arbitrary` protocol.
///
/// The `WitnessedArbitrary` protocol is a *HACK*, but a very necessary one.
/// Because Swift does not have Higher Kinded Types, but we need to know that,
/// say, the `Element`s underlying an `Array<Element>` are all `Arbitrary`, we
/// instead ask the conformee to hand over information about the type parameter
/// it wishes to guarantee is `Arbitrary` then SwiftCheck will synthesize a
/// function to act as a Witness that the parameter is in fact `Arbitrary`.
/// SwiftCheck presents a stronger but less general version of `forAll` that
/// must be implemented by the conformee to guarantee a type-safe interface with
/// the rest of the framework.
///
/// Implementating the `WitnessedArbitrary` protocol functions much like
/// implementing the `Arbitrary` protocol, but with a little extra baggage.  For
/// example, to implement the protocol for `Array`, we declare the usual
/// `arbitrary` and `shrink`:
///
///    extension Array where Element : Arbitrary {
///        public static var arbitrary : Gen<Array<Element>> {
///            return Gen.sized { n in
///                return Gen<Int>.choose((0, n)).flatMap { k in
///                    if k == 0 {
///                        return Gen.pure([])
///                    }
///
///                    return sequence((0...k).map { _ in Element.arbitrary })
///                }
///            }
///        }
///
///        public static func shrink(bl : Array<Element>) -> [[Element]] {
///            let rec : [[Element]] = shrinkOne(bl)
///            return Int.shrink(bl.count).reverse().flatMap({ k in removes(k.successor(), n: bl.count, xs: bl) }) + rec
///        }
///    }
///
/// In addition, we declare a witnessed version of `forAll` that simply invokes
/// `forAllShrink` and `map`s the witness function to make sure all generated
/// `Array`s are made of `Arbitrary ` elements:
///
///    extension Array : WitnessedArbitrary {
///        public typealias Param = Element
///
///        public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element, pf : ([Element] -> Testable)) -> Property {
///            return forAllShrink([A].arbitrary, shrinker: [A].shrink, f: { bl in
///                return pf(bl.map(wit))
///            })
///        }
///    }
public protocol WitnessedArbitrary {
	/// The witnessing type parameter.
	associatedtype Param

	/// A property test that relies on a witness that the given type parameter
	/// is actually `Arbitrary`.
	static func forAllWitnessed<A : Arbitrary>(_ wit : @escaping (A) -> Param, pf : @escaping (Self) -> Testable) -> Property
}

/// Converts a function into a universally quantified property using the default
/// shrinker and generator for that type.
///
/// - parameter pf: A block that carries the property or invariant to be tested.
///
/// - returns: A `Property` that executes the given testing block.
public func forAll<A : WitnessedArbitrary>(_ pf : @escaping (A) -> Testable) -> Property
	where A.Param : Arbitrary
{
	return A.forAllWitnessed(id, pf: pf)
}

/// Converts a function into a universally quantified property using the default
/// shrinker and generator for 2 types.
///
/// - parameter pf: A block that carries the property or invariant to be tested.
///
/// - returns: A `Property` that executes the given testing block.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary>(_ pf : @escaping (A, B) -> Testable) -> Property
	where A.Param : Arbitrary, B.Param : Arbitrary
{
	return forAll { t in forAll { b in pf(t, b) } }
}

/// Converts a function into a universally quantified property using the default
/// shrinker and generator for 3 types.
///
/// - parameter pf: A block that carries the property or invariant to be tested.
///
/// - returns: A `Property` that executes the given testing block.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary>(_ pf : @escaping (A, B, C) -> Testable) -> Property
	where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary
{
	return forAll { t in forAll { b, c in pf(t, b, c) } }
}

/// Converts a function into a universally quantified property using the default
/// shrinker and generator for 4 types.
///
/// - parameter pf: A block that carries the property or invariant to be tested.
///
/// - returns: A `Property` that executes the given testing block.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary, D : WitnessedArbitrary>(_ pf : @escaping (A, B, C, D) -> Testable) -> Property
	where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary, D.Param : Arbitrary
{
	return forAll { t in forAll { b, c, d in pf(t, b, c, d) } }
}

/// Converts a function into a universally quantified property using the default
/// shrinker and generator for 5 types.
///
/// - parameter pf: A block that carries the property or invariant to be tested.
///
/// - returns: A `Property` that executes the given testing block.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary, D : WitnessedArbitrary, E : WitnessedArbitrary>(_ pf : @escaping (A, B, C, D, E) -> Testable) -> Property
	where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary, D.Param : Arbitrary, E.Param : Arbitrary
{
	return forAll { t in forAll { b, c, d, e in pf(t, b, c, d, e) } }
}

/// Converts a function into a universally quantified property using the default
/// shrinker and generator for 6 types.
///
/// - parameter pf: A block that carries the property or invariant to be tested.
///
/// - returns: A `Property` that executes the given testing block.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary, D : WitnessedArbitrary, E : WitnessedArbitrary, F : WitnessedArbitrary>(_ pf : @escaping (A, B, C, D, E, F) -> Testable) -> Property
	where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary, D.Param : Arbitrary, E.Param : Arbitrary, F.Param : Arbitrary
{
	return forAll { t in forAll { b, c, d, e, f in pf(t, b, c, d, e, f) } }
}

/// Converts a function into a universally quantified property using the default
/// shrinker and generator for 7 types.
///
/// - parameter pf: A block that carries the property or invariant to be tested.
///
/// - returns: A `Property` that executes the given testing block.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary, D : WitnessedArbitrary, E : WitnessedArbitrary, F : WitnessedArbitrary, G : WitnessedArbitrary>(_ pf : @escaping (A, B, C, D, E, F, G) -> Testable) -> Property
	where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary, D.Param : Arbitrary, E.Param : Arbitrary, F.Param : Arbitrary, G.Param : Arbitrary
{
	return forAll { t in forAll { b, c, d, e, f, g in pf(t, b, c, d, e, f, g) } }
}

/// Converts a function into a universally quantified property using the default
/// shrinker and generator for 8 types.
///
/// - parameter pf: A block that carries the property or invariant to be tested.
///
/// - returns: A `Property` that executes the given testing block.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary, D : WitnessedArbitrary, E : WitnessedArbitrary, F : WitnessedArbitrary, G : WitnessedArbitrary, H : WitnessedArbitrary>(_ pf : @escaping (A, B, C, D, E, F, G, H) -> Testable) -> Property
	where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary, D.Param : Arbitrary, E.Param : Arbitrary, F.Param : Arbitrary, G.Param : Arbitrary, H.Param : Arbitrary
{
	return forAll { t in forAll { b, c, d, e, f, g, h in pf(t, b, c, d, e, f, g, h) } }
}
