//
//  CityPickerTableViewController.swift
//  Vendor Helper
//
//  Created by Theophilus Drackett on 1/28/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CityPickerTableViewController: UITableViewController, UISearchResultsUpdating {

    var databaseRef : DatabaseReference!
    var cityStateArray = [cityState]()
    var filteredCityStateArray = [cityState]()
    let searchController = UISearchController(searchResultsController: nil)
    var cityPicked : cityState?
    let homeCity = cityState(streetPicked: "Return", cityPicked: "Your", statePicked: "Home", zipPicked: "90210")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Type a city to search for"
        
        if #available(iOS 11.0, *) {
            // For iOS 11 and later, place the search bar in the navigation bar.
            navigationItem.searchController = searchController
            
            // Make the search bar always visible.
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            tableView.tableHeaderView = searchController.searchBar
        }
//        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.title = "Street Vendor Helper"

//        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .black
            searchController.searchBar.searchTextField.textColor = UIColor.white
        definesPresentationContext = true
//        self.cityStateArray.append(homeCity!)
        databaseRef = Database.database().reference(withPath: "Event")
        databaseRef?.observe(.childAdded) { (snapshot) in
            
            
            if !snapshot.exists() {
                print("no snapshot data mon!")
                return()
            }
            
            var streetPicked = ""
            if let street = snapshot.childSnapshot(forPath: "eventStreet").value as? String {
                streetPicked = street
            }
            var cityPicked = ""
            if let tmpCity = snapshot.childSnapshot(forPath: "eventCity").value as? String {
                cityPicked = tmpCity
            }
            var statePicked = ""
            if let tmpState = snapshot.childSnapshot(forPath: "eventState").value as? String {
                statePicked = tmpState
            }
            var zipPicked = ""
            if let tmpZip = snapshot.childSnapshot(forPath: "eventZip").value as? String {
                zipPicked = tmpZip
            }
            streetPicked = streetPicked.trimmingCharacters(in: .whitespaces)
            cityPicked = cityPicked.trimmingCharacters(in: .whitespaces)
            statePicked = statePicked.trimmingCharacters(in: .whitespaces)
            zipPicked = zipPicked.trimmingCharacters(in: .whitespaces)

            guard let citState = cityState(streetPicked: streetPicked, cityPicked: cityPicked, statePicked: statePicked, zipPicked: zipPicked)
                else {fatalError("Unable to instantiate event")}
 
            let city = citState.cityPicked
            if let cityExist = self.cityStateArray.first(where: {$0.cityPicked == city}) {
                print("The city \(cityExist) already exits. Not gonna add it")
            } else {
                self.cityStateArray.append(citState)
            }
            self.cityStateArray = self.cityStateArray.sorted(by: {$0.cityPicked < $1.cityPicked})
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredCityStateArray.count
        }
        return cityStateArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "cityPicker"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CityPickerTableViewCell  else {
            fatalError("The dequeued cell is not an instance of cityPicker.")
        }

        let homeCellIdentifier = "homeCity"
        guard let homeCell = tableView.dequeueReusableCell(withIdentifier: homeCellIdentifier, for: indexPath) as? CityPickerTableViewCell  else {
            fatalError("The dequeued cell is not an instance of cityPicker.")
        }

        // Configure home cell
        if indexPath.row == 0 {
            homeCell.homeCity.textColor = .systemBlue
            homeCell.homeCity.text = "Return to your hood"
        } else {
            // Configure the cell...
            var cityNstate = self.cityStateArray[indexPath.row]
            if searchController.isActive {
                cityNstate = self.filteredCityStateArray[indexPath.row]
            }
            
            Utilities.styleLabel(cell.cityName)
            cell.cityName.text = cityNstate.cityPicked + "," + " " + cityNstate.statePicked
        }
        if indexPath.row == 0 {
            return homeCell
        }
        return cell
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller when a row is selected
        guard let selectedCityCell = sender as? CityPickerTableViewCell else {
            fatalError("Unexpected sender: \(String(describing: sender))")
        }
        
        guard let indexPath = tableView.indexPath(for: selectedCityCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        var selectedCity = homeCity

        if indexPath.row != 0 {
            selectedCity = searchController.isActive ?  self.filteredCityStateArray[indexPath.row] : self.cityStateArray[indexPath.row]
        }
        cityPicked = selectedCity

    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInCityPickerRatingMode = presentingViewController is UINavigationController
        
        if isPresentingInCityPickerRatingMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The EventViewController is not inside a navigation controller.")
        }
    }
    
    func updateSearchResults(for search: UISearchController) {
        if let searchText = search.searchBar.text, !searchText.isEmpty {
            filteredCityStateArray = cityStateArray.filter { myCity in
                return myCity.cityPicked.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredCityStateArray = cityStateArray
        }
        tableView.reloadData()
    }
}
