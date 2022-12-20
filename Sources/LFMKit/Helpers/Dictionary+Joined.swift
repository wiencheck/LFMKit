//
//  File.swift
//  
//
//  Created by Adam Wienconek on 20/06/2022.
//

import Foundation

extension Dictionary {
    
    func joined(with other: Self) -> Self {
        var mutableSelf = self
        for entry in other {
            mutableSelf.updateValue(entry.value, forKey: entry.key)
        }
        
        return mutableSelf
    }
    
}
