//
//  FeedbackGenerator.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/28.
//

import UIKit

class FeedbackGenerator {
    
    private var feedbackGenerator: UINotificationFeedbackGenerator? = nil
    
    private init () {
        feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator?.prepare()
    }
    
    static let shared = FeedbackGenerator()
    
    func feedback(isSuccess: Bool) {
        feedbackGenerator?.notificationOccurred(isSuccess ? .success : .error)
        feedbackGenerator?.prepare()
    }
}
