//
//  ExportBookmarksViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 07/06/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit
import Alamofire
import CoreImage

class ExportBookmarksViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var qrcodeImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let bookmarks = BookmarksManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.blur(style: .regular)
        closeButton.isHidden = true
        logo.isHidden = true
        applyCorners()
        startExport()
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true)
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
            titleLabel.text = "Scan this!"
            activityIndicator.isHidden = true
            closeButton.isHidden = false
            logo.isHidden = false
            qrcodeImage.image = generateQRCode(from: uid)
            window?.showBottomToast("Export UID copied to Pasteboard")
        } else {
            window?.showBottomToast("Export failed, please try again later")
            dismiss(animated: true)
        }
        
    }

    // https://www.hackingwithswift.com/example-code/media/how-to-create-a-qr-code
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 7, y: 7)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
}
