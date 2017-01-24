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
  
  var isScrollEnabled: Bool { get set }
  var isTracking: Bool { get }
  
  func commit(error: ATHImagePickerError)
}

internal protocol EmbededController {
  var holder: SelectionController! { get set }
}

public protocol PreviewController: FloatingViewLayout {
  var image: UIImage? { get set }
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
  
  fileprivate var isZooming = false
  fileprivate var isChecking = false
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
}

// MARK: - IBActions

extension ATHImagePickerPreviewViewController {
  @IBAction func didRecognizeTap(_ rec: UITapGestureRecognizer) {
    if state == .folded {
      restore(view: holder.floatingView, to: .unfolded, animated: true)
    }
  }
  
  @IBAction func didRecognizeMainPan(_ rec: UIPanGestureRecognizer) {
    guard !holder.isTracking else { return }
    
    let location = rec.location(in: navigationController?.view)
    if holder.floatingView.frame.contains(location) {
      holder.isScrollEnabled = false
    } else {
      holder.isScrollEnabled = true
    }
    
    if rec.state == .ended || rec.state == .cancelled {
      holder.isScrollEnabled = true
    }
    
    guard !isZooming else { return }
    
    if state == .unfolded {
      allowPanOutside = false
    }
    
    receivePanGesture(recognizer: rec, with: holder.floatingView)
    
    updatePhotoCollectionViewScrolling()
  }
  
  @IBAction func didRecognizeCheckPan(_ rec: UIPanGestureRecognizer) {
    guard !isZooming && !holder.isTracking else { return }
    allowPanOutside = true
  }
}

// MARK: - Utils

extension ATHImagePickerPreviewViewController {
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
  
  fileprivate func updateCropViewScrolling() {
    if state == .moved {
      delegate.isEnabled = false
    } else {
      delegate.isEnabled = true
    }
  }
}

// MARK: - FloatingViewLayout

extension ATHImagePickerPreviewViewController {
  public func prepareForMovement() {
    updateCropViewScrolling()
  }
  
  public func didEndMoving() {
    updateCropViewScrolling()
  }
}

// MARK: - Cropable

extension ATHImagePickerPreviewViewController {
  public func willZoom() {
    isZooming = true
  }
  
  public func willEndZooming() {
    isZooming = false
  }
}

// MARK: - UIGestureRecognizerDelegate

extension ATHImagePickerPreviewViewController: UIGestureRecognizerDelegate {
  open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}
