//
//  ITCLoginViewController.swift
//  ITC
//
//  Created by YunTu on 2017/5/15.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit

class ITCLoginViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginBtn.layer.cornerRadius = 4
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

    @IBAction func loginDidClick(_ sender: Any) {
        self.performSegue(withIdentifier: "mainPush", sender: nil)
    }
    
}
