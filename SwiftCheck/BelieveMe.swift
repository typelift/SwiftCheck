//
//  BelieveMe.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/26/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

// Try to see it my way
// Do I have to keep on casting 'til I can't go on?
// While you see it your way
// Run the risk of knowing that our types may soon be wrong
// We can work it out
// We can work it out
//
// Think of what you're saying
// You can get it wrong and still you think that it's alright
// Think of what I'm saying
// We can work it out and get it straight, or say good night
// We can work it out
// We can work it out
//
// Life is very short, and there's no time
// For fussing and fighting, my friend
// I have always thought that it's a crime
// So I will ask you once again
//
// Try to see it my way
// Only this will tell if I am right or I am wrong
// While you see it your way
// There's a chance that you may fall apart before too long
// We can work it out
// We can work it out
//
// Life is very short, and there's no time
// For fussing and fighting, my friend
// I have always thought that it's a crime
// So I will ask you once again
//
// Try to see it my way
// Only time will tell if I am right or I am wrong
// While you see it your way
// There's a chance that you may fall apart before too long
// We can work it out
// We can work it out
public func unsafeCoerce<A, B>(x : A) -> B {
    return unsafeBitCast(x, B.self)
}
