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
	/// Returns true iff a single test case is exhaustive i.e. adequately covers
	/// the search space.
	///
	/// If true, the property will only be tested once.  Defaults to false.
	var exhaustive : Bool { get }

	/// Returns a `Property`, which SwiftCheck uses to perform test case 
	/// generation.
	var property : Property { get }
}

extension Testable {
	/// By default, all `Testable` types are non-exhaustive.
	public var exhaustive : Bool {
		return false
	}
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

	/// `Prop` tests are exhaustive because they unwrap to reveal non-exhaustive
	/// property tests.
	public var exhaustive : Bool { return true }

	/// Returns a property that tests the receiver. 
	public var property : Property {
//		return Property(Gen.pure(Prop(unProp: .IORose(protectRose({ self.unProp })))))
		return Property(Gen.pure(Prop(unProp: .IORose({ self.unProp }))))
	}
}

/// When returned from a test case, that particular case is discarded.
public struct Discard : Testable {
	/// `Discard`s are trivially exhaustive.
	public var exhaustive : Bool { return true }

	/// Create a `Discard` suitable for 
	public init() { }

	/// Returns a property that always rejects whatever result occurs.
	public var property : Property {
		return TestResult.rejected.property
	}
}

extension TestResult : Testable {
	/// `TestResult`s are trivially exhaustive.
	public var exhaustive : Bool { return true }

	/// Returns a property that tests the receiver.
	public var property : Property {
		return Property(Gen.pure(Prop(unProp: Rose.pure(self))))
	}
}

extension Bool : Testable {
	/// `Bool`ean values are trivially exhaustive.
	public var exhaustive : Bool { return true }

	/// Returns a property that evaluates to a test success if the receiver is
	/// `true`, else returns a property that evaluates to a test failure.
	public var property : Property {
		return TestResult.liftBool(self).property
	}
}

extension Gen /*: Testable*/ where A : Testable {
	public var property : Property {
		return Property(self >>- { $0.property.unProperty })
	}
}
