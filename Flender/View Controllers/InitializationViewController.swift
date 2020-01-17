//
//  InitializationViewController.swift
//  Flender
//
//  Created by Palmatier, Dustin on 1/15/20.
//  Copyright © 2020 Hexham Network. All rights reserved.
//

import UIKit
import SCSDKLoginKit
import SCLAlertView

class InitializationViewController: UIViewController {
    @IBOutlet weak var logoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoLabel.layer.cornerRadius = 10
        logoLabel.clipsToBounds = true
        print("Initializing data...")
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initialize()
    }
    
    func initialize() {
        let graphQLQuery = "{me{externalId, displayName, bitmoji{avatar}}}"
        
        SCSDKLoginClient.fetchUserData(withQuery: graphQLQuery, variables: nil, success: { (resources: [AnyHashable: Any]?) in
            guard let resources = resources,
                let data = resources["data"] as? [String: Any],
                let me = data["me"] as? [String: Any] else { return }
            
            let externalId = me["externalId"] as? String
            let displayName = me["displayName"] as? String
            var bitmojiAvatarUrl: String?
            if let bitmoji = me["bitmoji"] as? [String: Any] {
                bitmojiAvatarUrl = bitmoji["avatar"] as? String
            }
            
            DataStructure.sharedInstance.setDisplayName(string: displayName ?? "3940ejfkfi9483jro39ut43jti943uh94u3hrif9ru3h4")
            DataStructure.sharedInstance.setBitmojiUrl(string: bitmojiAvatarUrl ?? "error")
            DataStructure.sharedInstance.setExternalId(string: externalId!)
            
            DispatchQueue.main.async {
                let proceed = self.storyboard?.instantiateViewController(withIdentifier: "HomeController")
                self.present(proceed!, animated: true, completion: nil)
            }
        }, failure: { (error: Error?, isUserLoggedOut: Bool) in
            if (isUserLoggedOut) {
                DispatchQueue.main.async {
                    let proceed = self.storyboard?.instantiateViewController(withIdentifier: "LoginController")
                    self.present(proceed!, animated: true, completion: nil)
                }
            } else {
                let alertViewResponder:SCLAlertViewResponder = SCLAlertView().showError("Oh no we hit a snag!", subTitle: "There was an issue while connecting to Snapchat servers!")
                
                alertViewResponder.setDismissBlock {
                    self.initialize()
                }
            }
        })
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
