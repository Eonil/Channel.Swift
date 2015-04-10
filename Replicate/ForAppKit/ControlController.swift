//
//  ControlController.swift
//  Replicate
//
//  Created by Hoon H. on 2015/04/10.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Foundation
import AppKit

class ControlController {
	let	control: NSControl
	init<T: NSControl>(_ type: T.Type) {
		control	=	T()
		setup()
	}
	deinit {
		teardown()
	}
	var	actionEmitter: UnowningEmitterOf<()> {
		get {
			return	UnowningEmitterOf(targetActionRelay)
		}
	}
	
	private let	targetActionRelay	=	Relay<()>()
	private func setup() {
	}
	private func teardown() {
	}
}

class ButtonController: ControlController {
	
	init() {
		super.init(NSButton)
		setup()
	}
	deinit {
		teardown()
	}
	var button: NSButton {
		get {
			return	control as! NSButton
		}
	}
}