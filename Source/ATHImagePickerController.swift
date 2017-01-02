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

internal struct Color {
    static let black = UIColor.black
    static let tin = UIColor(hex: 0x7F7F7F)
    static let blue = UIColor(hex: 0x007AFF)
}

internal protocol ATHImagePickerCommiterDelegate: class {
    func commit(item: ATHImagePickerItem)
    func commit(error: ATHImagePickerError?)
}

//
// MARK: - `ATHImagePickerController` public components
//

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
        
        // TODO: Figure out how to work with that within a cocoa pod
        let storyboard = UIStoryboard(name: "ATHImagePickerController", bundle: nil)
        
        var controllers: [UIViewController] = []
        
        if sourceType.contains(.library) {
            let selectionViewController = storyboard.instantiateViewController(withIdentifier: ATHImagePickerSelectionViewController.identifier) as! ATHImagePickerSelectionViewController
            selectionViewController.pageTabBarItem.title = "Photos"
            selectionViewController.pageTabBarItem.titleColor = Color.black
            selectionViewController.pageTabBarItem.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
            selectionViewController.commiterDelegate = self
            
            controllers += [selectionViewController]
        }
        
        if sourceType.contains(.camera) {
            let captureViewController = storyboard.instantiateViewController(withIdentifier: ATHImagePickerCaptureViewController.identifier) as! ATHImagePickerCaptureViewController
            captureViewController.pageTabBarItem.title = "Camera"
            captureViewController.pageTabBarItem.titleColor = Color.tin
            captureViewController.pageTabBarItem.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
            captureViewController.commiterDelegate = self
            
            controllers += [captureViewController]
        }
        
        if sourceType.contains([.camera, .library]) {
            let controller = ATHImagePickerTabBarController(viewControllers: controllers)
            controller.commiterDelegate = self 
            controller.title = "Photo"
            
            setViewControllers([controller], animated: false)
        } else {
            setViewControllers(controllers, animated: false)
        }
    }
    
    // MARK: - ATHImagePickerCommiterDelegate
    
    internal func commit(item: ATHImagePickerItem) {
        pickerDelegate?.imagePickerController(self, didCancelWithItem: item)
    }
    
    internal func commit(error: ATHImagePickerError?) {
        pickerDelegate?.imagePickerController(self, didCancelWithError: error)
    }
}
