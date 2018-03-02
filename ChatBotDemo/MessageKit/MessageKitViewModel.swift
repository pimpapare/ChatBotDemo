//
//  MessageKitViewModel.swift
//  ChatBotDemo
//
//  Created by pimpaporn chaichompoo on 3/2/2561 BE.
//  Copyright © 2561 pimpaporn chaichompoo. All rights reserved.
//

import UIKit

class MessageKitViewModel: NSObject {

    var viewInterfaceProtocol:MessageKitViewController!
    var modelProtocol:MessageKitProtocol!
    
    var model:MessageKitModel = MessageKitModel()

    required init(view:MessageKitViewController, viewControllerModel:MessageKitProtocol) {
        self.viewInterfaceProtocol = view
        self.modelProtocol = viewControllerModel
    }
}
