//
//  Witness.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/22/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Basis

public struct WitnessTestableGen {
	let mp : Gen<Prop>

	public init(_ mp: Gen<Prop>) {
		self.mp = mp
	}

}

extension WitnessTestableGen : Testable {
	public func property() -> Property {
		return Property(mp >>- ({ (let p) in
			return p.property().unProperty
		}))
	}
}

public struct WitnessTestableFunction<A : Arbitrary, B : Testable> : Testable {
	let mp : A.A -> B

	public init(_ mp: A.A -> B) {
		self.mp = mp
	}

	public func property() -> Property {
		return forAllShrink(A.arbitrary())(shrinker: A.shrink)(f: self.mp)
	}
}

public func mkGen(x : WitnessTestableGen) -> Gen<Prop> {
	return x.mp
}
