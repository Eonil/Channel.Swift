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
///	DESIGN CONSIDERATIONS
///	---------------------
///	Each key and value are passed one by one. I also considered
///	passing `([K],[V])` instead of `(K,V)`, but it really has no benefit 
///	because keys are not guaranteed to be sorted efficiently for batch 
///	processing. Then one by one enumeration is unavoidable.
///	If you really need a sort of batch processing, you can set type `K`
///	and `V` to an appropriate type. For example, you can have `([Int],[String])`
///	typed transaction by setting `K` to `[Int]` and `V` to `[String]`.
///	Of course, making a processing node that supports such types is a different 
///	story. The point is, you can optionally promote this transaction type to a
///	batch processing type simply by setting each types to collection type while
///	reverse is impossible. This is why I chose non-collection type for passing
///	`K` and `V`.
///
///	:see:	Mutation
///			for more details.
public struct CollectionTransaction<K,V> {
	public typealias	Entry		=	(key: K, value: V?)
	///	This `typealias` is defined only to simplify illustration.
	///	We can represent these four operations with two key-value pairs.
	///
	///	-	Insert:		K,nil	-> K,T		(keys must be equal)
	///	-	Update:		K,T0	-> K,T1		(same keys with different values)
	///	-	Delete:		K,T		-> K,nil	(keys must be equal)
	///	-	Commute:	K0,T	-> K1,T		(different keys with same values)
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
	public typealias	Mutation	=	(past: Entry, future: Entry)
	public var			mutations	:	[Mutation]
}

extension CollectionTransaction {
	static func insert(entry: (key: K, value: V)) -> CollectionTransaction {
		return	CollectionTransaction(mutations: [Primitives.insert(entry)])
	}
	static func update(entry: (key: K, from: V, to: V)) -> CollectionTransaction {
		return	CollectionTransaction(mutations: [Primitives.update(entry)])
	}
	static func delete(entry: (key: K, value: V)) -> CollectionTransaction {
		return	CollectionTransaction(mutations: [Primitives.delete(entry)])
	}
	static func commute(entry: (from: K, to: K, value: V)) -> CollectionTransaction {
		return	CollectionTransaction(mutations: [Primitives.commute(entry)])
	}
	
	static func insert(subsets: [(key: K, value: V)]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: subsets.map(Primitives.insert))
	}
	static func update(subsets: [(key: K, from: V, to: V)]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: subsets.map(Primitives.update))
	}
	static func delete(subsets: [(key: K, value: V)]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: subsets.map(Primitives.delete))
	}
	static func commute(subsets: [(from: K, to: K, value: V)]) -> CollectionTransaction {
		return	CollectionTransaction(mutations: subsets.map(Primitives.commute))
	}
}

extension CollectionTransaction {
	///	You can undo a transaction by applying a reversion if all operations on the collection are commutative.
	func reverse() -> CollectionTransaction {
		func reverseMutationOf(m: Mutation) -> Mutation {
			return	(m.future, m.past)
		}
		return	CollectionTransaction(mutations: Swift.reverse(mutations))
	}
}

private struct Primitives {
	static func insert<K,V>(t: (K,V)) -> CollectionTransaction<K,V>.Mutation {
		return	(past: (t.0, nil), future: (t.0, t.1))
	}
	static func update<K,V>(t: (K,V,V)) -> CollectionTransaction<K,V>.Mutation {
		return	(past: (t.0, t.1), future: (t.0, t.2))
	}
	static func delete<K,V>(t: (K,V)) -> CollectionTransaction<K,V>.Mutation {
		return	(past: (t.0, t.1), future: (t.0, nil))
	}
	static func commute<K,V>(t: (K,K,V)) -> CollectionTransaction<K,V>.Mutation {
		return	(past: (t.0, t.2), future: (t.1, t.2))
	}
}
























/////	Represents an atomic transaction.
/////	Mutations are order-dependent to avoid diff cost and ambiguity.
/////
/////	:see:	Mutation	
/////			for more details.
//public struct CollectionTransaction<K,V> {
//	public typealias	Subset		=	(key: [K], value: [V]?)
//	///	This `typealias` is defined only to simplify illustration.
//	///	We can represent these four operations with two key-value pairs.
//	///
//	///	-	Insert:		K,nil	-> K,T		(keys must be equal)
//	///	-	Update:		K,T0	-> K,T1		(same keys with different values)
//	///	-	Delete:		K,T		-> K,nil	(keys must be equal)
//	///	-	Displace:	K0,T	-> K1,T		(different keys with same values)
//	///
//	///	No operation is defined for these cases, and result undefined.
//	///	(asserted in debug build)
//	///
//	///	-	K,nil	->	K,nil
//	///	-	K0,nil	->	K1,nil
//	///	-	K0,T0	->	K1,T1
//	///
//	///	The last case is can be interpreted as delete & insert, but I
//	///	avoid it to avoid ambiguity.
//	///
//	///	But in practice, type `V` is not `Equatable`, so there's no way to
//	///	detect equality of them at level of this class. It's observer's
//	///	responsibility how to parse meaning of last case.
//	///
//
//	public typealias	Mutation	=	(past: Subset, future: Subset)
//	public var			mutations	:	[Mutation]
//}
////public enum CollectionMutation<K,V> {
////	public typealias	Entry		=	(key: K, value: V?)
////	public typealias	Subset		=	(key: [K], value: [V]?)
////	case Single(past: Entry, future: Entry)
////	case Multiple(past: Subset, future: Subset)
////	init(_ single: (past: Entry, future: Entry)) {
////		self	=	Single(past: single.past, future: single.future)
////	}
////	init(_ multiple: (past: Subset, future: Subset)) {
////		self	=	Multiple(past: multiple.past, future: multiple.future)
////	}
////}
//
//
//
//
//
//
//
//
////
////private func arraysOf<K,V>(t: (K,V)) -> ([K],[V]) {
////	return	([t.0], [t.1])
////}
////private func arraysOf<K,V>(t: (K,K,V)) -> ([K],[K],[V]) {
////	return	([t.0], [t.1], [t.2])
////}
////private func arraysOf<K,V>(t: (K,V,V)) -> ([K],[V],[V]) {
////	return	([t.0], [t.1], [t.2])
////}
////
////
////extension CollectionTransaction {
////	static func insert(entry: (key: K, value: V)) -> CollectionTransaction {
////		return	insert(arraysOf(entry))
////	}
////	static func update(entry: (key: K, from: V, to: V)) -> CollectionTransaction {
////		return	update(arraysOf(entry))
////	}
////	static func delete(entry: (key: K, value: V)) -> CollectionTransaction {
////		return	delete(arraysOf(entry))
////	}
////	static func displace(entry: (from: K, to: K, value: V)) -> CollectionTransaction {
////		return	displace(arraysOf(entry))
////	}
////}
////
////extension CollectionTransaction {
////	static func insert(subset: (key: [K], value: [V])) -> CollectionTransaction {
////		return	insert([subset])
////	}
////	static func update(subset: (key: [K], from: [V], to: [V])) -> CollectionTransaction {
////		return	update([subset])
////	}
////	static func delete(subset: (key: [K], value: [V])) -> CollectionTransaction {
////		return	delete([subset])
////	}
////	static func displace(subset: (from: [K], to: [K], value: [V])) -> CollectionTransaction {
////		return	displace([subset])
////	}
////	
////	static func insert(subsets: [(key: [K], value: [V])]) -> CollectionTransaction {
////		return	CollectionTransaction(mutations: subsets.map(Primitives.insert))
////	}
////	static func update(subsets: [(key: [K], from: [V], to: [V])]) -> CollectionTransaction {
////		return	CollectionTransaction(mutations: subsets.map(Primitives.update))
////	}
////	static func delete(subsets: [(key: [K], value: [V])]) -> CollectionTransaction {
////		return	CollectionTransaction(mutations: subsets.map(Primitives.delete))
////	}
////	static func displace(subsets: [(from: [K], to: [K], value: [V])]) -> CollectionTransaction {
////		return	CollectionTransaction(mutations: subsets.map(Primitives.displace))
////	}
////	
////	///	You can undo a transaction by applying a reversion.
////	func reversion() -> CollectionTransaction {
////		func reverseMutationOf(m: Mutation) -> Mutation {
////			return	(m.future, m.past)
////		}
////		return	CollectionTransaction(mutations: reverse(mutations))
////	}
////}
////
////private struct Primitives {
////	static func insert<K,V>(k:[K], v:[V]) -> CollectionTransaction<K,V>.Mutation {
////		assert(k.count == v.count)
////		return	(past: (k,nil), future: (k,v))
////	}
////	static func update<K,V>(k:[K], v0:[V], v1:[V]) -> CollectionTransaction<K,V>.Mutation {
////		assert(k.count == v0.count)
////		assert(k.count == v1.count)
////		return	(past: (k,v0), future: (k,v1))
////	}
////	static func delete<K,V>(k:[K], v:[V]) -> CollectionTransaction<K,V>.Mutation {
////		assert(k.count == v.count)
////		return	(past: (k,v), future: (k,nil))
////	}
////	static func displace<K,V>(k0:[K], k1:[K], v:[V]) -> CollectionTransaction<K,V>.Mutation {
////		assert(k0.count == v.count)
////		assert(k1.count == v.count)
////		return	(past: (k0,v), future: (k1,v))
////	}
////}
//
//







