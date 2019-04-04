//
//  EventMonitor.swift
//  Denon Volume
//
//  Created by Melvin Gundlach.
//  Copyright © 2018 Melvin Gundlach. All rights reserved.
//

import Cocoa

public class EventMonitor {
	private var monitor: AnyObject?
	private let mask: NSEvent.EventTypeMask
	private let handler: (NSEvent?) -> Void
	
	public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
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
