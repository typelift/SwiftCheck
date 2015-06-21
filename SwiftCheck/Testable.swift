//
//  Testable.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/18/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//


/// The type of things that can be tested.
///
/// A testable type must be able to convert itself to a Property.  That entails being able to create
/// a Generator for elements of its encapsulated type.
///
/// An exhaustiveness property is also required.  If true, the property will only be tested once.
public protocol Testable {
	var exhaustive : Bool { get }


	func property() -> Property
}

/// A property is anything that generates propositions.
public struct Property : Testable {
	let unProperty : Gen<Prop>
	
	public var exhaustive : Bool { return false }

	public init(_ val : Gen<Prop>) {
		self.unProperty = val;
	}

	public func property() -> Property {
		return Property(self.unProperty)
	}
}

/// A proposition.
public struct Prop : Testable {
	var unProp : Rose<TestResult>
	
	public var exhaustive : Bool { return true }

	public func property() -> Property {
//		return Property(Gen.pure(Prop(unProp: .IORose(protectRose({ self.unProp })))))
		return Property(Gen.pure(Prop(unProp: .IORose({ self.unProp }))))
	}
}

/// When returned from a test case, that particular case is discarded.
public struct Discard : Testable {
	public var exhaustive : Bool { return true }

	public init() { }

	public func property() -> Property {
		return TestResult.rejected.property()
	}
}

extension TestResult : Testable {
	public var exhaustive : Bool { return true }

	public func property() -> Property {
		return Property(Gen.pure(Prop(unProp: Rose.pure(self))))
	}
}

extension Bool : Testable {
	public var exhaustive : Bool { return true }

	public func property() -> Property {
		return TestResult.liftBool(self).property()
	}
}
