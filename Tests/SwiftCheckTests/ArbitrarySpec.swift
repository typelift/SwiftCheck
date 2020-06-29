import SwiftCheck
import XCTest
import Foundation
#if SWIFT_PACKAGE
import FileCheck
#endif

class ArbitrarySpec : XCTestCase {
	func testAll() {
		XCTAssert(fileCheckOutput {
			// CHECK: *** Passed 100 tests
			// CHECK-NEXT: .
			property("generates arbitrary `Date`s") <- forAll { (_ : Date) in
				// The fact that we can return something here means that
				// generating the Date succeeded
				return true
			}

			// CHECK: *** Passed 100 tests
			// CHECK-NEXT: .
			property("generates arbitrary `UUID`s") <- forAll { (_ : UUID) in
				// The fact that we can return something here means that
				// generating the UUID succeeded
				return true
			}
		})
	}
}
