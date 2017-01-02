//
//  ATHImagePickerPreviewViewController.swift
//  ATHImagePickerController
//
//  Created by mac on 01/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit
import ImagePickerKit

public protocol SelectionController: class {
    var previewController: PreviewController? { get set }
    var assetsController: AssetsController? { get set }
    
    var constraint: NSLayoutConstraint { get }
    var floatingView: UIView { get }
    var offset: CGPoint { get set }
    
    func commit(error: ATHImagePickerError)
}

internal protocol EmbededController {
    var holder: SelectionController! { get set }
}

public protocol PreviewController: FloatingViewLayout {
    var image: UIImage? { get set }
}

internal extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

open class ATHImagePickerPreviewViewController: UIViewController, EmbededController, PreviewController, Cropable {
    
    // MARK: - Outlets 
    
    @IBOutlet weak var cropContainerView: UIView!
    
    // MARK: FloatingViewLayout properties
    
    open var animationCompletion: ((Bool) -> Void)?
    open var overlayBlurringView: UIView!
    
    open var topConstraint: NSLayoutConstraint {
        return holder.constraint
    }
    
    open var draggingZone: DraggingZone = .some(50)
    
    open var visibleArea: CGFloat = 50
    
    open var previousPoint: CGPoint?
    
    open var state: State {
        if topConstraint.constant == 0 {
            return .unfolded
        } else if topConstraint.constant + holder.floatingView.frame.height == visibleArea {
            return .folded
        } else {
            return .moved
        }
    }
    
    open var allowPanOutside = false
    
    // MARK: - PickerController properties
    
    public var image: UIImage? {
        didSet {
            guard let image = image else { return }
            holder.floatingView.clipsToBounds = true
            addImage(image)
        }
    }
    
    // MARK: - EmbededController properties
    
    internal weak var holder: SelectionController!
    
    // MARK: - Cropable properties
    
    public var cropView = UIScrollView()
    public var childContainerView = UIView()
    public var childView = UIImageView()
    public var linesView = LinesView()
    
    public var topOffset: CGFloat {
        guard let navBar = navigationController?.navigationBar else {
            return 0
        }
        
        return !navBar.isHidden ? navBar.frame.height : 0
    }
    
    lazy var delegate: CropableScrollViewDelegate<ATHImagePickerPreviewViewController> = {
        return CropableScrollViewDelegate(cropable: self)
    }()
    
    // MARK: - Properties 
    
    fileprivate var zooming = false
    fileprivate var checking = false
    fileprivate var addedRecognizers = false
    
    fileprivate var isMoving: Bool = false {
        didSet {
            if isMoving {
                cropView.isScrollEnabled = false
            } else {
                cropView.isScrollEnabled = true
            }
        }
    }
    
    fileprivate var offset: CGFloat = 0 {
        didSet {
            if offset < 0 && state == .moved {
                offset = 0
            }
        }
    }
    
    // MARK: - Life cycle 
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        addCropable(to: cropContainerView)
        cropView.delegate = delegate
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.layoutIfNeeded()
        updateContent()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !addedRecognizers {
            addedRecognizers = true
            addGestureRecognizers()
        }
    }
    
    // MARK: - Utils 
    
    fileprivate func addGestureRecognizers() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ATHImagePickerPreviewViewController.didRecognizeMainPan(_:)))
        parent?.view.addGestureRecognizer(pan)
        pan.delegate = self
        
        let checkPan = UIPanGestureRecognizer(target: self, action: #selector(ATHImagePickerPreviewViewController.didRecognizeCheckPan(_:)))
        holder.floatingView.addGestureRecognizer(checkPan)
        checkPan.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ATHImagePickerPreviewViewController.didRecognizeTap(_:)))
        holder.floatingView.addGestureRecognizer(tap)
    }
    
    fileprivate func updatePhotoCollectionViewScrolling() {
        if state == .moved {
            holder?.offset.y = offset
        } else {
            offset = holder.offset.y
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func didRecognizeTap(_ rec: UITapGestureRecognizer) {
        if state == .folded {
            restore(view: holder.floatingView, to: .unfolded, animated: true)
        }
    }
    
    @IBAction func didRecognizeMainPan(_ rec: UIPanGestureRecognizer) {
        guard !zooming else { return }
        
        if state == .unfolded {
            allowPanOutside = false
        }
        
        receivePanGesture(recognizer: rec, with: holder.floatingView)
        
        updatePhotoCollectionViewScrolling()
    }
    
    @IBAction func didRecognizeCheckPan(_ rec: UIPanGestureRecognizer) {
        guard !zooming else { return }
        
        if state == .moved && rec.state != .ended {
            isMoving = true
        } else {
            isMoving = false
        }
        
        allowPanOutside = true
    }
}

extension ATHImagePickerPreviewViewController: UIGestureRecognizerDelegate {
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
