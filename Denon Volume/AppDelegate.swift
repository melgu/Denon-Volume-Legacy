//
//  AppDelegate.swift
//  Denon Volume
//
//  Created by Melvin Gundlach.
//  Copyright © 2018 Melvin Gundlach. All rights reserved.
//

import Cocoa
import HotKey
import UpdateNotification

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTouchBarDelegate {
	
	// MARK: - Variables
	
	// Objects
	let denonCommunicator = DenonCommunicator()
	var menuViewController: MenuViewController?
	let updateNotification = UpdateNotification(feedUrl: URL(string: "http://www.melvin-gundlach.de/apps/app-feeds/Denon-Volume.json")!)
	
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
	var groupTouchBar: NSTouchBar?
	
	var tbControlStripButton = NSButton(title: "00", target: self, action: #selector(presentTouchBarMenu))
	let tbSlider = NSSliderTouchBarItem(identifier: .volumeSliderIdentifier)
	var tbLabelTextField: NSTextField = NSTextField(labelWithString: "00")
	
	// MARK: - Func: Touch Bar
	@objc func volumeSlider(sender: NSSliderTouchBarItem) {
		sendVolume(volume: sender.slider.integerValue)
	}
	@objc func presentTouchBarMenu() {
		print("Present")
		fetchVolume()
		NSTouchBar.presentSystemModalTouchBar(groupTouchBar, systemTrayItemIdentifier: .controlBarIconIdentifier)
		DFRElementSetControlStripPresenceForIdentifier(.controlBarIconIdentifier, true)
	}
	
	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
	
		switch identifier {
		case .volumeUpIdentifier:
			let item = NSCustomTouchBarItem(identifier: identifier)
			item.view = NSButton(title: "Volume Up", target: self, action: #selector(volumeUpBig))
			return item
		case .volumeDownIdentifier:
			let item = NSCustomTouchBarItem(identifier: identifier)
			item.view = NSButton(title: "Volume Down", target: self, action: #selector(volumeDownBig))
			return item
		case .volumeSliderIdentifier:
			return self.tbSlider
		case .volumeLabelIdentifier:
			let item = NSCustomTouchBarItem(identifier: identifier)
			item.view = tbLabelTextField
			return item
		case .controlBarIconIdentifier:
			let item = NSCustomTouchBarItem(identifier: identifier)
			item.view = NSButton(title: "🔈", target: self, action: #selector(presentTouchBarMenu))
			return item
		default:
			print("nil")
			return nil
		}
	}
	
	// MARK: - Func: Popover
	
	func showPopover() {
		print("Start showPopover")
		if let button = statusItem.button {
			print("showPopover Inside Button")
			popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
		}
		print("showPopover Button done")
		
		eventMonitor?.start()
	}
	
	func closePopover() {
		popover.performClose(nil)
		
		eventMonitor?.stop()
	}
	
	@objc func togglePopover() {
		if popover.isShown {
			closePopover()
		} else {
			showPopover()
		}
	}
	
	
	// MARK: - Func: Other
	
	func updateUI(volume: Int, state: Bool, reachable: Bool) {
		DispatchQueue.main.async {
			// Touch Bar
			
			self.tbSlider.slider.integerValue = volume
			self.tbLabelTextField.integerValue = volume
			
			if !reachable {
				self.tbSlider.slider.integerValue = 0
				self.tbLabelTextField.stringValue = "Unreachable"
				self.tbLabelTextField.textColor = .red
				let style = NSMutableParagraphStyle()
				style.alignment = .center
				self.tbControlStripButton.attributedTitle = NSMutableAttributedString(string: "Unreachable", attributes: [NSAttributedString.Key.foregroundColor: NSColor.red, NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15)])
			} else if !state {
				self.tbSlider.slider.integerValue = 0
				self.tbLabelTextField.stringValue = "Offline"
				self.tbLabelTextField.textColor = .gray
				let style = NSMutableParagraphStyle()
				style.alignment = .center
				self.tbControlStripButton.attributedTitle = NSMutableAttributedString(string: "Offline", attributes: [NSAttributedString.Key.foregroundColor: NSColor.gray, NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15)])
			} else if volume >= 50 {
				self.tbLabelTextField.textColor = .red
				let style = NSMutableParagraphStyle()
				style.alignment = .center
				self.tbControlStripButton.attributedTitle = NSMutableAttributedString(string: "\(volume)", attributes: [NSAttributedString.Key.foregroundColor: NSColor.red, NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15)])
			} else if volume == 0 {
				self.tbLabelTextField.textColor = .gray
				let style = NSMutableParagraphStyle()
				style.alignment = .center
				self.tbControlStripButton.attributedTitle = NSMutableAttributedString(string: "\(volume)", attributes: [NSAttributedString.Key.foregroundColor: NSColor.gray, NSAttributedString.Key.paragraphStyle: style, NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15)])
			} else {
				self.tbLabelTextField.textColor = .white
				self.tbControlStripButton.title = "\(volume)"
			}
			
			// Menu Bar Window
			self.menuViewController?.updateUI(volume: volume, state: state, reachable: reachable)
		}
	}
	
	func quit() {
		NSApplication.shared.terminate(self)
	}
	
	
	// MARK: - DenonCommunicator Proxies
	
	func sendPowerState(state: Bool) {
		denonCommunicator.sendPowerState(state: state)
	}
	
	@discardableResult func sendVolume(volume: Int) -> (successful: Bool, timeInterval: Bool) {
		return denonCommunicator.sendVolume(volume: volume)
	}
	
	@discardableResult func fetchVolume() -> (volume: Int, successful: Bool, timeInterval: Bool) {
		return denonCommunicator.fetchVolume()
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
	
	func setGlobalHotKeys() {
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
			self.togglePopover()
		}
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		
		denonCommunicator.appDelegate = self
		
		// Create Menu Bar Icon/Button
		if let button = statusItem.button {
			let mbIcon = NSImage(named: NSImage.Name("StatusBarButtonImage"))
			mbIcon?.isTemplate = true // best for dark mode
			button.image = mbIcon
			button.action = #selector(togglePopover)
		}
		
		popover.contentViewController = MenuViewController(nibName: NSNib.Name("MenuViewController"), bundle: nil)
		
		eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [unowned self] _ in
			if self.popover.isShown {
				self.closePopover()
			}
		}
		eventMonitor?.start()
		
		
		// Set Global Hotkeys
		setGlobalHotKeys()
		
		
		// Touch Bar
		tbSlider.action = #selector(volumeSlider)
		tbSlider.slider.minValue = Double(denonCommunicator.volumeMinValue)
		tbSlider.slider.maxValue = Double(denonCommunicator.volumeMaxValue)
		
		DFRSystemModalShowsCloseBoxWhenFrontMost(true)
		
		groupTouchBar = NSTouchBar()
		groupTouchBar?.defaultItemIdentifiers = [.volumeDownIdentifier, .volumeUpIdentifier, .volumeSliderIdentifier, .volumeLabelIdentifier]
		groupTouchBar?.delegate = self
		
		let controlBarIcon = NSCustomTouchBarItem(identifier: .controlBarIconIdentifier)
		controlBarIcon.view = tbControlStripButton
		
		print("Before showPopover")
		showPopover()
		print("showPopover finished")
		presentTouchBarMenu()
		print("presentTouchBarMenu finished")
		NSTouchBarItem.addSystemTrayItem(controlBarIcon)
		NSTouchBar.minimizeSystemModalTouchBar(groupTouchBar)
		print("Touch Bar finished")
		
		if updateNotification.checkForUpdates() {
			updateNotification.showNewVersionView()
		}
		print("applicationDidFinishLaunching finished")
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
}

extension NSTouchBarItem.Identifier {
	static let volumeUpIdentifier = NSTouchBarItem.Identifier("com.melgu.Denon-Volume.volumeUp")
	static let volumeDownIdentifier = NSTouchBarItem.Identifier("com.melgu.Denon-Volume.volumeDown")
	static let volumeSliderIdentifier = NSTouchBarItem.Identifier("com.melgu.Denon-Volume.volumeSlider")
	static let volumeLabelIdentifier = NSTouchBarItem.Identifier("com.melgu.Denon-Volume.volumeLabel")
	static let controlBarIconIdentifier = NSTouchBarItem.Identifier("com.melgu.Denon-Volume.controlBarIcon")
}
