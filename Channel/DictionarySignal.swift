//
//  DictionarySignal.swift
//  Replicate
//
//  Created by Hoon H. on 2015/04/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//


enum DictionarySignal<K: Hashable,V> {
	typealias	Snapshot	=	[K:V]
	typealias	Transaction	=	CollectionTransaction<K,V>
	case Initiation	(snapshot	: Snapshot)
	case Transition	(transaction: Transaction)
	case Termination(snapshot	: Snapshot)
}
extension DictionarySignal: CollectionSignalType {
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

/////	Represents an atomic transaction.
/////	Mutations are order-dependent to avoid diff cost and ambiguity.
//struct DictionaryTransaction<K: Hashable,V> {
//	var	mutations	:	[DictionaryMutation<K,V>]
//	
//}
//struct DictionaryMutation<K: Hashable,V> {
//	var	operation	:	DictionaryOperation
//	var	past		:	(K,V)
//	var	future		:	(K,V)
//}
//typealias DictionaryOperation	=	IndexCollectionOperation


















