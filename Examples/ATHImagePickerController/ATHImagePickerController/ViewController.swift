//
//  ViewController.swift
//  ATHImagePickerController
//
//  Created by mac on 02/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ATHImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var didPressButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func adwwa(_ sender: Any) {
        let controller = ATHImagePickerController()
        controller.sourceType = [.library, .camera]
        controller.pickerDelegate = self 
        present(controller, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: ATHImagePickerController, didCancelWithItem item: ATHImagePickerItem) {
        print("Item is nil=\(item.image == nil)")
        picker.dismiss(animated: true, completion: nil)
        
        DispatchQueue.main.async {
            self.imageView.image = item.image
        }
    }
    
    func imagePickerController(_ picker: ATHImagePickerController, didCancelWithError error: ATHImagePickerError?) {
        picker.dismiss(animated: true, completion: nil)
    }
}
