//
//  PhotoEffectMonoFilter.swift
//  Athlee-ImageEditorKit
//
//  Created by mac on 19/07/16.
//  Copyright © 2016 Athlee. All rights reserved.
//

import UIKit
import CoreImage

public struct PhotoEffectMonoFilter: ColorEffectFilter {
  
  // MARK: Filter
  
  public let name = "CIPhotoEffectMono"
  
  // MARK: ImageFilter
  
  public var image: UIImage
  public var inputImage: CIImage?
  
  // MARK: Initialization
  
  public init(image: UIImage) {
    self.image = image
    self.inputImage = CIImage(image: image)
  }
  
}
