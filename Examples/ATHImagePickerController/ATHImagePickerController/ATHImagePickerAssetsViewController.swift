//
//  ATHImagePickerAssetsViewController.swift
//  ATHImagePickerController
//
//  Created by mac on 01/01/2017.
//  Copyright © 2017 Athlee LLC. All rights reserved.
//

import UIKit
import Photos
import ImagePickerKit

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

public protocol AssetsController: class {
    var offset: CGPoint { get set }
}

open class ATHImagePickerAssetsViewController: UIViewController, AssetsController, EmbededController {
    
    // MARK: - Outlets 
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - AssetsController properties
    
    public var offset: CGPoint = .zero {
        didSet {
            collectionView.contentOffset = offset
        }
    }
    
    // MARK: - EmbededController properties
    
    internal weak var holder: SelectionController!
    
    // MARK: - Properties
    
    open var space: CGFloat = 2
    
    public lazy var fetchResult: PHFetchResult = { () -> PHFetchResult<PHAsset> in
        let options = PHFetchOptions()
        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        
        return fetchResult
    }()
    
    public lazy var cachingImageManager = PHCachingImageManager()
    
    public var previousPreheatRect: CGRect = .zero
    
    fileprivate var cellSize: CGSize {
        let side = (collectionView.frame.width - space * 3) / 4
        return CGSize(
            width: side,
            height: side
        )
    }
    
    fileprivate lazy var observer: CollectionViewChangeObserver = {
        return CollectionViewChangeObserver(collectionView: self.collectionView, source: self)
    }()
    
    fileprivate var reloaded = false
    
    // MARK: - Life cycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        resetCachedAssets()
        checkPhotoAuth()
        
        if fetchResult.count > 0 {
            collectionView.reloadData()
            collectionView.selectItem(
                at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
        
        PHPhotoLibrary.shared().register(observer)
        
        collectionView.backgroundColor = .clear
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.layoutIfNeeded()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !reloaded {
            let firstReversed = fetchResult[fetchResult.count - 1]
            cachingImageManager.requestImage(
                for: firstReversed,
                targetSize: UIScreen.main.bounds.size,
                contentMode: .aspectFill,
                options: nil) { result, info in
                    if info!["PHImageFileURLKey"] != nil  {
                        self.holder.previewController?.image = result
                    }
            }
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets(for: collectionView.bounds, targetSize: cellSize)
        
        if !reloaded {
            reloaded = true
            
            if collectionView.frame.width != parent!.view.frame.width {
                collectionView.reloadData()
                collectionView.selectItem(
                    at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
            }
        }
    }
    
    deinit {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            PHPhotoLibrary.shared().unregisterChangeObserver(observer)
        }
    }
}


// MARK: - PhotoFetchable

extension ATHImagePickerAssetsViewController: PhotoFetchable { }

// MARK: - PhotoCachable

extension ATHImagePickerAssetsViewController: PhotoCachable {
    public func checkPhotoAuth() {
        
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch status {
            case .authorized:
                self.cachingImageManager = PHCachingImageManager()
                if self.fetchResult.count > 0 {
                    // TODO: Set main initial image
                }
                
            case .restricted, .denied:
                DispatchQueue.main.async(execute: { () -> Void in
                    self.holder.commit(error: .error("Could not get permission to access the Photo Library!"))
                })
            default:
                break
            }
        }
    }
    
    public func cachingAssets(at rect: CGRect) -> [PHAsset] {
        let indexPaths = collectionView.indexPaths(for: rect)
        return assets(at: indexPaths, in: fetchResult as! PHFetchResult<AnyObject>)
    }
}

extension ATHImagePickerAssetsViewController {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            updateCachedAssets(for: collectionView.bounds, targetSize: cellSize)
            
            holder.offset = collectionView.contentOffset
            
            if scrollView.contentOffset.y < 0 {
                holder.previewController?.allowPanOutside = true
            } else {
                holder.previewController?.allowPanOutside = false
            }
        }
    }
}

extension ATHImagePickerAssetsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ATHPhotoCell.identifier, for: indexPath) as! ATHPhotoCell
        
        let reversedIndex = fetchResult.count - indexPath.item - 1
        let asset = fetchResult[reversedIndex]
        cachingImageManager.requestImage(
            for: asset,
            targetSize: cellSize,
            contentMode: .aspectFill,
            options: nil) { [cell] result, info in
                
                cell.photoImageView.image = result
                
        }
        
        cell.backgroundColor = .red
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reversedIndex = fetchResult.count - indexPath.item - 1
        
        let asset = fetchResult[reversedIndex]
        cachingImageManager.requestImage(
            for: asset,
            targetSize: UIScreen.main.bounds.size,
            contentMode: .aspectFill,
            options: nil) { result, info in
                if info!["PHImageFileURLKey"] != nil  {
                    if let previewController = self.holder.previewController, previewController.state == .folded {
                        let floatingView = self.holder.floatingView
                        previewController.restore(view: floatingView, to: .unfolded, animated: true)
                        previewController.animationCompletion = { _ in
                            self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
                            previewController.animationCompletion = nil
                        }
                    }

                    DispatchQueue.main.async {
                        self.holder.previewController?.image = result
                    }
                }
        }
        
    }
}

extension ATHImagePickerAssetsViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return space
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return space
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}
