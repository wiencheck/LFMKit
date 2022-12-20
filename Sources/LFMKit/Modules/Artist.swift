//
//  File.swift
//  
//
//  Created by Adam Wienconek on 20/06/2022.
//

import Foundation

public extension LFM {
    
    enum Artist {
        
        public static func getInfo(name: String, completion: @escaping (Result<LFMArtist, Error>) -> Void) {
            var params = LFM.defaultParams
            
            params["artist"] = name
            
            LFM.call(method: GetArtistInfo(), queryParams: params) { (result: Result<ArtistResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.artist))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        private struct GetArtistInfo: LFMMethod {
            var name: String { "artist.getinfo" }
            var httpMethod: HTTPMethod { .get }
        }
        
    }
    
}
