//
//  Witness.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/26/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public protocol WitnessedArbitrary {
	typealias Param

	static func forAllWitnessed<A : Arbitrary>(wit : A -> Param)(pf : (Self -> Testable)) -> Property
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for that type.
public func forAll<A : WitnessedArbitrary where A.Param : Arbitrary>(pf : (A -> Testable)) -> Property {
	return A.forAllWitnessed(id)(pf: pf)
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 2 types.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary where A.Param : Arbitrary, B.Param : Arbitrary>(pf : (A, B) -> Testable) -> Property {
	return forAll({ t in forAll({ b in pf(t, b) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 3 types.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary>(pf : (A, B, C) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c in pf(t, b, c) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 4 types.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary, D : WitnessedArbitrary where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary, D.Param : Arbitrary>(pf : (A, B, C, D) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d in pf(t, b, c, d) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 5 types.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary, D : WitnessedArbitrary, E : WitnessedArbitrary where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary, D.Param : Arbitrary, E.Param : Arbitrary>(pf : (A, B, C, D, E) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e in pf(t, b, c, d, e) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 6 types.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary, D : WitnessedArbitrary, E : WitnessedArbitrary, F : WitnessedArbitrary where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary, D.Param : Arbitrary, E.Param : Arbitrary, F.Param : Arbitrary>(pf : (A, B, C, D, E, F) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f in pf(t, b, c, d, e, f) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 7 types.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary, D : WitnessedArbitrary, E : WitnessedArbitrary, F : WitnessedArbitrary, G : WitnessedArbitrary where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary, D.Param : Arbitrary, E.Param : Arbitrary, F.Param : Arbitrary, G.Param : Arbitrary>(pf : (A, B, C, D, E, F, G) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f, g in pf(t, b, c, d, e, f, g) }) })
}

/// Converts a function into a universally quantified property using the default shrinker and
/// generator for 8 types.
public func forAll<A : WitnessedArbitrary, B : WitnessedArbitrary, C : WitnessedArbitrary, D : WitnessedArbitrary, E : WitnessedArbitrary, F : WitnessedArbitrary, G : WitnessedArbitrary, H : WitnessedArbitrary where A.Param : Arbitrary, B.Param : Arbitrary, C.Param : Arbitrary, D.Param : Arbitrary, E.Param : Arbitrary, F.Param : Arbitrary, G.Param : Arbitrary, H.Param : Arbitrary>(pf : (A, B, C, D, E, F, G, H) -> Testable) -> Property {
	return forAll({ t in forAll({ b, c, d, e, f, g, h in pf(t, b, c, d, e, f, g, h) }) })
}
