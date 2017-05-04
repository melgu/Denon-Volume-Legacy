//
//  AppDelegate.swift
//  Denon Volume
//
//  Created by Melvin Gundlach on 04.05.17.
//  Copyright © 2017 Melvin Gundlach. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	let statusItem = NSStatusBar.system().statusItem(withLength: -2)
	let popover = NSPopover()
	var eventMonitor: EventMonitor?
	
	func showPopover(sender: AnyObject?) {
		if let button = statusItem.button {
			popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
		}
		
		eventMonitor?.start()
	}
	
	func closePopover(sender: AnyObject?) {
		popover.performClose(sender)
		
		eventMonitor?.stop()
	}
	
	func togglePopover(sender: AnyObject?) {
		if popover.isShown {
			closePopover(sender: sender)
		} else {
			showPopover(sender: sender)
		}
	}
	
	func quit() {
		NSApplication.shared().terminate(self)
	}
	
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		
		// Create Menu Bar Icon/Button
		if let button = statusItem.button {
			button.image = NSImage(named: "StatusBarButtonImage")
			button.action = #selector(togglePopover(sender:))
		}
		
		popover.contentViewController = MenuViewController(nibName: "MenuViewController", bundle: nil)
		
		eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
			if self.popover.isShown {
				self.closePopover(sender: event)
			}
		}
		eventMonitor?.start()
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	
	
}

