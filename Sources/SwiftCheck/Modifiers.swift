//
//  Modifiers.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/29/15.
//  Copyright (c) 2015 CodaFi. All rights reserved.
//

// MARK: - Modifier Types

/// A Modifier Type is a type that wraps another to provide special semantics or
/// simply to generate values of an underlying type that would be unusually
/// difficult to express given the limitations of Swift's type system.
///
/// For an example of the former, take the `Blind` modifier.  Because
/// SwiftCheck's counterexamples come from a description a particular object
/// provides for itself, there are many cases where console output can become
/// unbearably long, or just simply isn't useful to your test suite.  By
/// wrapping that type in `Blind` SwiftCheck ignores whatever description the
/// property provides and just print "(*)".
///
///     property("All blind variables print '(*)'") <- forAll { (x : Blind<Int>) in
///         return x.description == "(*)"
///     }
///
/// For an example of the latter see the `ArrowOf` modifier.  Because Swift's
/// type system treats arrows (`->`) as an opaque entity that you can't interact
/// with or extend, SwiftCheck provides `ArrowOf` to enable the generation of
/// functions between 2 types.  That's right, we can generate arbitrary
/// functions!
///
///     property("map accepts SwiftCheck arrows") <- forAll { (xs : [Int]) in
///         return forAll { (f : ArrowOf<Int, Int>) in
///             /// Just to prove it really is a function (that is, every input
///             /// always maps to the same output), and not just a trick, we
///             /// map twice and should get equal arrays.
///                return xs.map(f.getArrow) == xs.map(f.getArrow)
///         }
///     }

/// For types that either do not have a `CustomStringConvertible` instance or
/// that wish to have no description to print, Blind will create a default
/// description for them.
public struct Blind<A : Arbitrary> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying value.
	public let getBlind : A

	/// Creates a new `Blind` modifier from an underlying value.
	public init(_ blind : A) {
		self.getBlind = blind
	}

	/// A default short description for the blind value.
	///
	/// By default, the value of this property is `(*)`.
	public var description : String {
		return "(*)"
	}

	/// Returns a generator of `Blind` values.
	public static var arbitrary : Gen<Blind<A>> {
		return A.arbitrary.map(Blind.init)
	}

	/// The default shrinking function for `Blind` values.
	public static func shrink(_ bl : Blind<A>) -> [Blind<A>] {
		return A.shrink(bl.getBlind).map(Blind.init)
	}
}

extension Blind : CoArbitrary {
	/// Uses the underlying value to perturb a generator.
	public static func coarbitrary<C>(_ x : Blind) -> ((Gen<C>) -> Gen<C>) {
		// Take the lazy way out.
		return coarbitraryPrintable(x)
	}
}

/// Guarantees test cases for its underlying type will not be shrunk.
public struct Static<A : Arbitrary> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying value.
	public let getStatic : A

	/// Creates a new `Static` modifier from an underlying value.
	public init(_ fixed : A) {
		self.getStatic = fixed
	}

	/// A textual representation of `self`.
	public var description : String {
		return "Static( \(self.getStatic) )"
	}

	/// Returns a generator of `Static` values.
	public static var arbitrary : Gen<Static<A>> {
		return A.arbitrary.map(Static.init)
	}
}

extension Static : CoArbitrary {
	/// Uses the underlying value to perturb a generator.
	public static func coarbitrary<C>(_ x : Static) -> ((Gen<C>) -> Gen<C>) {
		// Take the lazy way out.
		return coarbitraryPrintable(x)
	}
}

/// Generates a sorted array of arbitrary values of type A.
public struct OrderedArrayOf<A : Arbitrary & Comparable> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying sorted array of values.
	public let getOrderedArray : [A]

	/// Retrieves the underlying sorted array of values as a contiguous
	/// array.
	public var getContiguousArray : ContiguousArray<A> {
		return ContiguousArray(self.getOrderedArray)
	}

	/// Creates a new `OrderedArrayOf` modifier from an underlying array of 
	/// values.
	///
	/// The values in the array are not required to be sorted, they will
	/// be sorted by the initializer.
	public init(_ array : [A]) {
		self.getOrderedArray = array.sorted()
	}

	/// A textual representation of `self`.
	public var description : String {
		return "\(self.getOrderedArray)"
	}

	/// Returns a generator for an `OrderedArrayOf` values.
	public static var arbitrary : Gen<OrderedArrayOf<A>> {
		return Array<A>.arbitrary.map(OrderedArrayOf.init)
	}

	/// The default shrinking function for an `OrderedArrayOf` values.
	public static func shrink(_ bl : OrderedArrayOf<A>) -> [OrderedArrayOf<A>] {
		return Array<A>.shrink(bl.getOrderedArray).filter({ $0.sorted() == $0 }).map(OrderedArrayOf.init)
	}
}

/// Generates pointers of varying size of random values of type T.
public struct PointerOf<T : Arbitrary> : Arbitrary, CustomStringConvertible {
	fileprivate let _impl : PointerOfImpl<T>

	/// Retrieves the underlying pointer value.
	public var getPointer : UnsafeBufferPointer<T> {
		return UnsafeBufferPointer(start: self._impl.ptr, count: self.size)
	}

	public var size : Int {
		return self._impl.size
	}

	/// A textual representation of `self`.
	public var description : String {
		return self._impl.description
	}

	/// Returns a generator for a `PointerOf` values.
	public static var arbitrary : Gen<PointerOf<T>> {
		return PointerOfImpl.arbitrary.map(PointerOf.init)
	}
}

/// Generates a Swift function from T to U.
public struct ArrowOf<T : Hashable & CoArbitrary, U : Arbitrary> : Arbitrary, CustomStringConvertible {
	fileprivate let _impl : ArrowOfImpl<T, U>

	/// Retrieves the underlying function value, `T -> U`.
	public var getArrow : (T) -> U {
		return self._impl.arr
	}

	/// A textual representation of `self`.
	public var description : String {
		return self._impl.description
	}

	/// Returns a generator for an `ArrowOf` function values.
	public static var arbitrary : Gen<ArrowOf<T, U>> {
		return ArrowOfImpl<T, U>.arbitrary.map(ArrowOf.init)
	}
}

extension ArrowOf : CustomReflectable {
	public var customMirror : Mirror {
		return Mirror(self, children: [
			"types": "\(T.self) -> \(U.self)",
			"currentMap": self._impl.table,
		])
	}
}

/// Generates two isomorphic Swift functions from `T` to `U` and back again.
public struct IsoOf<T : Hashable & CoArbitrary & Arbitrary, U : Equatable & CoArbitrary & Arbitrary> : Arbitrary, CustomStringConvertible {
	fileprivate let _impl : IsoOfImpl<T, U>

	/// Retrieves the underlying embedding function, `T -> U`.
	public var getTo : (T) -> U {
		return self._impl.embed
	}

	/// Retrieves the underlying projecting function, `U -> T`.
	public var getFrom : (U) -> T {
		return self._impl.project
	}

	/// A textual representation of `self`.
	public var description : String {
		return self._impl.description
	}

	/// Returns a generator for an `IsoOf` function values.
	public static var arbitrary : Gen<IsoOf<T, U>> {
		return IsoOfImpl<T, U>.arbitrary.map(IsoOf.init)
	}
}

extension IsoOf : CustomReflectable {
	public var customMirror : Mirror {
		return Mirror(self, children: [
			"embed": "\(T.self) -> \(U.self)",
			"project": "\(U.self) -> \(T.self)",
			"currentMap": self._impl.table,
		])
	}
}

/// By default, SwiftCheck generates values drawn from a small range. `Large`
/// gives you values drawn from the entire range instead.
public struct Large<A : RandomType & LatticeType & BinaryInteger> : Arbitrary {
	/// Retrieves the underlying large value.
	public let getLarge : A

	/// Creates a new `Large` modifier from a given bounded integral value.
	public init(_ lrg : A) {
		self.getLarge = lrg
	}

	/// A textual representation of `self`.
	public var description : String {
		return "Large( \(self.getLarge) )"
	}

	/// Returns a generator of `Large` values.
	public static var arbitrary : Gen<Large<A>> {
		return Gen<A>.choose((A.min, A.max)).map(Large.init)
	}

	/// The default shrinking function for `Large` values.
	public static func shrink(_ bl : Large<A>) -> [Large<A>] {
		return bl.getLarge.shrinkIntegral.map(Large.init)
	}
}

/// Guarantees that every generated integer is greater than 0.
public struct Positive<A : Arbitrary & SignedInteger> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying positive value.
	public let getPositive : A

	/// Creates a new `Positive` modifier from a given signed integral value.
	public init(_ pos : A) {
		self.getPositive = pos
	}

	/// A textual representation of `self`.
	public var description : String {
		return "Positive( \(self.getPositive) )"
	}

	/// Returns a generator of `Positive` values.
	public static var arbitrary : Gen<Positive<A>> {
		return A.arbitrary.map(comp(Positive.init, abs)).suchThat { $0.getPositive > 0 }
	}

	/// The default shrinking function for `Positive` values.
	public static func shrink(_ bl : Positive<A>) -> [Positive<A>] {
		return A.shrink(bl.getPositive).filter({ $0 > 0 }).map(Positive.init)
	}
}

extension Positive : CoArbitrary {
	/// Uses the underlying positive integral value to perturb a generator.
	public static func coarbitrary<C>(_ x : Positive) -> ((Gen<C>) -> Gen<C>) {
		// Take the lazy way out.
		return coarbitraryPrintable(x)
	}
}

/// Guarantees that every generated integer is never 0.
public struct NonZero<A : Arbitrary & BinaryInteger> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying non-zero value.
	public let getNonZero : A

	/// Creates a new `NonZero` modifier from a given integral value.
	public init(_ non : A) {
		self.getNonZero = non
	}

	/// A textual representation of `self`.
	public var description : String {
		return "NonZero( \(self.getNonZero) )"
	}

	/// Returns a generator of `NonZero` values.
	public static var arbitrary : Gen<NonZero<A>> {
		return A.arbitrary.suchThat({ $0 != 0 }).map(NonZero.init)
	}

	/// The default shrinking function for `NonZero` values.
	public static func shrink(_ bl : NonZero<A>) -> [NonZero<A>] {
		return A.shrink(bl.getNonZero).filter({ $0 != 0 }).map(NonZero.init)
	}
}

extension NonZero : CoArbitrary {
	/// Uses the underlying non-zero integral value to perturb a generator.
	public static func coarbitrary<C>(_ x : NonZero) -> ((Gen<C>) -> Gen<C>) {
		return x.getNonZero.coarbitraryIntegral()
	}
}

/// Guarantees that every generated integer is greater than or equal to 0.
public struct NonNegative<A : Arbitrary & BinaryInteger> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying non-negative value.
	public let getNonNegative : A

	/// Creates a new `NonNegative` modifier from a given integral value.
	public init(_ non : A) {
		self.getNonNegative = non
	}

	/// A textual representation of `self`.
	public var description : String {
		return "NonNegative( \(self.getNonNegative) )"
	}

	/// Returns a generator of `NonNegative` values.
	public static var arbitrary : Gen<NonNegative<A>> {
		return A.arbitrary.suchThat({ $0 >= 0 }).map(NonNegative.init)
	}

	/// The default shrinking function for `NonNegative` values.
	public static func shrink(_ bl : NonNegative<A>) -> [NonNegative<A>] {
		return A.shrink(bl.getNonNegative).filter({ $0 >= 0 }).map(NonNegative.init)
	}
}

extension NonNegative : CoArbitrary {
	/// Uses the underlying non-negative integral value to perturb a generator.
	public static func coarbitrary<C>(_ x : NonNegative) -> ((Gen<C>) -> Gen<C>) {
		return x.getNonNegative.coarbitraryIntegral()
	}
}


// MARK: - Implementation Details Follow


private func undefined<A>() -> A {
	fatalError("")
}

fileprivate final class ArrowOfImpl<T : Hashable & CoArbitrary, U : Arbitrary> : Arbitrary, CustomStringConvertible {
	fileprivate var table : Dictionary<T, U>
	fileprivate var arr : (T) -> U

	init (_ table : Dictionary<T, U>, _ arr : @escaping (T) -> U) {
		self.table = table
		self.arr = arr
	}

	convenience init(_ arr : @escaping (T) -> U) {
		var table = [T:U]()
		self.init(table, { (_ : T) -> U in return undefined() })

		self.arr = { x in
			if let v = table[x] {
				return v
			}
			let y = arr(x)
			table[x] = y
			return y
		}
	}

	var description : String {
		return "\(T.self) -> \(U.self)"
	}

	static var arbitrary : Gen<ArrowOfImpl<T, U>> {
		return promote({ a in
			return T.coarbitrary(a)(U.arbitrary)
		}).map(ArrowOfImpl.init)
	}

	static func shrink(_ f : ArrowOfImpl<T, U>) -> [ArrowOfImpl<T, U>] {
		return f.table.flatMap { (t) -> [ArrowOfImpl<T, U>] in
			let (x, y) = t
			return U.shrink(y).map({ y2 in
				return ArrowOfImpl<T, U>({ z in
					if x == z {
						return y2
					}
					return f.arr(z)
				})
			})
		}
	}
}

fileprivate final class IsoOfImpl<T : Hashable & CoArbitrary & Arbitrary, U : Equatable & CoArbitrary & Arbitrary> : Arbitrary, CustomStringConvertible {
	fileprivate var table : Dictionary<T, U>
	fileprivate var embed : (T) -> U
	fileprivate var project : (U) -> T

	init (_ table : Dictionary<T, U>, _ embed : @escaping (T) -> U, _ project : @escaping (U) -> T) {
		self.table = table
		self.embed = embed
		self.project = project
	}

	convenience init(_ embed : @escaping (T) -> U, _ project : @escaping (U) -> T) {
		var table = [T:U]()
		self.init(table, { (_ : T) -> U in return undefined() }, { (_ : U) -> T in return undefined() })

		self.embed = { t in
			if let v = table[t] {
				return v
			}
			let y = embed(t)
			table[t] = y
			return y
		}

		self.project = { u in
			let ts = table.filter({ t in t.1 == u }).map { $0.0 }
			if let k = ts.first, let _ = table[k] {
				return k
			}
			let y = project(u)
			table[y] = u
			return y
		}
	}

	var description : String {
		return "IsoOf<\(T.self) -> \(U.self), \(U.self) -> \(T.self)>"
	}

	static var arbitrary : Gen<IsoOfImpl<T, U>> {
		return Gen<((T) -> U, (U) -> T)>.zip(promote({ a in
			return T.coarbitrary(a)(U.arbitrary)
		}), promote({ a in
			return U.coarbitrary(a)(T.arbitrary)
		})).map({ t in IsoOfImpl(t.0, t.1) })
	}

	static func shrink(_ f : IsoOfImpl<T, U>) -> [IsoOfImpl<T, U>] {
		return f.table.flatMap { (t) -> [IsoOfImpl<T, U>] in
			let (x, y) = t
			return Zip2Sequence(_sequence1: T.shrink(x), _sequence2: U.shrink(y)).map({ t in
				let (y1 , y2) = t
				return IsoOfImpl<T, U>(
					{ (z : T) -> U in
						if x == z {
							return y2
						}
						return f.embed(z)
					}, { (z : U) -> T in
						if y == z {
							return y1
						}
						return f.project(z)
					}
				)
			})
		}
	}
}

private final class PointerOfImpl<T : Arbitrary> : Arbitrary {
	var ptr : UnsafeMutablePointer<T>?
	let size : Int

	var description : String {
		return "\(String(describing: self.ptr))"
	}

	init(_ ptr : UnsafeMutablePointer<T>, _ size : Int) {
		self.ptr = ptr
		self.size = size
	}

	deinit {
		self.ptr?.deallocate()
		self.ptr = nil
	}

	static var arbitrary : Gen<PointerOfImpl<T>> {
		return Gen.sized { n in
			if n <= 0 {
				let size = 1
				return Gen.pure(PointerOfImpl(UnsafeMutablePointer<T>.allocate(capacity: size), size))
			}
			let pt = UnsafeMutablePointer<T>.allocate(capacity: n)
			let gt = sequence(Array((0..<n)).map { _ in T.arbitrary }).map({ UnsafeMutableBufferPointer(start: pt, count: n).initialize(from: $0) })
			return gt.map { _ in PointerOfImpl(pt, n) }
		}
	}
}
