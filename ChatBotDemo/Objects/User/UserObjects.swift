//
//  UserObjects.swift
//  ChatBotDemo
//
//  Created by pimpaporn chaichompoo on 3/2/2561 BE.
//  Copyright © 2561 pimpaporn chaichompoo. All rights reserved.
//

import UIKit
import CoreAPIs
import RealmSwift

class UserProfile: Object {

    @objc dynamic var username:String = ""
    
    override class func primaryKey() -> String? {
        return "username"
    }
}

open class UserObjectsManagement: NSObject {
    
    let realm = try! Realm()
    var count:Int = 0
    
    open static let sharedInstance = UserObjectsManagement()

    func writeObjects(withObjects object: UserCredentials) {
        
        let userProfile = UserInformation()
        
        userProfile.username = object.username
        userProfile.password = object.password
        userProfile.ticket = object.ticket

        try! realm.write {
            realm.add(userProfile)
        }
    }
    
    func removeObjects(){
        
        try! realm.write {
            realm.delete(realm.objects(UserInformation.self))
        }
    }
    
    func getObjects() -> UserInformation?{
        
        if let objects = realm.objects(UserInformation.self).first  {
            return objects
        }
        
        count = count + 1
        
        if count == 3 {
            count = 0
            return nil
        }
        
        return getObjects()
    }
}

class UserInformation: Object {
    
    @objc dynamic var username:String?
    @objc dynamic var password:String?
    @objc dynamic var ticket:String?
}
