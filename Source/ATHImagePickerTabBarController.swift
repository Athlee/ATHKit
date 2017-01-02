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
    
    internal weak var commiterDelegate: ATHImagePickerCommiterDelegate?
    
    fileprivate let handler = ATHNavigationBarHandler()
    
    // MARK: - Life cycle 
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        handler.setupItem(navigationItem, ignoreRight: false, leftHandler: { [weak self] in
            self?.commiterDelegate?.commit(item: ATHImagePickerItem(image: nil))
        }) { [weak self] in
            guard let image = self?.viewControllers.filter({ $0 is SelectionController}).map({ $0 as! SelectionController }).first?.floatingView.snapshot() else {
                return
            }
            
            self?.commiterDelegate?.commit(item: ATHImagePickerItem(image: image))
        }
    }
    
    override open func prepare() {
        super.prepare()
        
        delegate = self
        preparePageTabBar()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            title = "Photo"
            navigationItem.rightBarButtonItem?.tintColor = Color.blue
            navigationItem.rightBarButtonItem?.isEnabled = true
            
        case is ATHImagePickerCaptureViewController:
            title = "Camera"
            navigationItem.rightBarButtonItem?.tintColor = .clear
            navigationItem.rightBarButtonItem?.isEnabled = false
        default:
            ()
        }
    }
}
