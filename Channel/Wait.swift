//
//  Wait.swift
//  Channel
//
//  Created by Hoon H. on 2015/04/30.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation



class Wait<T,U> {
	init<S: SinkType where S.Element == (T, U->())>(_ transform: S) {
		
	}
	convenience init(_ transform: (T, U->()) -> ()) {
		self.init(SinkOf(transform))
	}
}


///	Just passes the signal by specified time.
class Time<T>: Wait<T,T> {
	init(_ duration: NSTimeInterval) {
		super.init(SinkOf(){ $1($0) })
	}
}


class IO<T,U>: Wait<T,U> {
}

//class RPC<T,U>: IO<T,U> {
//	init(name: String) {
//	}
//}

//class Listen<T>: IO<(),T> {
//	
//}
//
//class Dispatch<T>: IO<T,()> {
//	
//}


private func NOOP<T>(value: T, continuation: T->()) {
	continuation(value)
}


