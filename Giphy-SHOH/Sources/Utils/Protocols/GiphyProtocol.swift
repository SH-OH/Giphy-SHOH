//
//  GiphyProtocol.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/27.
//

import Foundation

protocol GiphyProtocol {
    var provider: BaseProvider<GiphyService> { get set }
}
