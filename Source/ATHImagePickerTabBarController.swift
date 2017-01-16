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

open class ATHImagePickerTabBarController: PageTabBarController, StatusBarUpdatable {

    typealias Config = ATHImagePickerStatusBarConfig
    
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
            updateStatusBar(with: ATHImagePickerController.statusBarConfig)
        }
    }
    
    fileprivate var statusBarAnimation: UIStatusBarAnimation = .none {
        didSet {
            updateStatusBar(with: ATHImagePickerController.statusBarConfig)
        }
    }
    
    fileprivate var lastPosition: CGFloat = UIScreen.main.bounds.maxX
    fileprivate var currentIndex: Int = 0
    fileprivate var nextIndex: Int = 0
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

// MARK: - UIPageViewController management

extension ATHImagePickerTabBarController {
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let controller = pendingViewControllers.first, let index = viewControllers.index(of: controller) {
            nextIndex = index
        }
    }
    
    open override func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        super.pageViewController(pageViewController, didFinishAnimating: finished, previousViewControllers: previousViewControllers, transitionCompleted: completed)
        nextIndex = currentIndex
    }
}

// MARK: - UIScrollViewDelegate

extension ATHImagePickerTabBarController {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentIndex = selectedIndex
    }
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        if nextIndex > currentIndex {
            if scrollView.contentOffset.x < lastPosition - (0.9 * scrollView.bounds.width) {
                currentIndex = nextIndex
            }
        } else {
            if scrollView.contentOffset.x > lastPosition + (0.9 * scrollView.bounds.width) {
                currentIndex = nextIndex
            }
        }
        
        let minOffset = scrollView.bounds.width - CGFloat(currentIndex) * scrollView.bounds.width
        let maxOffset = CGFloat(countOfPages - currentIndex) * scrollView.bounds.width
        let bounds = scrollView.bounds
        
        if scrollView.contentOffset.x <= minOffset {
            scrollView.contentOffset.x = minOffset
        } else if scrollView.contentOffset.x >= maxOffset {
            scrollView.contentOffset.x = maxOffset
        }
        
        scrollView.bounds = bounds
        
        lastPosition = scrollView.contentOffset.x
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let minOffset = scrollView.bounds.width - CGFloat(currentIndex) * scrollView.bounds.width
        let maxOffset = CGFloat(countOfPages - currentIndex) * scrollView.bounds.width
        
        let bounds = scrollView.bounds
        if scrollView.contentOffset.x <= minOffset {
            scrollView.contentOffset.x = minOffset
        } else if scrollView.contentOffset.x >= maxOffset {
            scrollView.contentOffset.x = maxOffset
        }
        
        scrollView.bounds = bounds
        
        lastPosition = scrollView.contentOffset.x
    }
}

// MAKR: - Utils

extension ATHImagePickerTabBarController {
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
