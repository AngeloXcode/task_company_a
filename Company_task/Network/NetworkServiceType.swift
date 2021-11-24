//
//  ManufacturerViewModel.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//

import Foundation
import Alamofire
import Combine
///enum for all network error
enum NetworkError : Error {
    case invalidRequest
    case invalidResponse
    case dataLoadingError(statusCode: Int)
    case jsonDecodingError(error: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest,.invalidResponse,.dataLoadingError(_):
            return RequestError
        case .jsonDecodingError(let error):
            return error
        }
    }
}


protocol NetworkServiceType{
     static func NetworkRequest<T:Decodable>(url: URLRequestConvertible) -> Future<T,NetworkError>
}
