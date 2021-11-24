//
//  Util.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//

import Foundation
import UIKit
import Alamofire
///util class for helping methods
class Util{
    // method fo show alert
    class func showAlert(caller:UIViewController,title:String?,message:String) -> Void {
        DispatchQueue.main.async {
            let alert = UIAlertController(title:title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            caller.present(alert, animated: true, completion: nil)
        }
    }
    // check internet connection
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
