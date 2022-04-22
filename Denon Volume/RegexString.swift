//
//  RegexString.swift
//  Denon Volume
//
//  Created by Melvin Gundlach.
//  Copyright © 2018 Melvin Gundlach. All rights reserved.
//

import Foundation

extension String {
	func matchingStrings(regex: String) -> [[String]] {
		guard let regex = try? NSRegularExpression(pattern: regex, options: []) else { return [] }
		let nsString = NSString(string: self)
		let results  = regex.matches(in: self, options: [], range: NSRange(0..<nsString.length))
		return results.map { result in
			(0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
				? nsString.substring(with: result.range(at: $0))
				: ""
			}
		}
	}
}
