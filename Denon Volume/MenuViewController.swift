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
	
	// MARK: - Functions
	
	// Volume 0-70, return otherwise (40 for testing)
	func sendVolume(volume: Int) {
		let result = appDelegate.sendVolume(deviceName: deviceField.stringValue, volume: volume)
		
		if result.timeInterval {
			self.updateUI(volume: volume, reachable: result.successful)
		}
	}
	
	func askVolume() {
		let result = appDelegate.askVolume(deviceName: deviceField.stringValue)
		
		if result.timeInterval {
			self.updateUI(volume: result.volume, reachable: result.successful)
		}
	}
	
	func updateUI(volume: Int, reachable: Bool) {
		if reachable {
			self.deviceField.textColor = NSColor.black
		} else {
			self.deviceField.textColor = NSColor.red
		}
		
		self.slider.integerValue = volume
		self.volumeLabel.integerValue = volume
		self.colorizeVolumeItems(volume: volume)
	}
	
	func colorizeVolumeItems(volume: Int) {
		if (volume >= 50) {
			self.appDelegate.statusItem.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImageRed"))
			self.volumeTextLabel.textColor = NSColor.red
			self.volumeLabel.textColor = NSColor.red
		} else if (volume == 0) {
			self.appDelegate.statusItem.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImageGray"))
			self.volumeTextLabel.textColor = NSColor.gray
			self.volumeLabel.textColor = NSColor.gray
		} else {
			self.appDelegate.statusItem.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
			self.volumeTextLabel.textColor = NSColor.black
			self.volumeLabel.textColor = NSColor.black
		}
	}
	
	
	// MARK: - Setup
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		appDelegate.setDeviceName(name: deviceField.stringValue)
    }
	
	override func viewWillAppear() {
		askVolume()
	}
}
