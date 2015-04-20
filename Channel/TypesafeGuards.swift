//
//  TypesafeGuards.swift
//  Channel
//
//  Created by Hoon H. on 2015/04/17.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation


///	Type erasuring emitter.
///	You can use this wrapper to provide an emission-only object
///	that cannot be registered to another node.
///
///	This is designed as an event emitter for an actor.
struct UnowningEmitterOf<T>: Emissive {
	init(_ relay: Relay<T>) {
		self.relay	=	relay
	}
	func register<U>(m: Sensor<T,U>) {
		relay.register(m)
	}
	func deregister<U>(m: Sensor<T,U>) {
		relay.deregister(m)
	}
	private unowned let	relay: Relay<T>
}

protocol Emissive {
	typealias	State
	func register<U>(m: Sensor<State,U>)
	func deregister<U>(m: Sensor<State,U>)
}