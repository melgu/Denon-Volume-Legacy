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
	var appDelegate: AppDelegate?
	
	let volumeMinValue = 0
	let volumeMaxValue = 70
	let volumeStepsBig = 3
	let volumeStepsLittle = 1
	
	var initDone = false
	
	var deviceName = "Denon-AVR"
	var lastTimeSend = Date()
	var lastTimeReceive = Date()
	var lastState = false
	var lastVolume = 0
	
	
	// MARK: - Functions
	
	func enforceLastVolumeBoundaries() {
		if lastVolume < volumeMinValue {
			lastVolume = volumeMinValue
		} else if volumeMaxValue < lastVolume {
			lastVolume = volumeMaxValue
		}
	}
	
	func updateUI(volume: Int, state: Bool, reachable: Bool) {
		appDelegate?.updateUI(volume: volume, state: state, reachable: reachable)
	}
	
	func setDeviceName(name: String) {
		deviceName = name
	}
	
	func volumeUpBig() {
		let result = askVolume()
		
		if result.successful && result.timeInterval {
			lastVolume += volumeStepsBig
			enforceLastVolumeBoundaries()
			sendVolume(volume: lastVolume)
		}
	}
	
	func volumeDownBig() {
		let result = askVolume()
		
		if result.successful && result.timeInterval {
			lastVolume -= volumeStepsBig
			enforceLastVolumeBoundaries()
			sendVolume(volume: lastVolume)
		}
	}
	
	func volumeUpLittle() {
		let result = askVolume()
		
		if result.successful && result.timeInterval {
			lastVolume += volumeStepsLittle
			enforceLastVolumeBoundaries()
			sendVolume(volume: lastVolume)
		}
	}
	
	func volumeDownLittle() {
		let result = askVolume()
		
		if result.successful && result.timeInterval {
			lastVolume -= volumeStepsLittle
			enforceLastVolumeBoundaries()
			sendVolume(volume: lastVolume)
		}
	}
	
	
	// Volume 0-70, return otherwise (40 for testing)
	// successful: Connection to AVR successful
	// timeInterval: 'false' if too short after previous execution
	@discardableResult func sendVolume(volume: Int) -> (successful: Bool, timeInterval: Bool) {
		if (Date().timeIntervalSince(lastTimeSend) < 0.05) {
			return (true, false)
		} else {
			lastTimeSend = Date()
		}
		
		let url = URL(string: "http://\(deviceName)/goform/formiPhoneAppVolume.xml?1+-\(80-volume)")
		var successful = true
		
		let semaphore = DispatchSemaphore(value: 0)
		
		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			guard error == nil else {
				print(error!)
				successful = false
				semaphore.signal()
				return
			}
			
			self.lastVolume = volume
			semaphore.signal()
		}
		
		task.resume()
		semaphore.wait()
		
		print(lastVolume)
		self.updateUI(volume: volume, state: lastState, reachable: successful)
		
		return (successful, true)
	}
	
	// successful: Connection to AVR successful
	// timeInterval: 'false' if too short after previous execution
	@discardableResult func askVolume() -> (volume: Int, successful: Bool, timeInterval: Bool) {
		
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
				print(error!)
				successful = false
				semaphore.signal()
				return
			}
			guard let data = data else {
				print("Data is empty")
				successful = false
				semaphore.signal()
				return
			}
			
			let dataString: String = String(data: data, encoding: String.Encoding.utf8) as String!
			let matchedStringState = dataString.matchingStrings(regex: "<Power><value>(.*)<\\/value><\\/Power>").first![1]
			if matchedStringState == "ON" {
				self.lastState = true
			}
			
			var matchedStringVolume = dataString.matchingStrings(regex: "<MasterVolume><value>-(.*)<\\/value><\\/MasterVolume>").first![1]
			if matchedStringVolume == "-" {
				matchedStringVolume = "80"
			}
			self.lastVolume = 80 - Int(Float(matchedStringVolume)!)
			
			semaphore.signal()
		}
		
		task.resume()
		semaphore.wait()
		
		print(lastVolume)
		self.updateUI(volume: self.lastVolume, state: lastState, reachable: successful)
		
		return (lastVolume, successful, true)
	}
	
	func sendPowerState(state: Bool) -> Bool {
		lastState = state
		let power = state ? "PowerOn" : "PowerStandby"
		
		let url = URL(string: "http://\(deviceName)/goform/formiPhoneAppPower.xml?1+\(power)")
		var successful = true
		
		let semaphore = DispatchSemaphore(value: 0)
		
		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			guard error == nil else {
				print(error!)
				successful = false
				semaphore.signal()
				return
			}
			
			semaphore.signal()
		}
		
		task.resume()
		semaphore.wait()
		
		print(lastVolume)
		self.updateUI(volume: lastVolume, state: state, reachable: successful)
		
		return successful
	}
}
