//
//  ITCLoginViewController.swift
//  ITC
//
//  Created by YunTu on 2017/5/15.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD

class ITCLoginViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var phoneNum: PhoneTextField!
    @IBOutlet weak var verifyTextField: CodeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginBtn.layer.cornerRadius = 4
        verifyTextField.sendCodeBtn?.addTarget(self, action: #selector(startCount(_:)), for: .touchUpInside)
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
    func startCount(_ sender: UIButton) -> Void {
        if phoneNum.text?.characters.count != 11 {
            SVProgressHUD.showError(withStatus: "请正确输入手机号")
            return
        }
        SVProgressHUD.show()
        NetworkModel.requestGet([:], url: "http://112.74.124.86/ybb/index.php?app=appsdefault&act=banner_list") { (dic) in
            SVProgressHUD.dismiss()
            self.verifyTextField.startCount()
        }
    }
    
    @IBAction func tapHideKeyboard(_ sender: Any) {
        UIApplication.shared.keyWindow?.endEditing(true)
    }

    @IBAction func loginDidClick(_ sender: Any) {
        if phoneNum.text?.characters.count != 11 {
            SVProgressHUD.showError(withStatus: "请正确输入手机号")
            return
        }
        if verifyTextField.text?.characters.count == 0 {
            SVProgressHUD.showError(withStatus: "请正确输入验证码")
            return
        }
        SVProgressHUD.show()
        NetworkModel.requestGet([:], url: "http://112.74.124.86/ybb/index.php?app=appsdefault&act=banner_list") { (dic) in
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: "mainPush", sender: nil)
        }
    }
    
}
