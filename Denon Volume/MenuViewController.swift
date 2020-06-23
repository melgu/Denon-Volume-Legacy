//
//  MenuViewController.swift
//  Denon Volume
//
//  Created by Melvin Gundlach.
//  Copyright © 2018 Melvin Gundlach. All rights reserved.
//

import Cocoa

class MenuViewController: NSViewController {
	
	// MARK: - Variables
	
	@IBOutlet weak var deviceField: NSTextField!
	@IBOutlet weak var slider: NSSlider!
	@IBOutlet weak var volumeLabel: NSTextField!
	@IBOutlet weak var volumeTextLabel: NSTextField!
	@IBOutlet weak var onOffToggle: NSButton!
	
	weak var appDelegate = NSApplication.shared.delegate as? AppDelegate
	
	@IBAction func deviceFieldTextChange(_ sender: Any) {
		print(deviceField.stringValue)
		appDelegate?.setDeviceName(name: deviceField.stringValue)
		fetchVolume()
	}
	
	@IBAction func quitButton(_ sender: Any) {
		appDelegate?.quit()
	}
	
	@IBAction func slider(_ sender: Any) {
		sendVolume(volume: Int(slider.intValue))
	}
	
	@IBAction func onOffToggle(_ sender: Any) {
		let state = (onOffToggle.state.rawValue == 1) ? true : false
		appDelegate?.sendPowerState(state: state)
	}
	
	// MARK: - Functions
	
	// Volume 0-70, return otherwise (40 for testing)
	func sendVolume(volume: Int) {
		appDelegate?.setDeviceName(name: deviceField.stringValue)
		appDelegate?.sendVolume(volume: volume)
	}
	
	func fetchVolume() {
		appDelegate?.setDeviceName(name: deviceField.stringValue)
		appDelegate?.fetchVolume()
	}
	
	func updateUI(volume: Int, state: Bool, reachable: Bool) {
		if reachable {
			deviceField.textColor = NSColor.black
			onOffToggle.isEnabled = true
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
				colorizeVolumeItems(volume: 0)
			}
		} else {
			deviceField.textColor = NSColor.red
			
			onOffToggle.state = NSControl.StateValue(0)
			onOffToggle.isEnabled = false
			slider.isEnabled = false
			volumeTextLabel.stringValue = "Unreachable"
			slider.integerValue = 0
			volumeLabel.integerValue = 0
			volumeLabel.textColor = NSColor.gray
			colorizeVolumeItems(volume: 0)
		}
		
		
	}
	
	func colorizeVolumeItems(volume: Int) {
		if volume >= 50 {
			self.appDelegate?.statusItem.button?.image = NSImage(named: NSImage.Name("StatusBarButtonImageRed"))
			self.volumeTextLabel.textColor = .red
			self.volumeLabel.textColor = .red
		} else if volume == 0 {
			self.appDelegate?.statusItem.button?.image = NSImage(named: NSImage.Name("StatusBarButtonImageGray"))
			self.volumeTextLabel.textColor = .gray
			self.volumeLabel.textColor = .gray
		} else {
			self.appDelegate?.statusItem.button?.image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
			self.volumeTextLabel.textColor = .black
			self.volumeLabel.textColor = .black
		}
	}
	
	
	// MARK: - Setup
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		appDelegate?.setDeviceName(name: deviceField.stringValue)
		appDelegate?.menuViewController = self
    }
	
	override func viewWillAppear() {
		fetchVolume()
	}
}
