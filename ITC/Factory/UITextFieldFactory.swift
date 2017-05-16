//
//  UITextFieldFactory.swift
//  ITC
//
//  Created by YunTu on 2017/5/15.
//  Copyright © 2017年 YunTu. All rights reserved.
//

import UIKit

class UITextFieldFactory: UITextField {

}

class PhoneTextField: UITextFieldFactory {
    
    fileprivate var holderLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addTarget(self, action: #selector(textFieldDidBeginEdit(_:)), for: .editingDidBegin)
        self.addTarget(self, action: #selector(textFieldDidBeginEdit(_:)), for: .editingDidEnd)
        self.addTarget(self, action: #selector(textFieldEditDidChange(_:)), for: .editingChanged)
        holderLabel = UILabel(frame: self.bounds)
        holderLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        holderLabel?.font = UIFont.systemFont(ofSize: 14)
        holderLabel?.text = "请输入手机号码"
        self.addSubview(holderLabel!)
    }
    
    @objc fileprivate func textFieldEditDidChange(_ sender:UITextField) {
        if (sender.text?.characters.count)! > 0 {
            holderLabel?.isHidden = true
        }else {
            holderLabel?.isHidden = false
        }
    }
    
    @objc fileprivate func textFieldDidBeginEdit(_ sender:UITextField) {
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setLineCap(.round)
        context.setLineWidth(1)
        context.setAllowsAntialiasing(true)
        context.setStrokeColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        context.beginPath()
        context.move(to: CGPoint(x: 0, y: self.bounds.size.height - 1))
        context.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - 1))
        if self.isEditing {
            context.move(to: CGPoint(x: 0, y: self.bounds.size.height))
            context.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
        }
        context.strokePath()
    }

    
}

class CodeTextField: PhoneTextField {
    
    var sendCodeBtn:UIButton?
    var count = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        holderLabel?.text = "请输入验证码"
        sendCodeBtn = UIButton(type: .custom)
        sendCodeBtn?.frame = CGRect(x: 86 + 10, y: 0, width: 100, height: self.bounds.size.height)
        sendCodeBtn?.setTitle("获取验证码", for: .normal)
        sendCodeBtn?.setTitleColor(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), for: .normal)
        sendCodeBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        sendCodeBtn?.backgroundColor = UIColor.lightGray
        sendCodeBtn?.layer.cornerRadius = 4
        self.rightView = sendCodeBtn
        self.rightViewMode = .always
    }
    
    override func draw(_ rect: CGRect) {
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setLineCap(.round)
        context.setLineWidth(1)
        context.setAllowsAntialiasing(true)
        context.setStrokeColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
        context.beginPath()
        context.move(to: CGPoint(x: 0, y: self.bounds.size.height - 1))
        context.addLine(to: CGPoint(x: 86, y: self.bounds.size.height - 1))
        if self.isEditing {
            context.move(to: CGPoint(x: 0, y: self.bounds.size.height))
            context.addLine(to: CGPoint(x: 86, y: self.bounds.size.height))
        }
        context.strokePath()
    }
    
    func startCount() -> Void {
        count = 60
        sendCodeBtn?.isUserInteractionEnabled = false
        sendCodeBtn?.setTitle(String(count) + "秒后再试", for: .normal)
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown(_:)), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func countDown(_ time:Timer) -> Void {
        count = count - 1
        if count <= 0 {
            time.invalidate()
            sendCodeBtn?.setTitle("获取验证码", for: .normal)
            sendCodeBtn?.isUserInteractionEnabled = true
            return
        }
        sendCodeBtn?.setTitle(String(count) + "秒后再试", for: .normal)
    }
}

class moneyTextField: PhoneTextField {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setLineCap(.round)
        context.setLineWidth(1)
        context.setAllowsAntialiasing(true)
        if self.isEditing {
            context.setStrokeColor(red: 168.0 / 255.0, green: 214.0 / 255.0, blue: 94.0 / 255.0, alpha: 1.0)
        }else{
            context.setStrokeColor(red: 216.0 / 255.0, green: 216.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0)
        }
        context.beginPath()
        context.move(to: CGPoint(x: 0, y: self.bounds.size.height - 1))
        context.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - 1))
        context.strokePath()
    }
}
