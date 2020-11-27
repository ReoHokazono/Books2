//
//  ViewControllerResolver.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/14.
//

import SwiftUI

struct ViewControllerResolver: UIViewControllerRepresentable {
    
    let onResolve: (UIViewController) -> ()
    
    init(onResolve: @escaping (UIViewController) -> ()) {
        self.onResolve = onResolve
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        ParentResolverViewController(onResolve: onResolve)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

class ParentResolverViewController: UIViewController {
    
    let onResolve: (UIViewController) -> ()
    
    init(onResolve: @escaping (UIViewController) -> ()) {
        self.onResolve = onResolve
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if let parent = parent {
            onResolve(parent)
            parent.navigationController?.navigationBar.sizeToFit()
        }
    }
}
