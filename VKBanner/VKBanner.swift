//
//  VKNotification.swift
//  VKNotification
//
//  Created by Ethan Jackwitz on 1/12/2015.
//

import UIKit
import EZSwiftExtensions

@objc
public enum VKBannerStyle: Int {
	case Success
	case Info
	case Warning
	case Error
	
	var color: UIColor {
		switch self {
		case .Success: return UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0)
		case .Info: return UIColor(red:0.16, green:0.50, blue:0.73, alpha:1.0)
		case .Warning: return UIColor(red:0.95, green:0.61, blue:0.07, alpha:1.0)
		case .Error:   return UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
		}
	}
}

public enum VKDismissal {
	case OnTap
	case After(seconds: Double)
}

public enum Direction {
	case Up
	case Down
}

public struct VKBannerConfiguration {
	let height: Float
	let horizontalPadding: Float
	let verticalPadding: Float
	
	init(height: Float = 40, horizontalPadding: Float = 20, verticalPadding: Float = 10) {
		self.height = height
		self.horizontalPadding = horizontalPadding
		self.verticalPadding = verticalPadding
	}
	
	internal var width: Float {
		return Float(UIScreen.mainScreen().bounds.size.width) - 2 * self.horizontalPadding
	}
}

public struct VKAnimationConfiguration {
	let damping: Float
	let velocity: Float
}

public protocol VKBannerDelegate {
	func userDidDismissBanner()
}

public protocol VKBannerManagerDelegate {
	func show(banner: VKBanner, inView view: UIView)
	func hide(banner: VKBanner, after: Double)
	func remove(banner: VKBanner)
}

public class VKBannerManager: VKBannerManagerDelegate {
	public static let sharedManager = VKBannerManager()
	
	private init() {}
	
	private var banners: [VKBanner] = []
	
	public func show(banner: VKBanner, inView view: UIView) {
		banners.forEach({ $0.move(.Up) })
		
		view.addSubview(banner)
		banner.manager = self
		banner.show()
		
		banners.append(banner)
	}
	
	public func hide(banner: VKBanner, after: Double) {
		guard let bannerIndex = banners.indexOfObject(banner) else { fatalError() }
		
		banners[0..<bannerIndex].forEach({ $0.move(.Down, delay: after) })
		banner.hide(delay: after)
	}
	
	public func remove(banner: VKBanner) {
		banners.removeObject(banner)
	}
	
	
}

public class VKBanner: UIView {
	
	///Used to modify some of the animation properties
	public var animationConfiguration: VKAnimationConfiguration = VKAnimationConfiguration(damping: 0.3, velocity: 0.5)
	public var delegate: VKBannerDelegate?
	public var manager: VKBannerManagerDelegate?
	
	private let style: VKBannerStyle
	private let bannerConfiguration: VKBannerConfiguration
	private let dismissalOptions: VKDismissal
	
	private let label: UILabel
	
	internal let initialFrameForConfiguration: VKBannerConfiguration -> CGRect = { config in
		return CGRect(x: CGFloat(config.horizontalPadding), y: UIScreen.mainScreen().bounds.size.height, width: CGFloat(config.width), height: CGFloat(config.height))
	}
	
	internal let moveFrame: (Direction, from: CGRect, VKBannerConfiguration) -> CGRect = { direction, from, config in
		switch direction {
		case .Up:
			return CGRect(x: from.origin.x, y: from.origin.y - from.height - CGFloat(config.verticalPadding), width: from.width, height: from.height)
		case .Down:
			return CGRect(x: from.origin.x, y: from.origin.y + from.height + CGFloat(config.verticalPadding), width: from.width, height: from.height)
		}
	}
	
	public init(title: String, style: VKBannerStyle, dismissal: VKDismissal = .After(seconds: 2.5), bannerConfiguration: VKBannerConfiguration = VKBannerConfiguration()) {
		self.style = style
		self.bannerConfiguration = bannerConfiguration
		self.dismissalOptions = dismissal
		
		let frame = initialFrameForConfiguration(bannerConfiguration)
		
		let labelFrame = CGRect(origin: CGPoint(x: 10, y: 0), size: CGSize(width: frame.width - 20, height: frame.height))
		
		self.label = UILabel(frame: labelFrame)
		
		self.label.textAlignment = .Center
		self.label.text = title
		self.label.textColor = .whiteColor()
		self.label.lineBreakMode = .ByWordWrapping
		self.label.adjustsFontSizeToFitWidth = true
		if self.label.font.pointSize < 8 {
			self.label.numberOfLines = 2
		}
		
		super.init(frame: frame)
		
		let tapRecognizer = UITapGestureRecognizer()
		tapRecognizer.addTarget(self, action: "didTap")
		self.addGestureRecognizer(tapRecognizer)
		
		self.addSubview(label)
		
		self.layer.backgroundColor = style.color.CGColor
		self.layer.cornerRadius = 3
		self.alpha = 0.0
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func didTap() {
		self.delegate?.userDidDismissBanner()
		
		if let manager = self.manager {
			manager.hide(self, after: 0.0)
		} else {
			self.hide()
		}
	}
	
	public func show(animationDuration: Double = 1.0) {
		UIView.animateWithDuration(
			animationDuration,
			delay: 0.0,
			usingSpringWithDamping: CGFloat(animationConfiguration.damping),
			initialSpringVelocity: CGFloat(animationConfiguration.velocity),
			options: [.BeginFromCurrentState, .AllowUserInteraction],
			animations: {
				self.frame = self.moveFrame(.Up, from: self.frame, self.bannerConfiguration)
				self.alpha = 1.0
			},
			completion: { _ in
				if case let .After(time) = self.dismissalOptions {
					if let manager = self.manager {
						manager.hide(self, after: time)
					} else {
						self.hide(delay: time)
					}
				}
			}
		)
	}
	
	public func hide(duration: Double = 1.0, delay: Double = 0) {
		UIView.animateWithDuration(
			duration,
			delay: delay,
			options: [.BeginFromCurrentState, .AllowUserInteraction],
			animations: {
				self.frame = self.initialFrameForConfiguration(self.bannerConfiguration)
				self.alpha = 0.0
			},
			completion: { _ in
				self.removeFromSuperview()
				self.manager?.remove(self)
			}
		)
	}
	
	internal func move(direction: Direction, duration: Double = 1.0, delay: Double = 0) {
		switch direction {
		case .Up:
			UIView.animateWithDuration(
				duration,
				delay: delay,
				usingSpringWithDamping: CGFloat(animationConfiguration.damping),
				initialSpringVelocity: CGFloat(animationConfiguration.velocity),
				options: [.BeginFromCurrentState, .AllowUserInteraction],
				animations: {
					self.frame = self.moveFrame(direction, from: self.frame, self.bannerConfiguration)
				},
				completion: nil
			)
		case .Down:
			UIView.animateWithDuration(
				duration,
				delay: delay,
				options: [.BeginFromCurrentState, .AllowUserInteraction],
				animations: {
					self.frame = self.moveFrame(direction, from: self.frame, self.bannerConfiguration)
				},
				completion: nil
			)
		}
	}
}
