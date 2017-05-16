//
//  WalletViewController.swift
//  ITC
//
//  Created by 果儿 on 2017/5/15.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD

class WalletViewController: UIViewController {

    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var textFieldTop: NSLayoutConstraint!
    @IBOutlet weak var chargeMoneyTextField: PhoneTextField!
    @IBOutlet weak var sureBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的钱包"
        SVProgressHUD.show()
        NetworkModel.requestGet([:], url: "http://112.74.124.86/ybb/index.php?app=appsdefault&act=banner_list") { (dic) in
            SVProgressHUD.dismiss()
            self.moneyLabel.text = "500"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(paySuccess), name: NSNotification.Name(rawValue: "PAYSUCCESS"), object: nil)
        self.sureBtn.layer.cornerRadius = 4
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PAYSUCCESS"), object: nil)
    }
    
    func paySuccess() -> Void {
        self.moneyLabel.text = String(500 + Int(chargeMoneyTextField.text!)!)
        chargeMoneyTextField.text = nil
        UIView.animate(withDuration: 0.5, animations: {
            self.textFieldTop.constant = -40
            self.view.layoutIfNeeded()
        })
        
    }
    
    @IBAction func charge(_ sender: Any) {
        if textFieldTop.constant < 0 {
            UIView.animate(withDuration: 0.5, animations: { 
                self.textFieldTop.constant = 20
                self.view.layoutIfNeeded()
            })
        }else {
            self.editDidEndOnExit(chargeMoneyTextField)
        }
    }
    
    @IBAction func sureCharge(_ sender: Any) {
        self.editDidEndOnExit(chargeMoneyTextField)
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        UIApplication.shared.keyWindow?.endEditing(true)
        chargeMoneyTextField.text = nil
    }

    @IBAction func editDidEndOnExit(_ sender: UITextField) {
        if sender.text?.characters.count == 0 {
            SVProgressHUD.showError(withStatus: "请输入金额")
            return
        }
        UIApplication.shared.keyWindow?.endEditing(true)
        let sheet = UIAlertController(title: "选择支付方式", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "支付宝", style: .default, handler: { (action) in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let orderId = formatter.string(from: Date())
            AlipaySend.toAlipay(orderId, withSubject: "充值", withBody: "充值", withTotalFee: 0.01) { (dic) in
                
            }
        }))
        sheet.addAction(UIAlertAction(title: "微信", style: .default, handler: { (action) in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let orderId = formatter.string(from: Date())
            startWeiChatPAy.jump(toBizPay: ["order_id":orderId])
            WXApiManager.shared().result = {(resp) in
                SVProgressHUD.dismiss()
                if resp?.errCode != 0 {
                    SVProgressHUD.showError(withStatus: "支付失败")
                }else{
                    SVProgressHUD.showSuccess(withStatus: "支付成功")
                    self.paySuccess()
                }
            }
        }))
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
        }))
        self.present(sheet, animated: true, completion: nil)
//        sender.text = nil
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
