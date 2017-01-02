//
//  ATHImagePickerController+Extensions.swift
//  ATHImagePickerController
//
//  Created by mac on 02/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit 

internal extension UIColor {
    convenience init(hex: Int) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / CGFloat(255)
        let green = CGFloat((hex & 0xFF00) >> 8) / CGFloat(255)
        let blue = CGFloat((hex & 0xFF) >> 0) / CGFloat(255)
        
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
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

internal extension UICollectionView {
    func indexPaths(for rect: CGRect) -> [IndexPath] {
        guard let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect) else {
            return []
        }
        
        guard allLayoutAttributes.count > 0 else {
            return []
        }
        
        let indexPaths = allLayoutAttributes.map { $0.indexPath }
        
        return indexPaths
    }
}
