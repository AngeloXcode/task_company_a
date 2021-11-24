# Code Challenge
##Using Alamofire is a Swift-based, HTTP networking library, also Codable for Data Model and Combine Framework .
>Alamofire is one of the most popular and widely used Swift networking libraries. Built on Apple’s Foundation networking stack, 
it provides an elegant API to make network requests. With over thirty-thousand stars on GitHub, it’s one of the top-rated Swift repositories.
> Codable is a type alias for the Encodable and Decodable protocols. When you use Codable as a type or a generic constraint, it matches any type 
that conforms to both protocols.

## I using a Model-View-ViewModel (MVVM) is a software design pattern that is structured to separate program logic and user interface controls. 
The pattern is often used in Windows and web graphics presentation software. design patterns MVVM 

## Code Architecture :  
   ### 1- Create Network Layer with Protocol and Generic in separate layer .
   ### 2- Use Model-View-ViewModel design pattern to make request to server and binding to ViewController .
   ### 3- To prevent duplication of code , I try to using the same view controller to used it again . 
   ### 4- Using of Cell Reuse Extensions   .   
   
   
   
  ## Example of code 
  
 >this method is make HTTP request and get response by Alamofire and It handle the response with Future publisher from Combine Framework 
 
   
    public static func NetworkRequest<T>(url: URLRequestConvertible) -> Future<T, NetworkError> where T : Decodable {
        return Future<T,NetworkError> { promise in
            AF.request(url).decodable { data in
                promise(.success(data))
            } failure: { (error) in
                promise(.failure(error!))
            }
        }
     }
     
       
 >Loading data from Network layer to ViewModel : here I return data from newtork layer and change state for enumeration depend on response 
 
     private func loadDataFromServer(manufacturerKey: String = "" ,page:Int) {
       if isConnected {
         let networkRequest = manufacturerKey.isEmpty ?  NetworkRequestLayer.loadData(page:"\(self.page)", pageSize:"\(pageSize)") 
                                                       : NetworkRequestLayer.loadData(manufacturerID:manufacturerKey,page: "\(page)", pageSize: "\(pageSize)")
            let cancellable = networkRequest.sink(receiveCompletion: { (result) in
                switch result {
                case .failure(let error):
                    if let errorMsg = "\(error.localizedDescription)" as String? {
                        self.state = .error(errorMsg)
                    }
                    break
                case .finished:
                    break
                }
            }, receiveValue: { (result) in
                if let data =  result.wkda {
                    if let totalPageCount = result.totalPageCount{
                        self.totalPageCount = totalPageCount
                        data.forEach { (k,v) in  self.dataSource[k] = v }
                        self.state = .loaded
                    }else{
                        self.state = .error("No Data in api")
                    }
                    
                }else{
                    self.state = .error("No Data in api")
                }
            })
            self.subscriptions.insert(cancellable)
        }else{
            self.state = .noInternet("No internet Connection Please check for internet settings")
        }
    }
    
    
    
> binding Data from View Model to View Controller 
    
        self.vm.$state.sink { (state) in
            switch state {
            case .noInternet(let noInternetMsg):
                //main screen thread to update UI after loading
                DispatchQueue.main.async {
                    Spinner.dissmiss()  // if no internet connection , you have to dismiss spinner
                    // show No internet connection of alert
                    Util.showAlert(caller: self, title: "Message", message: "\(noInternetMsg)")
                }
                break
            case .idle:
                Spinner.start() // start spinner animation
                break
            case .loading:
                Spinner.dissmiss()
                break
            case .loaded:
                //main screen thread to update UI after loading
                DispatchQueue.main.async {
                    Spinner.dissmiss() // if finish loading,you have to dismiss spinner
                    self.reloadTableView() // reload tableview again
                }
                break
            case .error(let error):
                //main screen thread to update UI after loading
                DispatchQueue.main.async {
                    Spinner.dissmiss()  // if error was happen , you have to dismiss spinner
                    // show error of alert
                    Util.showAlert(caller: self, title: "Message", message: "\(error)")
                }
                break
            }
        }.store(in: &cancellables)
