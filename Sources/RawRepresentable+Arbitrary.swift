//
//  RawRepresentable+Arbitrary.swift
//  SwiftCheck
//
//  Created by Brian Gerstle on 5/4/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

extension RawRepresentable where RawValue: Arbitrary {
    // Default implementation, maps arbitrary values of its RawValue type until a valid representation is obtained.
    public static var arbitrary: Gen<Self> {
        return RawValue.arbitrary.map(Self.init).suchThat { $0 != nil }.map { $0! }
    }
}
