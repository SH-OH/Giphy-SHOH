//
//  BaseCollectionViewLayout.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/02/03.
//

import Foundation
import UIKit.UICollectionViewFlowLayout

protocol CollectionViewCustomizable: class {
    func collectionView(_ collectionView: UICollectionView,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
}

class BaseCollectionViewLayout<T>: UICollectionViewFlowLayout {
    
    struct CacheModel<T> {
        let attributes: UICollectionViewLayoutAttributes
        let data: T?
        
        init(attributes: UICollectionViewLayoutAttributes,
             data: T? = nil) {
            self.attributes = attributes
            self.data = data
        }
    }
    
    enum PrepareState {
        case none, new, add
    }
    
    weak var delegate: CollectionViewCustomizable?
    
    var prepareState: PrepareState = .new
    
    var cache: [CacheModel<T>] = []
    var visibleLayoutAttributes: [CacheModel<T>] = []
    
    func setupLayout() {}
}

extension BaseCollectionViewLayout {
    
    // 기본 보이는 레이아웃 구하기.
    func getVisibleAttributesByDefault(in rect: CGRect) -> [CacheModel<T>] {
        visibleLayoutAttributes.removeAll(keepingCapacity: true)
        
        cache.forEach { (model) in
            if model.attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(model)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    // 이진탐색으로 보이는 레이아웃 구하기.
    func getVisibleAttributesByBinarySearch(in rect: CGRect) -> [CacheModel<T>] {
        visibleLayoutAttributes.removeAll(keepingCapacity: true)

        guard let lastIndex = cache.indices.last,
              let firstMatchIndex = findMidByBinarySearch(rect, start: 0, end: lastIndex) else {
            return visibleLayoutAttributes
        }
        
        for model in cache[..<firstMatchIndex].reversed() {
            guard model.attributes.frame.maxY >= rect.minY else { break }
            visibleLayoutAttributes.append(model)
        }

        for model in cache[firstMatchIndex...] {
            guard model.attributes.frame.minY <= rect.maxY else { break }
            visibleLayoutAttributes.append(model)
        }

        return visibleLayoutAttributes
    }
    
    fileprivate func findMidByBinarySearch(
        _ rect: CGRect,
        start: Int,
        end: Int
    ) -> Int? {
        if end < start { return nil }
        
        let mid = (start + end) / 2
        guard let model = cache[safe: mid] else {
            return nil
        }
        
        if model.attributes.frame.intersects(rect) {
            return mid
        } else {
            if model.attributes.frame.maxY < rect.minY {
                return findMidByBinarySearch(
                    rect,
                    start: (mid + 1),
                    end: end
                )
            } else {
                return findMidByBinarySearch(
                    rect,
                    start: start,
                    end: (mid - 1)
                )
            }
        }
    }
}
