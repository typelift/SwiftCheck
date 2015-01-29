//
//  State.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 7/31/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//


public struct Terminal {}

public struct State {
	var terminal			: Terminal
	var maxSuccessTests		: Int
	var maxDiscardedTests	: Int
	var computeSize			: Int -> Int -> Int
	var numSuccessTests		: Int
	var numDiscardedTests	: Int
	var collected			: [[(String,Int)]]
	var expectedFailure		: Bool
	var randomSeed			: StdGen
	var numSuccessShrinks	: Int
	var numTryShrinks		: Int
	var numTotTryShrinks	: Int
}
