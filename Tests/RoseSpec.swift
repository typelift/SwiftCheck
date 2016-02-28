//
//  RoseSpec.swift
//  SwiftCheck
//
//  Created by Robert Widmann on 1/24/16.
//  Copyright © 2016 Robert Widmann. All rights reserved.
//

import SwiftCheck
import XCTest

extension Rose {
	var root : A {
		switch self.reduce {
		case let .MkRose(root, _):
			return root()
		default:
			fatalError("Rose should not have reduced to .IORose")
		}
	}
	
	var children : [Rose<A>] {
		switch self.reduce {
		case let .MkRose(_, children):
			return children()
		default:
			fatalError("Rose should not have reduced to .IORose")
		}
	}
	
	var collapse : Rose<A> {
		let children = self.children
		
		let vs = children.map { $0.collapse }
		let cs = children.flatMap({ $0.children }).map { $0.collapse }
		
		return .MkRose({ self.root }, { vs + cs })
	}
}

class RoseSpec : XCTestCase {
	private static func intRoseTree(v : Int) -> Rose<Int> {
		return .MkRose({ v }, { Int.shrink(v).map(intRoseTree) })
	}
	
	private static func depthOneChildren<A>(rose : Rose<A>) -> [A] {
		return rose.children.map { $0.root }
	}
	
	private static func depthOneAndTwoChildren<A>(rose : Rose<A>) -> [A] {
		let topChildren = rose.children
		let vs = topChildren.map { $0.root }
		let cs = topChildren.flatMap({ $0.children }).map({ $0.root })
		return vs + cs
	}
	
	func testAll() {
		property("Collapse brings up one level of rose tree depth") <- forAll { (i : Int) in
			let tree = RoseSpec.intRoseTree(i)
			return RoseSpec.depthOneChildren(tree.collapse) == RoseSpec.depthOneAndTwoChildren(tree)
		}
	}
}
