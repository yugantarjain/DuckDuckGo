//
//  RemoteImageView.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

import UIKit
import Alamofire

class RemoteImageView: UIImageView {
    
    struct Constants {
        static let blankGifSize = 43
    }
    
    private var request:DataRequest?
    
    var url: URL? {
        didSet {
            load()
        }
    }
    
    func cancel() {
        request?.cancel()
        request = nil
    }
    
    private func load() {
        cancel()
        guard let url = url else { return }
        
        request = Alamofire.request(url).validate(statusCode: 200..<300)
            .responseData(queue: DispatchQueue.main) { response in
                guard let data = response.data else { return }
                guard data.count > Constants.blankGifSize else { return }
                self.image = UIImage(data: data)
                self.request = nil
            }
    }
    
}
