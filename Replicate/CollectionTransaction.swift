//
//  CollectionTransaction.swift
//  Replicate
//
//  Created by Hoon H. on 2015/04/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//






///	Represents an atomic transaction.
///	Mutations are order-dependent to avoid diff cost and ambiguity.
///
///	:see:	Mutation	
///			for more details.
struct CollectionTransaction<K,V> {
	typealias	Entry		=	(key: K, value: V?)
	///	We can represent these four operations with two key-value pairs.
	///
	///	-	Insert:		K,nil	-> K,T		(keys must be equal)
	///	-	Update:		K,T0	-> K,T1		(same keys with different values)
	///	-	Delete:		K,T		-> K,nil	(keys must be equal)
	///	-	Displace:	K0,T	-> K1,T		(different keys with same values)
	///
	///	No operation is defined for these cases, and result undefined.
	///	(asserted in debug build)
	///
	///	-	K,nil	->	K,nil
	///	-	K0,nil	->	K1,nil
	///	-	K0,T0	->	K1,T1	
	///
	///	The last case is can be interpreted as delete & insert, but I
	///	avoid it to avoid ambiguity.
	///
	typealias	Mutation	=	(past: Entry, future: Entry)
	var			mutations	:	[Mutation]
}
extension CollectionTransaction {
	static func insert(entry: (K,V)) -> CollectionTransaction {
		return	insert([entry])
	}
	static func update(entry: (key: K, from: V, to: V)) -> CollectionTransaction {
		return	update([entry])
	}
	static func delete(entry: (key: K, value: V)) -> CollectionTransaction {
		return	delete([entry])
	}
	static func displace(entry: (from: K, to: K, value: V)) -> CollectionTransaction {
		return	displace([entry])
	}
	static func insert(entries: [(key: K, value: V)]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: entries.map(Primitives.insert))
	}
	static func update(entries: [(key: K, from: V, to: V)]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: entries.map(Primitives.update))
	}
	static func delete(entries: [(key: K, value: V)]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: entries.map(Primitives.delete))
	}
	static func displace(entries: [(from: K, to: K, value: V)]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: entries.map(Primitives.displace))
	}
	
	///	You can rollback a transaction by applying a reversion.
	func reversion() -> CollectionTransaction {
		func reverseMutationOf(m: Mutation) -> Mutation {
			return	(m.future, m.past)
		}
		return	CollectionTransaction(mutations: reverse(mutations))
	}
}

private struct Primitives {
	static func insert<K,V>(k:K, v:V) -> CollectionTransaction<K,V>.Mutation {
		return	(past: (k,nil), future: (k,v))
	}
	static func update<K,V>(k:K, v0:V, v1:V) -> CollectionTransaction<K,V>.Mutation {
		return	(past: (k,v0), future: (k,v1))
	}
	static func delete<K,V>(k:K, v:V) -> CollectionTransaction<K,V>.Mutation {
		return	(past: (k,v), future: (k,nil))
	}
	static func displace<K,V>(k0:K, k1:K, v:V) -> CollectionTransaction<K,V>.Mutation {
		return	(past: (k0,v), future: (k1,v))
	}
}









