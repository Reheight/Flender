//
//  CardViewController.swift
//  Flender
//
//  Created by Palmatier, Dustin on 12/19/19.
//  Copyright © 2019 Hexham Network. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var handleAreaSecondary: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Modifying handle to look better
        handleArea.layer.cornerRadius = 8
        handleAreaSecondary.layer.cornerRadius = 3
        
        
        // Do any additional setup after loading the view.
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
