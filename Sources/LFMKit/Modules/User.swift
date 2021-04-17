//
//  File.swift
//  
//
//  Created by Adam Wienconek on 10/03/2021.
//

import Foundation

public extension LFM {
    enum User {
        public static func getWeeklyChartList(username: String? = nil, completion: @escaping (Result<[ChartTimestamp], Error>) -> Void) {
            guard let username = username ?? Auth.session?.name else {
                return
            }
            var params = LFM.defaultParams
            params["user"] = username
            
            LFM.call(method: Method.weeklyChartList, queryParams: params) { (result: Result<WeeklyChartListResponse, Error>) in
                switch result {
                case .success(let response):
                    let chartList = response.chartList
                    completion(.success(chartList.charts))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        public static func getWeeklyTrackChart(username: String? = nil, from: UInt? = nil, to: UInt? = nil, completion: @escaping (Result<WeeklyTrackChart, Error>) -> Void) {
            guard let username = username ?? Auth.session?.name else {
                return
            }
            var params = LFM.defaultParams
            params["user"] = username
            if let from = from {
                params["from"] = String(from)
            }
            if let to = to {
                params["to"] = String(to)
            }
            
            LFM.call(method: Method.weeklyTrackChart, queryParams: params) { (result: Result<WeeklyTrackChartResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.chart))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        private enum Method: String, LFMMethod {
            case weeklyChartList = "user.getWeeklyChartList"
            case weeklyTrackChart = "user.getWeeklyTrackChart"
            
            var httpMethod: HTTPMethod {
                return .get
            }
        }
    }
}
