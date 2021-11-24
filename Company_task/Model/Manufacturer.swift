//
//  Manufacturer.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//

import Foundation

// Model for Manufacturer
struct Manufacturer : Decodable {
    let page : Int?                // paing counter
    let pageSize : Int?           // pagin size
    let totalPageCount : Int?    // number of paging
    let wkda : [String:String]? // data for Manufacturer and model
    
    enum CodingKeys: String, CodingKey {
        case page = "page" 
        case pageSize = "pageSize"
        case totalPageCount = "totalPageCount"
        case wkda = "wkda"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        page = try values.decodeIfPresent(Int.self, forKey: .page)
        pageSize = try values.decodeIfPresent(Int.self, forKey: .pageSize)
        totalPageCount = try values.decodeIfPresent(Int.self, forKey: .totalPageCount)
        wkda = try values.decodeIfPresent([String:String].self, forKey: .wkda)
    }
    
}

