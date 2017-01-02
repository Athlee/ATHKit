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

final public class ATHImagePickerCaptureViewController: UIViewController, PhotoCapturable {

    // MARK: - Outlets
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var flashButton: UIButton!
    
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
    
    fileprivate var flashMode: AVCaptureFlashMode = .on {
        didSet {
            switch flashMode {
            case .on:
                flashButton.setImage(UIImage(named: "Flash"), for: UIControlState())
            case .off:
                flashButton.setImage(UIImage(named: "FlashOff"), for: UIControlState())
            case .auto:
                flashButton.setImage(UIImage(named: "FlashAuto"), for: UIControlState())
            }
            
            setFlashMode(flashMode)
        }
    }
    
    fileprivate var queue = OperationQueue()
    
    internal weak var commiterDelegate: ATHImagePickerCommiterDelegate?
    fileprivate let handler = ATHNavigationBarHandler()
    
    // MARK: - Life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        queue.addOperation {
            self.prepareForCapturing()
            self.setFlashMode(self.flashMode)
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ATHImagePickerCaptureViewController.recognizedTapGesture(_:)))
        previewViewContainer.addGestureRecognizer(tapRecognizer)
        
        handler.setupItem(navigationItem, ignoreRight: true, leftHandler: { [weak self] in
            self?.commiterDelegate?.commit(item: ATHImagePickerItem(image: nil))
        }, rightHandler: nil)
        
        title = "Camera"
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadPreview(previewViewContainer)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadPreview(previewViewContainer)
        pageTabBarItem.titleColor = Color.black
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pageTabBarItem.titleColor = Color.tin
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
