//
//  UserInfoViewController.swift
//  FacebookLoginTest
//
//  Created by Matheus Pacheco Fusco on 09/03/17.
//  Copyright © 2017 Matheus Pacheco Fusco. All rights reserved.
//

import UIKit
import SDWebImage

class UserInfoViewController: UIViewController {
    
    //MARK: - Variables
    public var user : UserModel = UserModel()
    
    //MARK: - IBOutlets
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        if let id = user.id {
            userIDLabel.text = "\(id)"
        }
        if let imageURL = user.imageURL {
            userImgView.sd_setImage(with: NSURL(string: "\(imageURL)") as URL?)
        }
        if let name = user.name {
            userNameLabel.text = name
        }
        if let email = user.email {
            userEmailLabel.text = email
        }
    }
    

    //MARK: - Memory Management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
