//
//  ManufacturerVC.swift
//  Company_task
//
//  Created by Mac on 23/11/2021.
//

import UIKit
import Combine


class ManufacturerVC : UIViewController {
    /// tableview which contains Manufacturer and Model Car
    @IBOutlet weak var manufacturerTableView: UITableView! {
        didSet{
            self.manufacturerTableView.dataSource = self
            self.manufacturerTableView.delegate   = self
        }
    }
    /// AnyCancellable for A type-erasing cancellable object
    var cancellables: [AnyCancellable]  = []
    /// ManufacturerViewModel for bind data to View
    private var vm : ManufacturerViewModel!
    /// get selection name Manufacturer
    var manufacturerValue : String = ""
    /// get selection value Manufacturer
    var manufacturerKey      : String = ""
    /// check for manufacturerKey is empty or no
    var isEmptyKey: Bool {
        return manufacturerKey.isEmpty
    }
  
    ///activity will be start animation if scrollview scrolled down
    @IBOutlet weak var activity: UIActivityIndicatorView!
    ///Container for loading more that contain activity
    @IBOutlet weak var loadingView: UIView!
    //View Did Load method
    override func viewDidLoad() {
        super.viewDidLoad()
        /// initialize viewmodel
        self.vm = ManufacturerViewModel()
        /// call method startLoadingData to Network Request
        startLoadingData()
        /// call method setTitleNavigation to return title of navigation bar
        setTitleNavigation()
        /// call method checkStateNetwork to check if the data fetched or still loading
        checkStateNetwork()
        /// call method hiddenShowView to  hidden loading View in first time
        hiddenShowView(isHidden: true)
    }
    /// method setTitleNavigation to return title of navigation bar
    fileprivate func setTitleNavigation() {
        self.navigationItem.title = isEmptyKey ? manufactDefaultTitle : manufacturerValue
    }
    /// method to start make request to server , by calling makeRequest method from view model
    fileprivate func startLoadingData() {
        let manuStr =  isEmptyKey ? "" : manufacturerKey
        self.vm.makeRequest(manufacturerKey:manuStr)
    }
    
}

extension ManufacturerVC {
    /// method checkStateNetwork to check if the data fetched or still loading
    fileprivate func checkStateNetwork(){
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
    }
    
}

extension ManufacturerVC :UITableViewDelegate,UITableViewDataSource {
    
    // reload tableView method
    private func reloadTableView() {
        self.manufacturerTableView.reloadData()
    }
    /// cellForRowAt method for display the cell content
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //creation of custom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.identifier) as? CustomCell else{
            fatalError("Error in initialization Custom Cell")
        }
        /// view model return  title for every cell by indexpath.row and create InfoCell struct to bind it and pass this struct to cell
        if let name = self.vm.getTitleForSelectionCell(indexRow: indexPath.row) as String? {
            cell.infoCell = InfoCell(nameType: name, indexPath: indexPath.row)
        }
        return cell
    }
    /// view model return  number of rows in tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.numberOfRowsInSection()
    }
    /// when click cell
    /// we have two event first one go to model screen ,
    /// second event (if screen model ) display alert for what is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = isEmptyKey ? pushVC(indexPath: indexPath.row) : displayAlert(indexPath: indexPath.row)
    }
    /// function to hidden or show loadingView if loading more is working
    fileprivate func hiddenShowView(isHidden : Bool) {
        UIView.animate(withDuration: 1.5) {
            self.loadingView.isHidden = isHidden
            self.activity.startAnimating()
        }
    }
    ///willDisplay will tell delegate to draw a cell for a particular row.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        ///first return last row in tableview
        let lastIndexRow     = tableView.numberOfRows(inSection: 0) - 1
        ///when current row  is last Row
        if (indexPath.row == lastIndexRow){
            ///check if there are more data to loaded
            ///may be no data to loaded it so that we have to check it before start loading
            if self.vm.checkLoadMore() {
                ///show  loading view if there are more data to load it
                hiddenShowView(isHidden: false)
                /// dealy main thread to load data
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    /// make request to load data
                    self.vm.makeRequest(manufacturerKey: self.isEmptyKey ? "" : self.manufacturerKey)
                }
            }else{
                ///hidden  loading view if there are no data
                hiddenShowView(isHidden: true)
            }
        }
    }
    
    private func pushVC(indexPath:Int){
        /// create instantiate of current screen and call it with what is Manufacturer selected
        let vc  = UIStoryboard.main.instantiate() as ManufacturerVC
        /// get title and key from view model and pass it to ViewController
        if let value = self.vm.getTitleForSelectionCell(indexRow: indexPath) as String?,
           let key   = self.vm.getKeyForSelectionCell(indexRow: indexPath) as String? {
            vc.manufacturerValue    = value /// manufacturer value
            vc.manufacturerKey      = key /// manufacturer Key
        }
        /// start to naviagtion to new screen
        self.navigationController?.pushViewController(vc, animated: true)
    }
    /// in model screen , this method will be show
    private func displayAlert(indexPath: Int){
        /// get title model from view model method getTitleForSelectionCell and add manufacturerValue that contain the manufacturer that user selected it from last screen
        if let value = self.vm.getTitleForSelectionCell(indexRow: indexPath) as String?{
            let message = "Selected Manufacturer : \(manufacturerValue),and Selected model : \(value) ."
            /// using Util to show alert
            Util.showAlert(caller: self, title: "Message", message: message)
        }
    }
}


