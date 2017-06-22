//
//  ITCLoginViewController.swift
//  ITC
//
//  Created by YunTu on 2017/5/15.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit
import SVProgressHUD
import AFNetworking

enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String  {
    var md5: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity:
            
            
            digestLen)
        CC_MD5(str!, strLen, result)
        return stringFromBytes(bytes: result, length: digestLen)
    }
    
    var sha1: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_SHA1_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_SHA1(str!, strLen, result)
        return stringFromBytes(bytes: result, length: digestLen)
    }
    
    var sha256String: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_SHA256(str!, strLen, result)
        return stringFromBytes(bytes: result, length: digestLen)
    }
    
    var sha512String: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_SHA512_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_SHA512(str!, strLen, result)
        return stringFromBytes(bytes: result, length: digestLen)
    }
    
    func stringFromBytes(bytes: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String{
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", bytes[i])
        }
        bytes.deallocate(capacity: length)
        return String(format: hash as String)
    }
    
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        let digest = stringFromResult(result: result, length: digestLen)
        
        result.deallocate(capacity: digestLen)
        
        return digest
    }
    
    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash)
    }
}

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
        self.rongCloudToken()
    }
    
    //获取融云token
    func rongCloudToken() -> Void {
        let date = Date()
        let nonce = String(arc4random() % 10000)
        let timestamp = NSString(format: "%.0f", date.timeIntervalSince1970) as String
        let str = String("sDYzkLV0O6htSQ" + nonce + timestamp)
        let signature = Util.sha1(str)
        var req = URLRequest(url: URL(string: "http://api.cn.ronghub.com/user/getToken.json")!)
        req.setValue("cpj2xarlc3hfn", forHTTPHeaderField: "RC-App-Key")
        req.setValue(nonce, forHTTPHeaderField: "RC-Nonce")
        req.setValue(timestamp, forHTTPHeaderField: "RC-Timestamp")
        req.setValue(signature, forHTTPHeaderField: "RC-Signature")
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "POST"
        let param = "userId=1&name=1&portraitUri="//["userId":"1","name":"1","portraitUri":""]
        
        
        req.httpBody = param.data(using: String.Encoding.utf8)
        
        NSURLConnection.sendAsynchronousRequest(req, queue: OperationQueue(), completionHandler: { (_ response:URLResponse?, data:Data?, error:Error?) in
            if error == nil {
                DispatchQueue.main.async(execute: {
                    do {
                        let dic = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        print(dic)
                    }catch{
                        
                    }
                })
            }else{
                print(error!)
            }
        })
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
