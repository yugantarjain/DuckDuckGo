//
//  BlockerListRequest.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

public enum BlockerList: String {
    
    case disconnectMe = "disconnectme"
    case easylist = "easylist"
    case easylistPrivacy = "easyprivacy"
    case trackersWhitelist
    case httpsUpgrade = "https"
    case surrogates
    case bang // TODO refactor this class to not be "blocker list" specific
    
}

public protocol BlockerListRequest {
    
    func request(_ list: BlockerList, completion:@escaping (Data?) -> Void)
    
    var requestCount: Int { get }

}

public class DefaultBlockerListRequest: BlockerListRequest {

    public var requestCount = 0
    
    let etagStorage: BlockerListETagStorage

    public init(etagStorage: BlockerListETagStorage = UserDefaultsETagStorage()) {
        self.etagStorage = etagStorage
    }

    public func request(_ list: BlockerList, completion:@escaping (Data?) -> Void) {
        requestCount += 1
        APIRequest.request(url: url(for: list)) { (response, error) in

            guard error == nil else {
                completion(nil)
                return
            }

            guard let response = response else {
                completion(nil)
                return
            }

            guard let data = response.data else {
                completion(nil)
                return
            }

            let etag = self.etagStorage.etag(for: list)

            if etag == nil || etag != response.etag {
                Logger.log(text: "Returning data for \(list.rawValue) with etag \(String(describing: response.etag))")
                self.etagStorage.set(etag: response.etag, for: list)
                completion(data)
            } else {
                completion(nil)
            }
        }
    }

    private func url(for list: BlockerList) -> URL {
        let appUrls = AppUrls()

        switch(list) {
            case .disconnectMe: return appUrls.disconnectMeBlockList
            case .easylist: return appUrls.easylistBlockList
            case .easylistPrivacy: return appUrls.easylistPrivacyBlockList
            case .httpsUpgrade: return appUrls.httpsUpgradeList
            case .trackersWhitelist: return appUrls.trackersWhitelist
            case .surrogates: return appUrls.surrogates
            case .bang: return appUrls.bang
        }

    }
    
}

public protocol BlockerListETagStorage {

    func set(etag: String?, for list: BlockerList)

    func etag(for list: BlockerList) -> String?

}

public class UserDefaultsETagStorage: BlockerListETagStorage {

    lazy var defaults = UserDefaults(suiteName: "com.duckduckgo.blocker-list.etags")
    
    public init() {}

    public func etag(for list: BlockerList) -> String? {
        let etag = defaults?.string(forKey: list.rawValue)
        Logger.log(items: "etag found for ", list.rawValue, etag as Any)
        return etag
    }

    public func set(etag: String?, for list: BlockerList) {
        Logger.log(items: "setting etag for ", list.rawValue, etag as Any)
        defaults?.set(etag, forKey: list.rawValue)
    }
    
}


