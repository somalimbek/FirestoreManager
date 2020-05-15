//
//  Date.swift
//  Sportsfella
//
//  Created by Limbek Soma on 2020. 04. 30..
//  Copyright © 2020. Soma Limbek. All rights reserved.
//

import Foundation

extension Date {
    
    // MARK: - Properties
    
    public var day: DateComponents {
        Calendar.current.dateComponents([.calendar, .year, .month, .day], from: self)
    }
    
    public var month: DateComponents {
        Calendar.current.dateComponents([.calendar, .year, .month], from: self)
    }
    
    public static var now: Date { Date() }
    
    // MARK: - Enums
    
    public enum Weekday: Int {
        case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    }
    
    // MARK: - Methods
    
    public func addingDateComponents(_ dateComponents: DateComponents) -> Date? {
        Calendar.current.date(byAdding: dateComponents, to: self)
    }
    
    public func at(hour: Int, minute: Int, second: Int) -> Date? {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: self)
    }
    
    public func next(_ weekday: Weekday, direction: Calendar.SearchDirection = .forward, considerToday: Bool = false) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(weekday: weekday.rawValue)
        
        if considerToday &&
            calendar.component(.weekday, from: self) == weekday.rawValue
        {
            return self
        }
        
        return calendar.nextDate(after: self, matching: components, matchingPolicy: .nextTime, direction: direction)!
    }
}
