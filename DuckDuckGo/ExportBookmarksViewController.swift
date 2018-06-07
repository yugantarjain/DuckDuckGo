//
//  ExportBookmarksViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 07/06/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit
import Alamofire

class ExportBookmarksViewController: UIViewController {
    
    @IBOutlet weak var infoView: UIView!
    
    let bookmarks = BookmarksManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyCorners() 
        startExport()
    }
    
    private func applyCorners() {
        infoView.layer.cornerRadius = 5
        infoView.layer.masksToBounds = true
    }
    
    private func startExport() {
        
        let json = bookmarks.exportJson()
        
        var urlRequest = URLRequest(url: URL(string:"https://ddgbookmarks-demo.vapor.cloud/bookmarks/")!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = json
        Alamofire.request(urlRequest)
            .validate(statusCode: 201...201)
            .response { response in
                
                guard response.error == nil else {
                    self.handleLocation(nil)
                    return
                }
                
                let location = response.response?.allHeaderFields["Location"] as? String
                self.handleLocation(location)
            }
        
    }
    
    private func handleLocation(_ uid: String?) {
        let window = UIApplication.shared.keyWindow

        if let uid = uid {
            UIPasteboard.general.string = uid
            window?.showBottomToast("Export UID copied to Pasteboard")
        } else {
            window?.showBottomToast("Export failed, please try again later")
        }
        dismiss(animated: true)
    }

}
