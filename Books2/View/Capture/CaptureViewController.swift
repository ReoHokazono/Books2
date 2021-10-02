//
//  CaptureViewController.swift
//  books
//
//  Created by 外園玲央 on 2020/04/17.
//  Copyright © 2020 外園玲央. All rights reserved.
//

import UIKit
import AVFoundation

protocol CaptureViewControllerDelegate: AnyObject {
    func isbnCodeDetected(_ isbn:String)
    func notAuthorized()
}

class CaptureViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var previewView: PreviewView!
    
    weak var delegate: CaptureViewControllerDelegate?
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session queue")
    private var setupResult: SessionSetupResult = .success
    private var currentDetectedValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView.session = session
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            }
        default:
            setupResult = .notAuthorized
        }
        
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                break
            case .notAuthorized:
                DispatchQueue.main.async {
                    self.delegate?.notAuthorized()
                }
            default:
                break
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        updateOrientation()
    }
    
    func updateOrientation() {
        guard let isVideoOrientationSupported = previewView.videoPreviewLayer.connection?.isVideoOrientationSupported, isVideoOrientationSupported else {
            return
        }
        guard let interfaceOrientation = view.window?.windowScene?.interfaceOrientation,
              let videoOrientation = AVCaptureVideoOrientation(rawValue: interfaceOrientation.rawValue) else {
            return
        }
        previewView.videoPreviewLayer.connection?.videoOrientation = videoOrientation
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
            }
        }
        super.viewWillDisappear(animated)
    }
    
    private func converOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        AVCaptureVideoOrientation(rawValue: orientation.rawValue)!
    }
    
    private func configureSession() {
        if setupResult != .success {
            return
        }
        session.beginConfiguration()
        do {
            guard  let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                session.commitConfiguration()
                return
            }
            let deviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(deviceInput){
                session.addInput(deviceInput)
            } else {
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.ean13]
        } else {
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.commitConfiguration()
    }
    
    func startRunning(){
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.startRunning()
                DispatchQueue.main.async {
                    self.updateOrientation()
                }
            }
        }
    }
    
    func stopRunning(){
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
            }
        }
    }
    
    func toggleFlash(_ torchMode: AVCaptureDevice.TorchMode) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard device.hasTorch else { return }
        guard device.torchMode != torchMode else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = torchMode
            device.unlockForConfiguration()
        } catch {
            fatalError("error: \(error)")
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            if let stringValue = metadata.stringValue
            {
                if (stringValue.hasPrefix("978") || stringValue.hasPrefix("979")) && stringValue != currentDetectedValue {
                    delegate?.isbnCodeDetected(stringValue)
                    currentDetectedValue = stringValue
                }
            }
        }
    }
}
