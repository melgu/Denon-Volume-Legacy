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
	
	func updateUI(volume: Int, reachable: Bool) {
		appDelegate?.updateUI(volume: volume, reachable: reachable)
	}
	
	func setDeviceName(name: String) {
		deviceName = name
	}
	
	func volumeUpBig() {
		let result = askVolume()
		
		if result.successful && result.timeInterval {
			sendVolume(volume: lastVolume+volumeStepsBig)
		}
		print(lastVolume)
	}
	
	func volumeDownBig() {
		let result = askVolume()
		
		if result.successful && result.timeInterval {
			sendVolume(volume: lastVolume-volumeStepsBig)
		}
		print(lastVolume)
	}
	
	func volumeUpLittle() {
		let result = askVolume()
		
		if result.successful && result.timeInterval {
			sendVolume(volume: lastVolume+volumeStepsLittle)
		}
		print(lastVolume)
	}
	
	func volumeDownLittle() {
		let result = askVolume()
		
		if result.successful && result.timeInterval {
			sendVolume(volume: lastVolume-volumeStepsLittle)
		}
		print(lastVolume)
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
		
		//updateUI(volume: volume, reachable: true)
		
		let url = URL(string: "http://\(deviceName)/goform/formiPhoneAppVolume.xml?1+-\(80-volume)")
		var successful = true
		
		let semaphore = DispatchSemaphore(value: 0)
		
		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			guard error == nil else {
				//print(error!)
				//self.updateUI(volume: volume, reachable: false)
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
		self.updateUI(volume: volume, reachable: successful)
		
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
				//print(error!)
				//self.updateUI(volume: self.lastVolume, reachable: false)
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
			self.lastVolume = 80 - Int(Float((dataString.matchingStrings(regex: "<MasterVolume><value>-(.*)<\\/value><\\/MasterVolume>").first?[1])!)!)
			
			semaphore.signal()
		}
		
		task.resume()
		semaphore.wait()
		
		print(lastVolume)
		self.updateUI(volume: self.lastVolume, reachable: successful)
		
		return (lastVolume, successful, true)
	}
}
