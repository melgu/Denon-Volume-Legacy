//
//  RegexString.swift
//  Denon Volume
//
//  Created by Melvin Gundlach on 09.05.17.
//  Copyright © 2017 Melvin Gundlach. All rights reserved.
//

import Foundation

extension String {
	func matchingStrings(regex: String) -> [[String]] {
		guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
		let nsString = self as NSString
		let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
		return results.map { result in
			(0..<result.numberOfRanges).map { result.rangeAt($0).location != NSNotFound
				? nsString.substring(with: result.rangeAt($0))
				: ""
			}
		}
	}
}

//"prefix12 aaa3 prefix45".matchingStrings(regex: "fix([0-9])([0-9])")
//// Prints: [["fix12", "1", "2"], ["fix45", "4", "5"]]
//
//"prefix12".matchingStrings(regex: "(?:prefix)?([0-9]+)")
//// Prints: [["prefix12", "12"]]
//
//"12".matchingStrings(regex: "(?:prefix)?([0-9]+)")
//// Prints: [["12", "12"]], other answers return an empty array here
//
//// Safely accessing the capture of the first match (if any):
//let number = "prefix12suffix".matchingStrings(regex: "fix([0-9]+)su").first?[1]
//// Prints: Optional("12")
