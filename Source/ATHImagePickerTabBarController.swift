//
//  ATHImagePickerTabBarController.swift
//  ATHImagePickerController
//
//  Created by mac on 01/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit
import Material

extension PageTabBarController {
    open var isTracking: Bool {
        return scrollView?.contentOffset.x != scrollView?.frame.width
    }
}

open class ATHImagePickerTabBarController: PageTabBarController {

    // MARK: - Properties 
    
    open override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return statusBarAnimation
    }
    
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
    
    fileprivate var isStatusBarHidden: Bool = false {
        didSet {
            updateStatusBar()
        }
    }
    
    fileprivate var statusBarAnimation: UIStatusBarAnimation = .none {
        didSet {
            updateStatusBar()
        }
    }
    
    fileprivate var countOfPages: Int {
        return viewControllers.count
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
    
    fileprivate func setupConfig(for sourceType: ATHImagePickerSourceType = []) {
        guard let config = commiterDelegate?.commit(configFor: sourceType) else {
            return
        }
        
        self.config = config
        
        title = config.title
        pageTabBarItem.title = config.title
        pageTabBarItem.titleColor = config.titleColor
        pageTabBarItem.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
        
        isStatusBarHidden = config.isStatusBarHidden
        statusBarAnimation = config.statusBarAnimation
    }
}

// MARK: - UIScrollViewDelegate

extension ATHImagePickerTabBarController {
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        keepInBounds(scrollView: scrollView)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        keepInBounds(scrollView: scrollView)
    }
}

// MAKR: - Utils

extension ATHImagePickerTabBarController {
    fileprivate func updateStatusBar() {
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    fileprivate func keepInBounds(scrollView: UIScrollView) {
        guard !isTabSelectedAnimation else { return }
        
        let offsetX = scrollView.contentOffset.x
        if selectedIndex == 0 && offsetX < scrollView.frame.width {
            scrollView.contentOffset.x = scrollView.frame.width
        } else if selectedIndex == (countOfPages - 1) && offsetX > scrollView.frame.width {
            scrollView.contentOffset.x = scrollView.frame.width
        }
    }
    
    fileprivate func preparePageTabBar() {
        pageTabBar.lineColor = .clear
    }
}

// MARK: - PageTabBarControllerDelegate

extension ATHImagePickerTabBarController: PageTabBarControllerDelegate {
    public func pageTabBarController(pageTabBarController: PageTabBarController, didTransitionTo viewController: UIViewController) {
        switch viewController {
        case is ATHImagePickerSelectionViewController:
            setupConfig(for: .library)
            
        case is ATHImagePickerCaptureViewController:
            setupConfig(for: .camera)
            
        default:
            ()
        }
    }
}
