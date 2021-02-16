//
//  ResultCell.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/30.
//

import Foundation
import UIKit.UICollectionViewCell
import Kingfisher

final class ResultCell: UICollectionViewCell {
    
    private let skeletonView = UIView().then {
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
        $0.layer.shouldRasterize = true
        $0.clipsToBounds = true
    }
    private let cellImageView = AnimatedImageView()
    private let favoritesImage = UIImageView().then {
        let config = UIImage.SymbolConfiguration(scale: .large)
        $0.image = UIImage(
            systemName: "heart.fill",
            withConfiguration: config
        )
        $0.tintColor = .white
        $0.alpha = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(skeletonView)
        skeletonView.addSubview(cellImageView)
        cellImageView.addSubview(favoritesImage)
    }
    
    private func setupLayout() {
        skeletonView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        cellImageView.snp.makeConstraints {
            $0.center.size.equalToSuperview()
        }
        favoritesImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(40)
        }
    }
    
    func configure(_ searchData: SearchData, index: Int) {
        if let color = ColorType(index)?.color {
            skeletonView.backgroundColor = color
        }
        if let imageUrl = searchData.images[.fixedWidth]?.url {
            cellImageView.setImageAnimated(with: URL(string: imageUrl))
        }
    }
    
    func cancel() {
        cellImageView.kf.cancelDownloadTask()
    }
    
    func startAnimation() {
        self.cellImageView.startAnimating()
    }
    
    func animateFavorites(_ isEmpty: Bool,
                          completion: SimpleCompletion? = nil) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        self.favoritesImage.tintColor = isEmpty
            ? .white
            : .systemPink
        self.favoritesImage.alpha = 1
        
        UIView.animate(withDuration: 0.5) {
            self.favoritesImage.tintColor = !isEmpty
                ? .white
                : .systemPink
            self.favoritesImage.layoutIfNeeded()
        } completion: { (_) in
            self.favoritesImage.alpha = 0
            completion?()
        }
    }
}
