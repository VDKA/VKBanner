//
//  ViewController.swift
//  VKBannerExample
//
//  Created by Ethan Jackwitz on 03/12/2015.
//  Copyright © 2015 Ethan Jackwitz. All rights reserved.
//

import UIKit
import VKBanner

class ViewController: UIViewController {

	let bannerFactory: VKNewBM = {
		//Perform config
	}()


	@IBAction func didPressSuccess(sender: AnyObject) {
		let banner = VKBanner(title: "Some Success Message", style: .Success)
		VKBannerManager.sharedManager.show(banner, inView: self.view)
	}

	@IBAction func didPressInfo(sender: AnyObject) {
		let banner = VKBanner(title: "Some Info Message", style: .Info)
		VKBannerManager.sharedManager.show(banner, inView: self.view)
	}

	@IBAction func didPressWarning(sender: AnyObject) {
		let banner = VKBanner(title: "Some Warning Message", style: .Warning)
		VKBannerManager.sharedManager.show(banner, inView: self.view)
	}

	@IBAction func didPressError(sender: AnyObject) {
		let banner = VKBanner(title: "Some Error Message", style: .Error, dismissal: .OnTap)
		VKBannerManager.sharedManager.show(banner, inView: self.view)
	}

}

