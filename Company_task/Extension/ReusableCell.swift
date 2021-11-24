//
//  Cell+Delaget.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//

import Foundation
import UIKit

protocol ReusableCell {
    static var identifier: String { get }
}

//Cell Reuse Extensions for fetch return identifier for cell in Storyboard
extension ReusableCell where Self: UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
