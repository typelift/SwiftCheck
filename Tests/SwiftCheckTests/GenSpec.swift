//
//  GenSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 5/27/15.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

import SwiftCheck
import XCTest
import Foundation

class GenSpec : XCTestCase {
	func testAll() {
		XCTAssert(fileCheckOutput {
			// CHECK: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.frequency behaves") <- {
				let g = Gen.frequency([
					(10, Gen.pure(0)),
					(5, Gen.pure(1)),
				])

				return forAll(g) { (i : Int) in
					return true
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.choose stays in bounds") <- forAll { (x : Int, y : Int) in
				let (mx, mn) = (Swift.max(x, y), Swift.min(x, y))
				return forAll(Gen<Int>.choose((mn, mx))) { n in
					return mn <= n && n <= mx
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen<Int>.chooseAny stays in bounds") <- forAll(Gen<Int>.chooseAny()) { x in Int.min <= x && x <= Int.max }
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen<Int8>.chooseAny stays in bounds") <- forAll(Gen<Int8>.chooseAny()) { x in Int8.min <= x && x <= Int8.max }
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen<Int16>.chooseAny stays in bounds") <- forAll(Gen<Int16>.chooseAny()) { x in Int16.min <= x && x <= Int16.max }
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen<Int32>.chooseAny stays in bounds") <- forAll(Gen<Int32>.chooseAny()) { x in Int32.min <= x && x <= Int32.max }
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen<Int64>.chooseAny stays in bounds") <- forAll(Gen<Int64>.chooseAny()) { x in Int64.min <= x && x <= Int64.max }

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen<UInt>.chooseAny stays in bounds") <- forAll(Gen<UInt>.chooseAny()) { x in UInt.min <= x && x <= UInt.max }
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen<UInt8>.chooseAny stays in bounds") <- forAll(Gen<UInt8>.chooseAny()) { x in UInt8.min <= x && x <= UInt8.max }
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen<UInt16>.chooseAny stays in bounds") <- forAll(Gen<UInt16>.chooseAny()) { x in UInt16.min <= x && x <= UInt16.max }
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen<UInt32>.chooseAny stays in bounds") <- forAll(Gen<UInt32>.chooseAny()) { x in UInt32.min <= x && x <= UInt32.max }
			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen<UInt64>.chooseAny stays in bounds") <- forAll(Gen<UInt64>.chooseAny()) { x in UInt64.min <= x && x <= UInt64.max }

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.frequency with N arguments behaves") <- forAll(Gen<Int>.choose((1, 1000))) { n in
				return forAll(Gen.frequency(Array(repeating: (1, Gen.pure(0)), count: n))) { $0 == 0 }
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.weighted behaves") <- {
				let g = Gen.weighted([
					(10, 0),
					(5, 1),
				])

				return forAll(g) { (i : Int) in
					return true
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.weighted with N arguments behaves") <- forAll(Gen<Int>.choose((1, 1000))) { n in
				return forAll(Gen.weighted(Array(repeating: (1, 0), count: n))) { $0 == 0 }
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("The only value Gen.pure generates is the given value") <- {
				let g = Gen.pure(0)
				return forAll(g) { $0 == 0 }
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.fromElementsOf only generates the elements of the given array") <- forAll { (xss : Array<Int>) in
				if xss.isEmpty {
					return Discard()
				}
				let l = Set(xss)
				return forAll(Gen<[Int]>.fromElements(of: xss)) { l.contains($0) }
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.fromElementsOf only generates the elements of the given array") <- forAll { (n1 : Int, n2 : Int) in
				return forAll(Gen<[Int]>.fromElements(of: [n1, n2])) { $0 == n1 || $0 == n2 }
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.fromElementsIn only generates the elements of the given interval") <- forAll { (n1 : Int, n2 : Int) in
				return (n1 < n2) ==> {
					let interval = n1...n2
					return forAll(Gen<[Int]>.fromElements(in: n1...n2)) { interval.contains($0) }
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.fromInitialSegmentsOf produces only prefixes of the generated array") <- forAll { (xs : Array<Int>) in
				return !xs.isEmpty ==> {
					return forAllNoShrink(Gen<[Int]>.fromInitialSegments(of: xs)) { (ys : Array<Int>) in
						return xs.starts(with: ys)
					}
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.fromShufflingElementsOf produces only permutations of the generated array") <- forAll { (xs : Array<Int>) in
				return forAllNoShrink(Gen<[Int]>.fromShufflingElements(of: xs)) { (ys : Array<Int>) in
					return (xs.count == ys.count) ^&&^ (xs.sorted() == ys.sorted())
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("oneOf n") <- forAll { (xss : ArrayOf<Int>) in
				if xss.getArray.isEmpty {
					return Discard()
				}
				let l = Set(xss.getArray)
				return forAll(Gen.one(of: xss.getArray.map(Gen.pure))) { l.contains($0) }
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.oneOf multiple generators picks only given generators") <- forAll { (n1 : Int, n2 : Int) in
				let g1 = Gen.pure(n1)
				let g2 = Gen.pure(n2)
				return forAll(Gen.one(of: [g1, g2])) { $0 == n1 || $0 == n2 }
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.proliferateSized n generates arrays of length n") <- forAll(Gen<Int>.choose((0, 100))) { n in
				let g = Int.arbitrary.proliferate(withSize: n).map(ArrayOf.init)
				return forAll(g) { $0.getArray.count == n }
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.proliferateSized 0 generates only empty arrays") <- forAll(Int.arbitrary.proliferate(withSize: 0).map(ArrayOf.init)) {
				return $0.getArray.isEmpty
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.resize bounds sizes for integers") <- forAll { (x : Int) in
				var n : Int = 0
				return forAll(Gen<Int>.sized { xx in
					n = xx
					return Int.arbitrary
				}.resize(n)) { (x : Int) in
					return x <= n
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.resize bounds count for arrays") <- forAll { (x : Int) in
				var n : Int = 0
				return forAllNoShrink(Gen<[Int]>.sized({ xx in
					n = xx
					return [Int].arbitrary
				}).resize(n)) { (xs : [Int]) in
					return xs.count <= n
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.suchThat in series obeys both predicates") <- {
				let g = String.arbitrary.suchThat({ !$0.isEmpty }).suchThat({ $0.range(of: ",") == nil })
				return forAll(g) { str in
					return !(str.isEmpty || str.range(of: ",") != nil)
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.suchThat in series obeys its first property") <- {
				let g = String.arbitrary.suchThat({ !$0.isEmpty }).suchThat({ $0.range(of: ",") == nil })
				return forAll(g) { str in
					return !str.isEmpty
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.suchThat in series obeys its last property") <- {
				let g = String.arbitrary.suchThat({ !$0.isEmpty }).suchThat({ $0.range(of: ",") == nil })
				return forAll(g) { str in
					return str.range(of: ",") == nil
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.sequence occurs in order") <- forAll { (xs : [String]) in
				return forAllNoShrink(sequence(xs.map(Gen.pure))) { ss in
					return ss == xs
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip2 behaves") <- forAll { (x : Int, y : Int) -> Property in
				let g = Gen<(Int, Int)>.zip(Gen.pure(x), Gen.pure(y))
				return forAllNoShrink(g) { $0 == (x, y) }
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip2 obeys the Cartesian associativity law") <- forAll { (x : Int, y : Int, z : Int) in
				let rightBiasedZip: Gen<(Int, (Int, Int))> = .zip(.pure(x), .zip(.pure(y), .pure(z)))
				let leftBiasedZip: Gen<((Int, Int), Int)> = .zip(.zip(.pure(x), .pure(y)), .pure(z))
				return rightBiasedZip ~= leftBiasedZip
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.ap is consistent with Gen.zip2") <- forAll { (x : Int, f : ArrowOf<Int, Int>) in
				let fx = Gen<Int>.pure(x)
				let ff = Gen<ArrowOf<Int, Int>>.pure(f).map { $0.getArrow }
				return fx.ap(ff) == Gen<((Int) -> Int, Int)>.zip(ff, fx).map { f, x in f(x) }
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip2 obeys the Monoidal Functor left identity law") <- forAll { (x : Int) in
				Gen<(Void, Int)>.zip(.pure(()), .pure(x)).map { $0.1 } == .pure(x)
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip2 obeys the Monoidal Functor right identity law") <- forAll { (x : Int) in
				Gen<(Int, Void)>.zip(.pure(x), .pure(())).map { $0.0 } == .pure(x)
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip3 behaves") <- forAll { (x : Int, y : Int, z : Int) in
				let g = Gen<(Int, Int, Int)>.zip(Gen.pure(x), Gen.pure(y), Gen.pure(z))
				return forAllNoShrink(g) { (x1, y1, z1) in
					return (x1, y1, z1) == (x, y, z)
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip4 behaves") <- forAll { (x : Int, y : Int, z : Int, w : Int) in
				let g = Gen<(Int, Int, Int, Int)>.zip(Gen.pure(x), Gen.pure(y), Gen.pure(z), Gen.pure(w))
				return forAllNoShrink(g) { (x1, y1, z1, w1) in
					return (x1, y1, z1, w1) == (x, y, z, w)
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip5 behaves") <- forAll { (x : Int, y : Int, z : Int, w : Int, a : Int) in
				let g = Gen<(Int, Int, Int, Int, Int)>.zip(Gen.pure(x), Gen.pure(y), Gen.pure(z), Gen.pure(w), Gen.pure(a))
				return forAllNoShrink(g) { (x1, y1, z1, w1, a1) in
					return (x1, y1, z1, w1, a1) == (x, y, z, w, a)
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip6 behaves") <- forAll { (x : Int, y : Int, z : Int, w : Int, a : Int, b : Int) in
				let g = Gen<(Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(x), Gen.pure(y), Gen.pure(z), Gen.pure(w), Gen.pure(a), Gen.pure(b))
				return forAllNoShrink(g) { (x1, y1, z1, w1, a1, b1) in
					return (x1, y1, z1, w1, a1, b1) == (x, y, z, w, a, b)
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip7 behaves") <- forAll { (x : Int, y : Int, z : Int, w : Int, a : Int, b : Int, c : Int) in
				let g = Gen<(Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(x), Gen.pure(y), Gen.pure(z), Gen.pure(w), Gen.pure(a), Gen.pure(b), Gen.pure(c))
				return forAllNoShrink(g) { (x1, y1, z1, w1, a1, b1, c1) in
					return (x1, y1, z1, w1, a1, b1) == (x, y, z, w, a, b)
						&& c1 == c
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip8 behaves") <- forAll { (x : Int, y : Int, z : Int, w : Int, a : Int, b : Int, c : Int, d : Int) in
				let g = Gen<(Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(x), Gen.pure(y), Gen.pure(z), Gen.pure(w), Gen.pure(a), Gen.pure(b), Gen.pure(c), Gen.pure(d))
				return forAllNoShrink(g) { (x1, y1, z1, w1, a1, b1, c1, d1) in
					return (x1, y1, z1, w1, a1, b1) == (x, y, z, w, a, b)
						&& (c1, d1) == (c, d)
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip9 behaves") <- forAll { (x : Int, y : Int, z : Int, w : Int, a : Int, b : Int, c : Int, d : Int) in
				return forAll { (e : Int) in
					let g = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(x), Gen.pure(y), Gen.pure(z), Gen.pure(w), Gen.pure(a), Gen.pure(b), Gen.pure(c), Gen.pure(d), Gen.pure(e))
					return forAllNoShrink(g) { (x1, y1, z1, w1, a1, b1, c1, d1, e1) in
						return (x1, y1, z1, w1, a1, b1) == (x, y, z, w, a, b)
							&& (c1, d1, e1) == (c, d, e)
					}
				}
			}

			// CHECK-NEXT: *** Passed 100 tests
			// CHECK-NEXT: .
			property("Gen.zip10 behaves") <- forAll { (x : Int, y : Int, z : Int, w : Int, a : Int, b : Int, c : Int, d : Int) in
				return forAll { (e : Int, f : Int) in
					let g = Gen<(Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>.zip(Gen.pure(x), Gen.pure(y), Gen.pure(z), Gen.pure(w), Gen.pure(a), Gen.pure(b), Gen.pure(c), Gen.pure(d), Gen.pure(e), Gen.pure(f))
					return forAllNoShrink(g) { (x1, y1, z1, w1, a1, b1, c1, d1, e1, f1) in
						return (x1, y1, z1, w1, a1, b1) == (x, y, z, w, a, b)
							&& (c1, d1, e1, f1) == (c, d, e, f)
					}
				}
			}
		})
	}

	func testLaws() {
		XCTAssert(fileCheckOutput(withPrefixes: ["LAW"]) {
			/// Turns out Gen is a really sketchy monad because of the underlying randomness.
			let lawfulGen = Gen<Gen<Int>>.fromElements(of: (0...500).map(Gen.pure))
			let lawfulArrowGen = Gen<Gen<ArrowOf<Int, Int>>>.fromElements(of: ArrowOf<Int, Int>.arbitrary.proliferate(withSize: 10).generate.map(Gen.pure))

			// LAW: *** Passed 100 tests
			// LAW-NEXT: .
			property("Gen obeys the Functor identity law") <- forAllNoShrink(lawfulGen) { (x : Gen<Int>) in
				return (x.map(id)) == id(x)
			}

			// LAW-NEXT: *** Passed 100 tests
			// LAW-NEXT: .
			property("Gen obeys the Functor composition law") <- forAll { (f : ArrowOf<Int, Int>, g : ArrowOf<Int, Int>) in
				return forAllNoShrink(lawfulGen) { (x : Gen<Int>) in
					return (x.map(f.getArrow • g.getArrow)) == (x.map(g.getArrow).map(f.getArrow))
				}
			}

			// LAW-NEXT: *** Passed 100 tests
			// LAW-NEXT: .
			property("Gen obeys the Applicative identity law") <- forAllNoShrink(lawfulGen) { (x : Gen<Int>) in
				return (x.ap(Gen.pure(id))) == x
			}

			// LAW-NEXT: *** Passed 100 tests
			// LAW-NEXT: .
			property("Gen obeys the first Applicative composition law") <- forAllNoShrink(lawfulArrowGen, lawfulArrowGen, lawfulGen) { (fl : Gen<ArrowOf<Int, Int>>, gl : Gen<ArrowOf<Int, Int>>, x : Gen<Int>) in
				let f = fl.map({ $0.getArrow })
				let g = gl.map({ $0.getArrow })
				return x.ap(g.ap(f.map(curry(•)))) == x.ap(g).ap(f)
			}

			// LAW-NEXT: *** Passed 100 tests
			// LAW-NEXT: .
			property("Gen obeys the second Applicative composition law") <- forAllNoShrink(lawfulArrowGen, lawfulArrowGen, lawfulGen) { (fl : Gen<ArrowOf<Int, Int>>, gl : Gen<ArrowOf<Int, Int>>, x : Gen<Int>) in
				let f = fl.map({ $0.getArrow })
				let g = gl.map({ $0.getArrow })
				return x.ap(g.ap(f.ap(Gen.pure(curry(•))))) == x.ap(g).ap(f)
			}

			// LAW-NEXT: *** Passed 100 tests
			// LAW-NEXT: .
			property("Gen obeys the Monad left identity law") <- forAll { (a : Int, fa : ArrowOf<Int, Int>) in
				let f : (Int) -> Gen<Int> = Gen<Int>.pure • fa.getArrow
				return Gen<Int>.pure(a).flatMap(f) == f(a)
			}

			// LAW-NEXT: *** Passed 100 tests
			// LAW-NEXT: .
			property("Gen obeys the Monad right identity law") <- forAllNoShrink(lawfulGen) { (m : Gen<Int>) in
				return (m.flatMap(Gen<Int>.pure)) == m
			}

			// LAW-NEXT: *** Passed 100 tests
			// LAW-NEXT: .
			property("Gen obeys the Monad associativity law") <- forAll { (fa : ArrowOf<Int, Int>, ga : ArrowOf<Int, Int>) in
				let f : (Int) -> Gen<Int> = Gen<Int>.pure • fa.getArrow
				let g : (Int) -> Gen<Int> = Gen<Int>.pure • ga.getArrow
				return forAllNoShrink(lawfulGen) { (m : Gen<Int>) in
					return m.flatMap(f).flatMap(g) == m.flatMap({ x in f(x).flatMap(g) })
				}
			}
		})
	}

	#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
	static var allTests = testCase([
		("testAll", testAll),
		("testLaws", testLaws),
	])
	#endif
}

internal func curry<A, B, C>(_ f : @escaping (A, B) -> C) -> (A) -> (B) -> C {
	return { a in { b in f(a, b) } }
}

internal func id<A>(_ x : A) -> A {
	return x
}

infix operator • : NilCoalescingPrecedence

internal func • <A, B, C>(f : @escaping (B) -> C, g : @escaping (A) -> B) -> (A) -> C {
	return { f(g($0)) }
}

private func ==(l : Gen<Int>, r : Gen<Int>) -> Bool {
	return l.proliferate(withSize: 10).generate == r.proliferate(withSize: 10).generate
}

/// `Gen` product is associative and has a natural isomorphism.
///
/// - Returns: True *iff* `(a1, a2, a3) == (b1, b2, b3)`
///            where `lhs = Gen((a1, (a2, a3)))` and `rhs = Gen(((b1, b2), b3))`.
private func ~= (lhs : Gen<(Int, (Int, Int))>, rhs : Gen<((Int, Int), Int)>) -> Bool {
	let normalizedL = lhs.map { ($0, $1.0, $1.1) }
	let normalizedR = rhs.map { ($0.0, $0.1, $1) }
	
	let sampleSize = 10
	let sampleL = normalizedL.proliferate(withSize: sampleSize).generate
	let sampleR = normalizedR.proliferate(withSize: sampleSize).generate
	
	for (tupleL, tupleR) in zip(sampleL, sampleR) {
		guard tupleL == tupleR else { return false }
	}
	
	return true
}
