//
//  CardViewController.swift
//  Flender
//
//  Created by Palmatier, Dustin on 12/19/19.
//  Copyright © 2019 Hexham Network. All rights reserved.
//

import UIKit
import SCSDKLoginKit
import SCLAlertView

class CardViewController: UIViewController {
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var handleAreaSecondary: UIView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var optionsTable: UITableView!
    @IBOutlet weak var identityView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Modifying handle to look better
        handleArea.layer.cornerRadius = 2
        handleAreaSecondary.layer.cornerRadius = 3
        shareButton.layer.cornerRadius = 0.5 * shareButton.bounds.size.width
        exitButton.layer.cornerRadius = 0.5 * exitButton.bounds.size.width
        // Do any additional setup after loading the view.
        //logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)

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
