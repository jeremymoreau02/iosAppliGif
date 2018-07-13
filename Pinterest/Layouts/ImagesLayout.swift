//
//  ImagesLayout.swift
//  Pinterest
//
//  Created by estiam on 05/07/2018.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

protocol ImagesLayoutDelegate: class {
  func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
  func collectionView(_ collectionView:UICollectionView, widthForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
}


class ImagesLayout: UICollectionViewLayout {
  weak var delegate: ImagesLayoutDelegate!
  
  fileprivate var numberOfColumns = 2
  fileprivate var cellPadding: CGFloat = 2
  
  fileprivate var cache = [UICollectionViewLayoutAttributes]()
  
  fileprivate var contentHeight: CGFloat = 0
  
  fileprivate var contentWidth: CGFloat {
    guard let collectionView = collectionView else {
      return 0
    }
    let insets = collectionView.contentInset
    return collectionView.bounds.width - (insets.left + insets.right) + 7
  }
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
  
  override func prepare() {
    guard cache.isEmpty == true, let collectionView = collectionView else {
      return
    }
    let columnWidth = contentWidth / CGFloat(numberOfColumns)
    var xOffset = [CGFloat]()
    for column in 0 ..< numberOfColumns {
      xOffset.append(CGFloat(column) * columnWidth )
    }
    var column = 0
    var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
    
    for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
      
      let indexPath = IndexPath(item: item, section: 0)
      
      let photoHeight = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
      let photoWidth = delegate.collectionView(collectionView, widthForPhotoAtIndexPath: indexPath)
      
      let height = cellPadding * 2 + photoHeight / 2.5
      let width = cellPadding * 2 + photoWidth / 2.5
      let frame = CGRect(x: xOffset[column], y: yOffset[column]+65, width: width, height: height)
      let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
      
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      attributes.frame = insetFrame
      cache.append(attributes)
      
      contentHeight = max(contentHeight, frame.maxY)
      yOffset[column] = yOffset[column] + height
      
      column = column < (numberOfColumns - 1) ? (column + 1) : 0
    }
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    
    var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
    
    visibleLayoutAttributes.append(self.layoutAttributesForSupplementaryViewOfKind(elementKind: UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(item: 0, section: 0) as IndexPath as IndexPath as NSIndexPath)!)
    
    // Loop through the cache and look for items in the rect
    for attributes in cache {
      if attributes.frame.intersects(rect) {
        visibleLayoutAttributes.append(attributes)
      }
    }
    return visibleLayoutAttributes
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cache[indexPath.item]
  }
  
  override func invalidateLayout() {
    super.invalidateLayout()
    cache.removeAll()
  }
  
  func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
    var attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath as IndexPath)
    attributes.frame = CGRect(x: 0, y: 0, width: contentWidth, height: 60)
    return attributes
  }

}


