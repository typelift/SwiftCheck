//
//  WitnessedArbitrary.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 12/15/15.
//  Copyright © 2016 Typelift. All rights reserved.
//

extension Array where Element : Arbitrary {
	/// Returns a generator of `Array`s of arbitrary `Element`s.
	public static var arbitrary : Gen<Array<Element>> {
		return Gen.sized { n in
			return Gen<Int>.choose((0, n)).flatMap { k in
				if k == 0 {
					return Gen.pure([])
				}

				return sequence((0...k).map { _ in Element.arbitrary })
			}
		}
	}

	/// The default shrinking function for `Array`s of arbitrary `Element`s.
	public static func shrink(bl : Array<Element>) -> [[Element]] {
		let rec : [[Element]] = shrinkOne(bl)
		return Int.shrink(bl.count).reverse().flatMap({ k in removes(k.successor(), n: bl.count, xs: bl) }) + rec
	}
}

extension Array : WitnessedArbitrary {
	public typealias Param = Element

	/// Given a witness and a function to test, converts them into a universally
	/// quantified property over `Array`s.
	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element, pf : ([Element] -> Testable)) -> Property {
		return forAllShrink([A].arbitrary, shrinker: [A].shrink, f: { bl in
			return pf(bl.map(wit))
		})
	}
}

extension AnyBidirectionalCollection where Element : Arbitrary {
	/// Returns a generator of `AnyBidirectionalCollection`s of arbitrary `Element`s.
	public static var arbitrary : Gen<AnyBidirectionalCollection<Element>> {
		return AnyBidirectionalCollection.init <^> [Element].arbitrary
	}

	/// The default shrinking function for `AnyBidirectionalCollection`s of arbitrary `Element`s.
	public static func shrink(bl : AnyBidirectionalCollection<Element>) -> [AnyBidirectionalCollection<Element>] {
		return [Element].shrink([Element](bl)).map(AnyBidirectionalCollection.init)
	}
}

extension AnyBidirectionalCollection : WitnessedArbitrary {
	public typealias Param = Element

	/// Given a witness and a function to test, converts them into a universally
	/// quantified property over `AnyBidirectionalCollection`s.
	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element, pf : (AnyBidirectionalCollection<Element> -> Testable)) -> Property {
		return forAllShrink(AnyBidirectionalCollection<A>.arbitrary, shrinker: AnyBidirectionalCollection<A>.shrink, f: { bl in
			return pf(AnyBidirectionalCollection<Element>(bl.map(wit)))
		})
	}
}

extension AnySequence where Element : Arbitrary {
	/// Returns a generator of `AnySequence`s of arbitrary `Element`s.
	public static var arbitrary : Gen<AnySequence<Element>> {
		return AnySequence.init <^> [Element].arbitrary
	}

	/// The default shrinking function for `AnySequence`s of arbitrary `Element`s.
	public static func shrink(bl : AnySequence<Element>) -> [AnySequence<Element>] {
		return [Element].shrink([Element](bl)).map(AnySequence.init)
	}
}

extension AnySequence : WitnessedArbitrary {
	public typealias Param = Element

	/// Given a witness and a function to test, converts them into a universally
	/// quantified property over `AnySequence`s.
	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element, pf : (AnySequence<Element> -> Testable)) -> Property {
		return forAllShrink(AnySequence<A>.arbitrary, shrinker: AnySequence<A>.shrink, f: { bl in
			return pf(AnySequence<Element>(bl.map(wit)))
		})
	}
}

extension ArraySlice where Element : Arbitrary {
	/// Returns a generator of `ArraySlice`s of arbitrary `Element`s.
	public static var arbitrary : Gen<ArraySlice<Element>> {
		return ArraySlice.init <^> [Element].arbitrary
	}

	/// The default shrinking function for `ArraySlice`s of arbitrary `Element`s.
	public static func shrink(bl : ArraySlice<Element>) -> [ArraySlice<Element>] {
		return [Element].shrink([Element](bl)).map(ArraySlice.init)
	}
}

extension ArraySlice : WitnessedArbitrary {
	public typealias Param = Element

	/// Given a witness and a function to test, converts them into a universally
	/// quantified property over `ArraySlice`s.
	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element, pf : (ArraySlice<Element> -> Testable)) -> Property {
		return forAllShrink(ArraySlice<A>.arbitrary, shrinker: ArraySlice<A>.shrink, f: { bl in
			return pf(ArraySlice<Element>(bl.map(wit)))
		})
	}
}

extension CollectionOfOne where Element : Arbitrary {
	/// Returns a generator of `CollectionOfOne`s of arbitrary `Element`s.
	public static var arbitrary : Gen<CollectionOfOne<Element>> {
		return CollectionOfOne.init <^> Element.arbitrary
	}
}

extension CollectionOfOne : WitnessedArbitrary {
	public typealias Param = Element

	/// Given a witness and a function to test, converts them into a universally
	/// quantified property over `CollectionOfOne`s.
	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element, pf : (CollectionOfOne<Element> -> Testable)) -> Property {
		return forAllShrink(CollectionOfOne<A>.arbitrary, shrinker: { _ in [] }, f: { (bl : CollectionOfOne<A>) -> Testable in
			return pf(CollectionOfOne<Element>(wit(bl[.Zero])))
		})
	}
}

/// Generates an Optional of arbitrary values of type A.
extension Optional where Wrapped : Arbitrary {
	/// Returns a generator of `Optional`s of arbitrary `Wrapped` values.
	public static var arbitrary : Gen<Optional<Wrapped>> {
		return Gen<Optional<Wrapped>>.frequency([
			(1, Gen<Optional<Wrapped>>.pure(.None)),
			(3, liftM(Optional<Wrapped>.Some, Wrapped.arbitrary)),
		])
	}

	/// The default shrinking function for `Optional`s of arbitrary `Wrapped`s.
	public static func shrink(bl : Optional<Wrapped>) -> [Optional<Wrapped>] {
		if let x = bl {
			let rec : [Optional<Wrapped>] = Wrapped.shrink(x).map(Optional<Wrapped>.Some)
			return [.None] + rec
		}
		return []
	}
}

extension Optional : WitnessedArbitrary {
	public typealias Param = Wrapped

	/// Given a witness and a function to test, converts them into a universally
	/// quantified property over `Optional`s.
	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Wrapped, pf : (Optional<Wrapped> -> Testable)) -> Property {
		return forAllShrink(Optional<A>.arbitrary, shrinker: Optional<A>.shrink, f: { bl in
			return pf(bl.map(wit))
		})
	}
}

extension ContiguousArray where Element : Arbitrary {
	/// Returns a generator of `ContiguousArray`s of arbitrary `Element`s.
	public static var arbitrary : Gen<ContiguousArray<Element>> {
		return ContiguousArray.init <^> [Element].arbitrary
	}

	/// The default shrinking function for `ContiguousArray`s of arbitrary `Element`s.
	public static func shrink(bl : ContiguousArray<Element>) -> [ContiguousArray<Element>] {
		return [Element].shrink([Element](bl)).map(ContiguousArray.init)
	}
}

extension ContiguousArray : WitnessedArbitrary {
	public typealias Param = Element

	/// Given a witness and a function to test, converts them into a universally
	/// quantified property over `ContiguousArray`s.
	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element, pf : (ContiguousArray<Element> -> Testable)) -> Property {
		return forAllShrink(ContiguousArray<A>.arbitrary, shrinker: ContiguousArray<A>.shrink, f: { bl in
			return pf(ContiguousArray<Element>(bl.map(wit)))
		})
	}
}

/// Generates an dictionary of arbitrary keys and values.
extension Dictionary where Key : Arbitrary, Value : Arbitrary {
	/// Returns a generator of `Dictionary`s of arbitrary `Key`s and `Value`s.
	public static var arbitrary : Gen<Dictionary<Key, Value>> {
		return [Key].arbitrary.flatMap { k in
			return [Value].arbitrary.flatMap { v in
				return Gen.pure(Dictionary(Zip2Sequence(k, v)))
			}
		}
	}

	/// The default shrinking function for `Dictionary`s of arbitrary `Key`s and
	/// `Value`s.
	public static func shrink(d : Dictionary<Key, Value>) -> [Dictionary<Key, Value>] {
		return d.map { Dictionary(Zip2Sequence(Key.shrink($0), Value.shrink($1))) }
	}
}

extension EmptyCollection : Arbitrary {
	/// Returns a generator of `EmptyCollection`s of arbitrary `Element`s.
	public static var arbitrary : Gen<EmptyCollection<Element>> {
		return Gen.pure(EmptyCollection())
	}
}

extension HalfOpenInterval where Bound : protocol<Comparable, Arbitrary> {
	/// Returns a generator of `HalfOpenInterval`s of arbitrary `Bound`s.
	public static var arbitrary : Gen<HalfOpenInterval<Bound>> {
		return Bound.arbitrary.flatMap { l in
			return Bound.arbitrary.flatMap { r in
				return Gen.pure(HalfOpenInterval(min(l, r), max(l, r)))
			}
		}
	}

	/// The default shrinking function for `HalfOpenInterval`s of arbitrary `Bound`s.
	public static func shrink(bl : HalfOpenInterval<Bound>) -> [HalfOpenInterval<Bound>] {
		return zip(Bound.shrink(bl.start), Bound.shrink(bl.end)).map(HalfOpenInterval.init)
	}
}

extension LazyCollection where Base : protocol<CollectionType, Arbitrary>, Base.Index : ForwardIndexType {
	/// Returns a generator of `LazyCollection`s of arbitrary `Base`s.
	public static var arbitrary : Gen<LazyCollection<Base>> {
		return LazyCollection<Base>.arbitrary
	}
}

extension LazySequence where Base : protocol<SequenceType, Arbitrary> {
	/// Returns a generator of `LazySequence`s of arbitrary `Base`s.
	public static var arbitrary : Gen<LazySequence<Base>> {
		return LazySequence<Base>.arbitrary
	}
}

extension Range where Element : protocol<ForwardIndexType, Comparable, Arbitrary> {
	/// Returns a generator of `Range`s of arbitrary `Element`s.
	public static var arbitrary : Gen<Range<Element>> {
		return Element.arbitrary.flatMap { l in
			return Element.arbitrary.flatMap { r in
				return Gen.pure(min(l, r)..<max(l, r))
			}
		}
	}

	/// The default shrinking function for `Range`s of arbitrary `Element`s.
	public static func shrink(bl : Range<Element>) -> [Range<Element>] {
		return Zip2Sequence(Element.shrink(bl.startIndex), Element.shrink(bl.endIndex)).map(..<)
	}
}

extension Repeat where Element : Arbitrary {
	/// Returns a generator of `Repeat`s of arbitrary `Element`s.
	public static var arbitrary : Gen<Repeat<Element>> {
		return Repeat.init <^> Gen<Any>.zip(Int.arbitrary, Element.arbitrary)
	}
}

extension Repeat : WitnessedArbitrary {
	public typealias Param = Element

	/// Given a witness and a function to test, converts them into a universally
	/// quantified property over `Repeat`s.
	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element, pf : (Repeat<Element> -> Testable)) -> Property {
		return forAllShrink(Repeat<A>.arbitrary, shrinker: { _ in [] }, f: { bl in
			let xs = bl.map(wit)
			return pf(Repeat<Element>(count: xs.count, repeatedValue: xs.first!))
		})
	}
}

extension Set where Element : protocol<Arbitrary, Hashable> {
	/// Returns a generator of `Set`s of arbitrary `Element`s.
	public static var arbitrary : Gen<Set<Element>> {
		return Gen.sized { n in
			return Gen<Int>.choose((0, n)).flatMap { k in
				if k == 0 {
					return Gen.pure(Set([]))
				}

				return Set.init <^> sequence(Array((0...k)).map { _ in Element.arbitrary })
			}
		}
	}

	/// The default shrinking function for `Set`s of arbitrary `Element`s.
	public static func shrink(s : Set<Element>) -> [Set<Element>] {
		return [Element].shrink([Element](s)).map(Set.init)
	}
}

extension Set : WitnessedArbitrary {
	public typealias Param = Element

	/// Given a witness and a function to test, converts them into a universally
	/// quantified property over `Set`s.
	public static func forAllWitnessed<A : Arbitrary>(wit : A -> Element, pf : (Set<Element> -> Testable)) -> Property {
		return forAll { (xs : [A]) in
			return pf(Set<Element>(xs.map(wit)))
		}
	}
}

// MARK: - Implementation Details Follow

private func bits<N : IntegerType>(n : N) -> Int {
	if n / 2 == 0 {
		return 0
	}
	return 1 + bits(n / 2)
}

private func removes<A : Arbitrary>(k : Int, n : Int, xs : [A]) -> [[A]] {
	let xs1 : [A] = take(k, xs: xs)
	let xs2 : [A] = drop(k, xs: xs)

	if k > n {
		return []
	} else if xs2.isEmpty {
		return [[]]
	} else {
		let rec : [[A]] = removes(k, n: n - k, xs: xs2).map({ xs1 + $0 })
		return [xs2] + rec
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
		return [[A]]()
	} else if let x : A = xs.first {
		let xss = [A](xs[1..<xs.endIndex])
		let a : [[A]] = A.shrink(x).map({ [$0] + xss })
		let b : [[A]] = shrinkOne(xss).map({ [x] + $0 })
		return a + b
	}
	fatalError("Array could not produce a first element")
}

extension Dictionary {
	private init<S : SequenceType where S.Generator.Element == Element>(_ pairs : S) {
		self.init()
		var g = pairs.generate()
		while let (k, v): (Key, Value) = g.next() {
			self[k] = v
		}
	}
}
