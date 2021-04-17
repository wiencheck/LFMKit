//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/03/2021.
//

import Foundation

public struct ChartTimestamp: Decodable {
    public let from: UInt
    
    public let to: UInt
    
    init(from: UInt, to: UInt) {
        self.from = from
        self.to = to
    }
    
    public var fromDate: Date {
        let time = TimeInterval(from)
        return Date(timeIntervalSince1970: time)
    }
    
    public var toDate: Date {
        let time = TimeInterval(to)
        return Date(timeIntervalSince1970: time)
    }
    
    // - MARK: Codable stuff
    private enum CodingKeys: String, CodingKey {
        case fromEpochTimestamp = "from"
        case toEpochTimestamp = "to"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fromEpochTimestampString = try container.decode(String.self, forKey: .fromEpochTimestamp)
        let toEpochTimestampString = try container.decode(String.self, forKey: .toEpochTimestamp)
        guard let fromTimestamp = UInt(fromEpochTimestampString),
              let toTimestamp = UInt(toEpochTimestampString) else {
            throw LFMError.couldNotReadData
        }
        from = fromTimestamp
        to = toTimestamp
    }
}
