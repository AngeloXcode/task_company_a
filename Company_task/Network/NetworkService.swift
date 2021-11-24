//
//  ManufacturerViewModel.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//


import Foundation
import Alamofire
import Combine
///Network Layer Service that make request
class NetworkService : NetworkServiceType {
    
    ///this method is make network request and resturn generatics from server with handle error
    public static func NetworkRequest<T>(url: URLRequestConvertible) -> Future<T, NetworkError> where T : Decodable {
        return Future<T,NetworkError> { promise in
            AF.request(url).decodable { data in
                promise(.success(data))
            } failure: { (error) in
                promise(.failure(error!))
            }
        }
    }

}

extension Alamofire.DataRequest {
    ///this method is handling the resposne , error network and encode the json
    @discardableResult
    func decodable<T: Decodable>(success: @escaping (T) -> Swift.Void, failure: @escaping (NetworkError?) -> Swift.Void) -> Self {
        response(completionHandler: { response in
            ///check for HTTPURLResponse
            guard let httpResponse = response.response as HTTPURLResponse? else {
                failure(NetworkError.invalidResponse)
                return
            }
            ///check for statusCode to handle error from statusCode
            guard 200..<300 ~= httpResponse.statusCode else {
                return failure(NetworkError.dataLoadingError(statusCode: httpResponse.statusCode))
            }
            ///wrapper the data
            if let data = response.data {
                do{
                    ///decode the data with JSONDecoder
                    let result = try JSONDecoder().decode(T.self, from: data)
                    success(result)
                }catch let error{
                    ///this part handle if error happen when convert json 
                    failure(NetworkError.jsonDecodingError(error:error.localizedDescription))
                }
            }
            
        })
        return self
    }
}
