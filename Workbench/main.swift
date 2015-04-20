//
//  main.swift
//  Replicate
//
//  Created by Hoon H. on 2015/04/08.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import Channel








//let	e	=	Emitter<Int>()
//let	m	=	Monitor<Int>(println)
//e.register(m)
//e.signal(222)

let	e	=	Dispatcher<Int>()
let	r	=	Relay<Int>()
let	m	=	Monitor<Int>(println)
e.register(r)
r.register(m)
e.signal(333)





















//class Gate<T,U> {
//	typealias	IncomingSignal	=	T
//	typealias	OutgoingSignal	=	U
//	
//	func register(m: Monitor<T>) {
//		
//	}
//	func deregister(m: Monitor<T>) {
//		
//	}
//	
//	private let	transform: T->U
//	private init(_ transform: T->U) {
//		self.transform	=	transform
//	}
//	private func signal(s: IncomingSignal) {
//		
//	}
//}









//class ArrayRepository<T> {
//	private(set) var state: [T] = []
//	func signal(t: ArrayTransaction<T>) {
//	}
//	func register(r: ArrayReplication<T>) {
//		assert(r.session == nil)
//		r.session	=	ArrayReplicationSession(source: self)
//	}
//	func deregister(r: ArrayReplication<T>) {
//		assert(r.session != nil)
//		assert(r.session!.source === self)
//		r.session	=	nil
//	}
//}
//
//class ArrayReplication<T> {
//	
//	init() {
//	}
//	
//	var state: [T]? {
//		get {
//			return	session?.localcopy
//		}
//	}
//	
//	private var session: ArrayReplicationSession<T>?
//	
//	private func signal(s: ArrayTransaction<T>) {
//		assert(session != nil)
//	}
//}
//
//private final class ArrayReplicationSession<T> {
//	unowned let	source: ArrayRepository<T>
//	private(set) var localcopy: [T]
//	init(source: ArrayRepository<T>) {
//		self.source	=	source
//		localcopy	=	source.state
//	}
//	deinit {
//	}
//}













//
//class ArrayMonitor<T> {
//	
//	init() {
//	}
//	var state: [T]? {
//		get {
//			return	session?.source.state
//		}
//	}
//	
//	private var session: ArrayMonitoringSession<T>?
//	
//	private func signal(s: ArrayTransaction<T>) {
//		assert(session != nil)
//	}
//}
//
//private final class ArrayMonitoringSession<T> {
//	unowned let	source: ArrayRepository<T>
//	init(source: ArrayRepository<T>) {
//		self.source	=	source
//	}
//	deinit {
//	}
//}
//











//
//class Spot<T> {
//	func register(r: Replication<T>) {
//		assert(r.session == nil)
//		r.session	=	ReplicationSession(source: self)
//	}
//	func deregister(r: Replication<T>) {
//		assert(r.session != nil)
//		assert(r.session!.source === self)
//		r.session	=	nil
//	}
//}
//class Replication<T> {
//	init() {
//	}
//	
//	private var session: ReplicationSession<T>?
//	
//	private func signal(T) {
//		assert(session != nil)
//	}
//}
//
//private final class ReplicationSession<T> {
//	unowned let	source: Spot<T>
//	init(source: Spot<T>) {
//		self.source	=	source
//	}
//	deinit {
//	}
//}
//



















































