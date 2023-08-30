//
//  Extensions.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 23/7/23.
//

import Foundation
import UIKit

extension UIView {
    
    var width: CGFloat {
        return frame.size.width
    }
    
    var height: CGFloat {
        return frame.size.height
    }
    
    var left: CGFloat {
        return frame.origin.x
    }
    
    var right: CGFloat {
        return left + width
    }
    
    var top: CGFloat {
        return frame.origin.y
    }
    
    var botton: CGFloat {
        return top + height
    }
}

extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let dataFormatter = DateFormatter()
        dataFormatter.dateFormat = "YYYY-MM-dd"
        return dataFormatter
    }()
    
    static let displayDateFormatter: DateFormatter = {
        let dataFormatter = DateFormatter()
        dataFormatter.dateStyle = .medium
        return dataFormatter
    }()
}

extension String {
    static func formattedDate(string: String) -> String {
        guard let date = DateFormatter.dateFormatter.date(from: string) else {
            return string
        }
        return DateFormatter.displayDateFormatter.string(from: date)
    }
}

extension Notification.Name {
    static let albumSavedNotification = Notification.Name("albumSavedNotification")
}
