[![Build Status](https://travis-ci.org/typelift/SwiftCheck.svg?branch=master)](https://travis-ci.org/typelift/SwiftCheck)

SwiftCheck
==========

QuickCheck for Swift.

Introduction
============

QuickCheck is a testing library that automatically generates random data for 
testing of program properties.  Tests, which before were just arbitrary 0-ary 
methods prefixed with the word test, now must be of the form:

```swift
func property<A, B, C ... Z where A, B, C ... Z : Arbitrary>(A, B, C, ..., Z) -> Bool
```

For example, if we wanted to test the property that every Integer is equal to
itself, we would express it as such:

```swift
func testAll() {
	property["Integer Equality is Reflexive"] = forAll { (i : Int) in
        return i == i
    }
}
```

SwiftCheck will handle the rest.  

Shrinking
=========
 
What makes QuickCheck unique is the notion of *shrinking* test cases.  When fuzz
testing with arbitrary data, rather than simply halt on a failing test, SwiftCheck
will begin whittling the data that causes the test to fail down to a minimal
counterexample.

For example, the following function uses the Sieve of Eratosthenes to generate
a list of primes less than some n:

```swift
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
    
    var marked : [Bool] = (0...n).map(const(false))
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

```

We would like to test whether our sieve works properly, so we run it through SwiftCheck
with the following property:

```swift
import SwiftCheck

property["All Prime"] = forAll { (n : Int) in
    return sieve(n).filter(isPrime) == sieve(n)
}
```

Which produces the following in our testing log:

```
Test Case '-[SwiftCheckTests.PrimeSpec testAll]' started.
*** Failed! Falsifiable (after 10 tests):
4
```

Indicating that our sieve has failed on the input number 4.  A quick look back
at the comments describing the sieve reveals the mistake immediately:

```
- for i in stride(from: 2 * p, to: n, by: p) {
+ for i in stride(from: 2 * p, through: n, by: p) {
```

Running SwiftCheck again reports a successful sieve of all 100 random cases:

```
*** Passed 100 tests
```

Custom Types
============

SwiftCheck implements random generation for most of the types in the Swift STL.
Any custom types that wish to take part in testing must conform to the included
`Arbitrary` protocol.  For the majority of types, this means providing a custom
means of generating random data and shrinking down to an empty array. 

For example:

```swift
import SwiftCheck
import func Swiftz.<^>
import func Swiftz.<*>

public struct ArbitraryFoo {
    let x : Int
    let y : Int

    public static func create(x : Int) -> Int -> ArbitraryFoo {
        return { y in ArbitraryFoo(x: x, y: y) }
    }

    public var description : String {
        return "Arbitrary Foo!"
    }
}

extension ArbitraryFoo : Arbitrary {
    public static func arbitrary() -> Gen<ArbitraryFoo> {
        return ArbitraryFoo.create <^> Int.arbitrary() <*> Int.arbitrary()
    }

    public static func shrink(x : ArbitraryFoo) -> [ArbitraryFoo] {
        return shrinkNone(x)
    }
}

class SimpleSpec : XCTestCase {
    func testAll() {
        property["ArbitraryFoo Properties are Reflexive"] = forAll { (i : ArbitraryFoo) in
            return i.x == i.x && i.y == i.y
        }
    }
}
```

