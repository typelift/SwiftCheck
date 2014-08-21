//
//  SimpleSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck

class SimpleSpec : XCTestCase {
    func prop(xs: [Int]) -> Bool {
        xs == xs.reverse().reverse()
    }
    func testAll() {
        quickCheck(prop);
    }
}