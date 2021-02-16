//
//  DetailCollectionViewLayout.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/02/01.
//

import Foundation
import UIKit.UICollectionViewFlowLayout

final class DetailCollectionViewLayout: BaseCollectionViewLayout<DetailCollectionViewLayout.Data> {
    
    struct Data {
        let originCenterY: CGFloat
    }
    
    var startIndex: Int = 0 {
        didSet {
            startState = (startIndex, true)
        }
    }
    
    private var startState: (index: Int, isStart: Bool) = (0, true)
    
    private var cellPadding: CGFloat {
        return 25
    }
    private var spacing: CGFloat {
        return 0
    }
    
    private var xOffset: CGFloat = 0
    private var prevCenterY: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: xOffset, height: 0)
    }
    
    override func prepare() {
        super.prepare()
        self.setupLayout()
    }
    
    override func setupLayout() {
        guard let collectionView = self.collectionView,
              let delegate = self.delegate else { return }
        
        guard prepareState != .none else { return }
        
        let numberOfItems: Int = collectionView.numberOfItems(inSection: 0)
        
        guard numberOfItems > 0 else { return }
        
        scrollDirection = .horizontal
        collectionView.decelerationRate = .fast
        minimumLineSpacing = 0
        
        xOffset = cellPadding
        
        for item in cache.count..<numberOfItems {
            let indexPath: IndexPath = IndexPath(item: item, section: 0)
            let size = delegate.collectionView(collectionView,
                                               sizeForItemAt: indexPath)
            
            let frame: CGRect = CGRect(
                x: xOffset,
                y: 0,
                width: size.width,
                height: size.height
            )
            let attributes: UICollectionViewLayoutAttributes = .init(forCellWith: indexPath)
            attributes.frame = frame
            
            xOffset = xOffset + size.width
            
            let data: Data = Data(originCenterY: attributes.center.y)
            let model: CacheModel = CacheModel(
                attributes: attributes,
                data: data
            )
            cache.append(model)
            
        }
        
        prepareState = .none
    }
    
}

extension DetailCollectionViewLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.getVisibleAttributesByDefault(in: rect)
            .enumerated()
            .map({ transformLayoutAttributes(index: $0, model: $1) })
    }
    
    private func transformLayoutAttributes(index: Int, model: CacheModel<Data>) -> UICollectionViewLayoutAttributes {
        guard let collectionView = self.collectionView,
              let data = model.data else { return model.attributes }
        
        let attributes = model.attributes
        
        let collectionViewCenter: CGFloat = collectionView.bounds.size.width / 2
        let contentOffset: CGFloat = collectionView.contentOffset.x
        let itemCenter: CGFloat = attributes.center.x - contentOffset
        
        let maxDistance: CGFloat = attributes.size.width + minimumLineSpacing
        let distance: CGFloat = min(abs(collectionViewCenter - itemCenter), maxDistance)
        let ratio: CGFloat = (maxDistance - distance)/maxDistance
        
        var sideItemScale: CGFloat = 1.0
        var centerY: CGFloat = ratio * data.originCenterY
        let diffCenterY = prevCenterY - data.originCenterY
        
        if let isLeftItem = isLeftOrRight(
            itemCenter: itemCenter,
            collectionViewCenter: collectionViewCenter
        ) {
            let centerIndex = isLeftItem ? index+1 : index-1
            if let centerItem = visibleLayoutAttributes[safe: centerIndex] {
                sideItemScale = (centerItem.attributes.size.height / attributes.size.height) * 0.7
                
                if isLeftItemOfStartIndex(centerItem.attributes, isLeftItem: isLeftItem) {
                    let diffCenterYOfStartIndex: CGFloat = prevCenterY - (centerItem.data?.originCenterY ?? data.originCenterY)
                    centerY = prevCenterY - diffCenterYOfStartIndex
                    startState.isStart = false
                } else {
                    centerY = prevCenterY - (ratio * diffCenterY)
                }
            }
        }
        
        let scale: CGFloat = ratio * (1 - sideItemScale) + sideItemScale
        attributes.transform = CGAffineTransform(scaleX: 1.0, y: scale)
        
        attributes.center.y = centerY
        prevCenterY = centerY
        
        return attributes
    }
    
    private func isLeftItemOfStartIndex(_ centerAttributes: UICollectionViewLayoutAttributes, isLeftItem: Bool) -> Bool {
        return startState.isStart
            &&
            startState.index == centerAttributes.indexPath.item
            &&
            isLeftItem
    }
    
    private func isLeftOrRight (
        itemCenter: CGFloat,
        collectionViewCenter: CGFloat
    ) -> Bool? {
        guard itemCenter != collectionViewCenter else { return nil }
        if itemCenter < collectionViewCenter {
            return true
        } else {
            return false
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item].attributes
    }
}

extension DetailCollectionViewLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = self.collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let collectionViewWidth: CGFloat = collectionView.bounds.width
        
        let targetRect: CGRect = .init(
            x: proposedContentOffset.x,
            y: 0,
            width: collectionViewWidth,
            height: collectionView.bounds.height
        )
        let rectAttributes = self.getVisibleAttributesByDefault(in: targetRect)
        
        var adjustOffset: CGFloat = .greatestFiniteMagnitude
        let proposedCenterOffset: CGFloat = proposedContentOffset.x + (collectionViewWidth / 2)
        
        for model in rectAttributes {
            let itemCenter: CGFloat = model.attributes.center.x
            if (itemCenter - proposedCenterOffset).magnitude < adjustOffset.magnitude {
                adjustOffset = itemCenter - proposedCenterOffset
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + adjustOffset, y: proposedContentOffset.y)
    }
}
