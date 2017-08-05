//
//  AppDelegate.swift
//  Denon Volume
//
//  Created by Melvin Gundlach on 04.05.17.
//  Copyright © 2017 Melvin Gundlach. All rights reserved.
//

import Cocoa
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTextFieldDelegate {
	
	// MARK: - Variables
	
	let denonCommunicator = DenonCommunicator()
	
	var hotKeyVolumeUp: HotKey?
	var hotKeyVolumeDown: HotKey?
	var hotKeyVolumeWindow: HotKey?
	
	let statusItem = NSStatusBar.system.statusItem(withLength: -2)
	let popover = NSPopover()
	var eventMonitor: EventMonitor?
	
	
	// MARK: - Func: Popover
	
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
	
	@objc func togglePopover(sender: AnyObject?) {
		if popover.isShown {
			closePopover(sender: sender)
		} else {
			showPopover(sender: sender)
		}
	}
	
	
	// MARK: - Func: Other
	
	func quit() {
		NSApplication.shared.terminate(self)
	}
	
	
	// MARK: - DenonCommunicator Proxies
	
	func sendVolume(deviceName: String, volume: Int) -> (successful: Bool, timeInterval: Bool) {
		return denonCommunicator.sendVolume(deviceName: deviceName, volume: volume)
	}
	
	func askVolume(deviceName: String) -> (volume: Int, successful: Bool, timeInterval: Bool) {
		return denonCommunicator.askVolume(deviceName: deviceName)
	}
	
	func volumeUp() {
		denonCommunicator.volumeUp()
	}
	
	func volumeDown() {
		denonCommunicator.volumeDown()
	}
	
	
	// MARK: - Setup
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		
		// Create Menu Bar Icon/Button
		if let button = statusItem.button {
			button.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
			button.action = #selector(togglePopover(sender:))
		}
		
		popover.contentViewController = MenuViewController(nibName: NSNib.Name(rawValue: "MenuViewController"), bundle: nil)
		
		eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
			if self.popover.isShown {
				self.closePopover(sender: event)
			}
		}
		eventMonitor?.start()
		
		
		// Set Global Hotkeys
		hotKeyVolumeUp = HotKey(key: .upArrow, modifiers: [.control, .option])
		hotKeyVolumeUp?.keyDownHandler = {
			print("Volume Up")
			self.volumeUp()
		}
		hotKeyVolumeDown = HotKey(key: .downArrow, modifiers: [.control, .option])
		hotKeyVolumeDown?.keyDownHandler = {
			print("Volume Down")
			self.volumeDown()
		}
		hotKeyVolumeWindow = HotKey(key: .leftArrow, modifiers: [.control, .option])
		hotKeyVolumeWindow?.keyDownHandler = {
			print("Volume Window")
			self.togglePopover(sender: self)
		}
		
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
}
