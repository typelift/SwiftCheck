//
//  LinuxMain.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 9/18/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

import XCTest

@testable import SwiftCheckTests

#if !os(macOS)
XCTMain([
	BooleanIdentitySpec.allTests,
	ComplexSpec.allTests,
	DiscardSpec.allTests,
	FailureSpec.allTests,
	GenSpec.allTests,
	LambdaSpec.allTests,
	ModifierSpec.allTests,
	PathSpec.allTests,
	PropertySpec.allTests,
	ReplaySpec.allTests,
	RoseSpec.allTests,
	ShrinkSpec.allTests,
	SimpleSpec.allTests,
	TestSpec.allTests,
])
#endif
