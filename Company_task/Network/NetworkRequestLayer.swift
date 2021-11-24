//
//  ManufacturerViewModel.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//

import Foundation
import Combine
import UIKit

// network layer return load data method
class NetworkRequestLayer : NetworkService {
    //this method return Future with model Manufacturer to pass it in ViewModel
    static func loadData(manufacturerID:String = "" ,page:String,pageSize:String)-> Future<Manufacturer,NetworkError>{
        if manufacturerID.isEmpty {
          return self.NetworkRequest(url: EndPoint.getManufacturer(page: page, pageSize: pageSize))
        }
        return self.NetworkRequest(url: EndPoint.getCarTypes(manufacturerID: manufacturerID, page: page, pageSize: pageSize))
    }
   
}

