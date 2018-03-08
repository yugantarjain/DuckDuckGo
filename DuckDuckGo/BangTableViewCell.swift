//
//  BangTableViewCell.swift
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


import UIKit
import Core

class BangTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "BangTableViewCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var faviconImage: UIImageView!
    @IBOutlet weak var trigger: UILabel!

    func update(withBang bang: BangEntity) {
        nameLabel.text = bang.name
        trigger.text = "!\(bang.trigger!)"
        
        let placeholder = #imageLiteral(resourceName: "SearchLoupe")
        faviconImage.image = placeholder
        let faviconUrl = AppUrls().faviconUrl(forDomain: bang.domain!)
        faviconImage.kf.setImage(with: faviconUrl, placeholder: placeholder) { image, error, cacheType, url in
            guard let image = image else { return }
            if image.size.width == 1 {
                self.faviconImage.image = placeholder
            }
        }
    }
    
}
