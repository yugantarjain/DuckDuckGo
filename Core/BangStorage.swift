//
//  BangStorage.swift
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

import Foundation
import CoreData

public protocol BangStorage {
    
    func removeAll()
    
    func findBang(withTrigger trigger: String) -> BangEntity?
    
    func findBangs(withTriggerStartingWith trigger: String) -> [BangEntity]
    
    func create(trigger: String, domain: String, name: String, score: Int)
    
    func save()
    
}

public class CoreDataBangStorage: BangStorage {
    
    let container: DDGPersistenceContainer
    
    public init(withConcurrencyType concurrencyType: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType) {
        container = DDGPersistenceContainer(name: "Bangs", concurrencyType: concurrencyType)!
    }
    
    public func removeAll() {
        let request = newFetchRequest()
        try? container.deleteAll(entities: container.managedObjectContext.fetch(request))
    }
    
    public func findBang(withTrigger trigger: String) -> BangEntity? {
        let request = newFetchRequest()
        request.predicate = NSPredicate(format: "trigger = [cd] %@", trigger)
        guard let result = try? container.managedObjectContext.fetch(request) else { return nil }
        return result.first
    }
    
    public func findBangs(withTriggerStartingWith trigger: String) -> [BangEntity] {
        let request = newFetchRequest()
        
        if trigger.isEmpty {
            request.sortDescriptors = [ NSSortDescriptor(key: "score", ascending: false) ]
        } else {
            request.predicate = NSPredicate(format: "trigger beginsWith %@", trigger)
            request.sortDescriptors = [ NSSortDescriptor(key: "trigger", ascending: true) ]
        }
        
        guard let result = try? container.managedObjectContext.fetch(request) else { return [] }
        return result
    }
    
    public func create(trigger: String, domain: String, name: String, score: Int) {
        let entityName = String(describing: BangEntity.self)
        let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: container.managedObjectContext) as! BangEntity
        entity.domain = domain
        entity.trigger = trigger
        entity.name = name
        entity.score = Int64(score)
    }
    
    public func save() {
        let inserted = container.managedObjectContext.insertedObjects.count
        if !container.save() {
            print(#function, "failed")
        } else {
            print(#function, "saved", inserted, "inserted")
        }
    }
    
    private func newFetchRequest() -> NSFetchRequest<BangEntity> {
        return BangEntity.fetchRequest()
    }
    
}
