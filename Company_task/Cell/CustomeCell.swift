//
//  CustomeCell.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//

import Foundation
import UIKit


///Create struct for fetch Information cell from ViewController
struct InfoCell{
    var nameType : String?
    var indexPath  : Int
}

///Implementation of CustomCell and usind ReusableCell protocal
///to fetch identifier for cell
class CustomCell : UITableViewCell, ReusableCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var bgView: UIView! /// make view to set color background
    ///object of struct to retrieve data from viewcontroller
    var infoCell : InfoCell! {
        didSet {
            ///fill label with title of manufacturer or model
            nameLbl.text = infoCell.nameType
            /// set different coloe depeend on Even or Odd
            bgView.backgroundColor = ((infoCell.indexPath % 2) == 0) ? Theme.ColorTheme.CreamColor :  Theme.ColorTheme.PeachColor
        }
    }
    
}
