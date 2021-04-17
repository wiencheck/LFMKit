//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/03/2021.
//

import Foundation

public typealias WeeklyArtistChart = WeeklyChart<LFMChartArtist>

struct WeeklyArtistChartResponse: Decodable {
    let chart: WeeklyTrackChart
    
    private enum CodingKeys: String, CodingKey {
        case chart = "weeklyartistchart"
    }
}
