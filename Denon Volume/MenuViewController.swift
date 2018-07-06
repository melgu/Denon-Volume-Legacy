//
//  MenuViewController.swift
//  Denon Volume
//
//  Created by Melvin Gundlach on 04.05.17.
//  Copyright © 2017 Melvin Gundlach. All rights reserved.
//

import Cocoa

class MenuViewController: NSViewController {
	
	// MARK: - Variables
	
	@IBOutlet weak var deviceField: NSTextField!
	@IBOutlet weak var slider: NSSlider!
	@IBOutlet weak var volumeLabel: NSTextField!
	@IBOutlet weak var volumeTextLabel: NSTextField!
	@IBOutlet weak var onOffToggle: NSButton!
	
	let appDelegate = NSApplication.shared.delegate as! AppDelegate
	
	@IBAction func deviceFieldTextChange(_ sender: Any) {
		print(deviceField.stringValue)
		appDelegate.setDeviceName(name: deviceField.stringValue)
	}
	
	@IBAction func quitButton(_ sender: Any) {
		appDelegate.quit()
	}
	
	@IBAction func slider(_ sender: Any) {
		sendVolume(volume: Int(slider.intValue))
	}
	
	@IBAction func onOffToggle(_ sender: Any) {
		let state = (onOffToggle.state.rawValue == 1) ? true : false
		appDelegate.sendPowerState(state: state)
	}
	
	// MARK: - Functions
	
	// Volume 0-70, return otherwise (40 for testing)
	func sendVolume(volume: Int) {
		appDelegate.setDeviceName(name: deviceField.stringValue)
		appDelegate.sendVolume(volume: volume)
	}
	
	func askVolume() {
		appDelegate.setDeviceName(name: deviceField.stringValue)
		appDelegate.askVolume()
	}
	
	func updateUI(volume: Int, state: Bool, reachable: Bool) {
		if reachable {
			deviceField.textColor = NSColor.black
		} else {
			deviceField.textColor = NSColor.red
		}
		
		if state {
			onOffToggle.state = NSControl.StateValue(1)
			slider.isEnabled = true
			volumeTextLabel.stringValue = "Volume"
			slider.integerValue = volume
			volumeLabel.integerValue = volume
			colorizeVolumeItems(volume: volume)
		} else {
			onOffToggle.state = NSControl.StateValue(0)
			slider.isEnabled = false
			volumeTextLabel.stringValue = "Offline"
			slider.integerValue = 0
			volumeLabel.integerValue = 0
			volumeLabel.textColor = NSColor.gray
			volumeTextLabel.textColor = NSColor.gray
		}
	}
	
	func colorizeVolumeItems(volume: Int) {
		if (volume >= 50) {
			self.appDelegate.statusItem.button?.image = NSImage(named: NSImage.Name("StatusBarButtonImageRed"))
			self.volumeTextLabel.textColor = .red
			self.volumeLabel.textColor = .red
		} else if (volume == 0) {
			self.appDelegate.statusItem.button?.image = NSImage(named: NSImage.Name("StatusBarButtonImageGray"))
			self.volumeTextLabel.textColor = .gray
			self.volumeLabel.textColor = .gray
		} else {
			self.appDelegate.statusItem.button?.image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
			self.volumeTextLabel.textColor = .black
			self.volumeLabel.textColor = .black
		}
	}
	
	
	// MARK: - Setup
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		appDelegate.setDeviceName(name: deviceField.stringValue)
		appDelegate.menuViewController = self
    }
	
	override func viewWillAppear() {
		askVolume()
	}
}
