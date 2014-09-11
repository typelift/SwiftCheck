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
		return Property(mp >>= ({ (let p) in
			return p.property().unProperty
		}))
	}
}

public struct WitnessTestableFunction<A : Arbitrary> : Testable {
	let mp : A -> Testable

	public init(_ mp: A -> Testable) {
		self.mp = mp
	}

	public func property() -> Property {
		return forAllShrink(A.arbitrary())(shrinker: { (let x) in
			return A.shrink(x)
		})(f: { (let x) in
			return unsafeCoerce(self.mp(x))
		})
	}
}

public func mkGen(x : WitnessTestableGen) -> Gen<Prop> {
	return x.mp
}
