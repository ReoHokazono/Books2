//
//  ReviewRecommender.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/28.
//

import UIKit
import StoreKit

#if DEBUG
fileprivate let bookInfoCountMin: Int = 1
fileprivate let openAppCountMin: Int = 1

#else
fileprivate let bookInfoCountMin: Int = 10
fileprivate let openAppCountMin: Int = 10
#endif
class ReviewRecommender {
    class func requestReviewIfNeeded(bookInfoCount: Int) {
        guard let windowScene = UIApplication.shared.windows.last?.windowScene else {
            return
        }
        
        guard bookInfoCount > bookInfoCountMin,
              UserDefaults.standard.openAppCount > openAppCountMin,
              UserDefaults.standard.lastVersionPromptedForReview != Bundle.main.build else {
            return
        }
        
        
        let twoSecsFromNow = DispatchTime.now() + 2
        
        DispatchQueue.main.asyncAfter(deadline: twoSecsFromNow) {
            SKStoreReviewController.requestReview(in: windowScene)
            UserDefaults.standard.lastVersionPromptedForReview = Bundle.main.build
        }
    }
}
