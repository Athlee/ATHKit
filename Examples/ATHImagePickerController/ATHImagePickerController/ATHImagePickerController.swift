//
//  ATHImagePickerNavigationController.swift
//  ATHImagePickerController
//
//  Created by mac on 01/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit

internal extension UIColor {
    convenience init(hex: Int) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / CGFloat(255)
        let green = CGFloat((hex & 0xFF00) >> 8) / CGFloat(255)
        let blue = CGFloat((hex & 0xFF) >> 0) / CGFloat(255)
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

internal struct Color {
    static let black = UIColor.black
    static let tin = UIColor(hex: 0x7F7F7F)
    static let blue = UIColor(hex: 0x007AFF)
}

public struct ATHImagePickerSourceType: OptionSet {
    public static let library = ATHImagePickerSourceType(rawValue: 1 << 0)
    public static let camera = ATHImagePickerSourceType(rawValue: 1 << 1)
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

internal class ATHNavigationBarHandler {
    internal var leftHandler: ((Void) -> Void)?
    internal var rightHandler: ((Void) -> Void)?
    
    internal func setupItem(_ item: UINavigationItem, ignoreRight: Bool = false, leftHandler: ((Void) -> Void)?, rightHandler: ((Void) -> Void)?) {
        self.leftHandler = leftHandler
        self.rightHandler = rightHandler
        
        if !ignoreRight {
            let rightItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(ATHNavigationBarHandler.didPressRightButton(_:)))
            item.rightBarButtonItem = rightItem
        }
        
        let leftItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ATHNavigationBarHandler.didPressLeftButton(_:)))
        item.leftBarButtonItem = leftItem
        item.leftBarButtonItem?.tintColor = .black 
    }
    
    @IBAction internal func didPressLeftButton(_ sender: Any) {
        leftHandler?()
    }
    
    @IBAction internal func didPressRightButton(_ sender: Any) {
        rightHandler?()
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

internal protocol ATHImagePickerCommiterDelegate: class {
    func commit(item: ATHImagePickerItem)
    func commit(error: ATHImagePickerError?)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
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
