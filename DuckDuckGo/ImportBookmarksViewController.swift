//
//  File.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 07/06/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation

protocol ImportBookmarksDelegate: class {
    
    func finished(controller: ImportBookmarksViewController)
    
    
}

// https://www.hackingwithswift.com/example-code/media/how-to-scan-a-qr-code
class ImportBookmarksViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scanningView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    weak var delegate: ImportBookmarksDelegate?
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    let bookmarksManager = BookmarksManager()
    
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyCorners()

        if uid != nil {
            startImport()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if uid == nil {
            startScanning()
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }

    }
    
    @IBAction func dismiss() {
        dismiss(animated: true)
    }
    
    private func applyCorners() {
        infoView.layer.cornerRadius = 5
        infoView.layer.masksToBounds = true
    }
    
    private func startScanning() {
        titleLabel.text = "Scan QRCode"
        
        scanningView.isHidden = false
        closeButton.isHidden = false
        activityIndicator.isHidden = true
        
        let view = scanningView!
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            scanningFailed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            scanningFailed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    private func scanningFailed() {
        UIApplication.shared.keyWindow?.showBottomToast("Failed to start scanning")
        delegate?.finished(controller: self)
        dismiss(animated: true)
    }
    
    // fix orientation when scanning
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return uid == nil ? .portrait : super.supportedInterfaceOrientations
    }
    
    private func startImport() {
        titleLabel.text = "Importing..."
        
        scanningView.isHidden = true
        closeButton.isHidden = true
        activityIndicator.isHidden = false

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
        delegate?.finished(controller: self)
        dismiss(animated: true)
    }
    
    private func handleData(_ data: Data) {
        guard bookmarksManager.importJson(from: data) else {
            handleError()
            return
        }
        
        delegate?.finished(controller: self)
        UIApplication.shared.keyWindow?.showBottomToast("Bookmarks imported")
        dismiss(animated: true)
    }
    
}

extension ImportBookmarksViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            uid = stringValue
        }
        
        startImport()
    }
    
}


