//
//  ATHPhotoCell.swift
//  ATHImagePickerController
//
//  Created by mac on 01/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit

internal class ATHPhotoCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: - Properties
    static let identifier = "ATHPhotoCell"
    
    let overlayView = UIView()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                overlayView.alpha = 0.6
            } else {
                overlayView.alpha = 0
            }
        }
    }
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0
        
        addSubview(overlayView)
        
        let anchors = [
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ].flatMap { $0 }
        
        NSLayoutConstraint.activate(anchors)
    }
}
