//
//  ViewController.swift
//  GRD Example
//
//  Created by Kien Vuong on 5/10/18.
//  Copyright © 2018 GameReward. All rights reserved.
//

import UIKit
import GameReward_SDK

class LoginViewController: UIViewController {
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var indicationLogin: UIActivityIndicatorView!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var txtMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GREEN_THEME
        GameReward.Init(appId: "cc8b8744dbb1353393aac31d371af9a55a67df16", secret: "1679091c5a880faf6fb5e6087eb1b2dc4daa3db355ef2b0e64b472968cb70f0df4be00279ee2e0a53eafdaa94a151e2ccbe3eb2dad4e422a7cba7b261d923784")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func OnLoginClick(_ sender: Any) {
        if txtUsername.text != "" && txtPassword.text != ""
        {
            txtMessage.text = " "
            indicationLogin.startAnimating()
            let button : UIButton = sender as! UIButton
            button.isUserInteractionEnabled = false
            button.setTitle("Logging In", for: UIControlState.disabled)
            GameReward.Login(username: txtUsername.text!, password: txtPassword.text!, otp: "") { (error, message, args) in
                if error == 0{
                    DispatchQueue.main.async{
                        self.LoginDone()
                    }
                    
                }else{
                    DispatchQueue.main.async{
                        self.LoginFailed(message : message)
                    }
                }
            }
            
        }
    }
    
    private func LoginDone() -> Void{
        let viewController:UIViewController = self.storyboard!.instantiateViewController(withIdentifier: "MainViewController") as UIViewController
        // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
        
        self.present(viewController, animated: true, completion: nil)
    }
    
    private func LoginFailed(message : String) -> Void{
        indicationLogin.stopAnimating()
        btnLogin.isUserInteractionEnabled=true
        btnLogin.setTitle("Log In", for: UIControlState.normal)
        txtMessage.text = message
    }
    
    @IBAction func RegisterToLogin(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

