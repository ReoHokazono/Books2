//
//  URLImage.swift
//  books
//
//  Created by 外園玲央 on 2020/04/20.
//  Copyright © 2020 外園玲央. All rights reserved.
//

import SwiftUI

struct URLImage: View {
    
    @StateObject var imageLoader: ImageLoader
    
    var body: some View {
        if let downloadedImage = imageLoader.downloadedImage {
            Image(uiImage: downloadedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .border(Color(.systemGray3), width: 0.5)
        } else {
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(.systemGray2)
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        URLImage(imageLoader: ImageLoader(url: URL(string: "https://cover.openbd.jp/9784101269313.jpg")!))
    }
}

class ImageLoader: ObservableObject {
    @Published var downloadedImage:UIImage?
    
    init(url: URL?) {
        guard let url = url else { return }
        downloadImage(url: url)
    }
    
    func downloadImage(url: URL) {
        if let cachedImage = ImageCache.shared.object(forKey: url as NSURL) {
            self.downloadedImage = cachedImage
        } else {
            let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        ImageCache.shared.setObject(image, forKey: url as NSURL)
                        self.downloadedImage = image
                    }
                }
            }
            task.resume()
        }
    }
}
