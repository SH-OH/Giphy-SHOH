//
//  BaseProvider.swift
//  Giphy-SHOH
//
//  Created by Oh Sangho on 2021/01/25.
//

import Foundation
import Moya
import RxMoya
import RxSwift

enum APIError: Error {
    case apiFail(String)
    case parseFail(Error)
}

final class BaseProvider<Target: TargetType>: MoyaProvider<Target> {
    
    init() {
        var plugins: [PluginType] = []
        let networkClosuer: NetworkActivityPlugin.NetworkActivityClosure = { (_ change: NetworkActivityChangeType, _ target: TargetType) in
            switch change {
            case .began:
                IndicatorManager.show()
            case .ended:
                IndicatorManager.hide()
            }
        }
        plugins.append(NetworkActivityPlugin(networkActivityClosure: networkClosuer))
        super.init(plugins: plugins)
    }
    
    func request<T: Decodable>(_ modelType: T.Type,
                    target: Target,
                    callbackQueue: DispatchQueue? = nil) -> Single<GiphyRootModel<T>> {
        return Single<GiphyRootModel<T>>.create { (observer) -> Disposable in
            _ = self.rx
                .request(target, callbackQueue: callbackQueue)
                .do(onSuccess: { (res) in
                    let makeDict: [String: Any] = [
                        "01.URL": "[\(target.method.rawValue)] \(target.baseURL)\(target.path)",
                        "02.Target": target,
                        "03.Response": String(data: res.data, encoding: .utf8) ?? "NO DATA"
                    ]
//                    Log.d(makeDict)
                })
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe(onSuccess: { (res) in
                    do {
                        let model = try GiphyRootModel<T>.decode(data: res.data)
                        if model.meta.status == 200 {
                            observer(.success(model))
                        } else {
                            observer(.error(APIError.apiFail(model.meta.msg)))
                        }
                    } catch {
                        Log.e(error)
                        observer(.error(APIError.parseFail(error)))
                    }
                })
            
            return Disposables.create()
        }
    }
}
