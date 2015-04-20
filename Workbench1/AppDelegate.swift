//
//  AppDelegate.swift
//  Workbench1
//
//  Created by Hoon H. on 2015/04/18.
//  Copyright (c) 2015 Eonil. All rights reserved.
//

import Cocoa
import Channel

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!

	let	scroll	=	NSScrollView()
	let	outline	=	NSOutlineView()

	func applicationDidFinishLaunching(aNotification: NSNotification) {
	
		let	e	=	Dispatcher<Int>()
		let	r	=	Relay<Int>()
		let	m	=	Monitor<Int>(println)
		e.register(r)
		r.register(m)
		e.signal(333)
		
		scroll.documentView	=	outline

		
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}



class TableViewDataBinding {
	deinit {
		reconfigure()
	}
	var	dataRepository: ArrayRepository<Int>? {
		didSet {
			reconfigure()
		}
	}
	var tableView: NSTableView? {
		didSet {
			reconfigure()
		}
	}
	private func reconfigure() {
		if let data = dataRepository, view = tableView {
			session	=	TableViewDataBindingSession((data, view, { _ in return NSView() }))
		} else {
			session	=	nil
		}
	}
	private var	session	:	TableViewDataBindingSession?
}

class TableViewDataBindingSession: NSObject, NSTableViewDataSource, NSTableViewDelegate {
	typealias	Configuration	=	(proxy: ArrayRepository<Int>, view: NSTableView, map: (row: Int, column: Int)->NSView)
	init(_ c: Configuration) {
		self.configuration	=	c
		super.init()
		monitor.handler		=	{ [unowned self] t in
			self.configuration.view.reloadData()
		}
	}
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return	proxy.state.count
	}
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
	}
	
	private let	configuration	:	Configuration
	private let	proxy			=	ArrayProxy<Int>()
	private let	monitor			=	ArrayMonitor<Int>()
}





