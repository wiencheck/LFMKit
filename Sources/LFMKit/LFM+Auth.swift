//
//  File.swift
//  
//
//  Created by Adam Wienconek on 01/09/2020.
//

import Foundation
import Alamofire

public extension LFM {
    class Auth {
        private static let sessionUserDefaultsKey = "LFMSessionUserDefaultsKey"
        
        public private(set)var session: Session? {
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
        
        public func renewSession(success: (() -> Void)? = nil, failure: ((Error) -> Void)? = nil) {
            if session == nil {
                print("*** Session cannot be nil")
                return
            }
            
            token(success: { token in
                self.session?.token = token
                success?()
            }, failure: failure)
        }
        
        public func removeSession() {
            session = nil
        }
        
        private func token(success: @escaping (String) -> Void, failure: ((Error) -> Void)? = nil) {
            guard !LFM.apiKey.isEmpty else {
                print("*** 'clientKey' cannot be empty")
                return
            }
            let method = Method.token
            let params = [
                "api_key": LFM.apiKey,
                "format": "json"
            ]
            guard let url = method.composed(with: params) else {
                failure?(LFMError(message: "Failed to create url for method: \(method)"))
                print("*** Failed to create url for method: \(method)\nParams:\n\(params)")
                return
            }
            
            Alamofire.request(url).responseData { response in
                if let error = response.error {
                    failure?(error)
                }
                guard let data = response.value else {
                    return
                }
                if let error = try? JSONDecoder().decode(LFMError.self, from: data) {
                    failure?(error)
                } else if let tokenResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) {
                    success(tokenResponse.token)
                }
            }
        }
        
        public func authenticate(username: String, password: String, success: @escaping (Session) -> Void, failure: ((Error) -> Void)? = nil) {
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
                
                guard let url = AuthenticatedMethod.session.composed(with: params) else {
                    failure?(LFMError(message: "Failed to create url for method: \(method)"))
                    print("*** Failed to create url for method: \(method)\nParams:\n\(params)")
                    return
                }
                Alamofire.request(url, method: .post).responseData { response in
                    if let error = response.error {
                        failure?(error)
                        return
                    }
                    guard let data = response.value else {
                        return
                    }
                    if let error = try? JSONDecoder().decode(LFMError.self, from: data) {
                        failure?(error)
                    } else if let sessionResponse = try? JSONDecoder().decode(SessionResponse.self, from: data) {
                        var session = sessionResponse.session
                        session.token = token
                        self.session = session
                        success(session)
                    }
                }
            }
            // Get token
            token(success: { token in
                // Session does not need updating
                if var session = self.session {
                    session.token = token
                    self.session = session
                    success(session)
                    return
                }
                updateSession(with: token)
            }, failure: failure)
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
    }
}
