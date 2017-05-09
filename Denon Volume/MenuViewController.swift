//
//  MenuViewController.swift
//  Denon Volume
//
//  Created by Melvin Gundlach on 04.05.17.
//  Copyright © 2017 Melvin Gundlach. All rights reserved.
//

import Cocoa

class MenuViewController: NSViewController {
	
	@IBOutlet weak var deviceField: NSTextField!
	@IBOutlet weak var slider: NSSlider!
	@IBOutlet weak var volumeLabel: NSTextField!
	@IBOutlet weak var volumeTextLabel: NSTextField!
	
	var lastTime = Date()
	
	let appDelegate = NSApplication.shared().delegate as! AppDelegate
	
	@IBAction func quitButton(_ sender: Any) {
		NSApplication.shared().terminate(self)
	}
	
	@IBAction func slider(_ sender: Any) {
		sendVolume(volume: Int(slider.intValue))
	}
	
	// Volume 0-70, return otherwise (40 for testing)
	func sendVolume(volume: Int) {
//		if (volume<0 || volume>70) {
//			print("\(volume) out of range")
//			return
//		}
		
		if (Date().timeIntervalSince(lastTime) < 0.05) {
			return
		} else {
			lastTime = Date()
		}
		
		if (volume >= 50) {
			appDelegate.statusItem.image = NSImage(named: "StatusBarButtonImageRed")
			volumeTextLabel.textColor = NSColor.red
			volumeLabel.textColor = NSColor.red
		} else if (volume == 0) {
			appDelegate.statusItem.image = NSImage(named: "StatusBarButtonImageGray")
			volumeTextLabel.textColor = NSColor.gray
			volumeLabel.textColor = NSColor.gray
		} else {
			appDelegate.statusItem.image = NSImage(named: "StatusBarButtonImage")
			volumeTextLabel.textColor = NSColor.black
			volumeLabel.textColor = NSColor.black
		}
		
		volumeLabel.integerValue = volume
		
		let url = URL(string: "http://\(deviceField.stringValue)/goform/formiPhoneAppVolume.xml?1+-\(80-volume)")
		
		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			guard error == nil else {
				print(error!)
				self.deviceField.textColor = NSColor.red
				return
			}
//			guard let data = data else {
//				print("Data is empty")
//				return
//			}
			
			self.deviceField.textColor = NSColor.black
		}
		
		task.resume()
	}
	
	func askVolume() {
		
		if (Date().timeIntervalSince(lastTime) < 0.05) {
			return
		} else {
			lastTime = Date()
		}
		
		let url = URL(string: "http://\(deviceField.stringValue)/goform/formMainZone_MainZoneXmlStatusLite.xml")
		
		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			guard error == nil else {
				print(error!)
				self.deviceField.textColor = NSColor.red
				return
			}
			guard let data = data else {
				print("Data is empty")
				return
			}
			
			self.deviceField.textColor = NSColor.black
			
			let dataString: String = String(data: data, encoding: String.Encoding.utf8) as String!
			let volume: Int = Int(Float((dataString.matchingStrings(regex: "<MasterVolume><value>-(.*)<\\/value><\\/MasterVolume>").first?[1])!)!)
			
			self.slider.integerValue = 80 - volume
			self.volumeLabel.integerValue = 80 - volume
			
			if (volume >= 50) {
				self.appDelegate.statusItem.image = NSImage(named: "StatusBarButtonImageRed")
				self.volumeTextLabel.textColor = NSColor.red
				self.volumeLabel.textColor = NSColor.red
			} else if (volume == 0) {
				self.appDelegate.statusItem.image = NSImage(named: "StatusBarButtonImageGray")
				self.volumeTextLabel.textColor = NSColor.gray
				self.volumeLabel.textColor = NSColor.gray
			} else {
				self.appDelegate.statusItem.image = NSImage(named: "StatusBarButtonImage")
				self.volumeTextLabel.textColor = NSColor.black
				self.volumeLabel.textColor = NSColor.black
			}
		}
		
		task.resume()
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	override func viewDidAppear() {
		askVolume()
	}
}
