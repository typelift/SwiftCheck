//
//  CartesianSpec.swift
//  SwiftCheck
//
//  Created by Adam Kuipers on 9/21/16.
//  Copyright © 2016 Typelift. All rights reserved.
//

// This is a GYB generated file; any changes will be overwritten
// during the build phase. Edit the template instead,
// found in Templates/CartesianSpec.swift.gyb


import SwiftCheck
import XCTest
#if SWIFT_PACKAGE
import FileCheck
#endif
import Foundation

final class CartesianSpec : XCTestCase {
	func testGeneratedZips() {

		let g3 = Gen<(Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3))

		property("Gen.zip3 behaves") <- forAllNoShrink(g3) { (tuple : (Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.2 == 3
		}

		let g4 = Gen<(Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4))

		property("Gen.zip4 behaves") <- forAllNoShrink(g4) { (tuple : (Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.3 == 4
		}

		let g5 = Gen<(Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5))

		property("Gen.zip5 behaves") <- forAllNoShrink(g5) { (tuple : (Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.4 == 5
		}

		let g6 = Gen<(Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6))

		property("Gen.zip6 behaves") <- forAllNoShrink(g6) { (tuple : (Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.5 == 6
		}

		let g7 = Gen<(Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7))

		property("Gen.zip7 behaves") <- forAllNoShrink(g7) { (tuple : (Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.6 == 7
		}

		let g8 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8))

		property("Gen.zip8 behaves") <- forAllNoShrink(g8) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.7 == 8
		}

		let g9 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9))

		property("Gen.zip9 behaves") <- forAllNoShrink(g9) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.8 == 9
		}

		let g10 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10))

		property("Gen.zip10 behaves") <- forAllNoShrink(g10) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.9 == 10
		}

		let g11 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11))

		property("Gen.zip11 behaves") <- forAllNoShrink(g11) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.10 == 11
		}

		let g12 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12))

		property("Gen.zip12 behaves") <- forAllNoShrink(g12) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.11 == 12
		}

		let g13 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13))

		property("Gen.zip13 behaves") <- forAllNoShrink(g13) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.12 == 13
		}

		let g14 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14))

		property("Gen.zip14 behaves") <- forAllNoShrink(g14) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.13 == 14
		}

		let g15 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15))

		property("Gen.zip15 behaves") <- forAllNoShrink(g15) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.14 == 15
		}

		let g16 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16))

		property("Gen.zip16 behaves") <- forAllNoShrink(g16) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.15 == 16
		}

		let g17 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17))

		property("Gen.zip17 behaves") <- forAllNoShrink(g17) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.16 == 17
		}

		let g18 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17), Gen.pure(18))

		property("Gen.zip18 behaves") <- forAllNoShrink(g18) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.17 == 18
		}

		let g19 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17), Gen.pure(18), Gen.pure(19))

		property("Gen.zip19 behaves") <- forAllNoShrink(g19) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.18 == 19
		}

		let g20 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17), Gen.pure(18), Gen.pure(19), Gen.pure(20))

		property("Gen.zip20 behaves") <- forAllNoShrink(g20) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.19 == 20
		}

		let g21 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17), Gen.pure(18), Gen.pure(19), Gen.pure(20), Gen.pure(21))

		property("Gen.zip21 behaves") <- forAllNoShrink(g21) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.20 == 21
		}

		let g22 = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17), Gen.pure(18), Gen.pure(19), Gen.pure(20), Gen.pure(21), Gen.pure(22))

		property("Gen.zip22 behaves") <- forAllNoShrink(g22) { (tuple : (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Bool in
			tuple.0 == 1 && tuple.21 == 22
		}
	}

	func testGeneratedZipWiths() {

		let g3 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3)) { max($0, $1, $2) }

		property("Gen.zip3 behaves") <- forAllNoShrink(g3) { maxInt in
			maxInt == 3
		}

		let g4 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4)) { max($0, $1, $2, $3) }

		property("Gen.zip4 behaves") <- forAllNoShrink(g4) { maxInt in
			maxInt == 4
		}

		let g5 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5)) { max($0, $1, $2, $3, $4) }

		property("Gen.zip5 behaves") <- forAllNoShrink(g5) { maxInt in
			maxInt == 5
		}

		let g6 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6)) { max($0, $1, $2, $3, $4, $5) }

		property("Gen.zip6 behaves") <- forAllNoShrink(g6) { maxInt in
			maxInt == 6
		}

		let g7 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7)) { max($0, $1, $2, $3, $4, $5, $6) }

		property("Gen.zip7 behaves") <- forAllNoShrink(g7) { maxInt in
			maxInt == 7
		}

		let g8 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8)) { max($0, $1, $2, $3, $4, $5, $6, $7) }

		property("Gen.zip8 behaves") <- forAllNoShrink(g8) { maxInt in
			maxInt == 8
		}

		let g9 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8) }

		property("Gen.zip9 behaves") <- forAllNoShrink(g9) { maxInt in
			maxInt == 9
		}

		let g10 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9) }

		property("Gen.zip10 behaves") <- forAllNoShrink(g10) { maxInt in
			maxInt == 10
		}

		let g11 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10) }

		property("Gen.zip11 behaves") <- forAllNoShrink(g11) { maxInt in
			maxInt == 11
		}

		let g12 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) }

		property("Gen.zip12 behaves") <- forAllNoShrink(g12) { maxInt in
			maxInt == 12
		}

		let g13 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) }

		property("Gen.zip13 behaves") <- forAllNoShrink(g13) { maxInt in
			maxInt == 13
		}

		let g14 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) }

		property("Gen.zip14 behaves") <- forAllNoShrink(g14) { maxInt in
			maxInt == 14
		}

		let g15 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) }

		property("Gen.zip15 behaves") <- forAllNoShrink(g15) { maxInt in
			maxInt == 15
		}

		let g16 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15) }

		property("Gen.zip16 behaves") <- forAllNoShrink(g16) { maxInt in
			maxInt == 16
		}

		let g17 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16) }

		property("Gen.zip17 behaves") <- forAllNoShrink(g17) { maxInt in
			maxInt == 17
		}

		let g18 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17), Gen.pure(18)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17) }

		property("Gen.zip18 behaves") <- forAllNoShrink(g18) { maxInt in
			maxInt == 18
		}

		let g19 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17), Gen.pure(18), Gen.pure(19)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18) }

		property("Gen.zip19 behaves") <- forAllNoShrink(g19) { maxInt in
			maxInt == 19
		}

		let g20 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17), Gen.pure(18), Gen.pure(19), Gen.pure(20)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19) }

		property("Gen.zip20 behaves") <- forAllNoShrink(g20) { maxInt in
			maxInt == 20
		}

		let g21 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17), Gen.pure(18), Gen.pure(19), Gen.pure(20), Gen.pure(21)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20) }

		property("Gen.zip21 behaves") <- forAllNoShrink(g21) { maxInt in
			maxInt == 21
		}

		let g22 = Gen<Int>.zipWith(Gen.pure(1), Gen.pure(2), Gen.pure(3), Gen.pure(4), Gen.pure(5), Gen.pure(6), Gen.pure(7), Gen.pure(8), Gen.pure(9), Gen.pure(10), Gen.pure(11), Gen.pure(12), Gen.pure(13), Gen.pure(14), Gen.pure(15), Gen.pure(16), Gen.pure(17), Gen.pure(18), Gen.pure(19), Gen.pure(20), Gen.pure(21), Gen.pure(22)) { max($0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21) }

		property("Gen.zip22 behaves") <- forAllNoShrink(g22) { maxInt in
			maxInt == 22
		}
	}
}
