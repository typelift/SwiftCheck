//
//  Lift.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/20/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public struct LiftTestableGen : Testable {
    let mp : Gen<Prop>
    
    public init(_ mp: Gen<Prop>) {
        self.mp = mp
    }
    
    public func property() -> Property {
        return Property(mp.bind({ (let p) in
            return p.property().unProperty
        }))
    }
}

public func mkGen(x : LiftTestableGen) -> Gen<Prop> {
    return x.mp
}