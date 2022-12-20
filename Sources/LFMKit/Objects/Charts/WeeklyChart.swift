//
//  File.swift
//  
//
//  Created by Adam Wienconek on 11/03/2021.
//

import Foundation

public class WeeklyChart<T: ChartItem>: Decodable {
    public let items: [T]
    
    public let user: String
    
    public let timestamp: ChartTimestamp
        
    // MARK: Codable
    private struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            self.stringValue = String(intValue)
            self.intValue = intValue
        }
        
        static var items: CodingKeys {
            return CodingKeys(stringValue: T.key)!
        }
        
        static var attributes: CodingKeys {
            return CodingKeys(stringValue: "@attr")!
        }
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        items = try container.decode([T].self, forKey: .items)
        let attributes = try container.decode([String: String].self, forKey: .attributes)
        
        guard let username = attributes["user"] else {
            throw LFMError.couldNotReadData
        }
        user = username
        
        guard let fromString = attributes["from"],
              let fromValue = UInt(fromString),
              let toString = attributes["to"],
                let toValue = UInt(toString) else {
            throw LFMError.couldNotReadData
        }
        timestamp = ChartTimestamp(from: fromValue, to: toValue)
    }
}
