//
//  ATHImagePickerSelectionViewController.swift
//  ATHImagePickerController
//
//  Created by mac on 01/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit
import Material
import ImagePickerKit

open class ATHImagePickerSelectionViewController: UIViewController, SelectionController {
    
    // MARK: - Outlets 
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    
    // MARK: - Static properties
    
    open static let identifier = "ATHImagePickerSelectionViewController"
    
    // MARK: - Properties
    
    open override var prefersStatusBarHidden: Bool {
        return false
    }
    
    public weak var previewController: PreviewController?
    public weak var assetsController: AssetsController?
    
    public var constraint: NSLayoutConstraint {
        return topConstraint
    }
    
    public var floatingView: UIView {
        return topView
    }
    
    public var offset: CGPoint = .zero {
        didSet {
            assetsController?.offset = offset
        }
    }
    
    internal weak var commiterDelegate: ATHImagePickerCommiterDelegate? {
        didSet {
            setupConfig()
        }
    }
    
    fileprivate let handler = ATHNavigationBarHandler()
    
    fileprivate var config: ATHImagePickerPageConfig! {
        didSet {
            handler.setupItem(navigationItem, config: config, ignoreRight: false, leftHandler: { [weak self] in
                self?.commiterDelegate?.commit(item: ATHImagePickerItem(image: nil))
            }) { [weak self] in
                self?.commiterDelegate?.commit(item: ATHImagePickerItem(image: self?.floatingView.snapshot()))
            }
        }
    }
    
    // MARK: - Life cycle 
    
    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pageTabBarItem.titleColor = Color.black
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pageTabBarItem.titleColor = Color.tin
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var embeddedViewController = segue.destination as? EmbededController {
            embeddedViewController.holder = self
            
            if let previewController = embeddedViewController as? PreviewController {
                self.previewController = previewController
            } else if let assetsController = embeddedViewController as? AssetsController {
                self.assetsController = assetsController
            }
        }
    }
    
    // MARK: - Setup utils 
    
    fileprivate func setupConfig() {
        guard let config = commiterDelegate?.commit(configFor: .library) else {
            return
        }
        
        self.config = config
        
        title = config.title
        pageTabBarItem.title = config.title
        pageTabBarItem.titleColor = config.titleColor
        pageTabBarItem.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
    }
    
    // MARK: - SelectionController
    
    public func commit(error: ATHImagePickerError) {
        commiterDelegate?.commit(error: error)
    }
}
