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
///	            return xs.map(f.getArrow) == xs.map(f.getArrow)
///         }
///     }
///
/// Finally, modifiers nest to allow the generation of intricate structures that
/// would not otherwise be possible due to the limitations above.  For example, 
/// to generate an Array of Arrays of Dictionaries of Integers and Strings (a 
/// type that normally looks like `Array<Array<Dictionary<String, Int>>>`), 
/// would look like this:
///
///     property("Generating monstrous data types is possible") <- forAll { (xs : ArrayOf<ArrayOf<DictionaryOf<String, Int>>>) in
///         /// We're gonna need a bigger boat.
///     }

/// For types that either do not have a `CustomStringConvertible` instance or 
/// that wish to have no description to print, Blind will create a default 
/// description for them.
public struct Blind<A : Arbitrary> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying value.
	public let getBlind : A

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
		return Blind.init <^> A.arbitrary
	}

	/// The default shrinking function for `Blind` values.
	public static func shrink(bl : Blind<A>) -> [Blind<A>] {
		return A.shrink(bl.getBlind).map(Blind.init)
	}
}

extension Blind : CoArbitrary {
	// Take the lazy way out.
	public static func coarbitrary<C>(x : Blind) -> (Gen<C> -> Gen<C>) {
		return coarbitraryPrintable(x)
	}
}

/// Guarantees test cases for its underlying type will not be shrunk.
public struct Static<A : Arbitrary> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying value.
	public let getStatic : A

	public init(_ fixed : A) {
		self.getStatic = fixed
	}

	/// A textual representation of `self`.
	public var description : String {
		return "Static( \(self.getStatic) )"
	}

	/// Returns a generator of `Static` values.
	public static var arbitrary : Gen<Static<A>> {
		return Static.init <^> A.arbitrary
	}
}

extension Static : CoArbitrary {
	// Take the lazy way out.
	public static func coarbitrary<C>(x : Static) -> (Gen<C> -> Gen<C>) {
		return coarbitraryPrintable(x)
	}
}

/// Generates an array of arbitrary values of type A.
public struct ArrayOf<A : Arbitrary> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying array of values.
	public let getArray : [A]
	
	/// Retrieves the underlying array of values as a contiguous array.
	public var getContiguousArray : ContiguousArray<A> {
		return ContiguousArray(self.getArray)
	}

	public init(_ array : [A]) {
		self.getArray = array
	}

	/// A textual representation of `self`.
	public var description : String {
		return "\(self.getArray)"
	}

	/// Returns a generator of `ArrayOf` values.
	public static var arbitrary : Gen<ArrayOf<A>> {
		return ArrayOf.init <^> Array<A>.arbitrary
	}

	/// The default shrinking function for an `ArrayOf` values.
	public static func shrink(bl : ArrayOf<A>) -> [ArrayOf<A>] {
		return Array<A>.shrink(bl.getArray).map(ArrayOf.init)
	}
}

extension ArrayOf : CoArbitrary {
	public static func coarbitrary<C>(x : ArrayOf) -> (Gen<C> -> Gen<C>) {
		let a = x.getArray
		if a.isEmpty {
			return { $0.variant(0) }
		}
		return { $0.variant(1) } • ArrayOf.coarbitrary(ArrayOf([A](a[1..<a.endIndex])))
	}
}

/// Generates a sorted array of arbitrary values of type A.
public struct OrderedArrayOf<A : protocol<Arbitrary, Comparable>> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying sorted array of values.
	public let getOrderedArray : [A]
	
	/// Retrieves the underlying sorted array of values as a contiguous 
	/// array.
	public var getContiguousArray : ContiguousArray<A> {
		return ContiguousArray(self.getOrderedArray)
	}

	public init(_ array : [A]) {
		self.getOrderedArray = array.sort()
	}

	/// A textual representation of `self`.
	public var description : String {
		return "\(self.getOrderedArray)"
	}

	/// Returns a generator for an `OrderedArrayOf` values.
	public static var arbitrary : Gen<OrderedArrayOf<A>> {
		return OrderedArrayOf.init <^> Array<A>.arbitrary
	}

	/// The default shrinking function for an `OrderedArrayOf` values.
	public static func shrink(bl : OrderedArrayOf<A>) -> [OrderedArrayOf<A>] {
		return Array<A>.shrink(bl.getOrderedArray).filter({ $0.sort() == $0 }).map(OrderedArrayOf.init)
	}
}


/// Generates an dictionary of arbitrary keys and values.
public struct DictionaryOf<K : protocol<Hashable, Arbitrary>, V : Arbitrary> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying dictionary of values.
	public let getDictionary : Dictionary<K, V>

	public init(_ dict : Dictionary<K, V>) {
		self.getDictionary = dict
	}

	/// A textual representation of `self`.
	public var description : String {
		return "\(self.getDictionary)"
	}

	/// Returns a generator for a `DictionaryOf` values.
	public static var arbitrary : Gen<DictionaryOf<K, V>> {
		return DictionaryOf.init <^> Dictionary<K, V>.arbitrary
	}

	/// The default shrinking function for a `DictionaryOf` values.
	public static func shrink(d : DictionaryOf<K, V>) -> [DictionaryOf<K, V>] {
		return Dictionary.shrink(d.getDictionary).map(DictionaryOf.init)
	}
}

extension DictionaryOf : CoArbitrary {
	public static func coarbitrary<C>(x : DictionaryOf) -> (Gen<C> -> Gen<C>) {
		return Dictionary.coarbitrary(x.getDictionary)
	}
}

/// Generates an Optional of arbitrary values of type A.
public struct OptionalOf<A : Arbitrary> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying optional value.
	public let getOptional : A?

	public init(_ opt : A?) {
		self.getOptional = opt
	}

	/// A textual representation of `self`.
	public var description : String {
		return "\(self.getOptional)"
	}

	/// Returns a generator for `OptionalOf` values.
	public static var arbitrary : Gen<OptionalOf<A>> {
		return OptionalOf.init <^> Optional<A>.arbitrary
	}

	/// The default shrinking function for `OptionalOf` values.
	public static func shrink(bl : OptionalOf<A>) -> [OptionalOf<A>] {
		return Optional<A>.shrink(bl.getOptional).map(OptionalOf.init)
	}
}

extension OptionalOf : CoArbitrary {
	public static func coarbitrary<C>(x : OptionalOf) -> (Gen<C> -> Gen<C>) {
		if let _ = x.getOptional {
			return { $0.variant(0) }
		}
		return { $0.variant(1) }
	}
}

/// Generates a set of arbitrary values of type A.
public struct SetOf<A : protocol<Hashable, Arbitrary>> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying set of values.
	public let getSet : Set<A>

	public init(_ set : Set<A>) {
		self.getSet = set
	}

	/// A textual representation of `self`.
	public var description : String {
		return "\(self.getSet)"
	}

	/// Returns a generator for a `SetOf` values.
	public static var arbitrary : Gen<SetOf<A>> {
		return Gen.sized { n in
			return Gen<Int>.choose((0, n)).flatMap { k in
				if k == 0 {
					return Gen.pure(SetOf(Set([])))
				}

				return (SetOf.init • Set.init) <^> sequence(Array((0...k)).map { _ in A.arbitrary })
			}
		}
	}

	/// The default shrinking function for a `SetOf` values.
	public static func shrink(s : SetOf<A>) -> [SetOf<A>] {
		return ArrayOf.shrink(ArrayOf([A](s.getSet))).map({ SetOf(Set($0.getArray)) })
	}
}

extension SetOf : CoArbitrary {
	public static func coarbitrary<C>(x : SetOf) -> (Gen<C> -> Gen<C>) {
		if x.getSet.isEmpty {
			return { $0.variant(0) }
		}
		return { $0.variant(1) }
	}
}

/// Generates pointers of varying size of random values of type T.
public struct PointerOf<T : Arbitrary> : Arbitrary, CustomStringConvertible {
	private let _impl : PointerOfImpl<T>

	/// Retrieves the underlying pointer value.
	public var getPointer : UnsafePointer<T> {
		return UnsafePointer(self._impl.ptr)
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
public struct ArrowOf<T : protocol<Hashable, CoArbitrary>, U : Arbitrary> : Arbitrary, CustomStringConvertible {
	private let _impl : ArrowOfImpl<T, U>

	/// Retrieves the underlying function value, `T -> U`.
	public var getArrow : T -> U {
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
	public func customMirror() -> Mirror {
		return Mirror(self, children: [
			"types": "\(T.self) -> \(U.self)",
			"currentMap": self._impl.table,
		])
	}
}

/// Generates two isomorphic Swift functions from `T` to `U` and back again.
public struct IsoOf<T : protocol<Hashable, CoArbitrary, Arbitrary>, U : protocol<Equatable, CoArbitrary, Arbitrary>> : Arbitrary, CustomStringConvertible {
	private let _impl : IsoOfImpl<T, U>

	/// Retrieves the underlying embedding function, `T -> U`.
	public var getTo : T -> U {
		return self._impl.embed
	}

	/// Retrieves the underlying projecting function, `U -> T`.
	public var getFrom : U -> T {
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
	public func customMirror() -> Mirror {
		return Mirror(self, children: [
			"embed": "\(T.self) -> \(U.self)",
			"project": "\(U.self) -> \(T.self)",
			"currentMap": self._impl.table,
		])
	}
}

/// By default, SwiftCheck generates values drawn from a small range. `Large` 
/// gives you values drawn from the entire range instead.
public struct Large<A : protocol<RandomType, LatticeType, IntegerType>> : Arbitrary {
	/// Retrieves the underlying large value.
	public let getLarge : A

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
	public static func shrink(bl : Large<A>) -> [Large<A>] {
		return bl.getLarge.shrinkIntegral.map(Large.init)
	}
}

/// Guarantees that every generated integer is greater than 0.
public struct Positive<A : protocol<Arbitrary, SignedNumberType>> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying positive value.
	public let getPositive : A

	public init(_ pos : A) {
		self.getPositive = pos
	}

	/// A textual representation of `self`.
	public var description : String {
		return "Positive( \(self.getPositive) )"
	}

	/// Returns a generator of `Positive` values.
	public static var arbitrary : Gen<Positive<A>> {
		return A.arbitrary.map(Positive.init • abs).suchThat { $0.getPositive > 0 }
	}

	/// The default shrinking function for `Positive` values.
	public static func shrink(bl : Positive<A>) -> [Positive<A>] {
		return A.shrink(bl.getPositive).filter({ $0 > 0 }).map(Positive.init)
	}
}

extension Positive : CoArbitrary {
	// Take the lazy way out.
	public static func coarbitrary<C>(x : Positive) -> (Gen<C> -> Gen<C>) {
		return coarbitraryPrintable(x)
	}
}

/// Guarantees that every generated integer is never 0.
public struct NonZero<A : protocol<Arbitrary, IntegerType>> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying non-zero value.
	public let getNonZero : A

	public init(_ non : A) {
		self.getNonZero = non
	}

	/// A textual representation of `self`.
	public var description : String {
		return "NonZero( \(self.getNonZero) )"
	}

	/// Returns a generator of `NonZero` values.
	public static var arbitrary : Gen<NonZero<A>> {
		return NonZero.init <^> A.arbitrary.suchThat { $0 != 0 }
	}

	/// The default shrinking function for `NonZero` values.
	public static func shrink(bl : NonZero<A>) -> [NonZero<A>] {
		return A.shrink(bl.getNonZero).filter({ $0 != 0 }).map(NonZero.init)
	}
}

extension NonZero : CoArbitrary {
	public static func coarbitrary<C>(x : NonZero) -> (Gen<C> -> Gen<C>) {
		return x.getNonZero.coarbitraryIntegral()
	}
}

/// Guarantees that every generated integer is greater than or equal to 0.
public struct NonNegative<A : protocol<Arbitrary, IntegerType>> : Arbitrary, CustomStringConvertible {
	/// Retrieves the underlying non-negative value.
	public let getNonNegative : A

	public init(_ non : A) {
		self.getNonNegative = non
	}

	/// A textual representation of `self`.
	public var description : String {
		return "NonNegative( \(self.getNonNegative) )"
	}

	/// Returns a generator of `NonNegative` values.
	public static var arbitrary : Gen<NonNegative<A>> {
		return NonNegative.init <^> A.arbitrary.suchThat { $0 >= 0 }
	}

	/// The default shrinking function for `NonNegative` values.
	public static func shrink(bl : NonNegative<A>) -> [NonNegative<A>] {
		return A.shrink(bl.getNonNegative).filter({ $0 >= 0 }).map(NonNegative.init)
	}
}

extension NonNegative : CoArbitrary {
	public static func coarbitrary<C>(x : NonNegative) -> (Gen<C> -> Gen<C>) {
		return x.getNonNegative.coarbitraryIntegral()
	}
}


// MARK: - Implementation Details Follow


private func undefined<A>() -> A {
	fatalError("")
}

private final class ArrowOfImpl<T : protocol<Hashable, CoArbitrary>, U : Arbitrary> : Arbitrary, CustomStringConvertible {
	private var table : Dictionary<T, U>
	private var arr : T -> U

	init (_ table : Dictionary<T, U>, _ arr : (T -> U)) {
		self.table = table
		self.arr = arr
	}

	convenience init(_ arr : (T -> U)) {
		self.init(Dictionary(), { (_ : T) -> U in return undefined() })

		self.arr = { [unowned self] x in
			if let v = self.table[x] {
				return v
			}
			let y = arr(x)
			self.table[x] = y
			return y
		}
	}

	var description : String {
		return "\(T.self) -> \(U.self)"
	}

	static var arbitrary : Gen<ArrowOfImpl<T, U>> {
		return ArrowOfImpl.init <^> promote { a in
			return T.coarbitrary(a)(U.arbitrary)
		}
	}

	static func shrink(f : ArrowOfImpl<T, U>) -> [ArrowOfImpl<T, U>] {
		return f.table.flatMap { (x, y) in
			return U.shrink(y).map({ (y2 : U) -> ArrowOfImpl<T, U> in
				return ArrowOfImpl<T, U>({ (z : T) -> U in
					if x == z {
						return y2
					}
					return f.arr(z)
				})
			})
		}
	}
}

private final class IsoOfImpl<T : protocol<Hashable, CoArbitrary, Arbitrary>, U : protocol<Equatable, CoArbitrary, Arbitrary>> : Arbitrary, CustomStringConvertible {
	var table : Dictionary<T, U>
	var embed : T -> U
	var project : U -> T

	init (_ table : Dictionary<T, U>, _ embed : (T -> U), _ project : (U -> T)) {
		self.table = table
		self.embed = embed
		self.project = project
	}

	convenience init(_ embed : (T -> U), _ project : (U -> T)) {
		self.init(Dictionary(), { (_ : T) -> U in return undefined() }, { (_ : U) -> T in return undefined() })

		self.embed = { [unowned self] t in
			if let v = self.table[t] {
				return v
			}
			let y = embed(t)
			self.table[t] = y
			return y
		}

		self.project = { [unowned self] u in
			let ts = self.table.filter { $1 == u }.map { $0.0 }
			if let k = ts.first, _ = self.table[k] {
				return k
			}
			let y = project(u)
			self.table[y] = u
			return y
		}
	}

	var description : String {
		return "IsoOf<\(T.self) -> \(U.self), \(U.self) -> \(T.self)>"
	}

	static var arbitrary : Gen<IsoOfImpl<T, U>> {
		return Gen<(T -> U, U -> T)>.zip(promote({ a in
			return T.coarbitrary(a)(U.arbitrary)
		}), promote({ a in
			return U.coarbitrary(a)(T.arbitrary)
		})).map(IsoOfImpl.init)
	}

	static func shrink(f : IsoOfImpl<T, U>) -> [IsoOfImpl<T, U>] {
		return f.table.flatMap { (x, y) in
			return Zip2Sequence(T.shrink(x), U.shrink(y)).map({ (y1 , y2) -> IsoOfImpl<T, U> in
				return IsoOfImpl<T, U>({ (z : T) -> U in
					if x == z {
						return y2
					}
					return f.embed(z)
				}, { (z : U) -> T in
						if y == z {
							return y1
						}
						return f.project(z)
				})
			})
		}
	}
}

private final class PointerOfImpl<T : Arbitrary> : Arbitrary {
	var ptr : UnsafeMutablePointer<T>
	let size : Int

	var description : String {
		return "\(self.ptr)"
	}

	init(_ ptr : UnsafeMutablePointer<T>, _ size : Int) {
		self.ptr = ptr
		self.size = size
	}

	deinit {
		if self.size > 0 && self.ptr != nil {
			self.ptr.dealloc(self.size)
			self.ptr = nil
		}
	}

	static var arbitrary : Gen<PointerOfImpl<T>> {
		return Gen.sized { n in
			if n <= 0 {
				return Gen.pure(PointerOfImpl(nil, 0))
			}
			let pt = UnsafeMutablePointer<T>.alloc(n)
			let gt = pt.initializeFrom <^> sequence(Array((0..<n)).map { _ in T.arbitrary })
			return gt.map { _ in PointerOfImpl(pt, n) }
		}
	}
}

