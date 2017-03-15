//
//  LoginViewController.swift
//  FacebookLoginTest
//
//  Created by Matheus Pacheco Fusco on 09/03/17.
//  Copyright © 2017 Matheus Pacheco Fusco. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import GoogleSignIn

class LoginViewController: UIViewController {

    //MARK: - Variables and Structs
    var user : UserModel = UserModel()
    
    struct MyProfileRequest: GraphRequestProtocol {
        struct Response: GraphResponseProtocol {
            
            fileprivate let rawResponse: Any?
            
            public init(rawResponse: Any?) {
                self.rawResponse = rawResponse
            }
            
            public var dictionaryValue: [String : Any]? {
                return rawResponse as? [String : Any]
            }
            
            public var arrayValue: [Any]? {
                return rawResponse as? [Any]
            }
            
            public var stringValue: String? {
                return rawResponse as? String
            }
        }
        
        var graphPath = "/me"
        var parameters: [String : Any]? = ["fields": "id, name, email"]
        var accessToken = AccessToken.current
        var httpMethod: GraphRequestHTTPMethod = .GET
        var apiVersion: GraphAPIVersion = .defaultVersion
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let facebookButton = UIButton(type: .custom)
        facebookButton.backgroundColor = UIColor.blue
        facebookButton.frame = CGRect(x: 0, y: 0, width: 200, height: 30)
        facebookButton.center = self.view.center
        facebookButton.setTitle("Login with Facebook", for: .normal)
        facebookButton.addTarget(self, action: #selector(facebookButtonClicked), for: .touchUpInside)
        self.view.addSubview(facebookButton)
        
        
        GIDSignIn.sharedInstance().delegate = self
        let googleButton = UIButton(type: .custom)
        googleButton.backgroundColor = UIColor.red
        googleButton.frame = CGRect(x: facebookButton.frame.origin.x, y: facebookButton.frame.origin.y + 38, width: 200, height: 30)
        googleButton.setTitle("Login with Google", for: .normal)
        googleButton.addTarget(self, action: #selector(googleButtonClicked), for: .touchUpInside)
        self.view.addSubview(googleButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let loginManager = LoginManager()
        loginManager.logOut()
        
        GIDSignIn.sharedInstance().signOut()
    }

    //MARK: - Button Actions
    @objc func googleButtonClicked() {
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc func facebookButtonClicked() {
        
        let loginManager = LoginManager()

        loginManager.logIn([.publicProfile, .email], viewController: self) { (result) in
            switch result {
            
            case .success/*(let granted, let declided, let userToken)*/:
                
                let connection = GraphRequestConnection()
                connection.add(MyProfileRequest()) { response, result in
                    switch result {
                    case .success(let response):
                        //print("Custom Graph Request Succeeded: \(response.dictionaryValue?["id"]) \(response.dictionaryValue?["name"]) \(response.dictionaryValue?["email"])")
                        
                        let id = response.dictionaryValue?["id"] as! String?
                        self.user.id    = id
                        self.user.name  = response.dictionaryValue?["name"]  as! String?
                        self.user.email = response.dictionaryValue?["email"] as! String?
                        self.user.imageURL = "http://graph.facebook.com/\(id!)/picture?type=large"
                        
                        self.performSegue(withIdentifier: "showUserInfo", sender: self)
                    case .failed(let error):
                        print("Custom Graph Request Failed: \(error)")
                    }
                }
                connection.start()
                
                break
                
            case .failed(let error):
                    print("Failed: \(error)")
                break
                
            case .cancelled:
                print("User canceled login")
                break
            }
        }
    }
    
    //MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showUserInfo" {
            let infoVC = segue.destination as! UserInfoViewController
            infoVC.user = self.user
        }
    }
    

}

//extension LoginViewController : GIDSignInUIDelegate {
//    
//}

//MARK: - Google Sign In Delegate Methods
extension LoginViewController : GIDSignInDelegate {
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            //let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            //let givenName = user.profile.givenName
            //let familyName = user.profile.familyName
            let email = user.profile.email
            if user.profile.hasImage {
                let imageURL = user.profile.imageURL(withDimension: 120)
                self.user.imageURL = imageURL?.absoluteString
            }
            // ...
            self.user.id    = userId!
            self.user.name  = fullName
            self.user.email = email
            
            self.performSegue(withIdentifier: "showUserInfo", sender: self)
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}



extension LoginViewController : GIDSignInUIDelegate {
    
}
