//
//  ActivityView.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/13.
//

import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    
    let fileUrl: URL
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let activityViewController = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

//struct ActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityView()
//    }
//}
