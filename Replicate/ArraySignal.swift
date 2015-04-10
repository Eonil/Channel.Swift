//
//  ArraySignal.swift
//  Replicate
//
//  Created by Hoon H. on 2015/04/08.
//  Copyright (c) 2015 Eonil. All rights reserved.
//



enum ArraySignal<T> {
	typealias	Snapshot	=	[T]
	typealias	Transaction	=	CollectionTransaction<Int,T>
	case Initiation	(snapshot	: Snapshot)
	case Transition	(transaction: Transaction)
	case Termination(snapshot	: Snapshot)
}
extension ArraySignal: CollectionSignalType {
	var initiation: Snapshot? {
		get {
			switch self {
			case .Initiation(snapshot: let s):	return	s
			default:							return	nil
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
			case .Termination(snapshot: let s):	return	s
			default:							return	nil
			}
		}
	}
}

/////	Represents an atomic transaction.
/////	Mutations are order-dependent to avoid diff cost and ambiguity.
//struct ArrayTransaction<T> {
//	var	mutations	:	[ArrayMutation<T>]
//}
//struct ArrayMutation<T> {
//	var	operation	:	ArrayOperation
//	var	past		:	(Int,T)
//	var	future		:	(Int,T)
//}
//typealias ArrayOperation	=	IndexCollectionOperation



















