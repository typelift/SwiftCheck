//
//  Witness.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/22/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public struct WitnessTestableGen {
	let mp : Gen<Prop>

	public init(_ mp: Gen<Prop>) {
		self.mp = mp
	}

}

extension WitnessTestableGen : Testable {
	public func property() -> Property {
		return Property(mp.bind({ (let p) in
			return p.property().unProperty
		}))
	}
}

public struct LiftTestableFunction<A, PROP : Testable where A : Arbitrary, A : Printable> : Testable {
	let mp : A -> PROP

	public init(_ mp: A -> PROP) {
		self.mp = mp
	}

	public func property() -> Property {
		return forAllShrink(A.arbitrary)(shrinker: A.shrink)(f: mp)
	}
}

public func mkGen(x : WitnessTestableGen) -> Gen<Prop> {
	return x.mp
}