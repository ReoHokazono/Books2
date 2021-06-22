//
//  TextCopyModifier.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/14.
//

import SwiftUI
import UIKit

struct TextCopyModifier: ViewModifier {
    
    let copyText: String
    
    func body(content: Content) -> some View {
        content
            .overlay(CopyBackgroundView(copyText: copyText).cornerRadius(5, style: .continuous).padding(-1))
            
    }
}

extension View {
    func longPressCopy(_ copyText: String) -> some View {
        modifier(TextCopyModifier(copyText: copyText))
    }
}

struct CopyBackgroundView: UIViewRepresentable {
    
    let copyText:String
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    func makeUIView(context: Context) -> some UIView {
        let view = CopyBackgroundUIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.copyText = copyText
        return view
    }
}

class CopyBackgroundUIView: UIView {
    var copyText = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(sender:))))
        NotificationCenter.default.addObserver(forName: UIMenuController.willHideMenuNotification, object: nil, queue: .main) { [weak self](_) in
            guard let self = self else { return }
            self.backgroundColor = .clear
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        action == #selector(UIResponderStandardEditActions.copy(_:))
    }
    
    override var canBecomeFirstResponder: Bool{
        true
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = copyText
    }
    
    @objc func onLongPress(sender: UIGestureRecognizer) {
        guard sender.state == .began else {
            return
        }
        becomeFirstResponder()
        backgroundColor = UIColor.systemGray4.withAlphaComponent(0.5)
        let menu = UIMenuController.shared
        menu.showMenu(from: self, rect: bounds)
        
        
    }
}
