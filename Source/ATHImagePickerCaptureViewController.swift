//
//  ATHImagePickerCaptureViewController.swift
//  ATHImagePickerController
//
//  Created by mac on 01/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit
import Material
import AVFoundation
import ImagePickerKit

final public class ATHImagePickerCaptureViewController: UIViewController, PhotoCapturable, StatusBarUpdatable {
  
  typealias Config = ATHImagePickerStatusBarConfig
  
  // MARK: - Outlets
  
  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var flashButton: UIButton!
  @IBOutlet weak var switchButton: UIButton!
  
  // MARK: - Capturable properties
  
  public var session: AVCaptureSession?
  
  public var device: AVCaptureDevice? {
    didSet {
      guard let device = device else { return }
      if !device.hasFlash {
        flashButton.isHidden = true
      }
    }
  }
  
  public var videoInput: AVCaptureDeviceInput?
  public var imageOutput: AVCaptureStillImageOutput?
  
  public var focusView: UIView?
  
  lazy public var previewViewContainer: UIView = {
    return self.cameraView
  }()
  
  public var captureNotificationObserver: CaptureNotificationObserver<ATHImagePickerCaptureViewController>?
  
  // MARK: Properties
  
  public static let identifier = "ATHImagePickerCaptureViewController"
  
  open override var prefersStatusBarHidden: Bool {
    return isStatusBarHidden
  }
  
  open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return statusBarAnimation
  }
  
  fileprivate var flashMode: AVCaptureFlashMode = .on {
    didSet {
      let bundle = Bundle(for: self.classForCoder)
      
      switch flashMode {
      case .on:
        let image = /*config.assets?.flashOnImage ??*/
          UIImage(named: "Flash", in: bundle, compatibleWith: nil)
        
        flashButton.setImage(image, for: .normal)
        
      case .off:
        let image = /*config.assets?.flashOffImage ??*/
          UIImage(named: "FlashOff", in: bundle, compatibleWith: nil)
        
        flashButton.setImage(image, for: .normal)
        
      case .auto:
        let image = /*config.assets?.flashAutoImage ??*/
          UIImage(named: "FlashAuto", in: bundle, compatibleWith: nil)
        
        flashButton.setImage(image, for: .normal)
      }
      
      setFlashMode(flashMode)
    }
  }
  
  fileprivate var queue = OperationQueue()
  
  internal weak var commiterDelegate: ATHImagePickerCommiterDelegate? {
    didSet {
      setupConfig()
    }
  }
  
  fileprivate let handler = ATHNavigationBarHandler()
  
  fileprivate var config: ATHImagePickerPageConfig! {
    didSet {
      handler.setupItem(navigationItem, config: config, ignoreRight: true, leftHandler: { [weak self] in
        self?.commiterDelegate?.commit(item: ATHImagePickerItem(image: nil))
        }, rightHandler: nil)
    }
  }
  
  fileprivate var isStatusBarHidden: Bool = false {
    didSet {
      updateStatusBar(with: config.statusBarConfig)
    }
  }
  
  fileprivate var statusBarAnimation: UIStatusBarAnimation = .none {
    didSet {
      updateStatusBar(with: config.statusBarConfig)
    }
  }
  
  // MARK: - Life cycle
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    queue.addOperation {
      self.prepareForCapturing()
      self.setFlashMode(self.flashMode)
    }
    
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ATHImagePickerCaptureViewController.recognizedTapGesture(_:)))
    previewViewContainer.addGestureRecognizer(tapRecognizer)
  }
  
  override public func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    reloadPreview(previewViewContainer)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    reloadPreview(previewViewContainer)
    pageTabBarItem.titleColor = config.titleColor
  }
  
  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    pageTabBarItem.titleColor = config.titleInactiveColor
  }
  
  // MARK: - Setup utils
  
  fileprivate func setupConfig() {
    guard let config = commiterDelegate?.commit(configFor: .camera) else {
      return
    }
    
    self.config = config
    
    pageTabBarItem.title = config.title
    pageTabBarItem.titleColor = view.window != nil ? config.titleColor : config.titleInactiveColor
    pageTabBarItem.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
    
    isStatusBarHidden = config.statusBarConfig.isStatusBarHidden
    statusBarAnimation = config.statusBarConfig.statusBarAnimation
    
    let bundle = Bundle(for: self.classForCoder)
    let image = /*config.assets?.switchCameraIcon ??*/
      UIImage(named: "FlipCamera", in: bundle, compatibleWith: nil)
    switchButton.setImage(image, for: .normal)
  }
  
  
  // MARK: - IBActions
  
  @IBAction func recognizedTapGesture(_ rec: UITapGestureRecognizer) {
    let point = rec.location(in: previewViewContainer)
    focus(at: point)
  }
  
  @IBAction func didPressCapturePhoto(_ sender: AnyObject) {
    captureStillImage { image in
      self.commiterDelegate?.commit(item: ATHImagePickerItem(image: image))
    }
  }
  
  @IBAction func didPressFlipButton(_ sender: AnyObject) {
    flipCamera()
  }
  
  @IBAction func didPressFlashButton(_ sender: AnyObject) {
    switch flashMode {
    case .auto:
      flashMode = .on
    case .on:
      flashMode = .off
    case .off:
      flashMode = .auto
    }
  }
}
