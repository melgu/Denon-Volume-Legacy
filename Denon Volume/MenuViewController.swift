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
		appDelegate.setDeviceName(name: deviceField.stringValue)
		_ = appDelegate.sendVolume(volume: volume)
	}
	
	func askVolume() {
		appDelegate.setDeviceName(name: deviceField.stringValue)
		_ = appDelegate.askVolume()
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
			self.volumeTextLabel.textColor = .red
			self.volumeLabel.textColor = .red
		} else if (volume == 0) {
			self.appDelegate.statusItem.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImageGray"))
			self.volumeTextLabel.textColor = .gray
			self.volumeLabel.textColor = .gray
		} else {
			self.appDelegate.statusItem.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
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
