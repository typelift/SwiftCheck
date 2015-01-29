//
//  PrimeSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck
import Swiftz

class PrimeSpec : XCTestCase {
	func sieve(n : Int) -> [Int] {
		if n <= 1 {
			return [Int]()
		}

		var marked : [Bool] = (0...n).map(const(false))
		marked[0] = true
		marked[1] = true

		for p in 2..<n {
			for i in stride(from: 2 * p, through: n, by: p) {
				marked[i] = true
			}
		}

		var primes : [Int] = []
		for (t, i) in Zip2(marked, 0...n) {
			if !t {
				primes.append(i)
			}
		}
		return primes
	}

	func isPrime(n : Int) -> Bool {
		if n == 0 || n == 1 {
			return false
		} else if n == 2 {
			return true
		}

		let max = Int(ceil(sqrt(Double(n))))
		for i in 2...max {
			if n % i == 0 {
				return false
			}
		}
		return true
	}

	func testAll() {
		property["All Prime"] = forAll { (n : Int) in
			return all(self.sieve(n), self.isPrime)
		}
	}
}

