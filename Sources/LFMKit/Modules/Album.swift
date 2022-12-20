//
//  File.swift
//  
//
//  Created by Adam Wienconek on 20/06/2022.
//

import Foundation

public extension LFM {
    
    enum Album {
        public static func getInfo(name: String, artist: String, completion: @escaping (Result<LFMAlbum, Error>) -> Void) {
            var params = LFM.defaultParams
            
            params["album"] = name
            params["artist"] = artist
            
            LFM.call(method: GetAlbumInfo(), queryParams: params) { (result: Result<AlbumResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.album))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        private struct GetAlbumInfo: LFMMethod {
            var name: String { "album.getinfo" }
            var httpMethod: HTTPMethod { .get }
        }
        
    }
    
}
