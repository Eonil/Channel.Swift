//
//  Channeling.swift
//  Replicate
//
//  Created by Hoon H. on 2015/04/08.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation





private protocol ChannelType: class {
	typealias	Signal
	func signal(Signal)
}
///	Type erasuring channel.
private struct ChannelOf<T> {
	let	identity: ObjectIdentifier
	let	signal: T->()
	init<CH: ChannelType where CH.Signal == T>(_ ch: CH) {
		identity	=	ObjectIdentifier(ch)
		signal		=	{ s in
			ch.signal(s)
		}
	}
}
private func === <T> (left: ChannelOf<T>, right: ChannelOf<T>) -> Bool {
	return	left.identity == right.identity
}














///	The fundamental type of signal processing node.
public class Gate<T,U> {
	private weak var	origin		:	AnyObject?
	private var			transform	:	T->U
	private var			observers	:	[ChannelOf<U>] = []
	
	private init(_ transform: T->U) {
		self.transform	=	transform
	}
	private func register<V>(m: Sensor<U,V>) {
		assert(m is DispatcherType == false, "You cannot plug a dispatcher type object `\(m)` into another gate.")
		assert(m.origin === nil, "You cannot register a gate into multiple gates. Transmission graph must be a strict tree.")
		m.origin	=	self
		observers.append(ChannelOf(m))
	}
	private func deregister<V>(m: Sensor<U,V>) {
		assert(m is DispatcherType == false, "You cannot plug a dispatcher type object `\(m)` into another gate.")
		assert(m.origin === self, "You cannot deregister a gate from an unrelated gate.")
		for i in reverse(0..<observers.count) {
			if observers[i].identity == ObjectIdentifier(m) {
				observers.removeAtIndex(i)
				m.origin	=	nil
				return
			}
		}
		fatalError("Could not find the observer `\(m)`.")
	}
	private func signal(s: T) {
		broadcast(transform(s))
	}
	private func broadcast(s: U) {
		for o in observers {
			o.signal(s)
		}
	}
}
extension Gate: ChannelType {
}





















/////	An abstract base type for types that cannot sense any input signal.
//public class Insensitive<T,U>: Gate<T,U> {
//	override private init(_ transform: T->U) {
//		super.init(transform)
//	}
//}

///	An abstract base type for types that can sense some signals.
///	You cannot use or derive from this class in your code. Use `Monitor` 
///	or `Relay` instead of.
public class Sensor<T,U>: Gate<T,U> {
	override private init(_ transform: T->U) {
		super.init(transform)
	}
}

















private protocol DispatcherType {
}
extension Emitter: DispatcherType {
}

///	Provides a state-less node that you can emit some signals by your control.
///
///	:param:		T	
///				Signal type.
///
///	You can't/shouldn't register a emitter to another gate.
public class Emitter<T>: Gate<(),T> {
	typealias	Signal	=	T
	public init() {
		super.init(Emitter.crashBecauseSignalingToThisClassIsNotAllowed)
	}
	public func signal(s: Signal) {
		broadcast(s)
	}
	public override func register<U>(m: Sensor<T,U>) {
		super.register(m)
	}
	public override func deregister<U>(m: Sensor<T,U>) {
		super.deregister(m)
	}
	private static func crashBecauseSignalingToThisClassIsNotAllowed()->Signal {
		fatalError("You cannot signal to this class object.")
	}
}


///	A node that let you monitor the signals coming into it.
public class Monitor<T>: Sensor<T,()> {
	public typealias	Signal	=	T
	public init<S: SinkType where S.Element == Signal>(_ handler: S) {
		var	h	=	handler
		super.init({h.put($0)})
	}
	public override convenience init(_ handler: Signal->()) {
		self.init(SinkOf(handler))
	}
	public var handler: Signal->() {
		get {
			return	transform
		}
		set(v) {
			transform	=	v
		}
	}
	
	private override func signal(s: Signal) {
		super.signal(s)
		handler(s)
	}
}
extension Monitor {
	public convenience init() {
		self.init({ _ in () })
	}
}

///	A node that just relays signals. This is provided to connect
///	component internal/external worlds.
public class Relay<T>: Sensor<T,T> {
	public typealias	Signal	=	T
	public init() {
		super.init(Relay.asIs)
	}
	public override func register<U>(m: Sensor<T,U>) {
		super.register(m)
	}
	public override func deregister<U>(m: Sensor<T,U>) {
		super.deregister(m)
	}
	
	///	Passes input to output just "as is".
	private static func asIs(s: T) -> T {
		return	s
	}
}









































//extension Gate {
//	@availability(*,unavailable)
//	func register(ArrayReplication<U>) {
//	}
//	@availability(*,unavailable)
//	func deregister(ArrayReplication<U>) {
//	}
//}




///	An emitter with state storage.
///	This stores and emits value snapshot for each time when the value is being 
///	set regardless of equality or duplication.
class Repository<T,S>: Emitter<S> {
	typealias	State	=	T
	private(set) var state: State
	private init(_ state: State) {
		self.state	=	state
	}
}
///	A relay that provides a read-only view of a repository.
class Proxy<T,S>: Relay<T> {
	private override init() {
		super.init()
	}
	private var state: T {
		get {
			return	originRepository.state
		}
	}
	private var originRepository: Repository<T,S> {
		get {
			return	origin as! Repository<T,S>
		}
	}
}



///	A specialized repository to store and emit single value.
public class ValueRepository<T>: Repository<T,T> {
	public override init(_ state: T) {
		super.init(state)
	}
}
///	A proxy that provides a read-only view of a repository.
public class ValueProxy<T>: Relay<T> {
	public override init() {
		super.init()
	}
	public var	state: T {
		get {
			return	originRepository.state
		}
	}
	private var originRepository: ValueRepository<T> {
		get {
			return	origin as! ValueRepository<T>
		}
	}
}










///	A specialized repository to handle multiple value collection type.
/// If the value is a collection type, you might want to take delta mutation
///	signals instead of snapshot dispatch. This provides that.
//class CollectionRepository<T where T: CollectionType>: Repository<T, CollectionTransaction<T.Index, T.Generator.Element>> {
class CollectionRepository<T,S where T: CollectionType, S: CollectionSignalType, S.Snapshot == T>: Repository<T,S> {
	private override init(_ state: State) {
		super.init(state)
	}
}

protocol CollectionSignalType {
	typealias	Snapshot
	typealias	Transaction
//	init(initiation: Snapshot)
//	init(transition: Transaction)
//	init(termination: Snapshot)
	var initiation: Snapshot? { get }
	var transition: Transaction? { get }
	var termination: Snapshot? { get }
}







































///	MARK:
///	MARK:	Collection Channeling Specializations
///	MARK:







///	Edits a linked `ArrayRepository`.
///	This does not own the linked repository.
public struct ArrayEditor<T> {
	public var count: Int {
		get {
			return	storage.state.count
		}
	}
	public var state: [T] {
		get {
			return	storage.state
		}
		set(s) {
			storage.signal(ArraySignal.Termination(snapshot: storage.state))
			storage.state	=	s
			storage.signal(ArraySignal.Initiation(snapshot: storage.state))
		}
	}
	public mutating func append(v: T) {
		storage.signal(ArraySignal.Transition(transaction: CollectionTransaction.insert([(count,v)])))
	}
	private unowned let storage: ArrayRepository<T>
}

public class ArrayRepository<T>: CollectionRepository<[T],ArraySignal<T>> {
	public convenience init() {
		self.init([])
	}
	public override init(_ state: State) {
		super.init(state)
	}
	public override func register<U>(m: Sensor<Signal, U>) {
		super.register(m)
		m.signal(Signal.Initiation(snapshot: state))
	}
	public override func deregister<U>(m: Sensor<Signal, U>) {
		m.signal(Signal.Termination(snapshot: state))
		super.deregister(m)
	}
}

public class ArrayProxy<T>: Relay<CollectionTransaction<Int,T>> {
	public override init() {
		super.init()
	}
	public var	state: [T] {
		get {
			return	originRepository.state
		}
	}
	private var originRepository: ArrayRepository<T> {
		get {
			return	origin as! ArrayRepository<T>
		}
	}
}

public class ArrayReplication<T>: Relay<CollectionTransaction<Int,T>> {
	public var state: [T] {
		get {
			return	session!.localcopy
		}
	}
	private override weak var origin: AnyObject? {
		willSet {
			if let o: AnyObject = origin {
				session	=	nil
			}
		}
		didSet {
			if let o: AnyObject = origin {
				assert(o is ArrayRepository<T>, "This class object must be directly plugged only into `ArrayRepository<T>`.")
				let	o	=	o as! ArrayRepository<T>
				session	=	ArrayReplicationSession(self, o.state)
			}
		}
	}
	private var session: ArrayReplicationSession<T>?
}
private class ArrayReplicationSession<T> {
	unowned let owner: ArrayReplication<T>
	var localcopy: [T] = []
	init(_ owner: ArrayReplication<T>, _ snapshot: [T]) {
		self.owner	=	owner
		localcopy	=	snapshot
	}
	deinit {
	}
}

public class ArrayTransform<T,U>: Gate<ArraySignal<T>, ArraySignal<U>> {
	public init(_ transform: T->U) {
		let	m0	=	transform
		let	m1	=	{ (v: T?)->U? in
			return	v == nil ? nil : transform(v!)
		}
		super.init(ArrayTransform.transformSignal(m0, m1))
	}
	private typealias	Transaction0	=	CollectionTransaction<Int,T>
	private typealias	Transaction1	=	CollectionTransaction<Int,U>
	private static func transformSignal(map: T->U, _ map1: T?->U?)(_ s: ArraySignal<T>) -> ArraySignal<U> {
		switch s {
		case .Initiation(snapshot: let s):		return	ArraySignal.Initiation(snapshot: s.map(map))
		case .Transition(transaction: let s):	return	ArraySignal.Transition(transaction: transformTransaction(s, map1))
		case .Termination(snapshot: let s):		return	ArraySignal.Termination(snapshot: s.map(map))
		}
	}
	private static func transformTransaction(t: Transaction0, _ map1: T?->U?) -> Transaction1 {
		return	Transaction1(mutations: t.mutations.map(transformMutation(map1)))
	}
	private static func transformMutation(map1: T?->U?)(_ m: Transaction0.Mutation) -> Transaction1.Mutation {
		return	(past: (m.past.key, map1(m.past.value)), future: (m.future.key, map1(m.future.value)))
	}
}
public class ArrayMonitor<T>: Monitor<CollectionTransaction<Int,T>> {
	public override init<S : SinkType where S.Element == Signal>(_ handler: S) {
		super.init(handler)
	}
}
























class DictionaryRepository<K: Hashable,V>: CollectionRepository<[K:V],DictionarySignal<K,V>> {
	convenience init() {
		self.init([:])
	}
	override init(_ state: State) {
		super.init(state)
	}
	override func register<U>(m: Sensor<Signal, U>) {
		super.register(m)
		m.signal(Signal.Initiation(snapshot: state))
	}
	override func deregister<U>(m: Sensor<Signal, U>) {
		m.signal(Signal.Termination(snapshot: state))
		super.deregister(m)
	}
}

class DictionaryReplication<K: Hashable,V>: Relay<CollectionTransaction<K,V>> {
	var state: [K:V] {
		get {
			return	session!.localcopy
		}
	}
	private override weak var origin: AnyObject? {
		willSet {
			if let o: AnyObject = origin {
				session	=	nil
			}
		}
		didSet {
			if let o: AnyObject = origin {
				assert(o is DictionaryRepository<K,V>, "This class object must be directly plugged only to `DictionaryRepository<T>`.")
				let	o	=	o as! DictionaryRepository<K,V>
				session	=	DictionaryReplicationSession(self, o.state)
			}
		}
	}
	private var session: DictionaryReplicationSession<K,V>?
}
private class DictionaryReplicationSession<K: Hashable,V> {
	unowned let owner: DictionaryReplication<K,V>
	var localcopy: [K:V] = [:]
	init(_ owner: DictionaryReplication<K,V>, _ snapshot: [K:V]) {
		self.owner	=	owner
		localcopy	=	snapshot
	}
	deinit {
	}
}

class DictionaryTransform<K: Hashable,T,U>: Gate<DictionarySignal<K,T>, DictionarySignal<K,U>> {
	init(_ transform: T->U) {
		let	m0	=	transform
		let	m1	=	{ (v: T?)->U? in
			return	v == nil ? nil : transform(v!)
		}
		super.init(DictionaryTransform.transformSignal(m0, m1))
	}
	private typealias	Transaction0	=	CollectionTransaction<K,T>
	private typealias	Transaction1	=	CollectionTransaction<K,U>
	private static func transformSignal(map: T->U, _ map1: T?->U?)(_ s: DictionarySignal<K,T>) -> DictionarySignal<K,U> {

		switch s {
		case .Initiation(snapshot: let s):		return	DictionarySignal.Initiation(snapshot: transformSnapshot(s, map))
		case .Transition(transaction: let s):	return	DictionarySignal.Transition(transaction: transformTransaction(s, map1))
		case .Termination(snapshot: let s):		return	DictionarySignal.Termination(snapshot: transformSnapshot(s, map))
		}
	}
	private static func transformSnapshot(s: [K:T], _ map0: T->U) -> [K:U] {
		var	m1	=	[:] as [K:U]
		for (k,t) in s {
			m1[k]	=	map0(t)
		}
		return	m1
	}
	private static func transformTransaction(t: Transaction0, _ map1: T?->U?) -> Transaction1 {
		return	Transaction1(mutations: t.mutations.map(transformMutation(map1)))
	}
	private static func transformMutation(map1: T?->U?)(_ m: Transaction0.Mutation) -> Transaction1.Mutation {
		return	(past: (m.past.key, map1(m.past.value)), future: (m.future.key, map1(m.future.value)))
	}
}
class DictionaryMonitor<K: Hashable,V>: Monitor<CollectionTransaction<K,V>> {
}







