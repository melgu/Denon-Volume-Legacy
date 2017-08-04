//
//  MenuViewController.swift
//  Denon Volume
//
//  Created by Melvin Gundlach on 04.05.17.
//  Copyright © 2017 Melvin Gundlach. All rights reserved.
//

import Cocoa
import HotKey

class MenuViewController: NSViewController {
	
	// MARK: - Variables
	
	@IBOutlet weak var deviceField: NSTextField!
	@IBOutlet weak var slider: NSSlider!
	@IBOutlet weak var volumeLabel: NSTextField!
	@IBOutlet weak var volumeTextLabel: NSTextField!
	
	var lastTime = Date()
	
	let appDelegate = NSApplication.shared.delegate as! AppDelegate
	
	@IBAction func quitButton(_ sender: Any) {
		NSApplication.shared.terminate(self)
	}
	
	@IBAction func slider(_ sender: Any) {
		sendVolume(volume: Int(slider.intValue))
	}
	
	let hotKeyVolumeUp = HotKey(key: .comma, modifiers: [.control, .option])
	let hotKeyVolumeDown = HotKey(key: .period, modifiers: [.control, .option])
	
	// MARK: - Functions
	
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
		
		colorizeVolumeItems(volume: volume)
		
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
			
			DispatchQueue.main.async {
				self.deviceField.textColor = NSColor.black
			}
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
			
			DispatchQueue.main.async {
				self.deviceField.textColor = NSColor.black
			}
			
			let dataString: String = String(data: data, encoding: String.Encoding.utf8) as String!
			let volume: Int = 80 - Int(Float((dataString.matchingStrings(regex: "<MasterVolume><value>-(.*)<\\/value><\\/MasterVolume>").first?[1])!)!)
			
			DispatchQueue.main.async {
				self.slider.integerValue = volume
				self.volumeLabel.integerValue = volume
			}
			
			self.colorizeVolumeItems(volume: volume)
		}
		
		task.resume()
	}
	
	func colorizeVolumeItems(volume: Int) {
		DispatchQueue.main.async {
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
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	override func viewDidAppear() {
		askVolume()
	}
}
