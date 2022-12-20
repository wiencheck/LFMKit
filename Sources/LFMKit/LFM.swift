import Foundation

public struct LFM {
    
    /**
     Your API key obtained from Last.fm.
     */
    public static var apiKey = ""
    
    /**
     Your secret key obtained from Last.fm.
     Secret is used for calls requiring authentication, like `scrobble`, or `updateNowPlaying`.
     */
    public static var apiSecret = ""
    
    /**
     Requested language of `getInfo` calls.
     */
    public static var language = "en"
    
    @available(*, unavailable)
    init() {}
    
    static var defaultParams: [String: String] {
        return [
            "api_key": apiKey,
            "lang": language,
            "format": "json"
        ]
    }
    
    static var defaultAuthParams: [String: String] {
        var params = [
            "api_key": apiKey
        ]
        if let sk = LFM.Auth.session?.key {
            params["sk"] = sk
        }
        return params
    }
    
    static func call<M, T>(method: M, queryParams: [String: String]?, completion: @escaping (Result<T, Error>) -> Void) where M: LFMMethod, T: Decodable {
        guard let request = method.request(with: queryParams) else {
            completion(.failure(LFMError.invalidRequest))
            return
        }
        
        perform(request: request, completion: completion)
    }
    
    static func call<M>(method: M, queryParams: [String: String]?, completion: ((Error?) -> Void)?) where M: LFMMethod {
        guard let request = method.request(with: queryParams) else {
            completion?(LFMError.invalidRequest)
            return
        }
        
        perform(request: request, completion: completion)
    }
    
}

private extension LFM {
    
    static func perform<T>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data, !data.isEmpty else {
                completion(.failure(LFMError.couldNotReadData))
                return
            }
            guard httpResponse.statusCode == 200 else {
                let lfmError = (try? LFMJSONDecoder().decode(LFMError.self, from: data)) ?? LFMError.unknown
                completion(.failure(lfmError))
                return
            }
            do {
                let decoded = try LFMJSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
        }.resume()
    }
    
    static func perform(request: URLRequest, completion: ((Error?) -> Void)?) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion?(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data, !data.isEmpty else {
                completion?(LFMError.couldNotReadData)
                return
            }
            if httpResponse.statusCode == 200 {
                completion?(nil)
                return
            }
            do {
                let decoded = try LFMJSONDecoder().decode(LFMError.self, from: data)
                completion?(decoded)
            } catch let decodingError {
                completion?(decodingError)
            }
        }.resume()
    }
    
}
