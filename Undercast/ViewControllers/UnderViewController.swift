//
//  UnderViewController.swift
//  Undercast
//
//  Created by Malij on 3/1/17.
//  Copyright © 2017 Coybit. All rights reserved.
//

import UIKit
import ChameleonFramework

class UnderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setStatusBarStyle(UIStatusBarStyleContrast)
        self.navigationController?.hidesNavigationBarHairline = true;
        self.navigationController?.navigationBar.barTintColor = UIColor.flatOrange();
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
