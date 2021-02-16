//
//  DefaultCell.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation
import UIKit.UICollectionViewCell

final class DefaultCell: UICollectionViewCell {
    
    @IBOutlet private weak var labelLeading: NSLayoutConstraint!
    
    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var cellLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellLabel.attributedText = nil
    }
    
    func configure(_ name: String,
                   keyword: String) {
        let attributed = name.toAttributed(
            keyword,
            attrs: [
                .font: UIFont.boldSystemFont(ofSize: 18)
            ]
        )
        cellImageView.image = UIImage(systemName: "magnifyingglass")
        cellLabel.attributedText = attributed
    }
    
    func configure(_ search: String,
                   isTitle: Bool) {
        let attributed = search.toAttributed(
            search,
            attrs: [
                .font: UIFont.systemFont(ofSize: 20, weight: .heavy)
            ]
        )
        cellImageView.image = UIImage(systemName: "arrow.up.right")
        cellLabel.attributedText = attributed
        
        cellImageView.isHidden = isTitle
        cellImageView.tintColor = .systemBlue
        labelLeading.constant = isTitle ? -20 : 15
    }
}
