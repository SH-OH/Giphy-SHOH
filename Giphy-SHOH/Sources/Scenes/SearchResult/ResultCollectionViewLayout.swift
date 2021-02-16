//
//  ResultCollectionViewLayout.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/30.
//

import Foundation
import UIKit.UICollectionViewFlowLayout

final class ResultCollectionViewLayout: BaseCollectionViewLayout<Void> {
    
    private var numberOfColumns: Int {
        return 2
    }
    private var cellPadding: CGFloat {
        return 5
    }
        
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = self.collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    private var yOffsets: [CGFloat] = []
    
    override var collectionViewContentSize: CGSize {
        let bottomPadding: CGFloat = contentHeight == 0
        ? 0
        : 100
        return CGSize(
            width: contentWidth,
            height: contentHeight + bottomPadding
        )
    }
    
    override func prepare() {
        self.setupLayout()
    }
    
    override func setupLayout() {
        guard let collectionView = self.collectionView,
              let delegate = self.delegate else { return }
        
        let numberOfItems: Int = collectionView.numberOfItems(inSection: 0)
        
        let isNew = numberOfItems <= GiphyUseCase.Constants.SearchLimit
        
        if isNew {
            cache.removeAll(keepingCapacity: true)
            contentHeight = 0
            yOffsets = [CGFloat](
                repeating: 0,
                count: numberOfColumns
            )
        }
        
        let columnWidth: CGFloat = contentWidth / CGFloat(numberOfColumns)
        let xOffsets: [CGFloat] = (0..<self.numberOfColumns)
            .map { (CGFloat($0) * columnWidth) }
        
        var column: Int = 0
        
        for item in 0..<numberOfItems {
            let indexPath: IndexPath = IndexPath(item: item, section: 0)
            let size = delegate.collectionView(collectionView,
                                               sizeForItemAt: indexPath)
            let frame: CGRect = CGRect(
                x: xOffsets[column],
                y: yOffsets[column],
                width: size.width,
                height: size.height
            )
            let attributes: UICollectionViewLayoutAttributes = .init(forCellWith: indexPath)
            attributes.frame = frame
            let model = CacheModel<Void>(attributes: attributes)
            
            cache.append(model)
            
            contentHeight = max(contentHeight, frame.maxY)
          
            yOffsets[column] = yOffsets[column] + size.height + cellPadding
            
            let realContentHeight = contentHeight + 5
            
            if yOffsets[column] >= realContentHeight {
                column = column < (numberOfColumns - 1)
                    ? column + 1
                    : 0
            }
        }
    }
    
}

extension ResultCollectionViewLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.getVisibleAttributesByBinarySearch(in: rect)
            .map { $0.attributes }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[safe: indexPath.item]?.attributes
    }
}

