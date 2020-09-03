//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

final class LFMDateFormatter {
    static let shared = LFMDateFormatter()
    
    private let formatter: DateFormatter
    private init() {
        formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "en_US")
    }
    
    func convert(string date: String) -> Date? {
        return formatter.date(from: date)
    }
}
