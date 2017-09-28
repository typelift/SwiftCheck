//
//  PathSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 2/10/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

import SwiftCheck
import XCTest
#if SWIFT_PACKAGE
import FileCheck
#endif

struct Path<A : Arbitrary> : Arbitrary {
	let unPath : [A]

	private static func pathFrom(_ x : A) -> Gen<[A]> {
		return Gen.sized { n in
			return Gen<[A]>.one(
				of: [Gen.pure([])] + A.shrink(x).map { pathFrom($0).resize(n - 1) }
			).map { [x] + $0 }
		}
	}

	static var arbitrary : Gen<Path<A>> {
		return A.arbitrary.flatMap { x in
			return pathFrom(x).map(Path.init)
		}
	}
}

func path<A>(_ p : (A) -> Bool, _ pth : Path<A>) -> Bool {
	return pth.unPath.reduce(true, { $0 && p($1) })
}

func somePath<A>(_ p : (A) -> Bool, _ pth : Path<A>) -> Property {
	return path({ !p($0) }, pth).expectFailure
}

struct Extremal<A : Arbitrary & LatticeType> : Arbitrary {
	let getExtremal : A

	static var arbitrary : Gen<Extremal<A>> {
		return Gen<A>.frequency([
			(1, Gen.pure(A.min)),
			(1, Gen.pure(A.max)),
			(8, A.arbitrary)
			]).map(Extremal.init)
	}

	static func shrink(_ x : Extremal<A>) -> [Extremal<A>] {
		return A.shrink(x.getExtremal).map(Extremal.init)
	}
}

class PathSpec : XCTestCase {
	private static func smallProp<A : BinaryInteger>(_ pth : Path<A>) -> Bool {
		return path({ x in
			return (x >= -100 || -100 >= 0) && x <= 100
		}, pth)
	}

	private static func largeProp<A : BinaryInteger>(_ pth : Path<A>) -> Property {
		return somePath({ x in
			return (x < -1000000 || x > 1000000)
		}, pth)
	}

	func testAll() {
		property("Int") <- forAll { (x : Path<Int>) in
			return somePath({ x in
				return (x < 1000000 || x > -1000000)
			}, x)
		}

		property("Int32") <- forAll { (x : Path<Int32>) in
			return path({ x in
				return (x >= -100 || -100 >= 0) && x <= 100
			}, x)
		}

		property("UInt") <- forAll { (x : Path<UInt>) in
			return somePath({ x in
				return (x < 1000000 || x > 0)
			}, x)
		}

		property("UInt32") <- forAll { (x : Path<UInt32>) in
			return path({ x in
				return (x >= 0 || -100 >= 0) && x <= 100
			}, x)
		}

		property("Large Int") <- forAll { (x : Path<Large<Int>>) in
			return PathSpec.largeProp(Path(unPath: x.unPath.map { $0.getLarge }))
		}

		property("Large UInt") <- forAll { (x : Path<Large<UInt>>) in
			return PathSpec.largeProp(Path(unPath: x.unPath.map { $0.getLarge }))
		}
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testAll", testAll),
	])
	#endif
}
