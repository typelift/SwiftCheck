//
//  Rose.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// A `Rose` is a modified rose tree, or multi-way tree, for representing the
/// steps necessary for testing a property.  The first case, .MkRose, consists
/// of a value and a list of trees.  The second, case, .IORose, is a suspended
/// IO action SwiftCheck must execute in order to produce another rose tree.
/// All values in a `Rose` are lazy.
///
/// - Note: In practice SwiftCheck will minimize the side-effects performed in
///   a given `IORose` to printing values to the console and executing callbacks.
public enum Rose<A> {
	/// A normal branch in the rose tree.
	case mkRose(() -> A, () -> [Rose<A>])
	/// An IO branch in the rose tree.  That is, a branch that must execute
	/// side effects before revealing further structure.
	case ioRose(() -> Rose<A>)

	/// Case analysis for a rose tree.
	public func onRose(_ f : @escaping (A, [Rose<A>]) -> Rose<A>) -> Rose<A> {
		switch self {
		case .mkRose(let x, let rs):
			return f(x(), rs())
		case .ioRose(let m):
			return .ioRose({ m().onRose(f) })
		}
	}

	/// Reduces a rose tree by evaluating all `.IORose` branches until the first
	/// `.MkRose` branch is encountered.  That branch is then returned.
	public var reduce : Rose<A> {
		switch self {
		case .mkRose(_, _):
			return self
		case .ioRose(let m):
			return m().reduce
		}
	}
}

extension Rose /*: Functor*/ {
	/// Maps a function over all the nodes of a rose tree.
	///
	/// For `.MkRose` branches the computation is applied to the node's value
	/// then application recurses into the sub-trees.  For `.IORose` branches
	/// the map is suspended.
	public func map<B>(_ f : @escaping (A) -> B) -> Rose<B> {
		switch self {
		case .mkRose(let root, let children):
			return .mkRose({ f(root()) }, { children().map() { $0.map(f) } })
		case .ioRose(let rs):
			return .ioRose({ rs().map(f) })
		}
	}
}

extension Rose /*: Applicative*/ {
	/// Lifts a value into a rose tree.
	public static func pure(_ a : A) -> Rose<A> {
		return .mkRose({ a }, { [] })
	}

	/// Applies a rose tree of functions to the rose tree to yield a new Rose
	/// Tree of values.
	///
	/// For `.MkRose` branches the computation is applied to the node's value
	/// then application recurses into the sub-trees.  For `.IORose` the branch
	/// is reduced to a `.MkRose` and applied, executing all side-effects along
	/// the way.
	public func ap<B>(_ fn : Rose<(A) -> B>) -> Rose<B> {
		switch fn {
		case .mkRose(let f, _):
			return self.map(f())
		case .ioRose(let rs):
			return self.ap(rs()) ///EEWW, EW, EW, EW, EW, EW
		}
	}
}

extension Rose /*: Monad*/ {
	/// Maps the values in the rose tree to rose trees and joins them all
	/// together.
	public func flatMap<B>(_ fn : @escaping (A) -> Rose<B>) -> Rose<B> {
		return joinRose(self.map(fn))
	}
}

/// Lifts functions to functions over rose trees.
public func liftM<A, R>(_ f : @escaping (A) -> R, _ m1 : Rose<A>) -> Rose<R> {
	return m1.flatMap { x1 in
		return Rose.pure(f(x1))
	}
}

/// Flattens a rose tree of rose trees by a single level.
///
/// For `.IORose` branches the join is suspended.  For `.MkRose` branches, the
/// kind of subtree at the node dictates the behavior of the join.  For
/// `.IORose` sub-trees The join is suspended.  For `.MkRose` the result is the
/// value at the sub-tree node and a recursive call to join the branch's tree to
/// its sub-trees.
public func joinRose<A>(_ rs : Rose<Rose<A>>) -> Rose<A> {
	switch rs {
	case .ioRose(let rs):
		return .ioRose({ joinRose(rs()) })
	case .mkRose(let bx , let rs):
		switch bx() {
		case .ioRose(let rm):
			return .ioRose({ joinRose(.mkRose(rm, rs)) })
		case .mkRose(let x, let ts):
			return .mkRose(x, { rs().map(joinRose) + ts() })
		}
	}
}

/// Sequences an array of rose trees into a rose tree of an array.
public func sequence<A>(_ ms : [Rose<A>]) -> Rose<[A]> {
	return ms.reduce(Rose<[A]>.pure([]), { n, m in
		return m.flatMap { x in
			return n.flatMap { xs in
				return Rose<[A]>.pure(xs + [x])
			}
		}
	})
}

/// Sequences the result of mapping values to rose trees into a single rose tree
/// of an array of values.
public func mapM<A, B>(_ f : (A) -> Rose<B>, xs : [A]) -> Rose<[B]> {
	return sequence(xs.map(f))
}
