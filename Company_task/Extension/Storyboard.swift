//
//  Storyboard.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//

import Foundation
import UIKit
/// extension for storyboard , add function called instantiate to read return the identifier for ViewController
extension UIStoryboard {
    func instantiate<T>() -> T {
        return instantiateViewController(withIdentifier: String(describing: T.self)) as! T
    }
/// storyboard name 
    static let main = UIStoryboard(name:StoryboardName, bundle: nil)
}
