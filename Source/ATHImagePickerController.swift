//
//  ATHImagePickerNavigationController.swift
//  ATHImagePickerController
//
//  Created by mac on 01/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit

//
// MARK: - Internal helpers' protocols 
//

internal typealias Color = ATHImagePickerColor

internal protocol StatusBarUpdatable {
    func updateStatusBar()
}

extension StatusBarUpdatable where Self: UIViewController {
    func updateStatusBar() {
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}

//
// MARK: - `ATHImagePickerController` public components
//

public struct ATHImagePickerColor {
    public static let black = UIColor.black
    public static let tin = UIColor(hex: 0x7F7F7F)
    public static let blue = UIColor(hex: 0x007AFF)
}

public protocol ATHImagePickerCommiterDelegate: class {
    func commit(item: ATHImagePickerItem)
    func commit(error: ATHImagePickerError?)
    func commit(configFor sourceType: ATHImagePickerSourceType) -> ATHImagePickerPageConfig
}

public struct ATHImagePickerSourceType: OptionSet {
    public static let library = ATHImagePickerSourceType(rawValue: 1 << 0)
    public static let camera = ATHImagePickerSourceType(rawValue: 1 << 1)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct ATHImagePickerItem {
    public let image: UIImage?
}

public enum ATHImagePickerError {
    case error(String)
}

public protocol ATHImagePickerControllerDelegate: class {
    func imagePickerController(_ picker: ATHImagePickerController, didCancelWithItem item: ATHImagePickerItem)
    func imagePickerController(_ picker: ATHImagePickerController, didCancelWithError error: ATHImagePickerError?)
    func imagePickerController(_ picker: ATHImagePickerController, configFor sourceType: ATHImagePickerSourceType) -> ATHImagePickerPageConfig
}

public struct ATHImagePickerAssets {
    public let switchCameraIcon: UIImage?
    public let flashOnImage: UIImage?
    public let flashOffImage: UIImage?
    public let flashAutoImage: UIImage?
    
    public init(switchCameraIcon: UIImage? = nil,
                flashOnImage: UIImage? = nil,
                flashOffImage: UIImage? = nil,
                flashAutoImage: UIImage? = nil) {
        self.switchCameraIcon = switchCameraIcon
        self.flashOnImage = flashOnImage
        self.flashOffImage = flashOffImage
        self.flashAutoImage = flashAutoImage
    }
}

public struct ATHImagePickerPageConfig {
    public let leftButtonTitle: String
    public let rightButtonTitle: String
    public let leftButtonImage: UIImage?
    public let rightButtonImage: UIImage?
    public let title: String
    public let titleColor: UIColor
    public let titleInactiveColor: UIColor
    public let leftButtonColor: UIColor
    public let rightButtonColor: UIColor
    
    public let isStatusBarHidden: Bool
    public let statusBarAnimation: UIStatusBarAnimation
    
    public let assets: ATHImagePickerAssets?
    
    public init(leftButtonTitle: String,
                rightButtonTitle: String,
                leftButtonImage: UIImage?,
                rightButtonImage: UIImage?,
                title: String,
                titleColor: UIColor,
                titleInactiveColor: UIColor,
                leftButtonColor: UIColor,
                rightButtonColor: UIColor,
                isStatusBarHidden: Bool = false,
                statusBarAnimation: UIStatusBarAnimation = .none,
                assets: ATHImagePickerAssets? = nil) {
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.leftButtonImage = leftButtonImage
        self.rightButtonImage = rightButtonImage
        self.title = title
        self.titleColor = titleColor
        self.titleInactiveColor = titleInactiveColor
        self.leftButtonColor = leftButtonColor
        self.rightButtonColor = rightButtonColor
        
        self.isStatusBarHidden = isStatusBarHidden
        self.statusBarAnimation = statusBarAnimation
        
        self.assets = assets
    }
}

open class ATHImagePickerController: UINavigationController, ATHImagePickerCommiterDelegate {
    // MARK: - Static properties
    open static var selectedImage: UIImage?
    
    // MARK: - Properties
    open override var prefersStatusBarHidden: Bool {
        return true 
    }
    
    open var sourceType: ATHImagePickerSourceType = [.camera]
    open weak var pickerDelegate: ATHImagePickerControllerDelegate?
    
    // MARK: - Life cycle 
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: self.classForCoder)
        let storyboard = UIStoryboard(name: "ATHImagePickerController", bundle: bundle)
        
        var controllers: [UIViewController] = []
        
        if sourceType.contains(.library) {
            let selectionViewController = storyboard.instantiateViewController(withIdentifier: ATHImagePickerSelectionViewController.identifier) as! ATHImagePickerSelectionViewController
            selectionViewController.commiterDelegate = self
            
            controllers += [selectionViewController]
        }
        
        if sourceType.contains(.camera) {
            let captureViewController = storyboard.instantiateViewController(withIdentifier: ATHImagePickerCaptureViewController.identifier) as! ATHImagePickerCaptureViewController
            captureViewController.commiterDelegate = self
            
            controllers += [captureViewController]
        }
        
        if sourceType.contains([.camera, .library]) {
            let controller = ATHImagePickerTabBarController(viewControllers: controllers)
            controller.commiterDelegate = self
            
            setViewControllers([controller], animated: false)
        } else {
            setViewControllers(controllers, animated: false)
        }
    }
    
    // MARK: - Static members 
    
    open static func createdChild(sourceType: ATHImagePickerSourceType, delegate: ATHImagePickerCommiterDelegate) -> UIViewController? {
        let bundle = Bundle(for: ATHImagePickerController.self.classForCoder())
        let storyboard = UIStoryboard(name: "ATHImagePickerController", bundle: bundle)
        
        var controllers: [UIViewController] = []
        
        if sourceType.contains(.library) {
            let selectionViewController = storyboard.instantiateViewController(withIdentifier: ATHImagePickerSelectionViewController.identifier) as! ATHImagePickerSelectionViewController
            selectionViewController.commiterDelegate = delegate
            
            controllers += [selectionViewController]
        }
        
        if sourceType.contains(.camera) {
            let captureViewController = storyboard.instantiateViewController(withIdentifier: ATHImagePickerCaptureViewController.identifier) as! ATHImagePickerCaptureViewController
            captureViewController.commiterDelegate = delegate
            
            controllers += [captureViewController]
        }
        
        if sourceType.contains([.camera, .library]) {
            let controller = ATHImagePickerTabBarController(viewControllers: controllers)
            controller.commiterDelegate = delegate
            
            return controller
        } else {
            return controllers.first
        }
    }
    
    // MARK: - ATHImagePickerCommiterDelegate
    
    public func commit(item: ATHImagePickerItem) {
        pickerDelegate?.imagePickerController(self, didCancelWithItem: item)
    }
    
    public func commit(error: ATHImagePickerError?) {
        pickerDelegate?.imagePickerController(self, didCancelWithError: error)
    }
    
    public func commit(configFor sourceType: ATHImagePickerSourceType) -> ATHImagePickerPageConfig {
        guard let delegate = pickerDelegate else {
            fatalError("Could not load a config from delegate!")
        }
        
        return delegate.imagePickerController(self, configFor: sourceType)
    }
}
