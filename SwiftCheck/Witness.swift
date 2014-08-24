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

	let forAllShrink_ : Gen<A> -> (A -> [A]) -> (A -> PROP) = {(let gen : Gen<A>) in
		return { (let shrinker: (A -> [A])) in
			return { (let f : (A -> PROP)) in
				let counterexample_ : String -> PROP -> Property = { (let s : String) -> PROP -> Property in
					return { (let p :PROP) -> Property in
						return callback(Callback.PostFinalFailure(kind: CallbackKind.Counterexample, f: { (let st) in
							return { (let _res) in
								println(s)
								return IO.pure(())
							}
						}))(p: p)
					}
				}
				return Property(gen.bindWitness({ (let x : A) -> WitnessTestableGen in
					return WitnessTestableGen(unProperty(shrinking(shrinker, x, { (let xs : A) -> Testable in
						return counterexample_(xs.description)(f(xs))
					})))
				}))
			}
		}
	}

	public func property() -> Property {
		return forAllShrink_(A.arbitrary)(shrinker: A.shrink)(f: mp)
	}
}

public func mkGen(x : WitnessTestableGen) -> Gen<Prop> {
	return x.mp
}