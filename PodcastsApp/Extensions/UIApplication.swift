//
//  UIApplication.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 18.7.22.
//

import Foundation
import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        return shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first?.rootViewController as? MainTabBarController
    }
}
