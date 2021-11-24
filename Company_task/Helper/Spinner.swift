//
//  Spinner.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//

import Foundation
import ZKProgressHUD

final class Spinner {
    // spinner to show loading when load
    public static func start() {
        ZKProgressHUD.setCornerRadius(5.0)
        ZKProgressHUD.dismiss(10)
        ZKProgressHUD.setBackgroundColor(.white)
        ZKProgressHUD.setForegroundColor(.black)
        ZKProgressHUD.show()
    }
    // dissmiss Spinner when loaded
    public static func dissmiss() {
        ZKProgressHUD.dismiss()
    }
    
}
