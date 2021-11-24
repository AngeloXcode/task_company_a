//
//  ManufacturerViewModel.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//

import Foundation
import Combine
import UIKit

protocol DataSourceProtocal{
    func numberOfRowsInSection() -> Int /// specify method to return number of rows
    func getTitleForSelectionCell(indexRow:Int) -> String   /// specify method to title (String) where this title will be using to bind the custom cell
    func getKeyForSelectionCell(indexRow:Int)   -> String   /// specify method to key  where this key will be using to get of selected cell
}

extension ManufacturerViewModel {
    ///State enum is handling every request states
    enum State {
        case idle
        case loading
        case loaded
        case noInternet(String)
        case error(String)
    }
}

class ManufacturerViewModel : ObservableObject {
    /// set first status for idle Until start request
    /// using  @Published to property wrappers  allowing us to create observable objects that announce when changes occur
    @Published private(set) var state = State.idle
    ///Dictionary to fill binding data to it
    private var dataSource: [String : String]  = [:]
    /// AnyCancellable for A type-erasing cancellable object
    private var subscriptions = Set<AnyCancellable>()
    /// counting page to looping
    private var page : Int = 0
    /// number of item that network request was fetched every time
    private var pageSize : Int = 15
    /// total number of page which I have to loaded it
    private var totalPageCount : Int = 0
    /// computed property to check if internet connection down or no
    private var isConnected : Bool {
        return Util.isConnectedToInternet()
    }
    /// init constructor to create  ManufacturerViewModel
    init() {
    }
    
    /// method make request to start requst
    public func makeRequest(manufacturerKey: String = "") {
        /// in first request , we know the totalPageCount so that
        /// we set default value to it with zero
        if self.totalPageCount > 0 {
            /// after first request totalPageCount is return it with value ,Now we can know how many time we have to load data.
            /// but we will stop loading data until our counter page will be less than totalPageCount
            /// that is meaning I fetch all data
            if self.page < self.totalPageCount-1 {
                /// increment page with 1 if it is less than self.totalPageCount
                self.page += 1
                /// start loading data from server
                self.loadDataFromServer(manufacturerKey: manufacturerKey, page: page)
            }
        }else{
            /// in first request we will start with page = 0
            ///this request for first time
            self.loadDataFromServer(manufacturerKey: manufacturerKey, page: page)
        }
        
    }
    private func loadDataFromServer(manufacturerKey: String = "" ,page:Int) {
        // check for internet connection before request
        if isConnected {
            ///make object of method if manufacturerKey is null , The object of method will be load manufacturer
            /// but manufacturerKey isnot null so that I will load Model depend on manufacturerKey
            let networkRequest = manufacturerKey.isEmpty ?  NetworkRequestLayer.loadData(page:"\(self.page)", pageSize:"\(pageSize)") : NetworkRequestLayer.loadData(manufacturerID:manufacturerKey,page: "\(page)", pageSize: "\(pageSize)")
            /// start to make request by calling method loadData from NetworkRequestLayer
            /// It will be return Future object with model and Error
            ///Future is publisher observer Object return Model of manufacturer and network error
            let cancellable = networkRequest.sink(receiveCompletion: { (result) in
                switch result {
                    /// if result have a error I will change state enumeration for error and pass messsage to View controller
                case .failure(let error):
                    if let errorMsg = "\(error.localizedDescription)" as String? {
                        self.state = .error(errorMsg)
                    }
                    break
                case .finished:
                    break
                }
            }, receiveValue: { (result) in
                /// if No error I will get result that object is my model
                /// if result have no  error I will change state  enumeration for loaded and append dataSource to data
                /// append data isn't old data but it is new data
                if let data =  result.wkda {
                    if let totalPageCount = result.totalPageCount{
                        self.totalPageCount = totalPageCount
                        data.forEach { (k,v) in  self.dataSource[k] = v }
                        self.state = .loaded
                    }else{
                        /// if result have no  data I will change state  enumeration for error and pass messsage to View controller
                        self.state = .error("No Data in api")
                    }
                    
                }else{
                    /// if result have no  data I will change state enumeration for error and pass messsage to View controller
                    self.state = .error("No Data in api")
                }
            })
            /// will be remove object from memory
            self.subscriptions.insert(cancellable)
        }else{
            self.state = .noInternet("No internet Connection Please check for internet settings")
        }
    }
    
}

extension ManufacturerViewModel : DataSourceProtocal {
    ///number of Rows in datasource
    ///return number of row from fetched data to tableview
    func numberOfRowsInSection() -> Int {
        return self.dataSource.count
    }
    ///return key for row according the row value
    func getTitleForSelectionCell(indexRow:Int) -> String  {
        return  Array(self.dataSource)[indexRow].value
    }
    ///return title from dataSource according the row value
    func getKeyForSelectionCell(indexRow:Int) -> String  {
        return  Array(self.dataSource)[indexRow].key
    }
    ///check if there are more data or no , by page counter is less than totalPageCount
    ///if true that is meaning more data
    ///if false that is meaning I fetch all data
    func checkLoadMore() -> Bool  {
        return (self.page < self.totalPageCount-1)
    }
    
}
