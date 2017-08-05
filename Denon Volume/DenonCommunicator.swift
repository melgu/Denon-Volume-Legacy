//
//  DenonCommunicator.swift
//  Denon Volume
//
//  Created by Melvin Gundlach on 05.08.17.
//  Copyright © 2017 Melvin Gundlach. All rights reserved.
//

import Foundation

public class DenonCommunicator {
	
	// MARK: - Variables
	
	let volumeMinValue = 0
	let volumeMaxValue = 70
	
	var initDone = false
	
	var deviceName = "Denon-AVR"
	var lastTimeSend = Date()
	var lastTimeReceive = Date()
	var lastVolume = 0 {
		didSet(newValue) {
			if newValue < volumeMinValue {
				lastVolume = volumeMinValue
			} else if volumeMaxValue < newValue {
				lastVolume = volumeMaxValue
			}
		}
	}
	
	
	// MARK: - Functions
	
	func volumeUp() {
		let result = askVolume(deviceName: deviceName)
		
		if result.successful && result.timeInterval {
			sendVolume(deviceName: deviceName, volume: lastVolume+5)
		}
	}
	
	func volumeDown() {
		print("Down")
		
		let result = askVolume(deviceName: deviceName)
		
		if result.successful && result.timeInterval {
			sendVolume(deviceName: deviceName, volume: lastVolume-5)
		}
	}
	
	
	// Volume 0-70, return otherwise (40 for testing)
	// successful: Connection to AVR successful
	// timeInterval: 'false' if too short after previous execution
	@discardableResult func sendVolume(deviceName: String, volume: Int) -> (successful: Bool, timeInterval: Bool) {
		if (Date().timeIntervalSince(lastTimeSend) < 0.05) {
			return (true, false)
		} else {
			lastTimeSend = Date()
		}
		
		//updateUI(volume: volume, reachable: true)
		
		let url = URL(string: "http://\(deviceName)/goform/formiPhoneAppVolume.xml?1+-\(80-volume)")
		var successful = true
		
		let semaphore = DispatchSemaphore(value: 0)
		
		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			guard error == nil else {
				//print(error!)
				//self.updateUI(volume: volume, reachable: false)
				successful = false
				return
			}
			
			self.lastVolume = volume
			//self.updateUI(volume: volume, reachable: true)
			semaphore.signal()
		}
		
		task.resume()
		semaphore.wait()
		
		return (successful, true)
	}
	
	// successful: Connection to AVR successful
	// timeInterval: 'false' if too short after previous execution
	@discardableResult func askVolume(deviceName: String) -> (volume: Int, successful: Bool, timeInterval: Bool) {
		
		if (Date().timeIntervalSince(lastTimeReceive) < 0.05) {
			return (lastVolume, true, false)
		} else {
			lastTimeReceive = Date()
		}
		
		let url = URL(string: "http://\(deviceName)/goform/formMainZone_MainZoneXmlStatusLite.xml")
		var successful = true
		
		let semaphore = DispatchSemaphore(value: 0)
		
		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			guard error == nil else {
				//print(error!)
				//self.updateUI(volume: self.lastVolume, reachable: false)
				successful = false
				return
			}
			guard let data = data else {
				print("Data is empty")
				successful = false
				return
			}
			
			let dataString: String = String(data: data, encoding: String.Encoding.utf8) as String!
			self.lastVolume = 80 - Int(Float((dataString.matchingStrings(regex: "<MasterVolume><value>-(.*)<\\/value><\\/MasterVolume>").first?[1])!)!)
			
			//self.updateUI(volume: self.lastVolume, reachable: true)
			semaphore.signal()
		}
		
		task.resume()
		semaphore.wait()
		
		return (lastVolume, successful, true)
	}
}

