//
//  LoginViewController.swift
//  Flender
//
//  Created by Palmatier, Dustin on 1/15/20.
//  Copyright © 2020 Hexham Network. All rights reserved.
//

import UIKit
import SCSDKLoginKit
import SCLAlertView

extension UIButton {
    func leftImage(image: UIImage, renderMode: UIImageRenderingMode) {
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width / 2)
        self.contentHorizontalAlignment = .left
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    func rightImage(image: UIImage, renderMode: UIImageRenderingMode){
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left:image.size.width / 2, bottom: 0, right: 0)
        self.contentHorizontalAlignment = .right
        self.imageView?.contentMode = .scaleAspectFit
    }
}

class LoginViewController: UIViewController {
    let loginButton = SCSDKLoginButton()
    @IBOutlet weak var snapchatButton: UIView!
    
    @IBOutlet weak var appName: UILabel!
    
    func setupLoginButton() {
        snapchatButton.layer.masksToBounds = true
        snapchatButton.layer.cornerRadius = 30
        snapchatButton.layer.borderColor = UIColor.black.cgColor
        snapchatButton.layer.borderWidth = 1
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(loginSnapchat))
        
        snapchatButton.addGestureRecognizer(singleTapGesture)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Transition to Login complete...")
        
        appName.layer.cornerRadius = 10
        appName.clipsToBounds = true
        
        setupLoginButton()
    }
    
    @objc
    func loginSnapchat() {
        SCSDKLoginClient.login(from: self) { (Bool, Error) in
            if (Bool) {
                DispatchQueue.main.async {
                    let alertViewResponder:SCLAlertViewResponder = SCLAlertView().showSuccess("You have logged in!", subTitle: "Select 'okay' to continue to Flender!")
                    
                    alertViewResponder.setDismissBlock {
                        let proceed = self.storyboard?.instantiateViewController(withIdentifier: "InitializationController")
                        self.present(proceed!, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
