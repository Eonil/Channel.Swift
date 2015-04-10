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















class Gate<T,U> {
	private weak var	origin		:	AnyObject?
	private var			transform	:	T->U
	private var			observers	:	[ChannelOf<U>] = []
	
	private init(_ transform: T->U) {
		self.transform	=	transform
	}
	///	We can setup an andditional type constraint if compiler works well with this.
	private func register<V,G where G: Gate<U,V>>(m: G) {
	}
	private func register<V>(m: Gate<U,V>) {
		assert(m is DispatcherType == false, "You cannot plug a dispatcher type object `\(m)` into another gate.")
		assert(m.origin === nil, "You cannot register a gate into multiple gates. Transmission graph must be a strict tree.")
		m.origin	=	self
		observers.append(ChannelOf(m))
	}
	private func deregister<V>(m: Gate<U,V>) {
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











private protocol DispatcherType {
}
extension Dispatcher: DispatcherType {
}

///	Type erasuring emitter.
///	You can use this wrapper to provide an emission-only object
///	that cannot be registered to another node.
///
///	This is designed as an event emitter for an actor.
struct UnowningEmitterOf<T> {
	init(_ relay: Relay<T>) {
		self.relay	=	relay
	}
	func register<U>(m: Gate<T,U>) {
		relay.register(m)
	}
	func deregister<U>(m: Gate<T,U>) {
		relay.deregister(m)
	}
	private unowned let	relay: Relay<T>
}

///	:param:		T	Signal type.
class Dispatcher<T>: Gate<(),T> {
	typealias	Signal	=	T
	init() {
		super.init(Dispatcher.crashBecauseSignalingToThisClassIsNotAllowed)
	}
	func signal(s: Signal) {
		broadcast(s)
	}
	override func register<U>(m: Gate<T,U>) {
		super.register(m)
	}
	override func deregister<U>(m: Gate<T,U>) {
		super.deregister(m)
	}
	private static func crashBecauseSignalingToThisClassIsNotAllowed()->Signal {
		fatalError("You cannot signal to this class object.")
	}
}

class Monitor<T>: Gate<T,()> {
	typealias	Signal	=	T
	init<S: SinkType where S.Element == Signal>(_ handler: S) {
		var	h	=	handler
		super.init({h.put($0)})
	}
	override convenience init(_ handler: Signal->()) {
		self.init(SinkOf(handler))
	}
	convenience init() {
		self.init({ _ in () })
	}
	private override func signal(s: Signal) {
		super.signal(s)
		handler(s)
	}
	var handler: Signal->() {
		get {
			return	transform
		}
		set(v) {
			transform	=	v
		}
	}
}

class Relay<T>: Gate<T,T> {
	typealias	Signal	=	T
	init() {
		super.init(Relay.asIs)
	}
	override func register<U>(m: Gate<T,U>) {
		super.register(m)
	}
	override func deregister<U>(m: Gate<T,U>) {
		super.deregister(m)
	}
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




///	Emits snapshot for each time when the value set
///	regardless or equality or duplication.
class StatefulDispatcher<T,S>: Dispatcher<S> {
	typealias	State	=	T
	private(set) var state: State
	private init(_ state: State) {
		self.state	=	state
	}
}



///	Emits snapshot for each time when the value set 
///	regardless or equality or duplication.
class ValueRepository<T>: StatefulDispatcher<T,T> {
}

class CollectionRepository<T,S where T: CollectionType, S: CollectionSignalType>: StatefulDispatcher<T,S> {
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
struct ArrayEditor<T> {
	var count: Int {
		get {
			return	storage.state.count
		}
	}
	var state: [T] {
		get {
			return	storage.state
		}
		set(s) {
			storage.signal(ArraySignal.Termination(snapshot: storage.state))
			storage.state	=	s
			storage.signal(ArraySignal.Initiation(snapshot: storage.state))
		}
	}
	mutating func append(v: T) {
		storage.signal(ArraySignal.Transition(transaction: CollectionTransaction.insert([(count,v)])))
	}
	private unowned let storage: ArrayRepository<T>
}

class ArrayRepository<T>: CollectionRepository<[T],ArraySignal<T>> {
	convenience init() {
		self.init([])
	}
	override init(_ state: State) {
		super.init(state)
	}
	override func register<U>(m: Gate<Signal, U>) {
		super.register(m)
		m.signal(Signal.Initiation(snapshot: state))
	}
	override func deregister<U>(m: Gate<Signal, U>) {
		m.signal(Signal.Termination(snapshot: state))
		super.deregister(m)
	}
}

class ArrayReplication<T>: Relay<CollectionTransaction<Int,T>> {
	var state: [T] {
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
				assert(o is ArrayRepository<T>, "This class object must be directly plugged only to `ArrayRepository<T>`.")
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

class ArrayTransform<T,U>: Gate<ArraySignal<T>, ArraySignal<U>> {
	init(_ transform: T->U) {
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
class ArrayMonitor<T>: Monitor<CollectionTransaction<Int,T>> {
}
























class DictionaryRepository<K: Hashable,V>: CollectionRepository<[K:V],DictionarySignal<K,V>> {
	convenience init() {
		self.init([:])
	}
	override init(_ state: State) {
		super.init(state)
	}
	override func register<U>(m: Gate<Signal, U>) {
		super.register(m)
		m.signal(Signal.Initiation(snapshot: state))
	}
	override func deregister<U>(m: Gate<Signal, U>) {
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
				assert(o is DictionaryRepository<K,V>, "This class object must be directly plugged only to `ArrayRepository<T>`.")
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







