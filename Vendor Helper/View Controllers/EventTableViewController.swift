//
//  EventTableViewController.swift
//  event Helper
//
//  Created by Theophilus Drackett on 1/5/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit
import os.log
import CoreLocation
import GeoFire
import Firebase
import FirebaseUI
import FirebaseStorage
import FirebaseAuth


class EventTableViewController: UITableViewController, UISearchResultsUpdating  {

    
    //MARK: Properties

    @IBOutlet weak var cityButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var signInButton: UIBarButtonItem!
    
    let backgroundView = UIImageView()
    private var events: [Event] = []
    var filteredEvents = [Event]()
    var allPhotos = [UIImage]()
    var numPicArray = [Int]()
    let searchController = UISearchController(searchResultsController: nil)
    var databaseRef : DatabaseReference!
    let storage = Storage.storage()
    var cityPicked : String = ""
    var locationManager = CLLocationManager()
    var imageDownloadURL : String?
    var numEvents = 0
    var userLocation : CLLocation?
    var userStreet = ""
    var userCity = ""
    var userState = ""
    var userZip = ""
    var userLat = 0.0
    var userLon = 0.0
    var eventLat = 0.0
    var eventLon = 0.0
    var distanceToEvent = 0.0

    private lazy var storageRef = storage.reference()

    //number of pictures in each category in pic database. Each category must have the same number of pics
    let numPics = 10

    fileprivate var _refHandle: DatabaseHandle!
    
    lazy var refreshTable: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .eventGold
        refreshControl.addTarget(self, action: #selector(getNearByEvents), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Get the user's location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()

        //setup color scheme
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = UIColor.eventGold
        navigationController?.toolbar.isTranslucent = false
        navigationController?.toolbar.barTintColor = UIColor.black
        navigationController?.toolbar.backgroundColor = UIColor.black
        
        cityButton.tintColor = UIColor.eventGold
        addButton.tintColor = UIColor.eventGold
        signInButton.tintColor = UIColor.eventGold

        // Add a search controller

        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true

        if #available(iOS 11.0, *) {
            // For iOS 11 and later, place the search bar in the navigation bar.
            navigationItem.searchController = searchController
            
            // Make the search bar always visible.
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            tableView.tableHeaderView = searchController.searchBar
        }

//        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.barStyle = .black
//        searchController.searchBar.backgroundColor = UIColor.lightGray
        searchController.searchBar.searchTextField.textColor = UIColor.white

        getNearByEvents()
        
        //refresh the tableview by means of pull down
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshTable
        } else {
            tableView.addSubview(refreshTable)
        }

        _ = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if user == nil {

                if let authUI = FUIAuth.defaultAuthUI() {
                    authUI.delegate = self

                    let providers: [FUIAuthProvider] = [
                        FUIGoogleAuth(),
                        FUIFacebookAuth(),
                        FUIOAuth.appleAuthProvider()
                    ]
                    authUI.providers = providers

                }
            }
            else{
                print("users logged in: ", user?.displayName as Any)
//                self.userLbl.text = user?.displayName
            }
        })

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if user is signed in and set Sign in button accordingly
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if Auth.auth().currentUser != nil {
                // User is signed in.
                self.signInButton.title = "Sign Out"
            } else {
                //User is not signed in
                self.signInButton.title = "Sign In"
                return
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return self.filteredEvents.count
        }
        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // Table view cells are reused and should be dequeued using a cell identifier.
            let cellIdentifier = "EventCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EventTableViewCell  else {
                fatalError("The dequeued cell is not an instance of EventCell.")
            }
            // Fetches the appropriate event for the data source layout.
            let event = searchController.isActive ?  self.filteredEvents[indexPath.row] : self.events[indexPath.row]
            let eventStreet = event.eventStreet
            let eventCity = event.eventCity
            let eventState = event.eventState
            let eventZip = event.eventZip
            
            let eventAddress:String = eventStreet + "," + " " + eventCity + "," + " " + eventState + " " + eventZip
            
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(eventAddress) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let eventLocation = placemarks.first?.location
                    else {
                        //handle no location found
                        print("\(eventAddress) NOT FOUNDED")
                        return
                }
                let eventLat = eventLocation.coordinate.latitude
                let eventLon = eventLocation.coordinate.longitude
                //                let userCoord:CLLocation = CLLocation(latitude: cityLat, longitude: cityLon)
                let eventLoc = CLLocation(latitude: eventLat, longitude: eventLon)

                self.distanceToEvent = Double(((self.userLocation?.distance(from: eventLoc))!))
                self.distanceToEvent = (self.distanceToEvent/1609.344).rounded()
            
            let stringDist = String(self.distanceToEvent)
                Utilities.styleLabel(cell.eventName)
            cell.eventName.text = event.eventName
                Utilities.styleLabel(cell.eventCatCity)
            cell.eventCatCity.text = event.eventStreet + ", " + event.eventCity + "  " + stringDist + "mi"
            let numURLs = event.eventImageURLs.count
        
            if numURLs > 0 {
                let url = URL(string: event.eventImageURLs[0])
                cell.eventImage.sd_setImage(with: url, placeholderImage: UIImage(named: "UploadPhoto"))
            } else  {
                let photo = self.randomPic()
                cell.eventImage.image = (UIImage(named: photo)!)
            }

            //Calculate the average rating and assign it to the rating control
            let numReviews = event.eventReviews.count
            if numReviews > 0 {
                var totalRatings = 0
                for ctr in 0...numReviews-1 {
                    totalRatings = totalRatings + event.eventReviews[ctr].eventRating
                }
                let averageRating = Int(totalRatings/numReviews)
                cell.RatingControl.rating = averageRating
            } else {
                cell.RatingControl.rating = 0
            }
                Utilities.styleLabel(cell.numReviews)
                if numReviews == 0 {
                    cell.numReviews.text = "Be first to rate"
                } else {
                    cell.numReviews.text = String(numReviews) + " Reviews"
                }
                
            
    }
            return cell
            
        }

        // Override to support conditional editing of the table view.
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the specified item to be editable.
            return true
        }

/*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let event = self.events[indexPath.row]
            let eventId = event.eventName + " " + event.eventCity
            self.events.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            deleteEvent(id:eventId)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view

        }    
    }
*/
    // Allow searching the table

    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredEvents = events.filter { myEvent in
//let fireKey = event.eventName.trimmingCharacters(in: .whitespaces) + " " + event.eventCity.trimmingCharacters(in: .whitespaces)
                return (myEvent.eventName.lowercased().contains(searchText.lowercased()) || myEvent.eventCity.lowercased().contains(searchText.lowercased()))
            }
            
        } else {
            filteredEvents = events
        }
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddEvent":
            os_log("Adding a new event.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let EventDetailViewController = segue.destination as? EventDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedEventCell = sender as? EventTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedEventCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedEvent = searchController.isActive ?  self.filteredEvents[indexPath.row] : self.events[indexPath.row]
            EventDetailViewController.event = selectedEvent
        case "CityPickerVC":
            print("The user's city is \(userCity)")
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }

    //MARK: Actions
    @IBAction func unwindToEventList(sender: UIStoryboardSegue) {

        if let sourceViewController = sender.source as? AddEventViewController, let event = sourceViewController.event {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing event
                events[selectedIndexPath.row] = event
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new event
                let newIndexPath = IndexPath(row: self.events.count, section: 0)
            
                self.events.append(event)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            // Save the events to Firebase
            saveEvent(event: event)
        }
        
        if let sourceViewController = sender.source as? CityPickerTableViewController {
            var myStreet = sourceViewController.cityPicked?.streetPicked
            var myCity = sourceViewController.cityPicked?.cityPicked
            var myState = sourceViewController.cityPicked?.statePicked
            var myZip = sourceViewController.cityPicked?.zipPicked
            if myCity == "Your" {
                myStreet = self.userStreet
                myCity = self.userCity
                myState = self.userState
                myZip = self.userZip
            }
            cityButton.title = myCity
            let address:String = myStreet! + "," + " " + myCity! + "," + " " + myState! + " " + myZip!

            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                    else {
                        //handle no location found
                        print("\(address) NOT FOUNDED")
                        return
                }
                let cityLat = location.coordinate.latitude
                let cityLon = location.coordinate.longitude
//                let userCoord:CLLocation = CLLocation(latitude: cityLat, longitude: cityLon)
                self.userLocation = CLLocation(latitude: cityLat, longitude: cityLon)
                self.getNearByEvents()
            }
        }
    }
    
//MARK:- Private Methods
    
    private func saveEvent(event : Event) {

        // Createe a database reference
        databaseRef = Database.database().reference()
        
        let fireKey = event.eventName.trimmingCharacters(in: .whitespaces) + " " + event.eventCity.trimmingCharacters(in: .whitespaces)
        self.databaseRef?.child("Event").child(fireKey)
        if let databaseRef = databaseRef?.child("Event").child(fireKey) {

        // Get event long and lat
        let address:String = event.eventStreet + "," + " " + event.eventCity + "," + " " + event.eventState + " " + event.eventZip
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {
                    //handle no location found
                    print("\(address) NOT FOUNDED")
                    return
            }

        
        let eventToSave = [
            "eventName": event.eventName,
//            "eventImageURLs": event.eventImageURLs,
            "eventCategory": event.eventCategory,
            "eventStreet": event.eventStreet,
            "eventCity": event.eventCity,
            "eventState": event.eventState,
            "eventCountry": event.eventCountry,
            "eventContact": event.eventContact,
            "eventPhone": event.eventPhone,
            "eventEmail": event.eventEmail,
            "eventWebSite": event.eventWebSite,
            "eventFromDate": event.eventFromDate,
            "eventToDate": event.eventToDate,
            "eventCreator": event.eventCreator,
            "frequency": event.eventFrequency,
            "eventAttendance": event.eventAttendance,
            "eventAvgEarnings": event.eventAvgEarnings,
            "eventVenue": event.eventVenue,
            "eventVendorFee": event.eventVendorFee,
            "eventZip": event.eventZip,
            "eventRatingCount": event.eventRatingCount,
            "eventDetails": event.eventDetails,
            "eventAvgRating": event.eventAvgRating] as [String : Any]

                databaseRef.setValue(eventToSave) { error, ref in
                    if error != nil {
                        // error handle
                        print("There was an error saving the event to firebase")
                    } else {
                        for review in event.eventReviews {
                            let commentKey = event.eventName + " " + review.ratingUsername
                            self.databaseRef?.child("Event").child(fireKey).child("Reviews")
                            self.databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey)
                            self.databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("ratingComment").setValue(review.ratingComment)
                            self.databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("eventRating").setValue(review.eventRating)
                            self.databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("ratingUsername").setValue(review.ratingUsername)
                            self.databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("ratingUserID").setValue(review.ratingUserID)
                            self.databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("amntEarned").setValue(review.amntEarned)
                            self.databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("dateRated").setValue(review.dateRated)
                            
                        }
                        
                        for imageURL in event.eventImageURLs {
                            let imageRef = self.databaseRef.child("Event").child(fireKey).child("images").childByAutoId()
                            imageRef.child("imageDownloadURL").setValue(imageURL)

                        }

                        // Now upload your photos since the write was successful
//                        if event.eventImage != UIImage(named: "UploadPhoto") {
//                            if event.eventImageURLs.count > 0 {
//                            let imageRef = self.databaseRef.child("Event").child(fireKey).child("images").childByAutoId()
//                            let imageStorageKey = imageRef.key
//                            if let imageData = event.eventImage.jpegData(compressionQuality: 0.6) {
//                                let imageStorageRef = self.storageRef.child("images").child(imageStorageKey!)
//                                let uploadTask = imageStorageRef.putData(imageData, metadata: nil) { (metadata, error) in
//                                    guard let metadata = metadata else {
//                                        // Uh-oh, an error occurred!
//                                        return
//                                    }
//                                    // Metadata contains file metadata such as size, content-type
//                                    //let size = metadata.size
//
//                                    // You can also access to download URL after upload.
//                                    imageStorageRef.downloadURL(completion: { (url, error) in
//                                        guard let downloadURL = url else {
//                                            // Uh-oh, an error occurred!
//                                            return
//                                        }
//                                        self.imageDownloadURL = downloadURL.absoluteString
//                                        imageRef.child("imageDownloadURL").setValue(self.imageDownloadURL)
//                                    })
//                                }
//                            }
//                        }
                    }
                }

            }
        }
        saveGeoFire()
    }

    // function to add geofire (latitude, longitude) to DB
    func saveGeoFire() {
        
        databaseRef = Database.database().reference()
        databaseRef.child("Event").observe(.childAdded) { (snapshot) in
            
            if !snapshot.exists() {
                print("no snapshot data mon!")
                return()
            }
                let eventKey = snapshot.key
                var eventStreet = ""
            if let tmpStreet = snapshot.childSnapshot(forPath: "eventStreet").value as? String {
                eventStreet = tmpStreet
            }
            var eventCity = ""
            if let tmpCity = snapshot.childSnapshot(forPath: "eventCity").value as? String {
                eventCity = tmpCity
            }
            var eventState = ""
            if let tmpState = snapshot.childSnapshot(forPath: "eventState").value as? String {
                eventState = tmpState
            }
            var eventZip = ""
            if let tmpZip = snapshot.childSnapshot(forPath: "eventZip").value as? String {
                eventZip = tmpZip
            }
                let address:String = eventStreet + ", " + eventCity + ", " + eventState + " " + eventZip
                
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(address) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                        else {
                            //handle no location found
                            print("No location found for ", address)
                            return
                    }
                    self.setEventLocation(eventKey: eventKey, location: location)
                }
        }

    }

    func setEventLocation(eventKey: String, location: CLLocation) {

        FndDatabase.GEO_REF.setLocation(location, forKey: eventKey)
    }
    

    @objc func getNearByEvents() {
        self.databaseRef = Database.database().reference(withPath: "Event")
        var eventKeys = [String]()
        var whereYouAt : CLLocation?
        if let userHood = self.userLocation {
            //User just picked a city
            whereYouAt = userHood
        } else {
            //Display events based on the user's current location
            if let latitude = locationManager.location?.coordinate.latitude, let longtitude = locationManager.location?.coordinate.longitude {
                whereYouAt = CLLocation(latitude: latitude, longitude: longtitude)
            } else {
                whereYouAt = CLLocation(latitude: 37.332, longitude: -122.031)
            }
        }
        let query = FndDatabase.GEO_REF.query(at: whereYouAt!, withRadius: 100)
        self.userLocation = CLLocation()
        
            // Populate list of keys
        query.observe(.keyEntered, with: { (eventKey: String!, location: CLLocation!) in
                eventKeys.append(eventKey)
            })

            // Do something with list of keys.
            query.observeReady({
                if eventKeys.count > 0 {
                    for eventKey in eventKeys {
                        self.events = []
                        self.databaseRef.queryOrderedByKey().queryEqual(toValue: eventKey).observe(.childAdded, with: { snapshot in
                            
                            //Build the event variables
                            if !snapshot.exists() {
                                print("no snapshot data mon!")
                                return()
                            }
                            
                            let eventName = snapshot.childSnapshot(forPath: "eventName").value as! String
                            let eventStreet = snapshot.childSnapshot(forPath: "eventStreet").value as! String
                            let eventCity = snapshot.childSnapshot(forPath: "eventCity").value as! String
                            let eventState = snapshot.childSnapshot(forPath: "eventState").value as! String
                            var eventCountry = "United States"
                            let country = snapshot.childSnapshot(forPath: "eventCountry").value as? String
                            if let Country = country, !Country.isEmpty {
                                eventCountry = Country
                            }
                            
                            let eventContact = snapshot.childSnapshot(forPath: "eventContact").value as! String
                            let eventPhone = snapshot.childSnapshot(forPath: "eventPhone").value as! String
                            let eventEmail = snapshot.childSnapshot(forPath: "eventEmail").value as! String
                            var eventWebSite = ""
                            let webSite = snapshot.childSnapshot(forPath: "eventWebSite").value as? String
                            if let Site = webSite, !Site.isEmpty {
                                eventWebSite = Site
                            }
                            let eventFromDate = snapshot.childSnapshot(forPath: "eventFromDate").value as! String
                            var eventToDate = ""
                            let toDate = snapshot.childSnapshot(forPath: "eventToDate").value as? String
                            if let endDate = toDate, !endDate.isEmpty {
                                eventToDate = endDate
                            }
                            let eventCreator = snapshot.childSnapshot(forPath: "eventCreator").value as! String
                            let eventFrequency = snapshot.childSnapshot(forPath: "frequency").value as! String
                            let eventCategory = snapshot.childSnapshot(forPath: "eventCategory").value as! String
                            var eventAttendance = 0
                            let attendance = snapshot.childSnapshot(forPath: "eventAttendance").value as? Int
                            if let attendees = attendance, (attendees != 0) {
                                eventAttendance = attendees
                            }
                            var eventAvgEarnings = 0.0
                            let earnings = snapshot.childSnapshot(forPath: "eventAvgEarnings").value as? Double
                            if let vendorTake = earnings, !vendorTake.isZero {
                                eventAvgEarnings = vendorTake
                            }
                            var eventDetails = ""
                            let detail = snapshot.childSnapshot(forPath: "eventDetails").value as? String
                            if let details = detail, !details.isEmpty {
                                eventDetails = details
                            }
                            var eventVendorFee = ""
                            let fee = snapshot.childSnapshot(forPath: "eventVendorFee").value as? String
                            if let fees = fee, !fees.isEmpty {
                                eventVendorFee = fees
                            }
                            var eventVenue = ""
                            let venue = snapshot.childSnapshot(forPath: "eventVenue").value as? String
                            if let locale = venue, !locale.isEmpty {
                                eventVenue = locale
                            }
                            var eventRatingCount = 0
                            let ratings = snapshot.childSnapshot(forPath: "eventRatingCount").value as? Int
                            if let rating = ratings, (rating != 0) {
                                eventRatingCount = rating
                            }
                            var eventZip = ""
                            let zip = snapshot.childSnapshot(forPath: "eventZip").value as? String
                            if let postal = zip, !postal.isEmpty {
                                eventZip = postal
                            }
                            var eventAvgRating = 0.0
                            let avgRating = snapshot.childSnapshot(forPath: "eventAvgRating").value as? Double
                            if let avgRatings = avgRating, !avgRatings.isZero {
                                eventAvgRating = avgRatings
                            }

                            var eventReviews = [vendorRatings]()
                            for reviews in snapshot.childSnapshot(forPath: "Reviews").children {
                                let snap = reviews as! DataSnapshot
                                let eventRating = snap.childSnapshot(forPath: "Rating").value as! Int
                                let ratingUserID = snap.childSnapshot(forPath: "ratingUserID").value as! String
                                let ratingUsername = snap.childSnapshot(forPath: "Reviewer").value as! String
                                let ratingComment = snap.childSnapshot(forPath: "Comment").value as! String
                                let amntEarned = snap.childSnapshot(forPath: "Earnings").value as! Double
                                let dateRated = snap.childSnapshot(forPath: "dateRated").value as! String
                                guard let review = vendorRatings(eventRating : eventRating, ratingUserID : ratingUserID, ratingUsername : ratingUsername, ratingComment : ratingComment, amntEarned : amntEarned, dateRated : dateRated) else {
                                    fatalError("Unable to instantiate review")
                                }
                                eventReviews.append(review)
                            }

                            let eventImage = UIImage()
                            var eventImageURLs = [String]()
                            if snapshot.childSnapshot(forPath: "images").childrenCount == 0 {
                            } else {
                                
                                for images in snapshot.childSnapshot(forPath: "images").children {
                                    let imageSnap = images as! DataSnapshot
                                    let imageURL = imageSnap.childSnapshot(forPath: "imageDownloadURL").value as! String
                                    eventImageURLs.append(imageURL)
                                }
                            }

                            guard let event = Event(eventName : eventName, eventImage : eventImage, eventImageURLs : eventImageURLs, eventCategory : eventCategory, eventStreet : eventStreet, eventCity : eventCity, eventState : eventState, eventCountry : eventCountry, eventContact : eventContact, eventPhone : eventPhone, eventEmail : eventEmail, eventWebSite : eventWebSite, eventFromDate : eventFromDate, eventToDate : eventToDate, eventCreator : eventCreator, eventFrequency : eventFrequency, eventAttendance : eventAttendance, eventAvgEarnings : eventAvgEarnings, eventVenue : eventVenue, eventVendorFee : eventVendorFee, eventZip : eventZip, eventRatingCount : eventRatingCount, eventAvgRating : eventAvgRating, eventDetails: eventDetails, eventReviews : eventReviews)
                                else {
                                    fatalError("Unable to instantiate event")
                            }
                            self.events += [event]
                            self.filteredEvents = self.events
                            self.tableView.reloadData()
                        })
                    }
                } else {
                    self.addFirstEvent()
                }
        })
                
        let deadline = DispatchTime.now() + .milliseconds(700)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refreshTable.endRefreshing()
        }
        self.tableView.reloadData()
    }

    func random(from range: ClosedRange<Int>) -> Int {
        let lowerBound = range.lowerBound
        let upperBound = range.upperBound
        
        return lowerBound + Int(arc4random_uniform(UInt32(upperBound - lowerBound + 1)))
    }

    func showAlert(title: String, message: String? = "") {
       if #available(iOS 8.0, *) {
         let alertController =
             UIAlertController(title: title, message: message, preferredStyle: .alert)
         alertController.addAction(UIAlertAction(title: "OK",
                                                 style: .default,
                                               handler: { (UIAlertAction) in
           alertController.dismiss(animated: true, completion: nil)
         }))
         self.present(alertController, animated: true, completion: nil)
       } else {
         UIAlertView(title: title,
                     message: message ?? "",
                     delegate: nil,
                     cancelButtonTitle: nil,
                     otherButtonTitles: "OK").show()
       }
     }
    
    private func ifNoError(_ error: Error?, execute: () -> Void) {
      guard error == nil else {
        showAlert(title: "Error", message: error!.localizedDescription)
        return
      }
      execute()
    }
    
    @IBAction func signInTapped(_ sender: AnyObject) {
        
        if (Auth.auth().currentUser) != nil {
            if (Auth.auth().currentUser?.isAnonymous != false) {
                Auth.auth().currentUser?.delete() { error in
                self.ifNoError(error) {
                self.showAlert(title: "", message:"The user was properly deleted.")
                self.signInButton.title = "Sign In"
              }
            }
          } else {
            do {
                try FUIAuth.defaultAuthUI()!.signOut()
            } catch let error {
                self.ifNoError(error) {
                self.showAlert(title: "Error", message:"The user was properly signed out.")
                self.signInButton.title = "Sign In"
              }
            }
          }
            return
        }
        guard let authUI = FUIAuth.defaultAuthUI()
            else { return }
        
        authUI.delegate = self
        
        let authViewController = authUI.authViewController()
        present(authViewController, animated: true)
        
    }

    func addFirstEvent() {

        let alertController = UIAlertController(title: "No events found nearby", message: "Be the first to add one!", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Add Event", style: .default) { (_) in

            self.performSegue(withIdentifier: "AddEvent", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (alert: UIAlertAction!) -> Void in

        }

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func randomPic() -> String {
        
        // Get a random pic for the event based on category if user didn't add a photo
//        let eventTypes = ["Other", "Entertainment", "Wine & Food", "Arts & Craft", "Shopping"]
        let eventAcro = ["OI", "CI", "FI", "AW", "SI"]
        var selectedImage : String?
        
        let photoNum = random(from: 1 ... 10)
        let randAcro = random(from: 0 ... 4)

        selectedImage = eventAcro[randAcro] + String(photoNum)
        return selectedImage!
    }

}

extension EventTableViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        print("handle user signup / login")
    }
}
//MARK: - Location Manager Elements

extension EventTableViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        
        CLGeocoder().reverseGeocodeLocation(userLocation!) { (placemarks, error) in
            
            if error != nil {
                print (error!)
                
            } else if let placemark = placemarks?[0] {
                
                var userStreet = ""
                if placemark.locality != nil {
                    userStreet = placemark.thoroughfare!
                    self.userCity = userStreet
                }
                
                var userCity = ""
                if placemark.locality != nil {
                    userCity = placemark.locality!
                    self.cityButton.title = userCity
                    self.userCity = userCity
                }
                
                var userState = ""
                if placemark.administrativeArea != nil {
                    userState = placemark.administrativeArea!
                    self.userState = userState
                }
                
                var userZip = ""
                if placemark.postalCode != nil {
                    userZip = placemark.postalCode!
                    self.userZip = userZip
                }
                if placemark.location != nil {
                    self.userLat = (placemark.location?.coordinate.latitude)!
                    self.userLon = (placemark.location?.coordinate.longitude)!
//                    self.self.getNearByEvents(userLoc: self.userLocation!)
                }
                print(userCity + "\n" + userState)
            }
        }
    }
}

