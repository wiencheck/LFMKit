//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/03/2021.
//

import Foundation

public typealias WeeklyAlbumChart = WeeklyChart<LFMChartAlbum>

class WeeklyAlbumChartResponse: Decodable {
    let chart: WeeklyTrackChart
    
    private enum CodingKeys: String, CodingKey {
        case chart = "weeklyalbumchart"
    }
}
