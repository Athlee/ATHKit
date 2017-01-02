//
//  ATHImagePickerTabBarController.swift
//  ATHImagePickerController
//
//  Created by mac on 01/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit
import Material

open class ATHImagePickerTabBarController: PageTabBarController {

    // MARK: - Properties 
    
    internal weak var commiterDelegate: ATHImagePickerCommiterDelegate? {
        didSet {
            setupConfig()
        }
    }
    
    fileprivate let handler = ATHNavigationBarHandler()
    fileprivate var config: ATHImagePickerPageConfig! {
        didSet {
            title = config.title
            
            handler.setupItem(navigationItem, config: config, ignoreRight: false, leftHandler: { [weak self] in
                self?.commiterDelegate?.commit(item: ATHImagePickerItem(image: nil))
            }) { [weak self] in
                guard let image = self?.viewControllers.filter({ $0 is SelectionController}).map({ $0 as! SelectionController }).first?.floatingView.snapshot() else {
                    return
                }
                
                self?.commiterDelegate?.commit(item: ATHImagePickerItem(image: image))
            }
        }
    }
    
    // MARK: - Life cycle 
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override open func prepare() {
        super.prepare()
        
        delegate = self
        preparePageTabBar()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Setup utils
    
    fileprivate func setupConfig() {
        guard let config = commiterDelegate?.commit(configFor: []) else {
            return
        }
        
        self.config = config
        
        title = config.title
        pageTabBarItem.title = config.title
        pageTabBarItem.titleColor = config.titleColor
        pageTabBarItem.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
    }
}

extension ATHImagePickerTabBarController {
    fileprivate func preparePageTabBar() {
        pageTabBar.lineColor = .clear
    }
}

extension ATHImagePickerTabBarController: PageTabBarControllerDelegate {
    public func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController) {
        switch viewController {
        case is ATHImagePickerSelectionViewController:
            title = viewController.pageTabBarItem.title
            navigationItem.rightBarButtonItem?.tintColor = Color.blue
            navigationItem.rightBarButtonItem?.isEnabled = true
            
        case is ATHImagePickerCaptureViewController:
            title = viewController.pageTabBarItem.title
            navigationItem.rightBarButtonItem?.tintColor = .clear
            navigationItem.rightBarButtonItem?.isEnabled = false
        default:
            ()
        }
    }
}
