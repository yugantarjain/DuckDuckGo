//
//  BangLoader.swift
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

public class BangLoader {
    
    struct BangStorageReceiver: BangReceiver {
        
        let storage: BangStorage
        
        func receive(bang: BangParser.Bang) {
            storage.create(trigger: bang.t, domain: bang.d, name: bang.s)
        }
        
    }

    let storage: BangStorage
    let request: BlockerListRequest

    public init(storage: BangStorage = CoreDataBangStorage(withConcurrencyType: .privateQueueConcurrencyType), request: BlockerListRequest = DefaultBlockerListRequest()) {
        self.storage = storage
        self.request = request
    }
    
    public func start(completion: @escaping (_ newData: Bool) -> Void) {
        request.request(.bang) { data in
    
            guard let data = data else {
                completion(false)
                return
            }
    
            self.storage.removeAll()
            let receiver = BangStorageReceiver(storage: self.storage)
            let result = BangParser().parse(data, into: receiver)
            self.storage.save()
            completion(result)
        }
    }
    
}

