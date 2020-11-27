//
//  CaptureView.swift
//  books
//
//  Created by 外園玲央 on 2020/04/18.
//  Copyright © 2020 外園玲央. All rights reserved.
//

import SwiftUI
import UIKit

struct CaptureView: UIViewControllerRepresentable {
    
    @Binding var isRunning:Bool
    @Binding var isFlashOn: Bool
    var isbnCodeDetected:(_ isbn:String)->()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> CaptureViewController {
        let captureViewController = CaptureViewController(nibName: "CaptureViewController", bundle: nil)
        captureViewController.delegate = context.coordinator
        return captureViewController
    }
    
    func updateUIViewController(_ captureViewController: CaptureViewController, context: Context) {
        if isRunning {
            captureViewController.startRunning()
        } else {
            captureViewController.stopRunning()
        }
        
        captureViewController.toggleFlash(isFlashOn ? .on : .off)
    }
    
    class Coordinator: NSObject, CaptureViewControllerDelegate {
        var parent: CaptureView
        init(_ captureView: CaptureView) {
            self.parent = captureView
        }
        
        func isbnCodeDetected(_ isbn: String) {
            parent.isbnCodeDetected(isbn)
        }
    }
}
