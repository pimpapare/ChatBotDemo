//
//  MessageKitViewModel.swift
//  ChatBotDemo
//
//  Created by pimpaporn chaichompoo on 3/2/2561 BE.
//  Copyright © 2561 pimpaporn chaichompoo. All rights reserved.
//

import UIKit
import AI
import CoreAPIs

import Foundation

open class Parameter  : NSObject {
    
    open var key : String!
    open var value : String!
    
    public init(key: String,value: String){
        
        self.key = key
        self.value = value
    }
}

class MessageKitViewModel: NSObject {
    
    var viewController:MessageKitViewController!
    var model:MessageKitModel = MessageKitModel()
    
    var parameters:[Parameter] = [Parameter]()
        
    required init(view:MessageKitViewController) {
        self.viewController = view
    }
    
    func sendTextRequest(text:String?) {
        
        print("📱 Text Request: ",text ?? "")
        
        if text != nil, text?.count != 0 {
            
            AI.sharedService.textRequest(text!).success { (response) -> Void in
                
                print("REQUEST ",response)
                
                self.verifyResult(result: response)
                
                if let textResponse = response.result.fulfillment?.speech {
                    self.viewController.textResponseSuccess(text: textResponse)
                }
                
                }.failure { (error) -> Void in
                    
                    print("🚨 ERROR: ",error.localizedDescription)
                    self.viewController.textResponseError()
            }
            
        } else {
            viewController.textResponseError()
        }
    }
    
    func verifyResult(result:QueryResponse) {
        
        var completeResult:Bool = true
        
        for obj in result.result.parameters!{
            print("💛 ",obj.value)
            if obj.value as? String ?? "" == "" || obj.value == nil {
                completeResult = false
            }
        }
        
        if completeResult == true { // mean result of summary
            
            for parameter in result.result.parameters! {
                let parameter = Parameter(key: parameter.key, value: parameter.value as? String ?? "")
                parameters.append(parameter)
            }
        }
        
        if result.result.metadata.intentName == "create.appointment.confirm" {
            
            var mutableAppointment: Appointment!
            mutableAppointment = Appointment(withIdentifier: "")
            
            let callHandlingType = verifyCallHandlingType(text: parameters[0].value).rawValue
            mutableAppointment.callHandling = CallHandling(withInstructionID: "\(callHandlingType)")
            mutableAppointment.callHandling?.instructionID = "\(callHandlingType)"
            mutableAppointment.callHandling?.isDefault = false
            mutableAppointment.callHandling?.isProfile = false
            mutableAppointment.callHandling?.profileName = "text"
            mutableAppointment.callHandling?.message = parameters[1].value
            
            parameters = [Parameter]()
            self.createDefaultCellHandling(appointment: mutableAppointment)
        }
    }

    func verifyCallHandlingType(text:String) -> MobileCallHandlingType{
     
        if text.lowercased().range(of: "vip") != nil{
            return MobileCallHandlingType.forwardingOnlyVIP
        }else if text.lowercased().range(of: "all") != nil || text.lowercased().range(of: "everybody") != nil {
            return MobileCallHandlingType.forwardingAll
        }else {
            return MobileCallHandlingType.notForwarding
        }
    }
    
    func jsonObject(withCallHandling callHandling: CallHandling) -> [String: AnyObject] {
        
        var cchObject = [String: AnyObject]()
        
        if let identifier = callHandling.identifier, !identifier.isEmpty {
            cchObject["identifier"] = identifier as AnyObject?
        }
        if let value = callHandling.message {
            cchObject["message"] = value as AnyObject?
        }
        if let value = callHandling.profileName {
            cchObject["profileName"] = value as AnyObject?
        }
        if let value = callHandling.instructionID {
            cchObject["instructionID"] = value as AnyObject?
        }
        if callHandling.isProfile {
            cchObject["profile"] = "true" as AnyObject?
        } else {
            cchObject["profile"] = "false" as AnyObject?
        }
        if callHandling.isDefault {
            cchObject["defaultProfile"] = "true" as AnyObject?
        } else {
            cchObject["defaultProfile"] = "false" as AnyObject?
        }
        
        return cchObject
    }
    
    func createDefaultCellHandling(appointment:Appointment) {
        
        let userAccount = UserAccount.sharedInstance.fetchUserAccount()
        let userCredential = UserCredentials(username: userAccount?.username ?? "", password: userAccount?.password ?? "", ticket: userAccount?.ticket ?? "")
        
        let callHandlingInfo = jsonObject(withCallHandling: appointment.callHandling!)
        DayAgendaAPIs.sharedInstance.updateDefaultCallHandling(callHandlingInfo, forUser: userCredential) { (success, error) in
            
            print("📆 Create Default Appointment Status: ",success)
            self.viewController.textResponseSuccess(text: "I have done to create appointment for you.")
        }
    }
}
