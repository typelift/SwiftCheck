//
//  Random.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/3/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Swiftz

public protocol RandonGen {
	func next() -> (Int, Self)
	
	func genRange() -> (Int, Int)
	func split() -> (Self, Self)
}

let theStdGen : StdGen = StdGen(time(nil))

public struct StdGen : RandonGen {
	let seed: Int
	
	init(_ seed : Int) {
		self.seed = seed
	}
	
	
	public func next() -> (Int, StdGen) {
		let s = Int(time(nil))
		return (Int(rand()), StdGen(s))
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

public func newStdGen() -> StdGen {
	return theStdGen.split().1
}

private func mkStdRNG(seed : Int) -> StdGen {
	return StdGen(seed)
}
