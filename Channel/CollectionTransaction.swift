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
public struct CollectionSingleTransaction<K,V> {
	public typealias	Entry		=	(key: K, value: V?)
	///	This `typealias` is defined only to simplify illustration.
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
	///	But in practice, type `V` is not `Equatable`, so there's no way to
	///	detect equality of them at level of this class. It's observer's
	///	responsibility how to parse meaning of last case.
	///
	private typealias	Mutation	=	(past: Entry, future: Entry)
	public var			mutations	:	[Mutation]
}

///	Represents an atomic transaction.
///	Mutations are order-dependent to avoid diff cost and ambiguity.
///
///	:see:	Mutation	
///			for more details.
public struct CollectionTransaction<K,V> {
	public typealias	Subset		=	(key: [K], value: [V]?)
	///	This `typealias` is defined only to simplify illustration.
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
	///	But in practice, type `V` is not `Equatable`, so there's no way to
	///	detect equality of them at level of this class. It's observer's
	///	responsibility how to parse meaning of last case.
	///
	public typealias	Mutation	=	(past: Subset, future: Subset)
	public var			mutations	:	[Mutation]
}
//public enum CollectionMutation<K,V> {
//	public typealias	Entry		=	(key: K, value: V?)
//	public typealias	Subset		=	(key: [K], value: [V]?)
//	case Single(past: Entry, future: Entry)
//	case Multiple(past: Subset, future: Subset)
//	init(_ single: (past: Entry, future: Entry)) {
//		self	=	Single(past: single.past, future: single.future)
//	}
//	init(_ multiple: (past: Subset, future: Subset)) {
//		self	=	Multiple(past: multiple.past, future: multiple.future)
//	}
//}





extension CollectionSingleTransaction {
	static func insert(entry: (key: K, value: V)) -> CollectionSingleTransaction {
		return	insert([entry.key, entry.value])
	}
	static func update(entry: (key: K, from: V, to: V)) -> CollectionSingleTransaction {
		return	update([entry])
	}
	static func delete(entry: (key: K, value: V)) -> CollectionSingleTransaction {
		return	delete([entry])
	}
	static func displace(entry: (from: K, to: K, value: V)) -> CollectionSingleTransaction {
		return	displace([entry])
	}
}
extension CollectionTransaction {
	static func insert(subset: (key: [K], value: [V])) -> CollectionTransaction {
		return	insert([subset])
	}
	static func update(subset: (key: [K], from: [V], to: [V])) -> CollectionTransaction {
		return	update([subset])
	}
	static func delete(subset: (key: [K], value: [V])) -> CollectionTransaction {
		return	delete([subset])
	}
	static func displace(subset: (from: [K], to: [K], value: [V])) -> CollectionTransaction {
		return	displace([subset])
	}
	
	static func insert(subsets: [(key: [K], value: [V])]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: subsets.map(Primitives.insert))
	}
	static func update(subsets: [(key: [K], from: [V], to: [V])]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: subsets.map(Primitives.update))
	}
	static func delete(subsets: [(key: [K], value: [V])]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: subsets.map(Primitives.delete))
	}
	static func displace(subsets: [(from: [K], to: [K], value: [V])]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: subsets.map(Primitives.displace))
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
	static func insert<K,V>(k:[K], v:[V]) -> CollectionTransaction<K,V>.Mutation {
		assert(k.count == v.count)
		return	(past: (k,nil), future: (k,v))
	}
	static func update<K,V>(k:[K], v0:[V], v1:[V]) -> CollectionTransaction<K,V>.Mutation {
		assert(k.count == v0.count)
		assert(k.count == v1.count)
		return	(past: (k,v0), future: (k,v1))
	}
	static func delete<K,V>(k:[K], v:[V]) -> CollectionTransaction<K,V>.Mutation {
		assert(k.count == v.count)
		return	(past: (k,v), future: (k,nil))
	}
	static func displace<K,V>(k0:[K], k1:[K], v:[V]) -> CollectionTransaction<K,V>.Mutation {
		assert(k0.count == v.count)
		assert(k1.count == v.count)
		return	(past: (k0,v), future: (k1,v))
	}
}









