//
//  SetSignal.swift
//  Replicate
//
//  Created by Hoon H. on 2015/04/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//


enum SetSignal<T: Hashable> {
	typealias	Snapshot	=	Set<T>
	typealias	Transaction	=	CollectionTransaction<(),T>
	case Initiation	(snapshot	: Snapshot)
	case Transition	(transaction: Transaction)
	case Termination(snapshot	: Snapshot)
}
extension SetSignal: CollectionSignalType {
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
//struct SetTransaction<T: Hashable> {
//	var	mutations	:	[SetMutation<T>]
//}
//struct SetMutation<T: Hashable> {
//	var	operation	:	SetOperation
//	var	value		:	T?
//}
//typealias	SetOperation	=	IndexlessCollectionOperation



















