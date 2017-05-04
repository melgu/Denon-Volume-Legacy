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
	
	var lastTime = Date()
	
	@IBAction func quitButton(_ sender: Any) {
		NSApplication.shared().terminate(self)
	}
	
	@IBAction func slider(_ sender: Any) {
		sendRestRequest(volume: Int(slider.intValue))
	}
	
	// Volume 0-70, return otherwise (40 for testing)
	func sendRestRequest(volume: Int) {
//		if (volume<0 || volume>70) {
//			print("\(volume) out of range")
//			return
//		}
		
		if (Date().timeIntervalSince(lastTime) < 0.05) {
			return
		} else {
			lastTime = Date()
		}
		
		volumeLabel.integerValue = volume
		
		let url = URL(string: "http://\(deviceField.stringValue)/goform/formiPhoneAppVolume.xml?1+-\(80-volume)")
		
		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			guard error == nil else {
				print(error!)
				return
			}
			guard let data = data else {
				print("Data is empty")
				return
			}
			
			print(data)
		}
		
		task.resume()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
