//
//  EventMonitor.swift
//  Denon Volume
//
//  Created by Melvin Gundlach on 05.05.17.
//  Copyright © 2017 Melvin Gundlach. All rights reserved.
//

import Cocoa

public class EventMonitor {
	private var monitor: AnyObject?
	private let mask: NSEvent.EventTypeMask
	private let handler: (NSEvent?) -> ()
	
	public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> ()) {
		self.mask = mask
		self.handler = handler
	}
	
	deinit {
		stop()
	}
	
	public func start() {
		monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler) as AnyObject
	}
	
	public func stop() {
		if monitor != nil {
			NSEvent.removeMonitor(monitor!)
			monitor = nil
		}
	}
}
