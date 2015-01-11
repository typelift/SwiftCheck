//
//  Random.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Basis

public protocol RandonGen {
	func next() -> (Int, Self)
	
	func genRange() -> (Int, Int)
	func split() -> (Self, Self)
}

public struct StdGen : RandonGen {
	let seed: Int
	
	init(_ seed : Int) {
		self.seed = seed
	}
	
	private func nextST() -> IO<ST<(), (Int, StdGen)>> {
		return do_ { () -> ST<(), (Int, StdGen)> in
			let s = Int(time(nil))
			let t = (Int(rand()), StdGen(s))
			return ST<(), (Int, StdGen)>.pure(t)
		}
	}
	
	public func next() -> (Int, StdGen) {
		return nextST().unsafePerformIO().runST()
	}
	
	public func split() -> (StdGen, StdGen) {
		let (s1, g) = self.next()
		let (s2, _) = g.next()
		return (StdGen(s1), StdGen(s2))
	}
	
	public func genRange() -> (Int, Int) {
		return (Int.minBound(), Int.maxBound())
	}

}

private func stdRange() -> (UInt, UInt) {
	return (0, UInt.max)
}

public func setStdGen(g: StdGen) -> IO<()> {
	return writeIORef(theStdGen())(v: g)
}

public func getStdGen() -> IO<StdGen> {
	return readIORef(theStdGen())
}

public func theStdGen() -> IORef<StdGen> {
	return !newIORef(mkStdRNG(0))
}

public func newStdGen() -> IO<StdGen> {
	return IO.pure(readIORef(theStdGen()).unsafePerformIO().split().1)
}

private func mkStdRNG(seed : Int) -> StdGen {
	return StdGen(seed)
}
