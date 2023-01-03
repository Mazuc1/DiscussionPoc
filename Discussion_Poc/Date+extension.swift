//
//  Date+extension.swift
//  Discussion_Poc
//
//  Created by Loïc MAZUC on 20/09/2022.
//

import Foundation

extension Date {
    static func randomBetween(start: Date, end: Date) -> Date {
        var date1 = start
        var date2 = end
        if date2 < date1 {
            let temp = date1
            date1 = date2
            date2 = temp
        }
        let span = TimeInterval.random(in: date1.timeIntervalSinceNow...date2.timeIntervalSinceNow)
        return Date(timeIntervalSinceNow: span)
    }
    
    static func parse(_ string: String, format: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.default
        dateFormatter.dateFormat = format
        
        let date = dateFormatter.date(from: string)!
        return date
    }
    
    static func randomDate() -> Date {
        let date1 = Date.parse("2002-01-01")
        let date2 = Date.parse("2022-01-01")
        return Date.randomBetween(start: date1, end: date2)
    }
}
