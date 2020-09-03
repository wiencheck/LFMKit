//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

struct Wiki: Codable {
    public let content: String
        
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var con = try container.decode(String.self, forKey: .content)
        
        // Cut hyperlink at the end.
        if let linkRange = con.range(of: "<a href") {
            con.removeSubrange(linkRange.lowerBound ..< con.endIndex)
        }
        con = con.trimmingCharacters(in: .whitespaces)
        if con.isEmpty {
            throw LFMError(message: "wiki/content was empty")
        }
        // Add dot at the end.
        if con.last != "." {
            con += "."
        }
        content = con
    }
}
