//
//  PrimeSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/19/15.
//  Copyright (c) 2015 Robert Widmann. All rights reserved.
//

import XCTest
import SwiftCheck

/// The Sieve of Eratosthenes:
///
/// To find all the prime numbers less than or equal to a given integer n:
///    - let l = [2...n]
///    - let p = 2
///    - for i in [(2 * p) through n by p] {
///          mark l[i]
///      }
///    - Remaining indices of unmarked numbers are primes
func sieve(n : Int) -> [Int] {
	if n <= 1 {
		return [Int]()
	}
	
	var marked : [Bool] = (0...n).map({ _ in false })
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

/// Short and sweet check if a number is prime by enumerating from 2...⌈√(x)⌉ and checking 
/// for a nonzero modulus.
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

class PrimeSpec : XCTestCase {
	func testAll() {
		property["All Prime"] = forAll { (n : Int) in
			return sieve(n).filter(isPrime) == sieve(n)
		}
	}
}

