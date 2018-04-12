//
//  Testable.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/18/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// The type of things that can be tested.  Consequently, the type of things
/// that can be returned from a `forAll` block.
///
/// `Testable` values must be able to produce a `Rose<TestResult>`, that is a
/// rose tree of test cases that terminates in a passing or failing
/// `TestResult`.  SwiftCheck provides instances for `Bool`, `Discard`, `Prop`,
/// and `Property`.  The last of these enables `forAll`s to return further
/// `forAll`s that can depend on previously generated values.
public protocol Testable {
	/// Returns a `Property`, which SwiftCheck uses to perform test case
	/// generation.
	var property : Property { get }
}

/// A property is anything that generates `Prop`s.
public struct Property : Testable {
	let unProperty : Gen<Prop>

	public init(_ val : Gen<Prop>) {
		self.unProperty = val
	}

	/// Yields self.
	public var property : Property {
		return self
	}
}

/// A `Prop` describes a strategy for evaluating a test case to a final
/// `TestResult`.  It holds a Rose Tree of branches that evaluate the test and
/// any modifiers and mappings that may have been applied to a particular
/// testing tree.
///
/// As a testable value, it creates a Property that generates only its testing
/// tree.
public struct Prop : Testable {
	var unProp : Rose<TestResult>

	/// Returns a property that tests the `Prop`.
	public var property : Property {
		// return Property(Gen.pure(Prop(unProp: .IORose(protectRose({ self.unProp })))))
		return Property(Gen.pure(Prop(unProp: .ioRose({ self.unProp }))))
	}
}

/// When returned from a test case, that particular case is discarded.
public struct Discard : Testable {
	/// Create a `Discard` suitable for disregarding a test case as though a
	/// precondition was false.
	public init() { }

	/// Returns a property that always rejects whatever result occurs.
	public var property : Property {
		return TestResult.rejected.property
	}
}

extension TestResult : Testable {
	/// Returns a property that evaluates to this test result.
	public var property : Property {
		return Property(Gen.pure(Prop(unProp: Rose.pure(self))))
	}
}

extension Bool : Testable {
	/// Returns a property that evaluates to a test success if this boolean 
	/// value is `true`, else returns a property that evaluates to a test 
	/// failure.
	public var property : Property {
		return TestResult.liftBool(self).property
	}
}

extension Gen : Testable where A : Testable {
	public var property : Property {
		return Property(self.flatMap { $0.property.unProperty })
	}
}
