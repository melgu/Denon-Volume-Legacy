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
class AppDelegate: NSObject, NSApplicationDelegate, NSTouchBarDelegate {
	
	// MARK: - Variables
	
	let denonCommunicator = DenonCommunicator()
	var menuViewController: MenuViewController?
	
	// Global Hotkeys
	var hotKeyVolumeUpBig: HotKey?
	var hotKeyVolumeDownBig: HotKey?
	var hotKeyVolumeUpLittle: HotKey?
	var hotKeyVolumeDownLittle: HotKey?
	var hotKeyVolumeWindow: HotKey?
	
	// Status Bar
	let statusItem = NSStatusBar.system.statusItem(withLength: -2)
	let popover = NSPopover()
	var eventMonitor: EventMonitor?
	
	// Touch Bar
	static let volumeUpIdentifier = NSTouchBarItem.Identifier("Volume Up")
	static let volumeDownIdentifier = NSTouchBarItem.Identifier("Volume Down")
	static let volumeSliderIdentifier = NSTouchBarItem.Identifier("Volume Slider")
	static let volumeLabelIdentifier = NSTouchBarItem.Identifier("Volume Label")
	static let controlBarIconIdentifier = NSTouchBarItem.Identifier("Control Bar Icon")
	
	var groupTouchBar: NSTouchBar?
	
	let tbSlider = NSSliderTouchBarItem(identifier: volumeSliderIdentifier)
	var tbLabelTextField: NSTextField = NSTextField(labelWithString: "00")
	
	// MARK: - Func: Touch Bar
	@objc func volumeSlider(sender: NSSliderTouchBarItem) {
		sendVolume(volume: sender.slider.integerValue)
	}
	@objc func presentTouchBarMenu() {
		print("Present")
		NSTouchBar.presentSystemModalFunctionBar(groupTouchBar, systemTrayItemIdentifier: AppDelegate.controlBarIconIdentifier.rawValue)
	}
	
	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? { switch identifier {
	case AppDelegate.volumeUpIdentifier:
		let item = NSCustomTouchBarItem(identifier: identifier)
		item.view = NSButton(title: "Volume Up", target: self, action: #selector(volumeUpBig))
		return item
	case AppDelegate.volumeDownIdentifier:
		let item = NSCustomTouchBarItem(identifier: identifier)
		item.view = NSButton(title: "Volume Down", target: self, action: #selector(volumeDownBig))
		return item
	case AppDelegate.volumeSliderIdentifier:
		return self.tbSlider
	case AppDelegate.volumeLabelIdentifier:
		let item = NSCustomTouchBarItem(identifier: identifier)
		item.view = tbLabelTextField
		return item
	case AppDelegate.controlBarIconIdentifier:
		let item = NSCustomTouchBarItem(identifier: identifier)
		item.view = NSButton(title: "🔈", target: self, action: #selector(presentTouchBarMenu))
		return item
	default:
		print("nil")
		return nil
		}
	}
	
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
	
	func updateUI(volume: Int, reachable: Bool) {
		DispatchQueue.main.async {
			self.tbSlider.slider.integerValue = volume
			self.tbLabelTextField.integerValue = volume
			
			if (volume >= 50) {
				self.tbLabelTextField.textColor = .red
			} else if (volume == 0) {
				self.tbLabelTextField.textColor = .gray
			} else {
				self.tbLabelTextField.textColor = .white
			}
			
			self.menuViewController?.updateUI(volume: volume, reachable: reachable)
		}
	}
	
	func quit() {
		NSApplication.shared.terminate(self)
	}
	
	
	// MARK: - DenonCommunicator Proxies
	
	@discardableResult func sendVolume(volume: Int) -> (successful: Bool, timeInterval: Bool) {
		return denonCommunicator.sendVolume(volume: volume)
	}
	
	func askVolume() -> (volume: Int, successful: Bool, timeInterval: Bool) {
		return denonCommunicator.askVolume()
	}
	
	@objc func volumeUpBig() {
		denonCommunicator.volumeUpBig()
	}
	
	@objc func volumeDownBig() {
		denonCommunicator.volumeDownBig()
	}
	
	func volumeUpLittle() {
		denonCommunicator.volumeUpLittle()
	}
	
	func volumeDownLittle() {
		denonCommunicator.volumeDownLittle()
	}
	
	func setDeviceName(name: String) {
		denonCommunicator.setDeviceName(name: name)
	}
	
	
	// MARK: - Setup
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		
		denonCommunicator.appDelegate = self
		_ = denonCommunicator.askVolume()
		
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
		
		hotKeyVolumeUpBig = HotKey(keyCombo: KeyCombo(key: .upArrow, modifiers: [.control, .option]))
		hotKeyVolumeUpBig?.keyDownHandler = {
			self.volumeUpBig()
		}
		hotKeyVolumeDownBig = HotKey(keyCombo: KeyCombo(key: .downArrow, modifiers: [.control, .option]))
		hotKeyVolumeDownBig?.keyDownHandler = {
			self.volumeDownBig()
		}
		hotKeyVolumeUpLittle = HotKey(keyCombo: KeyCombo(key: .leftArrow, modifiers: [.control, .option]))
		hotKeyVolumeUpLittle?.keyDownHandler = {
			self.volumeDownLittle()
		}
		hotKeyVolumeDownLittle = HotKey(keyCombo: KeyCombo(key: .rightArrow, modifiers: [.control, .option]))
		hotKeyVolumeDownLittle?.keyDownHandler = {
			self.volumeUpLittle()
		}
		hotKeyVolumeWindow = HotKey(keyCombo: KeyCombo(key: .return, modifiers: [.control, .option]))
		hotKeyVolumeWindow?.keyDownHandler = {
			self.togglePopover(sender: self)
		}
		
		
		// Touch Bar
		tbSlider.action = #selector(volumeSlider)
		tbSlider.slider.minValue = Double(denonCommunicator.volumeMinValue)
		tbSlider.slider.maxValue = Double(denonCommunicator.volumeMaxValue)
		
		DFRSystemModalShowsCloseBoxWhenFrontMost(true)
		
		groupTouchBar = NSTouchBar()
		groupTouchBar?.defaultItemIdentifiers = [AppDelegate.volumeDownIdentifier, AppDelegate.volumeUpIdentifier, AppDelegate.volumeSliderIdentifier, AppDelegate.volumeLabelIdentifier]
		groupTouchBar?.delegate = self
		
		let controlBarIcon = NSCustomTouchBarItem(identifier: AppDelegate.controlBarIconIdentifier)
		controlBarIcon.view = NSButton(title: "🔈", target: self, action: #selector(presentTouchBarMenu))
		
		presentTouchBarMenu()
		NSTouchBarItem.addSystemTrayItem(controlBarIcon)
		
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
}
