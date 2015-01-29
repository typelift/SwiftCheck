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

For example, if we wanted to test the property that every Float is equal to
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


Custom Types
============

SwiftCheck implements random generation for most of the types in the Swift STL.
Any custom types that wish to take part in testing must conform to the included
`Arbitrary` protocol.  For the majority of types, this means providing a custom
means of generating random data and shrinking down to an empty array. 

For example:

```swift
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
        return ArbitraryFoo.create <%> Int.arbitrary() <*> Int.arbitrary()
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

