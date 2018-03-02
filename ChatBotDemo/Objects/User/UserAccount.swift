//
//  UserAccount.swift
//  ChatBotDemo
//
//  Created by pimpaporn chaichompoo on 3/2/2561 BE.
//  Copyright © 2561 pimpaporn chaichompoo. All rights reserved.
//

import UIKit

struct UserDetails {
    static var userLoginName:String = ""
}

open class UserAccount: NSObject {
    
    open static let sharedInstance = UserAccount()
    
    func fetchUserAccount() -> UserProfile? {
        let userObjects:UserObjectsManagement = UserObjectsManagement()
        return userObjects.getObjects()
    }
}

