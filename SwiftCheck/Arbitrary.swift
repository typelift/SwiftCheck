//
//  Arbitrary.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// A type that implements random generation and shrinking of values.
///
/// While testing, SwiftCheck will invoke `arbitrary()` a given amount of times (usually 100 if the
/// default settings are used).  During that time, the receiver has an opportunity to call through
/// to any data or sources of randomness it needs to return what it deems an "Arbitrary" value.
///
/// Shrinking is reduction in the complexity of a tested value to remove noise and present a minimal
/// counterexample when a property fails.  While it may seem counterintuitive, a shrink necessitates
/// returning a list of all possible "smaller" values for SwiftCheck to run through.  As long as
/// each individual value in the returned list is less than or equal to the size of the input value,
/// and is not a duplicate of the input value, a minimal case should be reached fairly efficiently.
/// Shrinking is an optional extension of normal testing.  If no implementation of `shrink` is
/// provided, SwiftCheck will default to an empty one.
///
/// As an example, take the `ArrayOf` implementation of shrink:
///
/// Arbitrary.shrink(ArrayOf([1, 2, 3]))
///	> [[], [2,3], [1,3], [1,2], [0,2,3], [1,0,3], [1,1,3], [1,2,0], [1,2,2]]
///
/// SwiftCheck will search each case one-by-one and continue shrinking until it has reached a case
/// it deems minimal enough to present.
///
/// SwiftCheck implements a number of generators for common STL types for convenience.  If more fine-
/// grained testing is required see `Modifiers.swift` for an example of how to define a "Modifier"
/// type to implement it.
public protocol Arbitrary {
	/// The generator for this particular type.
	///
	/// This function should call out to any sources of randomness or state necessary to generate
	/// values.  It should not, however, be written as a deterministic function.  If such a
	/// generator is needed, combinators are provided in `Gen.swift`.
	static var arbitrary : Gen<Self> { get }

	/// An optional shrinking function.  If this function goes unimplemented, it is the same as
	/// returning the empty list.
	///
	/// Shrunken values must be less than or equal to the "size" of the original type but never the
	/// same as the value provided to this function (or a loop will form in the shrinker).  It is
	/// recommended that they be presented smallest to largest to speed up the overall shrinking
	/// process.
	static func shrink(_ : Self) -> [Self]
}

extension Arbitrary {
	/// The implementation of a shrink that returns no alternatives.
	public static func shrink(_ : Self) -> [Self] {
		return []
	}
}

extension IntegerType {
	/// Shrinks any IntegerType.
	public var shrinkIntegral : [Self] {
		return unfoldr({ i in
			if i <= 0 {
				return .None
			}
			let n = i / 2
			return .Some((n, n))
		}, initial: self < 0 ? (self * -1) : self)
	}
}

extension Bool : Arbitrary {
	public static var arbitrary : Gen<Bool> {
		return Gen<Bool>.choose((false, true))
	}

	public static func shrink(x : Bool) -> [Bool] {
		if x {
			return [false]
		}
		return []
	}
}

extension Int : Arbitrary {
	public static var arbitrary : Gen<Int> {
		return Gen.sized { n in
			return Gen<Int>.choose((-n, n))
		}
	}

	public static func shrink(x : Int) -> [Int] {
		return x.shrinkIntegral
	}
}

extension Int8 : Arbitrary {
	public static var arbitrary : Gen<Int8> {
		return Gen.sized { n in
			return Gen<Int8>.choose((Int8(truncatingBitPattern: -n), Int8(truncatingBitPattern: n)))
		}
	}

	public static func shrink(x : Int8) -> [Int8] {
		return x.shrinkIntegral
	}
}

extension Int16 : Arbitrary {
	public static var arbitrary : Gen<Int16> {
		return Gen.sized { n in
			return Gen<Int16>.choose((Int16(truncatingBitPattern: -n), Int16(truncatingBitPattern: n)))
		}
	}

	public static func shrink(x : Int16) -> [Int16] {
		return x.shrinkIntegral
	}
}

extension Int32 : Arbitrary {
	public static var arbitrary : Gen<Int32> {
		return Gen.sized { n in
			return Gen<Int32>.choose((Int32(truncatingBitPattern: -n), Int32(truncatingBitPattern: n)))
		}
	}

	public static func shrink(x : Int32) -> [Int32] {
		return x.shrinkIntegral
	}
}

extension Int64 : Arbitrary {
	public static var arbitrary : Gen<Int64> {
		return Gen.sized { n in
			return Gen<Int64>.choose((Int64(-n), Int64(n)))
		}
	}

	public static func shrink(x : Int64) -> [Int64] {
		return x.shrinkIntegral
	}
}

extension UInt : Arbitrary {
	public static var arbitrary : Gen<UInt> {
		return Gen.sized { n in Gen<UInt>.choose((0, UInt(n))) }
	}

	public static func shrink(x : UInt) -> [UInt] {
		return x.shrinkIntegral
	}
}

extension UInt8 : Arbitrary {
	public static var arbitrary : Gen<UInt8> {
		return Gen.sized { n in
			return Gen.sized { n in Gen<UInt8>.choose((0, UInt8(truncatingBitPattern: n))) }
		}
	}

	public static func shrink(x : UInt8) -> [UInt8] {
		return x.shrinkIntegral
	}
}

extension UInt16 : Arbitrary {
	public static var arbitrary : Gen<UInt16> {
		return Gen.sized { n in Gen<UInt16>.choose((0, UInt16(truncatingBitPattern: n))) }
	}

	public static func shrink(x : UInt16) -> [UInt16] {
		return x.shrinkIntegral
	}
}

extension UInt32 : Arbitrary {
	public static var arbitrary : Gen<UInt32> {
		return Gen.sized { n in Gen<UInt32>.choose((0, UInt32(truncatingBitPattern: n))) }
	}

	public static func shrink(x : UInt32) -> [UInt32] {
		return x.shrinkIntegral
	}
}

extension UInt64 : Arbitrary {
	public static var arbitrary : Gen<UInt64> {
		return Gen.sized { n in Gen<UInt64>.choose((0, UInt64(n))) }
	}

	public static func shrink(x : UInt64) -> [UInt64] {
		return x.shrinkIntegral
	}
}

extension Float : Arbitrary {
	public static var arbitrary : Gen<Float> {
		let precision : Int64 = 9999999999999

		return Gen.sized { n in
			if n == 0 {
				return Gen<Float>.pure(0.0)
			}

			return Gen<Int64>.choose((Int64(-n) * precision, Int64(n) * precision))
				>>- { a in Gen<Int64>.choose((1, precision))
					>>- { b in Gen<Float>.pure(Float(a) / Float(b)) } }
		}
	}

	public static func shrink(x : Float) -> [Float] {
		return unfoldr({ i in
			if i == 0.0 {
				return .None
			}
			let n = i / 2.0
			return .Some((n, n))
		}, initial: x)
	}
}

extension Double : Arbitrary {
	public static var arbitrary : Gen<Double> {
		let precision : Int64 = 9999999999999

		return Gen.sized { n in
			if n == 0 {
				return Gen<Double>.pure(0.0)
			}

			return Gen<Int64>.choose((Int64(-n) * precision, Int64(n) * precision))
				>>- { a in Gen<Int64>.choose((1, precision))
					>>- { b in Gen<Double>.pure(Double(a) / Double(b)) } }
		}
	}

	public static func shrink(x : Double) -> [Double] {
		return unfoldr({ i in
			if i == 0.0 {
				return .None
			}
			let n = i / 2.0
			return .Some((n, n))
		}, initial: x)
	}
}

extension UnicodeScalar : Arbitrary {
	public static var arbitrary : Gen<UnicodeScalar> {
		return UInt32.arbitrary.bind(Gen<UnicodeScalar>.pure • UnicodeScalar.init)
	}

	public static func shrink(x : UnicodeScalar) -> [UnicodeScalar] {
		let s : UnicodeScalar = UnicodeScalar(UInt32(towlower(Int32(x.value))))
		return nub([ "a", "b", "c", s, "A", "B", "C", "1", "2", "3", "\n", " " ]).filter { $0 < x }
	}
}

extension String : Arbitrary {
	public static var arbitrary : Gen<String> {
		let chars = Gen.sized(Character.arbitrary.proliferateSized)
		return chars >>- (Gen<String>.pure • String.init)
	}

	public static func shrink(s : String) -> [String] {
		return [Character].shrink([Character](s.characters)).map(String.init)
	}
}

extension Character : Arbitrary {
	public static var arbitrary : Gen<Character> {
		return Gen<UInt32>.choose((32, 255)) >>- (Gen<Character>.pure • Character.init • UnicodeScalar.init)
	}

	public static func shrink(x : Character) -> [Character] {
		let ss = String(x).unicodeScalars
		return UnicodeScalar.shrink(ss[ss.startIndex]).map(Character.init)
	}
}

extension Array where Element : Arbitrary {
	public static var arbitrary : Gen<Array<Element>> {
		return Gen.sized { n in
			return Gen<Int>.choose((0, n)).bind { k in
				if k == 0 {
					return Gen.pure([])
				}

				return sequence((0...k).map { _ in Element.arbitrary })
			}
		}
	}

	public static func shrink(bl : Array<Element>) -> [[Element]] {
		return Int.shrink(bl.count).reverse().flatMap({ k in removes(k.successor(), n: bl.count, xs: bl) }) + shrinkOne(bl)
	}
}

extension Array : WitnessedArbitrary {
	public typealias Param = Element

	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element)(pf : ([Element] -> Testable)) -> Property {
		return forAllShrink([A].arbitrary, shrinker: [A].shrink, f: { bl in
			return pf(bl.map(wit))
		})
	}
}

extension AnyBidirectionalCollection where Element : Arbitrary {
	public static var arbitrary : Gen<AnyBidirectionalCollection<Element>> {
		return AnyBidirectionalCollection.init <^> [Element].arbitrary
	}

	public static func shrink(bl : AnyBidirectionalCollection<Element>) -> [AnyBidirectionalCollection<Element>] {
		return [Element].shrink([Element](bl)).map(AnyBidirectionalCollection.init)
	}
}

extension AnyBidirectionalCollection : WitnessedArbitrary {
	public typealias Param = Element

	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element)(pf : (AnyBidirectionalCollection<Element> -> Testable)) -> Property {
		return forAllShrink(AnyBidirectionalCollection<A>.arbitrary, shrinker: AnyBidirectionalCollection<A>.shrink, f: { bl in
			return pf(AnyBidirectionalCollection<Element>(bl.map(wit)))
		})
	}
}

extension AnyForwardIndex : Arbitrary {
	public static var arbitrary : Gen<AnyForwardIndex> {
		return Gen<Int64>.choose((1, Int64.max)).bind(Gen<AnyForwardIndex>.pure • AnyForwardIndex.init)
	}
}

extension AnyRandomAccessIndex : Arbitrary {
	public static var arbitrary : Gen<AnyRandomAccessIndex> {
		return Gen<Int64>.choose((1, Int64.max)).bind(Gen<AnyRandomAccessIndex>.pure • AnyRandomAccessIndex.init)
	}
}

extension AnySequence where Element : Arbitrary {
	public static var arbitrary : Gen<AnySequence<Element>> {
		return AnySequence.init <^> [Element].arbitrary
	}

	public static func shrink(bl : AnySequence<Element>) -> [AnySequence<Element>] {
		return [Element].shrink([Element](bl)).map(AnySequence.init)
	}
}

extension AnySequence : WitnessedArbitrary {
	public typealias Param = Element

	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element)(pf : (AnySequence<Element> -> Testable)) -> Property {
		return forAllShrink(AnySequence<A>.arbitrary, shrinker: AnySequence<A>.shrink, f: { bl in
			return pf(AnySequence<Element>(bl.map(wit)))
		})
	}
}

extension ArraySlice where Element : Arbitrary {
	public static var arbitrary : Gen<ArraySlice<Element>> {
		return ArraySlice.init <^> [Element].arbitrary
	}

	public static func shrink(bl : ArraySlice<Element>) -> [ArraySlice<Element>] {
		return [Element].shrink([Element](bl)).map(ArraySlice.init)
	}
}

extension ArraySlice : WitnessedArbitrary {
	public typealias Param = Element

	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element)(pf : (ArraySlice<Element> -> Testable)) -> Property {
		return forAllShrink(ArraySlice<A>.arbitrary, shrinker: ArraySlice<A>.shrink, f: { bl in
			return pf(ArraySlice<Element>(bl.map(wit)))
		})
	}
}

extension CollectionOfOne where Element : Arbitrary {
	public static var arbitrary : Gen<CollectionOfOne<Element>> {
		return CollectionOfOne.init <^> Element.arbitrary
	}
}

extension CollectionOfOne : WitnessedArbitrary {
	public typealias Param = Element

	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element)(pf : (CollectionOfOne<Element> -> Testable)) -> Property {
		return forAllShrink(CollectionOfOne<A>.arbitrary, shrinker: { _ in [] }, f: { (bl : CollectionOfOne<A>) -> Testable in
			return pf(CollectionOfOne<Element>(wit(bl[.Zero])))
		})
	}
}

/// Generates an Optional of arbitrary values of type A.
extension Optional where Wrapped : Arbitrary {
	public static var arbitrary : Gen<Optional<Wrapped>> {
		return Gen<Optional<Wrapped>>.frequency([
			(1, Gen<Optional<Wrapped>>.pure(.None)),
			(3, liftM(Optional<Wrapped>.Some)(m1: Wrapped.arbitrary)),
		])
	}

	public static func shrink(bl : Optional<Wrapped>) -> [Optional<Wrapped>] {
		if let x = bl {
			return [.None] + Wrapped.shrink(x).map(Optional<Wrapped>.Some)
		}
		return []
	}
}

extension Optional : WitnessedArbitrary {
	public typealias Param = Wrapped

	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Wrapped)(pf : (Optional<Wrapped> -> Testable)) -> Property {
		return forAllShrink(Optional<A>.arbitrary, shrinker: Optional<A>.shrink, f: { bl in
			return pf(bl.map(wit))
		})
	}
}

extension ContiguousArray where Element : Arbitrary {
	public static var arbitrary : Gen<ContiguousArray<Element>> {
		return ContiguousArray.init <^> [Element].arbitrary
	}

	public static func shrink(bl : ContiguousArray<Element>) -> [ContiguousArray<Element>] {
		return [Element].shrink([Element](bl)).map(ContiguousArray.init)
	}
}

extension ContiguousArray : WitnessedArbitrary {
	public typealias Param = Element

	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element)(pf : (ContiguousArray<Element> -> Testable)) -> Property {
		return forAllShrink(ContiguousArray<A>.arbitrary, shrinker: ContiguousArray<A>.shrink, f: { bl in
			return pf(ContiguousArray<Element>(bl.map(wit)))
		})
	}
}

/// Generates an dictionary of arbitrary keys and values.
extension Dictionary where Key : Arbitrary, Value : Arbitrary {
	public static var arbitrary : Gen<Dictionary<Key, Value>> {
		return [Key].arbitrary.bind { k in
			return [Value].arbitrary.bind { v in
				return Gen.pure(Dictionary(Zip2Sequence(k, v)))
			}
		}
	}

	public static func shrink(d : Dictionary<Key, Value>) -> [Dictionary<Key, Value>] {
		return d.map { Dictionary(Zip2Sequence(Key.shrink($0), Value.shrink($1))) }
	}
}

extension Dictionary {
	init<S : SequenceType where S.Generator.Element == Element>(_ pairs : S) {
		self.init()
		var g = pairs.generate()
		while let (k, v): (Key, Value) = g.next() {
			self[k] = v
		}
	}
}

extension EmptyCollection : Arbitrary {
	public static var arbitrary : Gen<EmptyCollection<Element>> {
		return Gen.pure(EmptyCollection())
	}
}

extension HalfOpenInterval where Bound : protocol<Comparable, Arbitrary> {
	public static var arbitrary : Gen<HalfOpenInterval<Bound>> {
		return Bound.arbitrary.bind { l in
			return Bound.arbitrary.bind { r in
				return Gen.pure(HalfOpenInterval(min(l, r), max(l, r)))
			}
		}
	}

	public static func shrink(bl : HalfOpenInterval<Bound>) -> [HalfOpenInterval<Bound>] {
		return zip(Bound.shrink(bl.start), Bound.shrink(bl.end)).map(HalfOpenInterval.init)
	}
}

extension ImplicitlyUnwrappedOptional where Wrapped : Arbitrary {
	public static var arbitrary : Gen<ImplicitlyUnwrappedOptional<Wrapped>> {
		return ImplicitlyUnwrappedOptional.init <^> Optional<Wrapped>.arbitrary
	}

	public static func shrink(bl : ImplicitlyUnwrappedOptional<Wrapped>) -> [ImplicitlyUnwrappedOptional<Wrapped>] {
		return Optional<Wrapped>.shrink(bl).map(ImplicitlyUnwrappedOptional.init)
	}
}

extension ImplicitlyUnwrappedOptional : WitnessedArbitrary {
	public typealias Param = Wrapped

	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Wrapped)(pf : (ImplicitlyUnwrappedOptional<Wrapped> -> Testable)) -> Property {
		return forAllShrink(ImplicitlyUnwrappedOptional<A>.arbitrary, shrinker: ImplicitlyUnwrappedOptional<A>.shrink, f: { bl in
			return pf(bl.map(wit))
		})
	}
}

extension LazyCollection where Base : protocol<CollectionType, Arbitrary>, Base.Index : ForwardIndexType {
	public static var arbitrary : Gen<LazyCollection<Base>> {
		return LazyCollection<Base>.arbitrary
	}
}

extension LazySequence where Base : protocol<SequenceType, Arbitrary> {
	public static var arbitrary : Gen<LazySequence<Base>> {
		return LazySequence<Base>.arbitrary
	}
}

extension Range where Element : protocol<ForwardIndexType, Comparable, Arbitrary> {
	public static var arbitrary : Gen<Range<Element>> {
		return Element.arbitrary.bind { l in
			return Element.arbitrary.bind { r in
				return Gen.pure(Range(start: min(l, r), end: max(l, r)))
			}
		}
	}

	public static func shrink(bl : Range<Element>) -> [Range<Element>] {
		return Zip2Sequence(Element.shrink(bl.startIndex), Element.shrink(bl.endIndex)).map(Range.init)
	}
}

extension Repeat where Element : Arbitrary {
	public static var arbitrary : Gen<Repeat<Element>> {
		return Repeat.init <^> Gen<Any>.zip(Int.arbitrary, Element.arbitrary)
	}
}

extension Repeat : WitnessedArbitrary {
	public typealias Param = Element

	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element)(pf : (Repeat<Element> -> Testable)) -> Property {
		return forAllShrink(Repeat<A>.arbitrary, shrinker: { _ in [] }, f: { bl in
			let xs = bl.map(wit)
			return pf(Repeat<Element>(count: xs.count, repeatedValue: xs.first!))
		})
	}
}

extension Set where Element : protocol<Arbitrary, Hashable> {
	public static var arbitrary : Gen<Set<Element>> {
		return Gen.sized { n in
			return Gen<Int>.choose((0, n)).bind { k in
				if k == 0 {
					return Gen.pure(Set([]))
				}

				return Set.init <^> sequence(Array((0...k)).map { _ in Element.arbitrary })
			}
		}
	}

	public static func shrink(s : Set<Element>) -> [Set<Element>] {
		return [Element].shrink([Element](s)).map(Set.init)
	}
}

extension Set : WitnessedArbitrary {
	public typealias Param = Element

	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element)(pf : (Set<Element> -> Testable)) -> Property {
		return forAll { (xs : [A]) in
			return pf(Set<Element>(xs.map(wit)))
		}
	}
}

/// Coarbitrary types must take an arbitrary value of their type and yield a function that
/// transforms a given generator by returning a new generator that depends on the input value.  Put
/// simply, the function should perturb the given generator (more than likely using `Gen.variant()`.
public protocol CoArbitrary {
	/// Uses an instance of the receiver to return a function that perturbs a generator.
	static func coarbitrary<C>(x : Self) -> (Gen<C> -> Gen<C>)
}

extension IntegerType {
	/// A coarbitrary implementation for any IntegerType
	public func coarbitraryIntegral<C>() -> Gen<C> -> Gen<C> {
		return { $0.variant(self) }
	}
}

/// A coarbitrary implementation for any Printable type.  Avoid using this function if you can, it
/// can be quite an expensive operation given a detailed enough description.
public func coarbitraryPrintable<A, B>(x : A) -> Gen<B> -> Gen<B> {
	return String.coarbitrary(String(x))
}

extension Bool : CoArbitrary {
	public static func coarbitrary<C>(x : Bool) -> Gen<C> -> Gen<C> {
		return { g in
			if x {
				return g.variant(1)
			}
			return g.variant(0)
		}
	}
}

extension UnicodeScalar : CoArbitrary {
	public static func coarbitrary<C>(x : UnicodeScalar) -> Gen<C> -> Gen<C> {
		return UInt32.coarbitrary(x.value)
	}
}

extension Character : CoArbitrary {
	public static func coarbitrary<C>(x : Character) -> (Gen<C> -> Gen<C>) {
		let ss = String(x).unicodeScalars
		return UnicodeScalar.coarbitrary(ss[ss.startIndex])
	}
}

extension String : CoArbitrary {
	public static func coarbitrary<C>(x : String) -> (Gen<C> -> Gen<C>) {
		if x.isEmpty {
			return { $0.variant(0) }
		}
		return Character.coarbitrary(x[x.startIndex]) • String.coarbitrary(x[x.startIndex.successor()..<x.endIndex])
	}
}

extension Int : CoArbitrary {
	public static func coarbitrary<C>(x : Int) -> Gen<C> -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension Int8 : CoArbitrary {
	public static func coarbitrary<C>(x : Int8) -> Gen<C> -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension Int16 : CoArbitrary {
	public static func coarbitrary<C>(x : Int16) -> Gen<C> -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension Int32 : CoArbitrary {
	public static func coarbitrary<C>(x : Int32) -> Gen<C> -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension Int64 : CoArbitrary {
	public static func coarbitrary<C>(x : Int64) -> Gen<C> -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension UInt : CoArbitrary {
	public static func coarbitrary<C>(x : UInt) -> Gen<C> -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension UInt8 : CoArbitrary {
	public static func coarbitrary<C>(x : UInt8) -> Gen<C> -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension UInt16 : CoArbitrary {
	public static func coarbitrary<C>(x : UInt16) -> Gen<C> -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension UInt32 : CoArbitrary {
	public static func coarbitrary<C>(x : UInt32) -> Gen<C> -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

extension UInt64 : CoArbitrary {
	public static func coarbitrary<C>(x : UInt64) -> Gen<C> -> Gen<C> {
		return x.coarbitraryIntegral()
	}
}

// In future, implement these with Ratios like QuickCheck.
extension Float : CoArbitrary {
	public static func coarbitrary<C>(x : Float) -> (Gen<C> -> Gen<C>) {
		return Int64(x).coarbitraryIntegral()
	}
}

extension Double : CoArbitrary {
	public static func coarbitrary<C>(x : Double) -> (Gen<C> -> Gen<C>) {
		return Int64(x).coarbitraryIntegral()
	}
}

extension Array : CoArbitrary {
	public static func coarbitrary<C>(a : [Element]) -> (Gen<C> -> Gen<C>) {
		if a.isEmpty {
			return { $0.variant(0) }
		}
		return { $0.variant(1) } • [Element].coarbitrary([Element](a[1..<a.endIndex]))
	}
}

extension Dictionary : CoArbitrary {
	public static func coarbitrary<C>(x : Dictionary<Key, Value>) -> (Gen<C> -> Gen<C>) {
		if x.isEmpty {
			return { $0.variant(0) }
		}
		return { $0.variant(1) }
	}
}

extension Optional : CoArbitrary {
	public static func coarbitrary<C>(x : Optional<Wrapped>) -> (Gen<C> -> Gen<C>) {
		if let _ = x {
			return { $0.variant(0) }
		}
		return { $0.variant(1) }
	}
}

extension Set : CoArbitrary {
	public static func coarbitrary<C>(x : Set<Element>) -> (Gen<C> -> Gen<C>) {
		if x.isEmpty {
			return { $0.variant(0) }
		}
		return { $0.variant(1) }
	}
}

/// MARK: - Implementation Details

private func bits<N : IntegerType>(n : N) -> Int {
	if n / 2 == 0 {
		return 0
	}
	return 1 + bits(n / 2)
}

private func nub<A : Hashable>(xs : [A]) -> [A] {
	return [A](Set(xs))
}

private func unfoldr<A, B>(f : B -> Optional<(A, B)>, initial : B) -> [A] {
	var acc = [A]()
	var ini = initial
	while let next = f(ini) {
		acc.insert(next.0, atIndex: 0)
		ini = next.1
	}
	return acc
}

private func removes<A : Arbitrary>(k : Int, n : Int, xs : [A]) -> [[A]] {
	let xs1 = take(k, xs: xs)
	let xs2 = drop(k, xs: xs)

	if k > n {
		return []
	} else if xs2.isEmpty {
		return [[]]
	} else {
		return [xs2] + removes(k, n: n - k, xs: xs2).map({ xs1 + $0 })
	}
}

private func take<T>(num : Int, xs : [T]) -> [T] {
	let n = (num < xs.count) ? num : xs.count
	return [T](xs[0..<n])
}

private func drop<T>(num : Int, xs : [T]) -> [T] {
	let n = (num < xs.count) ? num : xs.count
	return [T](xs[n..<xs.endIndex])
}

private func shrinkOne<A : Arbitrary>(xs : [A]) -> [[A]] {
	if xs.isEmpty {
		return []
	} else if let x = xs.first {
		let xss = [A](xs[1..<xs.endIndex])
		let a = A.shrink(x).map({ [$0] + xss })
		let b = shrinkOne(xss).map({ [x] + $0 })
		return a + b
	}
	fatalError("Array could not produce a first element")
}
