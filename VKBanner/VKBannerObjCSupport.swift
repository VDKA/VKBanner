//
//  VKBannerObjCSupport.swift
//  VKBannerObjCSupport
//
//  Created by Ethan Jackwitz on 1/12/2015.
//

@objc
class VKObjCBannerManager: NSObject {
	static let sharedManager = VKBannerManager.sharedManager
}

public extension VKBanner {
	
	///ObjC Initializer
	public convenience init(title: String, style: VKBannerStyle, dismissalAfter: NSTimeInterval) {
		if dismissalAfter == 0 {
    		self.init(title: title, style: style, dismissal: .OnTap)
		} else {
    		self.init(title: title, style: style, dismissal: .After(seconds: 2.5))
		}
	}
}
