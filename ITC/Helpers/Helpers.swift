//
//  Helpers.swift
//  LocalUser
//
//  Created by YunTu on 2016/12/20.
//  Copyright © 2016年 果儿. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
//import SVProgressHUD

class Helpers : NSObject, CLLocationManagerDelegate {
    
    static fileprivate var manager:CLLocationManager?
    static let share = Helpers()
    static var latitude = 0.0
    static var longitude = 0.0
    static var completeLocation: (() -> Void)?
    
    public class func screanSize() -> CGSize{
        return UIScreen.main.bounds.size
    }
    
    public class func baseImgUrl() -> String {
        return "http://112.74.124.86/ybb/"
    }
    
    public class func findSuperViewClass(_ className:AnyClass,with view:UIView) -> UIView? {
        var superView:UIView? = view
        for _ in 0...10 {
            superView = superView?.superview
            if superView!.isKind(of: className) {
                return superView
            }
        }
        return superView
    }
    
    public class func findClass(_ className:AnyClass,at parentView:UIView) -> UIView? {
        var view:UIView? = nil
        for v in parentView.subviews {
            if v.isKind(of: className) {
                view = v
                break
            }else{
                view = self.findClass(className, at: v)
                if view != nil {
                    break
                }
            }
        }
        
        return view
    }
    
    public class func image(_ image:UIImage, with color:UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        context!.translateBy(x: 0,y: image.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        context!.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        context!.clip(to: rect, mask: image.cgImage!)
        color.setFill()
        context!.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        return newImage!
    }
    
    public class func locationManager(){
        if CLLocationManager.locationServicesEnabled() {
            manager = CLLocationManager()
            manager?.delegate = self.share
            manager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager?.distanceFilter = 200
            manager?.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            manager.startUpdatingLocation()
        }else {
//            SVProgressHUD.showError(withStatus: "请到设置里面打开定位，我们才能给你提供更好的服务")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        Helpers.latitude = (location?.coordinate.latitude)!
        Helpers.longitude = (location?.coordinate.longitude)!
        print("latitude:\(String((location?.coordinate.latitude)!)),longitude:\(String((location?.coordinate.longitude)!))")
        if Helpers.completeLocation != nil {
            Helpers.completeLocation!()
        }
    }
    
    public class func timeChange(_ timeStamp: String) -> String {
        //转换为时间
        let timeInterval:TimeInterval = TimeInterval(timeStamp)!
        let date = NSDate(timeIntervalSince1970: timeInterval)
        
        
        //格式话输出
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        return dformatter.string(from: date as Date)
    }

    public class func getStatus(_ status: Int) -> String {
        switch status {
        case 0:
            return "取消中"
        case 1:
            return "待付款"
        case 2:
            return "待发货"
        case 3:
            return "已发货"
        case 4:
            return "待返回"
        case 5:
            return "已返回"
        case 6:
            return "已评价"
        default:
            return ""
        }
    }
    

}
