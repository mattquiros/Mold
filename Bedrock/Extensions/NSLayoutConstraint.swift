//
//  NSLayoutConstraint.swift
//  Bedrock
//
//  Created by Matt Quiros on 4/17/15.
//  Copyright (c) 2015 Matt Quiros. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
	
	class func constraintsWithVisualFormatArray(_ array: [String], metrics: [String: AnyObject]?, views: [String: AnyObject]) -> [NSLayoutConstraint] {
		var constraints = [NSLayoutConstraint]()
		for rule in array {
			constraints.append(contentsOf: self.constraints(withVisualFormat: rule,
																											options: NSLayoutConstraint.FormatOptions(),
																											metrics: metrics,
																											views: views) )
		}
		return constraints
	}
	
}
