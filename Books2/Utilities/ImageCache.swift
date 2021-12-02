//
//  ImageCache.swift
//  books
//
//  Created by 外園玲央 on 2020/05/02.
//  Copyright © 2020 外園玲央. All rights reserved.
//

#if os(iOS)
import UIKit
public typealias CrossPlatformImage = UIImage

#elseif os(macOS)
import AppKit
public typealias CrossPlatformImage = NSImage

#endif

class ImageCache: NSCache<NSURL, CrossPlatformImage> {
    private override init() {}
    static let shared = ImageCache()
}
