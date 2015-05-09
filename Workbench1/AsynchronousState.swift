//
//  AsynchronousState.swift
//  Channel
//
//  Created by Hoon H. on 2015/05/05.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import Channel



//
//enum Process<In,Progress,Out> {
//	case Ready(()->In)
//	case Running(()->Progress)
//	case Done(()->Out)
//}
//
//enum Resolution<Solution,Error> {
//	case Existing(()->Solution)
//	case Missing(()->Error)
//}
//
//typealias	HTTPOperation			=	Process<NSURL,(),Resolution<NSData,String>>
//
//func b() {
//	let	a	=	ValueRepository<Process<Int,Float,Resolution<String,()>>>(Process.Ready({111}))
//	
//	
//}
//









enum ProxyProcessingState<Progress,Reason> {
	case Running(()->Progress)
	case Done
	case Error(()->Reason)
}

class ProxyCollection<T> {
	///	`false` if no synchroniztion has been made, so current collection state is actually unknown.
	let	ready		=	ValueProxy<Bool>()
	///	A flag to represent whether some asynchronous I/O to mutate the `items` are currently running.
	let	running		=	ValueProxy<Bool>()
	///	Any error from last I/O operation.
	let	error		=	ValueProxy<NSError?>()
	///	Current in-memory local copy(cache) of items.
	let	items		=	ArrayProxy<T>()

	init() {
		readyRepo	>>>	ready
		runningRepo	>>>	running
		errorRepo	>>>	error
		itemsRepo	>>>	items
	}
	
	///	Makes this to un-ready state.
	func purge() {
		
	}
	///
	func reload() {
		
	}
	
	////
	
	private let	readyRepo	=	ValueRepository<Bool>(false)
	private let	runningRepo	=	ValueRepository<Bool>(false)
	private let	errorRepo	=	ValueRepository<NSError?>(nil)
	private let	itemsRepo	=	ArrayRepository<T>([])
}

infix operator >>> {
}

func >>> <T> (left: ValueRepository<T>, right: ValueProxy<T>) {
	left.register(right)
}
func >>> <T> (left: ArrayRepository<T>, right: ArrayProxy<T>) {
	left.register(<#m: Sensor<ArraySignal<T>, U>#>)
	left.register(right)
}



















//enum IOPhase<ID,Value,Reason> {
//	///	No trial of resolution for the key has been made.
//	case Unknown(ID)
//	case Resolving
//	case Present(()->Value)
//	///	This means the value has been requested, but was not available in result.
//	case Missing(()->Reason)
//	
//	init(_ id: ID) {
//		
//	}
//	init(_ value: Value) {
//		self	=	Present({value})
//	}
//	init(_ error: Reason) {
//		self	=	Missing({error})
//	}
//	
//	var presentValue: Value? {
//		get {
//			switch self {
//			case .Present(let s):		return	s()
//			default:					return	nil
//			}
//		}
//	}
//	var missingReason: Reason? {
//		get {
//			switch self {
//			case .Missing(let s):	return	s()
//			default:					return	nil
//			}
//		}
//	}
//}
//
//
//
//
//
//func a() {
//	let	v1	=	ValueRepository<IOPhase<Int,String,()>>(IOPhase.Present({123}))
//	v1.signal(IOPhase())
//	v1.signal(IOPhase(444))
//}