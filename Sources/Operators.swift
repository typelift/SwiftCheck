//
//  Operators.swift
//  Operadics
//
//  Created by Robert Widmann on 07/07/2015.
//  Copyright (c) 2015 TypeLift. All rights reserved.
//  Released under the MIT License.
//
// Precedence marks for certain symbols aligned with Runes 
// ~( https://github.com/thoughtbot/Runes/blob/master/Source/Runes.swift ) until Swift gets a proper
// resolver.

// MARK: Combinators

/// Compose | Applies one function to the result of another function to produce a third function.
infix operator • {
	associativity right
	precedence 190
}

/// Apply | Applies an argument to a function.
infix operator § {
	associativity right
	precedence 95
}

/// Pipe Backward | Applies the function to its left to an argument on its right.
infix operator <| {
	associativity right
	precedence 95
}

/// Pipe forward | Applies an argument on the left to a function on the right.
infix operator |> {
	associativity left
	precedence 95
}

/// On | Given a "combining" function and a function that converts arguments to the target of the
/// combiner, returns a function that applies the right hand side to two arguments, then runs both
/// results through the combiner.
infix operator |*| {
	associativity left
	precedence 100
}


// MARK: Control.*

/// Fmap | Maps a function over the value encapsulated by a functor.
infix operator <^> {
	associativity left
	// https://github.com/thoughtbot/Runes/blob/master/Source/Runes.swift
	precedence 130
}

/// Replace | Maps all the values encapsulated by a functor to a user-specified constant.
infix operator <^ {
	associativity left
	precedence 140
}

/// Replace Backwards | Maps all the values encapsulated by a functor to a user-specified constant.
infix operator ^> {
	associativity left
	precedence 140
}


/// Ap | Applies a function encapsulated by a functor to the value encapsulated by another functor.
infix operator <*> {
	associativity left
	// https://github.com/thoughtbot/Runes/blob/master/Source/Runes.swift
	precedence 130
}

/// Sequence Right | Disregards the Functor on the Left.
///
/// Default definition:
///		`const(id) <^> a <*> b`
infix operator *> {
	associativity left
	precedence 140
}

/// Sequence Left | Disregards the Functor on the Right.
///
/// Default definition:
///		`const <^> a <*> b`
infix operator <* {
	associativity left
	precedence 140
}

/// Bind | Sequences and composes two monadic actions by passing the value inside the monad on the
/// left to a function on the right yielding a new monad.
infix operator >>- {
	associativity left
	// https://github.com/thoughtbot/Runes/blob/master/Source/Runes.swift
	precedence 100
}

/// Bind Backwards | Composes two monadic actions by passing the value inside the monad on the 
/// right to the funciton on the left.
infix operator -<< {
	associativity right
	// https://github.com/thoughtbot/Runes/blob/master/Source/Runes.swift
	precedence 100
}

/// Left-to-Right Kleisli | Composition for monads.
infix operator >>->> {
	associativity right
	precedence 110
}

/// Right-to-Left Kleisli | Composition for monads.
infix operator <<-<< {
	associativity right
	precedence 110
}

/// Extend | Duplicates the surrounding context and computes a value from it while remaining in the
/// original context.
infix operator ->> {
	associativity left
	precedence 110
}

/// Imap | Maps covariantly over the index of a right-leaning bifunctor.
infix operator <^^> {
	associativity left
	precedence 140
}

/// Contramap | Contravariantly maps a function over the value encapsulated by a functor.
infix operator <!> {
	associativity left
	precedence 140
}

// MARK: Data.Result

/// From | Creates a Result given a function that can possibly fail with an error.
infix operator !! {
	associativity none
	precedence 120
}

// MARK: Data.Monoid

/// Append | Alias for a Semigroup's operation.
infix operator <> {
	associativity right
	precedence 160
}

// MARK: Control.Category

/// Right-to-Left Composition | Composes two categories to form a new category with the source of
/// the second category and the target of the first category.
///
/// This function is literally `•`, but for Categories.
infix operator <<< {
	associativity right
	precedence 110
}

/// Left-to-Right Composition | Composes two categories to form a new category with the source of
/// the first category and the target of the second category.
///
/// Function composition with the arguments flipped.
infix operator >>> {
	associativity right
	precedence 110
}

// MARK: Control.Arrow

/// Split | Splits two computations and combines the result into one Arrow yielding a tuple of
/// the result of each side.
infix operator *** {
	associativity right
	precedence 130
}

/// Fanout | Given two functions with the same source but different targets, this function
/// splits the computation and combines the result of each Arrow into a tuple of the result of
/// each side.
infix operator &&& {
	associativity right
	precedence 130
}

// MARK: Control.Arrow.Choice

/// Splat | Splits two computations and combines the results into Eithers on the left and right.
infix operator +++ {
	associativity right
	precedence 120
}

/// Fanin | Given two functions with the same target but different sources, this function splits
/// the input between the two and merges the output.
infix operator ||| {
	associativity right
	precedence 120
}

// MARK: Control.Arrow.Plus

/// Op | Combines two ArrowZero monoids.
infix operator <+> {
	associativity right
	precedence 150
}

// MARK: Data.JSON

/// Retrieve | Retrieves a value from a dictionary of JSON values using a given keypath.
///
/// If the given keypath is not present or the retrieved value is not of the appropriate type, this
/// function returns `.None`.
infix operator <? {
	associativity left
	precedence 150
}

/// Force Retrieve | Retrieves a value from a dictionary of JSON values using a given keypath,
/// forcing any Optionals it finds.
///
/// If the given keypath is not present or the retrieved value is not of the appropriate type, this
/// function will terminate with a fatal error.  It is recommended that you use Force Retrieve's
/// total cousin `<?` (Retrieve).
infix operator <! {
	associativity left
	precedence 150
}

// MARK: Data.Set

/// Intersection | Returns the intersection of two sets.
infix operator ∩ {}

/// Union | Returns the union of two sets.
infix operator ∪ {}
