//
//  CMTime.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 20.6.22.
//

import Foundation
import AVKit

extension CMTime {
    
    func toDisplayString() -> String {
        if CMTimeGetSeconds(self).isNaN {
            return "--:--"
        }
        let totalSeconds = Int(CMTimeGetSeconds(self))
        let seconds = totalSeconds % 60
        let minutes = totalSeconds / 60
        let timeFormatString = String(format: "%02d:%02d", minutes, seconds)
        if totalSeconds >= 3600 {
            let seconds = totalSeconds % 60
            let minutes = totalSeconds % (60 * 60) / 60
            let hours = totalSeconds / 60 / 60
            let timeFormatString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            return timeFormatString
        }
        return timeFormatString
    }
    
}
