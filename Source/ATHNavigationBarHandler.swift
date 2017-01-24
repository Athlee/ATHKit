//
//  ATHNavigationBarHandler.swift
//  ATHImagePickerController
//
//  Created by mac on 02/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit

internal class ATHNavigationBarHandler {
  internal var leftHandler: ((Void) -> Void)?
  internal var rightHandler: ((Void) -> Void)?
  
  internal func setupItem(_ item: UINavigationItem, config: ATHImagePickerPageConfig, ignoreRight: Bool = false, leftHandler: ((Void) -> Void)?, rightHandler: ((Void) -> Void)?) {
    self.leftHandler = leftHandler
    self.rightHandler = rightHandler
    
    if !ignoreRight {
      let rightItem: UIBarButtonItem
      if let image = config.rightButtonImage {
        rightItem = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(ATHNavigationBarHandler.didPressRightButton(_:)))
      } else {
        rightItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(ATHNavigationBarHandler.didPressRightButton(_:)))
      }
      
      item.rightBarButtonItem = rightItem
      item.rightBarButtonItem?.tintColor = config.rightButtonColor
    }
    
    let leftItem: UIBarButtonItem
    if let image = config.leftButtonImage {
      leftItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(ATHNavigationBarHandler.didPressLeftButton(_:)))
    } else {
      leftItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ATHNavigationBarHandler.didPressLeftButton(_:)))
    }
    
    item.leftBarButtonItem = leftItem
    item.leftBarButtonItem?.tintColor = config.leftButtonColor
  }
  
  @IBAction internal func didPressLeftButton(_ sender: Any) {
    leftHandler?()
  }
  
  @IBAction internal func didPressRightButton(_ sender: Any) {
    rightHandler?()
  }
}
