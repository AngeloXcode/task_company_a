//
//  ManufacturerViewModel.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//

import Foundation
import Alamofire
import UIKit

enum EndPoint : URLRequestConvertible {
    
    static let baseURLString  = "" // main URL for API
    static let pathAPIString  = "" // path api in server
    static let fullUrl        = "\(baseURLString)\(pathAPIString)"
    
    // Create Routes for API
    case getManufacturer(page:String,pageSize:String)
    case getCarTypes(manufacturerID:String,page:String,pageSize:String)
    
    // Selection of HTTPMethod
    var method : HTTPMethod {
        switch self {
        case .getManufacturer,.getCarTypes:
            return .get
        }
    }
    
    // path for every Routes in API
    var path: String {
        switch self {
        case .getManufacturer(let page,let pageSize):
            return "manufacturer?page=\(page)&pageSize=\(pageSize)&wa_key=\(API_KEY)"
        case .getCarTypes(let manufacturerID,let page,let pageSize):
            return "main-types?manufacturer=\(manufacturerID)&page=\(page)&pageSize=\(pageSize)&wa_key=\(API_KEY)"
        }
    }
    
    ///generate URLRequestConvertible with append path
    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        switch self {
        case  .getManufacturer(_,_),.getCarTypes(_,_,_):
            let fullUrl     = try EndPoint.fullUrl.asURL().appendingPathComponent(path).absoluteString.removingPercentEncoding
            guard let url = fullUrl else{
                fatalError("Error in create URL")
            }
            var urlRequest  = URLRequest(url:URL(string: url)!)
            urlRequest.httpMethod = method.rawValue
            return urlRequest
        default:
            break
        }
        
    }
}

