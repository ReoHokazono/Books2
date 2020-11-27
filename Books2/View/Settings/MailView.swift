//
//  MailView.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/19.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    
    @Binding var mailViewPresented: Bool
    var subject: String
    var recipient: String
    var messageBody: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = context.coordinator
        mailComposeViewController.setSubject(subject)
        mailComposeViewController.setToRecipients([recipient])
        mailComposeViewController.setMessageBody(messageBody, isHTML: false)
        return mailComposeViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.mailViewPresented = false
        }
    }
    
}
