//: ## SwiftCheck - noun: QuickCheck for Swift.
//:
//: SwiftCheck is a testing library that automatically generates random data for testing of program
//: properties.

import SwiftCheck

//: For example, if we wanted to test the property that every Integer is equal to itself, we would 
//: express it as such and SwiftCheck will handle the rest:
property["Integer equality obeys reflexivity"] = forAll { (i : Int) in
	return i == i
}

//: ## Shrinking
//: What makes QuickCheck unique is the notion of shrinking test cases. When fuzz testing with 
//: arbitrary data, rather than simply halt on a failing test, SwiftCheck will begin whittling the 
//: data that causes the test to fail down to a minimal counterexample.
//:
//: For example, the following function uses the Sieve of Eratosthenes to generate a list of primes 
//: less than some n:

// The Sieve of Eratosthenes:
//
// To find all the prime numbers less than or equal to a given integer n:
//    - let l = [2...n]
//    - let p = 2
//    - for i in [(2 * p) through n by p] {
//          mark l[i]
//      }
//    - Remaining indices of unmarked numbers are primes
func sieve(n : Int) -> [Int] {
	if n <= 1 {
		return [Int]()
	}

	var marked : [Bool] = (0...n).map({ _ in false })
	marked[0] = true
	marked[1] = true

	for p in 2..<n {
		for i in stride(from: 2 * p, to: n, by: p) {
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

// Trial Division
//
// Short and sweet check if a number is prime by enumerating from 2...⌈√(x)⌉ and checking
// for a nonzero modulus.
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

//: We would like to test whether our sieve works properly, so we run it through SwiftCheck with the
//: following property:

property["All Prime"] = forAll { (n : Int) in
	return sieve(n).filter(isPrime) == sieve(n)
}

//: Which produces the following in our testing log:
//:
//: > Test Case '-[SwiftCheckTests.PrimeSpec testAll]' started.
//: > *** Failed! Falsifiable (after 10 tests):
//: > 4
//: 
//: Indicating that our sieve has failed on the input number 4. A quick look back at the comments 
//: describing the sieve reveals the mistake immediately:
//:
//: > - for i in stride(from: 2 * p, to: n, by: p) {
//: > + for i in stride(from: 2 * p, through: n, by: p) {
//:
//: Running SwiftCheck again reports a successful sieve of all 100 random cases:

func sieveProperly(n : Int) -> [Int] {
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

property["All Prime"] = forAll { (n : Int) in
	return sieveProperly(n).filter(isPrime) == sieveProperly(n)
}
