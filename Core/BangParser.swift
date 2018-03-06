//
//  BangParser.swift
//  Core
//
//  Created by Chris Brind on 06/03/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation

protocol BangReceiver {
    
    func receive(bang: BangParser.Bang)
    
}

class BangParser {

    /*
     * {
     *     p: "",   // parent
     *     u: "",   // url
     *     r: 1,    // score
     *     a: [],   // aliases
     *     d: "",   // domain
     *     s: "",   // name
     *     sb: "",  // name w/ bold (for text searches)
     *     t: "",   // trigger
     *     tb: "",  // trigger w/ bold (for text searches)
     *     sc: "",  // subcategory
     *     c: ""    // category
     * }
     */
    
    struct Bang: Decodable {
        
        let d: String
        let s: String
        let t: String

    }

    func parse(_ data: Data, into receiver: BangReceiver) -> Bool {
        
        guard let bangs = try? JSONDecoder().decode(Array<BangParser.Bang>.self, from: data) else {
            return false
        }

        for bang in bangs {
            receiver.receive(bang: bang)
        }
        
        return true
    }
    
}


