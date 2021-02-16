//
//  ImageModel.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation
import UIKit

struct ImageModel: Decodable {
    let height: String?
    let width: String?
    let size: String?
    let url: String?
}

extension ImageModel {
    private func toCGSize() -> CGSize {
        guard let _height = self.height,
              let height = Int(_height),
              let _width = self.width,
              let width = Int(_width) else {
            return .zero
        }
        return CGSize(width: width, height: height)
    }
    
    func getSize(with width: CGFloat) -> CGSize {
        let originSize: CGSize = self.toCGSize()
        let scale: CGFloat = width / originSize.width
        let newHeight: CGFloat = scale * originSize.height
        return CGSize(width: width, height: newHeight)
    }
}
