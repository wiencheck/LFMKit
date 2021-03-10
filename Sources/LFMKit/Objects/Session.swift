//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

public struct Session: Codable {
    public let name: String
    
    let key: String
    
    var token: String? {
        didSet {
            tokenCreationDate = Date()
        }
    }
    
    private var tokenCreationDate: Date?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        key = try container.decode(String.self, forKey: .key)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        tokenCreationDate = try container.decodeIfPresent(Date.self, forKey: .tokenCreationDate)
    }
    
    public var isValid: Bool {
        guard token != nil,
              let creationDate = tokenCreationDate else {
            return false
        }
        let interval = Date().timeIntervalSince(creationDate)
        return interval < 60 * 60
    }
}

struct SessionResponse: Decodable {
    var session: Session
}
