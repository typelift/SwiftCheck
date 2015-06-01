//
//  Modifiers.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/29/15.
//  Copyright (c) 2015 CodaFi. All rights reserved.
//


/// For types that either do not have a Printable instance or that wish to have no description to
/// print, Blind will create a default description for them.
public struct Blind<A : Arbitrary> : Arbitrary, Printable {
	public let getBlind : A
	
	public init(_ blind : A) {
		self.getBlind = blind
	}
	
	public var description : String {
		return "(*)"
	}
	
	private static func create(blind : A) -> Blind<A> {
		return Blind(blind)
	}
	
	public static func arbitrary() -> Gen<Blind<A>> {
		return A.arbitrary().fmap(Blind.create)
	}
	
	public static func shrink(bl : Blind<A>) -> [Blind<A>] {
		return A.shrink(bl.getBlind).map(Blind.create)
	}
}

extension Blind : CoArbitrary {
	// Take the lazy way out.
	public static func coarbitrary<C>(x : Blind) -> (Gen<C> -> Gen<C>) {
		return coarbitraryPrintable(x)
	}
}

/// Guarantees test cases for its underlying type will not be shrunk.
public struct Static<A : Arbitrary> : Arbitrary, Printable {
	public let getStatic : A
	
	public init(_ fixed : A) {
		self.getStatic = fixed
	}
	
	public var description : String {
		return "Static( \(self.getStatic) )"
	}
	
	private static func create(blind : A) -> Static<A> {
		return Static(blind)
	}
	
	public static func arbitrary() -> Gen<Static<A>> {
		return A.arbitrary().fmap(Static.create)
	}
	
	public static func shrink(bl : Static<A>) -> [Static<A>] {
		return []
	}
}

extension Static : CoArbitrary {
	// Take the lazy way out.
	public static func coarbitrary<C>(x : Static) -> (Gen<C> -> Gen<C>) {
		return coarbitraryPrintable(x)
	}
}

/// Generates an array of arbitrary values of type A.
public struct ArrayOf<A : Arbitrary> : Arbitrary, Printable {
	public let getArray : [A]
	public var getContiguousArray : ContiguousArray<A> {
		return ContiguousArray(self.getArray)
	}

	public init(_ array : [A]) {
		self.getArray = array
	}

	public var description : String {
		return "\(self.getArray)"
	}

	private static func create(array : [A]) -> ArrayOf<A> {
		return ArrayOf(array)
	}

	public static func arbitrary() -> Gen<ArrayOf<A>> {
		return Gen.sized { n in
			return Gen<Int>.choose((0, n)).bind { k in
				if k == 0 {
					return Gen.pure(ArrayOf([]))
				}

				return sequence(Array((0...k)).map { _ in A.arbitrary() }).fmap(ArrayOf.create)
			}
		}
	}

	public static func shrink(bl : ArrayOf<A>) -> [ArrayOf<A>] {
		let n = bl.getArray.count
		let xs = Int.shrink(n).reverse().flatMap({ k in removes(k + 1, n, bl.getArray) }) + shrinkOne(bl.getArray)
		return xs.map({ ArrayOf($0) })
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

private func removes<A : Arbitrary>(k : Int, n : Int, xs : [A]) -> [[A]] {
	let xs1 = take(k, xs)
	let xs2 = drop(k, xs)

	if k > n {
		return []
	} else if xs2.isEmpty {
		return [[]]
	} else {
		return [xs2] + removes(k, n - k, xs2).map({ xs1 + $0 })
	}
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

func take<T>(num : Int, xs : [T]) -> [T] {
	let n = (num < xs.count) ? num : xs.count
	return [T](xs[0..<n])
}

func drop<T>(num : Int, xs : [T]) -> [T] {
	let n = (num < xs.count) ? num : xs.count
	return [T](xs[n..<xs.endIndex])
}

/// Generates an dictionary of arbitrary keys and values.
public struct DictionaryOf<K : protocol<Hashable, Arbitrary>, V : Arbitrary> : Arbitrary, Printable {
	public let getDictionary : Dictionary<K, V>

	public init(_ dict : Dictionary<K, V>) {
		self.getDictionary = dict
	}

	public var description : String {
		return "\(self.getDictionary)"
	}

	private static func create(dict : Dictionary<K, V>) -> DictionaryOf<K, V> {
		return DictionaryOf(dict)
	}

	public static func arbitrary() -> Gen<DictionaryOf<K, V>> {
		return ArrayOf<K>.arbitrary().bind { k in
			return ArrayOf<V>.arbitrary().bind { v in
				return Gen.pure(DictionaryOf(Dictionary<K, V>(Zip2(k.getArray, v.getArray))))
			}
		}
	}

	public static func shrink(d : DictionaryOf<K, V>) -> [DictionaryOf<K, V>] {
		var xs = [DictionaryOf<K, V>]()
		for (k, v) in d.getDictionary {
			xs.append(DictionaryOf(Dictionary(Zip2(K.shrink(k), V.shrink(v)))))
		}
		return xs
	}
}

extension DictionaryOf : CoArbitrary {
	public static func coarbitrary<C>(x : DictionaryOf) -> (Gen<C> -> Gen<C>) {
		if x.getDictionary.isEmpty {
			return { $0.variant(0) }
		}
		return { $0.variant(1) }
	}
}

extension Dictionary {
	init<S : SequenceType where S.Generator.Element == Element>(_ pairs : S) {
		self.init()
		var g = pairs.generate()
		while let (k : Key, v : Value) = g.next() {
			self[k] = v
		}
	}
}

/// Generates an Optional of arbitrary values of type A.
public struct OptionalOf<A : Arbitrary> : Arbitrary, Printable {
	public let getOptional : A?

	public init(_ opt : A?) {
		self.getOptional = opt
	}

	public var description : String {
		return "\(self.getOptional)"
	}

	private static func create(opt : A?) -> OptionalOf<A> {
		return OptionalOf(opt)
	}

	public static func arbitrary() -> Gen<OptionalOf<A>> {
		return Gen.frequency([
			(1, Gen.pure(OptionalOf(Optional<A>.None))),
			(3, liftM({ OptionalOf(Optional<A>.Some($0)) })(m1: A.arbitrary()))
		])
	}

	public static func shrink(bl : OptionalOf<A>) -> [OptionalOf<A>] {
		if let x = bl.getOptional {
			return [OptionalOf(Optional<A>.None)] + A.shrink(x).map({ OptionalOf(Optional<A>.Some($0)) })
		}
		return []
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
public struct SetOf<A : protocol<Hashable, Arbitrary>> : Arbitrary, Printable {
	public let getSet : Set<A>

	public init(_ set : Set<A>) {
		self.getSet = set
	}

	public var description : String {
		return "\(self.getSet)"
	}

	private static func create(set : Set<A>) -> SetOf<A>{
		return SetOf(set)
	}

	public static func arbitrary() -> Gen<SetOf<A>> {
		return Gen.sized { n in
			return Gen<Int>.choose((0, n)).bind { k in
				if k == 0 {
					return Gen.pure(SetOf(Set([])))
				}

				return sequence(Array((0...k)).map { _ in A.arbitrary() }).fmap({ SetOf.create(Set($0)) })
			}
		}
	}

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

/// Generates a Swift function from T to U.
public struct ArrowOf<T : protocol<Hashable, CoArbitrary>, U : Arbitrary> : Arbitrary, Printable {
	private var table : Dictionary<T, U>
	private var arr : T -> U
	public var getArrow : T -> U {
		return self.arr
	}

	private init (_ table : Dictionary<T, U>, _ arr : (T -> U)) {
		self.table = table
		self.arr = arr
	}

	public init(_ arr : (T -> U)) {
		self.init(Dictionary(), { (_ : T) -> U in return undefined() })
		
		self.arr = { x in
			if let v = self.table[x] {
				return v
			}
			let y = arr(x)
			self.table[x] = y
			return y
		}
	}

	public var description : String {
		return "\(T.self) -> \(U.self)"
	}

	private static func create(arr : (T -> U)) -> ArrowOf<T, U> {
		return ArrowOf(arr)
	}

	public static func arbitrary() -> Gen<ArrowOf<T, U>> {
		return promote({ a in
			return T.coarbitrary(a)(U.arbitrary())
		}).fmap({ ArrowOf($0) })
	}

	public static func shrink(f : ArrowOf<T, U>) -> [ArrowOf<T, U>] {
		var xxs : [ArrowOf<T, U>] = []
		for (x, y) in f.table {
			xxs += U.shrink(y).map({ (y2 : U) -> ArrowOf<T, U> in
				return ArrowOf<T, U>({ (z : T) -> U in
					if x == z {
						return y2
					}
					return f.arr(z)
				})
			})
		}
		return xxs
	}
}

private func undefined<A>() -> A {
	fatalError("")
}

/// Guarantees that every generated integer is greater than 0.
public struct Positive<A : protocol<Arbitrary, SignedNumberType>> : Arbitrary, Printable {
	public let getPositive : A
	
	public init(_ pos : A) {
		self.getPositive = pos
	}
	
	public var description : String {
		return "Positive( \(self.getPositive) )"
	}
	
	private static func create(blind : A) -> Positive<A> {
		return Positive(blind)
	}
	
	public static func arbitrary() -> Gen<Positive<A>> {
		return A.arbitrary().fmap({ Positive.create(abs($0)) }).suchThat({ $0.getPositive > 0 })
	}
	
	public static func shrink(bl : Positive<A>) -> [Positive<A>] {
		return A.shrink(bl.getPositive).filter({ $0 > 0 }).map({ Positive($0) })
	}
}

extension Positive : CoArbitrary {
	// Take the lazy way out.
	public static func coarbitrary<C>(x : Positive) -> (Gen<C> -> Gen<C>) {
		return coarbitraryPrintable(x)
	}
}

/// Guarantees that every generated integer is never 0.
public struct NonZero<A : protocol<Arbitrary, IntegerType>> : Arbitrary, Printable {
	public let getNonZero : A
	
	public init(_ non : A) {
		self.getNonZero = non
	}
	
	public var description : String {
		return "NonZero( \(self.getNonZero) )"
	}
	
	private static func create(blind : A) -> NonZero<A> {
		return NonZero(blind)
	}
	
	public static func arbitrary() -> Gen<NonZero<A>> {
		return A.arbitrary().suchThat({ $0 != 0 }).fmap(NonZero.create)
	}
	
	public static func shrink(bl : NonZero<A>) -> [NonZero<A>] {
		return A.shrink(bl.getNonZero).filter({ $0 != 0 }).map({ NonZero($0) })
	}
}

extension NonZero : CoArbitrary {
	public static func coarbitrary<C>(x : NonZero) -> (Gen<C> -> Gen<C>) {
		return coarbitraryIntegral(x.getNonZero)
	}
}

/// Guarantees that every generated integer is greater than or equal to 0.
public struct NonNegative<A : protocol<Arbitrary, IntegerType>> : Arbitrary, Printable {
	public let getNonNegative : A
	
	public init(_ non : A) {
		self.getNonNegative = non
	}
	
	public var description : String {
		return "NonNegative( \(self.getNonNegative) )"
	}
	
	private static func create(blind : A) -> NonNegative<A> {
		return NonNegative(blind)
	}
	
	public static func arbitrary() -> Gen<NonNegative<A>> {
		return A.arbitrary().suchThat({ $0 >= 0 }).fmap(NonNegative.create)
	}
	
	public static func shrink(bl : NonNegative<A>) -> [NonNegative<A>] {
		return A.shrink(bl.getNonNegative).filter({ $0 >= 0 }).map({ NonNegative($0) })
	}
}

extension NonNegative : CoArbitrary {
	public static func coarbitrary<C>(x : NonNegative) -> (Gen<C> -> Gen<C>) {
		return coarbitraryIntegral(x.getNonNegative)
	}
}
