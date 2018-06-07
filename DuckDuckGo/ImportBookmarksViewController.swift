//
//  File.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 07/06/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit
import Alamofire

class ImportBookmarksViewController: UIViewController {
    
    @IBOutlet weak var infoView: UIView!
    
    let bookmarksManager = BookmarksManager()
    
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyCorners()

        // TODO if uid is nil, scan a QR code?
        
        startImport()
    }

    private func applyCorners() {
        infoView.layer.cornerRadius = 5
        infoView.layer.masksToBounds = true
    }
    
    private func startImport() {
        
        Alamofire.request(URL(string: "https://ddgbookmarks-demo.vapor.cloud/bookmarks/\(uid!)")!)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseData { data in
                
                guard data.error == nil else {
                    self.handleError()
                    return
                }
                
                guard let data = data.data else {
                    self.handleError()
                    return
                }
                
                self.handleData(data)
        }
        
    }
    
    private func handleError() {
        UIApplication.shared.keyWindow?.showBottomToast("Failed to import bookmarks, try again later")
        dismiss(animated: true)
    }
    
    private func handleData(_ data: Data) {
        guard bookmarksManager.importJson(from: data) else {
            handleError()
            return
        }
        
        UIApplication.shared.keyWindow?.showBottomToast("Bookmarks imported")
        dismiss(animated: true)
    }
    
}
