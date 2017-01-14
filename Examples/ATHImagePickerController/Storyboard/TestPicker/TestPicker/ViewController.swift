//
//  ViewController.swift
//  TestPicker
//
//  Created by mac on 02/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit
import ATHKit

class ViewController: UIViewController, ATHImagePickerControllerDelegate, ATHImagePickerCommiterDelegate {

    // MARK: - Outlets 
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties 
    
    fileprivate var picker: UIViewController?
    
    // MARK: - Life cycle 
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - IBActions 
    
    @IBAction func didPressPresentButton(_ sender: Any) {
        let picker = ATHImagePickerController()
        picker.sourceType = [.library, .camera]
        picker.pickerDelegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func didPressShowButton(_ sender: Any) {
        picker = ATHImagePickerController.createdChild(sourceType: [.camera, .library], delegate: self)
        guard let picker = picker else { return }
        show(picker, sender: self)
    }
    
    // MARK: - ATHImagePickerControllerDelegate
    
    func imagePickerController(_ picker: ATHImagePickerController, didCancelWithItem item: ATHImagePickerItem) {
        picker.dismiss(animated: true, completion: nil)
        imageView.image = item.image
    }
    
    func imagePickerController(_ picker: ATHImagePickerController, didCancelWithError error: ATHImagePickerError?) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: ATHImagePickerController, configFor sourceType: ATHImagePickerSourceType) -> ATHImagePickerPageConfig {
        return config(for: sourceType)
    }
    
    // MARK: - ATHImagePickerCommiterDelegate
    
    public func commit(item: ATHImagePickerItem) {
        imageView.image = item.image
        _ = picker?.navigationController?.popViewController(animated: true)
    }
    
    public func commit(error: ATHImagePickerError?) {
        _ = picker?.navigationController?.popViewController(animated: true)
    }
    
    func commit(configFor sourceType: ATHImagePickerSourceType) -> ATHImagePickerPageConfig {
        return config(for: sourceType)
    }
    
    // MARK: - Helpers 
    
    internal func config(for sourceType: ATHImagePickerSourceType) -> ATHImagePickerPageConfig {
        switch sourceType {
        case ATHImagePickerSourceType.camera:
            return ATHImagePickerPageConfig(
                leftButtonTitle: "Cancel",
                rightButtonTitle: "Next",
                leftButtonImage: #imageLiteral(resourceName: "LeftArrow"),
                rightButtonImage: nil,
                title: "Camera",
                titleColor: ATHImagePickerColor.black,
                titleInactiveColor: ATHImagePickerColor.tin,
                leftButtonColor: ATHImagePickerColor.black,
                rightButtonColor: ATHImagePickerColor.blue,
                isStatusBarHidden: false,
                statusBarAnimation: .slide
            )
            
        case ATHImagePickerSourceType.library:
            return ATHImagePickerPageConfig(
                leftButtonTitle: "Cancel",
                rightButtonTitle: "Next",
                leftButtonImage: #imageLiteral(resourceName: "LeftArrow"),
                rightButtonImage: nil,
                title: "Photos",
                titleColor: ATHImagePickerColor.black,
                titleInactiveColor: ATHImagePickerColor.tin,
                leftButtonColor: ATHImagePickerColor.black,
                rightButtonColor: ATHImagePickerColor.blue,
                isStatusBarHidden: false,
                statusBarAnimation: .slide)
            
        default:
            return ATHImagePickerPageConfig(
                leftButtonTitle: "Cancel",
                rightButtonTitle: "Next",
                leftButtonImage: #imageLiteral(resourceName: "LeftArrow"),
                rightButtonImage: nil,
                title: "Photos",
                titleColor: ATHImagePickerColor.black,
                titleInactiveColor: ATHImagePickerColor.tin,
                leftButtonColor: ATHImagePickerColor.black,
                rightButtonColor: ATHImagePickerColor.blue,
                isStatusBarHidden: false,
                statusBarAnimation: .slide)
        }
    }
}

