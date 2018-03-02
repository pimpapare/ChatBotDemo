//
//  MessageObjects.swift
//  ChatBotDemo
//
//  Created by pimpaporn chaichompoo on 3/2/2561 BE.
//  Copyright © 2561 pimpaporn chaichompoo. All rights reserved.
//

import UIKit
import CoreAPIs
import RealmSwift

class MessageObjects: Object {
    
    @objc dynamic var messageID:String = ""
    
    override class func primaryKey() -> String? {
        return "messageID"
    }
}

open class MessageObjectsManagement: NSObject {
    
    let realm = try! Realm()
    var count:Int = 0
    
    open static let sharedInstance = MessageObjectsManagement()
    
    func writeObjects(withObjects object: [String:String]) {
        
        let messageObjects = MessageObjects()
        
//        userProfile.messageID =
        
            
        try! realm.write {
            realm.add(messageObjects)
        }
    }
    
    func removeObjects(){
        
        try! realm.write {
            realm.delete(realm.objects(MessageObjects.self))
        }
    }
    
    func getObjects() -> MessageObjects?{
        
        if let objects = realm.objects(MessageObjects.self).first  {
            return objects
        }
        
        count = count + 1
        
        if count == 3 {
            count = 0
            return nil
        }
        
        return getObjects()
    }
    
    func getObjectsWitLimit(startLimit:Int,endLimit:Int) -> MessageObjects?{
        
        if let objects = realm.objects(MessageObjects.self).filter("sth = sth").get(offset: startLimit, limit: endLimit)  {
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

class MessageInformation: Object {
    
    @objc dynamic var password:String?
    @objc dynamic var ticket:String?
}
