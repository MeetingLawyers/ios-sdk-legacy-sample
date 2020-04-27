//
//  MediQuo+Extension.swift
//  Mediquo Swift Example App
//
//  Created by David Martin on 09/01/2019.
//  Copyright © 2019 Edgar Paz Moreno. All rights reserved.
//

import MediQuo

extension MediQuo {
    
    internal static func getUserToken() -> String {
        return "00000000A" // <#your demo user token#>
    }

    internal static func getClientName() -> String? {
        return "Asisa" ////<#your company name#>
    }

    internal static func getClientSecret() -> String? {
        return "tS347Jf56Idr5fD5" // <#your API Key#>
    }
}
