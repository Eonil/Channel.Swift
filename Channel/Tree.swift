//
//  Tree.swift
//  Channel
//
//  Created by Hoon H. on 2015/04/18.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation


class Tree<T> {
	
}
class Node<T> {
	
}

class TreeRepository<T>: StatefulDispatcher<Tree<T>,NodeSignal<T>> {
	
}

enum NodeSignal<T> {
	typealias	Snapshot	=	Tree<T>
	typealias	Transaction	=	CollectionTransaction<TreeNodeLocation,Node<T>>
	case Initiation	(snapshot	: Snapshot)
	case Transition	(transaction: Transaction)
	case Termination(snapshot	: Snapshot)
}
extension NodeSignal: CollectionSignalType {
	var initiation: Snapshot? {
		get {
			switch self {
			case .Initiation(snapshot: let s):		return	s
			default:								return	nil
			}
		}
	}
	var transition: Transaction? {
		get {
			switch self {
			case .Transition(transaction: let s):	return	s
			default:								return	nil
			}
		}
	}
	var termination: Snapshot? {
		get {
			switch self {
			case .Termination(snapshot: let s):		return	s
			default:								return	nil
			}
		}
	}
}


///	Represents location of a tree node.
///
///	If `indexes == []`, it's a root node.
//	Otherwise, this designate a node at the index at the level.
struct TreeNodeLocation {
	var	indexes: [Int]
}