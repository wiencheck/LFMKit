//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/03/2021.
//

import Foundation

public struct WeeklyChartList: Decodable {
    public let charts: [ChartTimestamp]
    
    // MARK: Codable stuff
    private enum CodingKeys: String, CodingKey {
        case charts = "chart"
    }
}

struct WeeklyChartListResponse: Decodable {
    let chartList: WeeklyChartList
    
    // MARK: Codable stuff
    private enum CodingKeys: String, CodingKey {
        case chartList = "weeklychartlist"
    }
}
