//
//  MediQuo+Extension.swift
//  Mediquo Swift Example App
//
//  Created by David Martin on 09/01/2019.
//  Copyright © 2019 Edgar Paz Moreno. All rights reserved.
//

import MediQuo

extension MediQuo {
    internal enum UserInfo: String {
        case clientName = "MediQuoClientName"
        case clientSecret = "MediQuoClientSecret"
        case userToken = "MediQuoUserToken"
    }
    
    internal static func getUserInfo() -> [String: Any]? {
        return Bundle.main.infoDictionary
    }
    
    internal static func getUserToken() -> String? {
        if let userInfo = getUserInfo() {
            return userInfo[MediQuo.UserInfo.userToken.rawValue] as? String
        }
        return nil
    }

    internal static func getClientName() -> String? {
        if let userInfo = getUserInfo() {
            return userInfo[MediQuo.UserInfo.clientName.rawValue] as? String
        }
        return nil
    }

    internal static func getClientSecret() -> String? {
        if let userInfo = getUserInfo() {
            return userInfo[MediQuo.UserInfo.clientSecret.rawValue] as? String
        }
        return nil
    }
}
