//
//  ViewController.swift
//  ChatBotDemo
//
//  Created by pimpaporn chaichompoo on 3/1/2561 BE.
//  Copyright © 2561 pimpaporn chaichompoo. All rights reserved.
//

import UIKit
import CoreAPIs

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyUserObjects()
    }
    
    func verifyUserObjects() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let userObjects = UserAccount.sharedInstance.fetchUserAccount()
        
        if userObjects == nil {
            
            let userAccount:UserCredentials = UserCredentials(username:"appletest", password:"appletest", ticket: "")
            
            UserAPIs.sharedInstance.login(userAccount) { (result, error) in
                
                if result == nil {
                    // error message
                    return
                }
                
                UserObjectsManagement.sharedInstance.writeObjects(withObjects: result!)
                
                print("👽 USERNAME: ",result?.username ?? "")
                
                self.prepareUserProfile(alreadyLogin: false, username: result?.username ?? "")
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                    self.goToMessageKitViewController()
                }
            }
            
        }else{
            
            prepareUserProfile(alreadyLogin: true,username: userObjects?.username ?? "")

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                self.goToMessageKitViewController()
            }
        }
    }
    
    func prepareUserProfile(alreadyLogin:Bool, username:String) {
        
        let usernameLabel:UILabel = UILabel(frame: CGRect(x: 0, y: (UIScreen.main.bounds.height / 2) - 20, width: UIScreen.main.bounds.width, height: 40))
        usernameLabel.numberOfLines = 0
        usernameLabel.textAlignment = .center
        usernameLabel.textColor = (alreadyLogin) ? UIColor.darkGray:UIColor.red
        usernameLabel.text = username
        self.view.addSubview(usernameLabel)
    }
    
    func goToMessageKitViewController() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        let storyBoard = UIStoryboard(name: "Main" , bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier : "MessageKitViewController") as! MessageKitViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

