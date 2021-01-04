//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation

public extension LFM {
    enum Auth {
        private static let sessionUserDefaultsKey = "LFMSessionUserDefaultsKey"
        
        public private(set) static var session: Session? {
            get {
                guard let data = UserDefaults.standard.data(forKey: Auth.sessionUserDefaultsKey),
                    let decoded = try? JSONDecoder().decode(Session.self, from: data) else {
                        return nil
                }
                return decoded
            } set {
                guard let newValue = newValue,
                    let data = try? JSONEncoder().encode(newValue) else {
                        UserDefaults.standard.removeObject(forKey: Auth.sessionUserDefaultsKey)
                        return
                }
                UserDefaults.standard.set(data, forKey: Auth.sessionUserDefaultsKey)
            }
        }
        
        public static func renewSession(completion: ((Error?) -> Void)?) {
            if session == nil {
                print("*** Session cannot be nil")
                return
            }
            
            token { result in
                switch result {
                case .success(_):
                    completion?(nil)
                case .failure(let error):
                    completion?(error)
                }
            }
        }
        
        public static func removeSession() {
            session = nil
        }
        
        private static func token(completion: @escaping (Result<String, Error>) -> Void) {
            guard !LFM.apiKey.isEmpty else {
                print("*** 'clientKey' cannot be empty")
                return
            }
            let params = [
                "api_key": LFM.apiKey,
                "format": "json"
            ]
            
            LFM.shared.call(method: Method.token, queryParams: params) { (result: Result<TokenResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.token))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        public static func authenticate(username: String, password: String, completion: @escaping (Result<Session, Error>) -> Void) {
            guard !LFM.apiKey.isEmpty && !LFM.apiSecret.isEmpty else {
                print("*** 'clientKey' cannot be empty")
                return
            }
            
            func updateSession(with token: String) {
                var params = [
                    "username": username,
                    "password": password,
                    "api_key": LFM.apiKey
                ]
                
                let method = AuthenticatedMethod.session
                params["api_sig"] = method.signed(with: params)
                // Default format is XML but we want Jason!
                params["format"] = "json"
                
                LFM.shared.call(method: method, queryParams: params) { (result: Result<SessionResponse, Error>) in
                    switch result {
                    case .success(let response):
                        var newSession = response.session
                        newSession.token = token
                        self.session = newSession
                        completion(.success(newSession))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
            // Get token
            token { result in
                switch result {
                case .success(let token):
                    // Session does not need updating
                    if var session = self.session {
                        session.token = token
                        self.session = session
                        completion(.success(session))
                        return
                    }
                    updateSession(with: token)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

extension LFM.Auth {
    enum Method: String, LFMMethod {
        /**
         Parameters for this method are:
         -  api_key
         -  api_sig
         */
        case token = "auth.gettoken"
        
        var httpMethod: HTTPMethod {
            return .get
        }
    }
    
    enum AuthenticatedMethod: String, LFMAuthenticatedMethod {
        /**
         Parameters for this method are:
         -  password
         -  username
         -  api_key
         -  api_sig
         */
        case session = "auth.getMobileSession"
        
        var httpMethod: HTTPMethod {
            return .post
        }
    }
}
