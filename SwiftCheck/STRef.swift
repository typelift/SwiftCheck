//
//  STRef.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 8/20/14.
//  Copyright (c) 2014 Robert Widmann. All rights reserved.
//

import Foundation

public struct STRef<S, A> {
    private var value: A
    
    init(a: A) {
        self.value = a
    }
    
    func readSTRef() -> ST<S, A> {
        return .pure(self.value)
    }
    
    mutating func writeSTRef(a: A) -> ST<S, STRef<S, A>> {
        return ST(apply: { (let s) in
            self.value = a
            return (s, self)
        })
    }
    
    mutating func modifySTRef(f: A -> A) -> ST<S, STRef<S, A>> {
        return ST(apply: { (let s) in
            self.value = f(self.value)
            return (s, self)
        })
    }
}

