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

public struct StdGen {
	private var a, b : UInt32
	//	private var seed: UInt32
	
	func next() -> (UInt32, StdGen) {
		return ((arc4random() % self.b) + self.a, StdGen(a: self.a + 1, b: self.b + 1))
	}
	
	func genRange() -> (UInt, UInt) {
		return stdRange()
	}
	
	func split() -> (StdGen, StdGen) {
		
		let nextGen = self.next().1
		let new_s1 = (self.a == UInt32.max) ? 1 : self.a + 1
		let new_s2 = (self.b == 1) ? UInt32.max : self.b - 1
		let left = StdGen(a: new_s1, b: nextGen.b)
		let right = StdGen(a: nextGen.a, b: new_s2)
		
		return (left, right)
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
	return newIORef(mkStdRNG(0).unsafePerformIO()).unsafePerformIO()
}

public func newStdGen() -> IO<StdGen> {
	return IO.pure(readIORef(theStdGen()).unsafePerformIO().split().1)
}

private func mkStdRNG(i: Int) -> IO<StdGen> {
	let ct = clock()
	let (sec, psec) = (time(nil), time(nil))
	return IO.pure(StdGen(a:UInt32(sec), b:UInt32(psec)))
}
