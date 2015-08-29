//
//  Rose.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//

/// A `Rose` is a modified Rose Tree, or multi-way tree, for representing the steps necessary for
/// testing a property.  The first case, .MkRose, consists of a value and a list of trees.  The
/// second, case, .IORose, is a suspended IO action SwiftCheck must execute in order to produce
/// another Rose tree.  All values in a `Rose` are lazy.
///
/// In practice SwiftCheck will minimize the side-effects performed in a given `IORose` to printing
/// values to the console and executing callbacks.
public enum Rose<A> {
	case MkRose(() -> A, () -> [Rose<A>])
	case IORose(() -> Rose<A>)
}

extension Rose /*: Functor*/ {
	typealias B = Swift.Any
	typealias FB = Rose<B>

	/// Maps a function over all the nodes of a Rose Tree.
	///
	/// For `.MkRose` branches the computation is applied to the node's value then application
	/// recurses into the sub-trees.  For `.IORose` branches the map is suspended.
	public func fmap<B>(f : (A -> B)) -> Rose<B> {
		return f <^> self
	}
}

public func <^> <A, B>(f : A -> B, g : Rose<A>) -> Rose<B> {
	switch g {
		case .MkRose(let root, let children):
			return .MkRose({ f(root()) }, { children().map() { $0.fmap(f) } })
		case .IORose(let rs):
			return .IORose({ rs().fmap(f) })
	}
}

extension Rose /*: Applicative*/ {
	typealias FAB = Rose<A -> B>

	/// Lifts a value into a Rose Tree.
	public static func pure(a : A) -> Rose<A> {
		return .MkRose({ a }, { [] })
	}

	/// Applies a Rose Tree of functions to the receiver to yield a new Rose Tree of values.
	///
	/// For `.MkRose` branches the computation is applied to the node's value then application
	/// recurses into the sub-trees.  For `.IORose` the branch is reduced to a `.MkRose` and
	/// applied, executing all side-effects along the way.
	public func ap<B>(fn : Rose<A -> B>) -> Rose<B> {
		return fn <*> self
	}
}

public func <*> <A, B>(fn : Rose<A -> B>, g : Rose<A>) -> Rose<B> {
	switch fn {
		case .MkRose(let f, _):
			return g.fmap(f())
		case .IORose(let rs):
			return g.ap(rs()) ///EEWW, EW, EW, EW, EW, EW
	}
}

extension Rose /*: Monad*/ {
	/// Maps the values in the receiver to Rose Trees and joins them all together.
	public func bind<B>(fn : A -> Rose<B>) -> Rose<B> {
		return self >>- fn
	}
}

public func >>- <A, B>(m : Rose<A>, fn : A -> Rose<B>) -> Rose<B> {
	return joinRose(m.fmap(fn))
}

/// Lifts functions to functions over Rose Trees.
public func liftM<A, R>(f : A -> R)(m1 : Rose<A>) -> Rose<R> {
	return m1.bind { x1 in
		return Rose.pure(f(x1))
	}
}

/// Flattens a Rose Tree of Rose Trees by a single level.
///
/// For `.IORose` branches the join is suspended.  For `.MkRose` branches, the kind of subtree at
/// the node dictates the behavior of the join.  For `.IORose` sub-trees The join is suspended.  For
/// `.MkRose` the result is the value at the sub-tree node and a recursive call to join the branch's
/// tree to its sub-trees.
public func joinRose<A>(rs : Rose<Rose<A>>) -> Rose<A> {
	switch rs {
		case .IORose(let rs):
			return .IORose({ joinRose(rs()) })
		case .MkRose(let bx , let rs):
			switch bx() {
				case .IORose(let rm):
					return .IORose({ joinRose(.MkRose(rm, rs)) })
				case .MkRose(let x, let ts):
					return .MkRose(x, { rs().map(joinRose) + ts() })
			}
	}
}

/// Reduces a rose tree by evaluating all `.IORose` branches until the first `.MkRose` branch is
/// encountered.  That branch is then returned.
public func reduce(rs : Rose<TestResult>) -> Rose<TestResult> {
	switch rs {
		case .MkRose(_, _):
			return rs
		case .IORose(let m):
			return reduce(m())
	}
}

/// Case analysis for a Rose Tree.
public func onRose<A>(f : (A -> [Rose<A>] -> Rose<A>))(rs : Rose<A>) -> Rose<A> {
	switch rs {
		case .MkRose(let x, let rs):
			return f(x())(rs())
		case .IORose(let m):
			return .IORose({ onRose(f)(rs: m()) })
	}
}

/// Sequences an array of Rose Trees into a Rose Tree of an array.
public func sequence<A>(ms : [Rose<A>]) -> Rose<[A]> {
	return ms.reduce(Rose<[A]>.pure([]), combine: { n, m in
		return m.bind { x in
			return n.bind { xs in
				return Rose<[A]>.pure([x] + xs)
			}
		}
	})
}

/// Sequences the result of mapping values to Rose trees into a single rose tree of an array of
/// values.
public func mapM<A, B>(f : A -> Rose<B>, xs : [A]) -> Rose<[B]> {
	return sequence(xs.map(f))
}
