//
//  NSDataSpec.swift
//  SwiftCheck
//
//  Created by Projector on 12/28/15.
//  Copyright © 2015 Robert Widmann. All rights reserved.
//

import SwiftCheck

extension NSData {
    static var generator: Gen<NSData> {
        return Gen<NSData>.pure(
            String.arbitrary.generate.dataUsingEncoding(NSUTF8StringEncoding)!
        )
    }
    static func generate() -> NSData { return self.generator.generate }
}

public struct ArbitraryNSData: Arbitrary {
    let getInstance: NSData
    init(instance: NSData) { getInstance = instance }
    public static var arbitrary: Gen<ArbitraryNSData> { return NSData.generator.fmap(ArbitraryNSData.init) }
}

class NSDataSpec: XCTestCase {

    func testAll() {
        #if DEBUG
            XCTFail("Must be tested under RELEASE Build Configuration")
        #else
            property("NSData is a String underneath") <- forAll { (arbData: ArbitraryNSData) in
                let d = arbData.getInstance
                let s = String(data: d, encoding: NSUTF8StringEncoding)
                let _d = s?.dataUsingEncoding(NSUTF8StringEncoding)
                return d == _d
            }
        #endif
    }

}
