//
//  Testable.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/18/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
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
	var unProp: Rose<TestResult>
	
	public var exhaustive : Bool { return true }

	public func property() -> Property {
		return Property(Gen.pure(Prop(unProp: ioRose(self.unProp))))
	}
}

/// When returned from a test case, that particular case is discarded.
public struct Discard : Testable {
	public var exhaustive : Bool { return true }

	public init() { }

	public func property() -> Property {
		return rejected().property()
	}
}

extension TestResult : Testable {
	public var exhaustive : Bool { return true }

	public func property() -> Property {
		return Property(Gen.pure(Prop(unProp: protectResults(Rose.pure(self)))))
	}
}

extension Bool : Testable {
	public var exhaustive : Bool { return true }

	public func property() -> Property {
		return liftBool(self).property()
	}
}

/// The type of testable functions.
///
/// TODO: File radar; Cannot use these functions without an explicit closure.
public struct TestableFunction<T : Arbitrary> : Testable {
	let f : T -> Testable

	public init(_ f : T -> Testable) {
		self.f = f
	}

	public var exhaustive : Bool { return false }

	public func property() -> Property {
		return forAllShrink(T.arbitrary(), { x in T.shrink(x) }, { x in self.f(x) })
	}
}
