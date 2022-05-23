//
//  EventDetailsViewController.swift
//  Vendor Helper
//
//  Created by Theophilus Drackett on 1/5/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit
import os.log
import FirebaseDatabase
import MapKit
import GoogleMobileAds

class EventDetailsViewController: UIViewController  {
    
    //MARK: Properties
    
    @IBOutlet weak var bannerVu: GADBannerView!
    @IBOutlet weak var eventImages: UIScrollView!
    @IBOutlet weak var scrollEvent: UIScrollView!
    @IBOutlet weak var RatingControl: RatingControl!
    @IBOutlet weak var numReviews: UILabel!
    @IBOutlet weak var catCity: UILabel!
    @IBOutlet weak var eventWhen: UILabel!
    @IBOutlet weak var eventWhere: UILabel!
    @IBOutlet weak var eventAddress: UITextView!
    @IBOutlet weak var eventContact: UILabel!
    @IBOutlet weak var eventPhone: UITextView!
    @IBOutlet weak var eventEmail: UITextView!
    @IBOutlet weak var eventWebsite: UITextView!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var rateThisEvent: UIBarButtonItem!
    @IBOutlet weak var eventFrequency: UILabel!
    @IBOutlet weak var eventTurnout: UILabel!
    @IBOutlet weak var eventVendorFee: UILabel!
    @IBOutlet weak var eventEarnings: UILabel!
    @IBOutlet weak var eventMap: MKMapView!
    @IBOutlet weak var eventDetails: UILabel!
    @IBOutlet weak var showEventScrollView: UIScrollView!
    @IBOutlet weak var reviewTableLabel: UILabel!
    @IBOutlet weak var seeAllReviewsButton: UIButton!
    
    var event : Event?
    var events = [Event]()
    var databaseRef : DatabaseReference!
    var imageArray = [UIImage]()
    
    let formatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        commentTableView.dataSource = self
        commentTableView.register(UINib(nibName: "MiniTableViewCell", bundle: nil), forCellReuseIdentifier: "MiniTableCell")
        
        displayEvent()
        initBannerView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showEventScrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 450)
        
    }
    
    func displayEvent() {
        if let event = event {
            navigationItem.title = event.eventName
            //            seeAllReviewsButton.backgroundColor = .black
            
            if event.eventReviews.count == 0 {
                seeAllReviewsButton.isHidden = true
                reviewTableLabel.text = "Be the first to review"
            }
            
            if event.eventImageURLs.count > 0 {
                let stackView = UIStackView()
                stackView.translatesAutoresizingMaskIntoConstraints = false
                eventImages.addSubview(stackView)
                stackView.leadingAnchor.constraint(equalTo: eventImages.leadingAnchor, constant: 0.0).isActive = true
                stackView.topAnchor.constraint(equalTo: eventImages.topAnchor, constant: 0.0).isActive = true
                stackView.trailingAnchor.constraint(equalTo: eventImages.trailingAnchor, constant: 0.0).isActive = true
                stackView.bottomAnchor.constraint(equalTo: eventImages.bottomAnchor, constant: 0.0).isActive = true
                
                for i in 0..<event.eventImageURLs.count {
                    let imageView = UIImageView()
                    let url = URL(string: event.eventImageURLs[i])
                    imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "Default"))
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    imageView.contentMode = .scaleAspectFill
                    stackView.addArrangedSubview(imageView)
                    
                    // set imgView's width and height to the scrollView's width and height
                    imageView.widthAnchor.constraint(equalTo: eventImages.widthAnchor, multiplier: 1.0).isActive = true
                    imageView.heightAnchor.constraint(equalTo: eventImages.heightAnchor, multiplier: 1.0).isActive = true
                    
                }
            } else {
                let imageView = UIImageView()
                let photo = self.randomPic()
                imageView.image = (UIImage(named: photo)!)
                imageView.contentMode = .scaleAspectFill
                let xPosition = self.eventImages.frame.width * CGFloat(0)
                imageView.frame = CGRect(x: xPosition, y: 0, width: 414, height: 160)
                
                imageView.layer.cornerRadius = 5.0
                eventImages.contentSize.width = eventImages.frame.width * CGFloat(0 + 1)
                
                eventImages.addSubview(imageView)
            }
            
            //Calculate the average rating and assign it to the rating control
            let reviewsAmt = event.eventReviews.count
            var totalRatings = 0
            var averageRating = 0
            if reviewsAmt > 0 {
                for ctr in 0...reviewsAmt-1 {
                    totalRatings = totalRatings + event.eventReviews[ctr].eventRating
                }
                averageRating = Int(totalRatings/reviewsAmt)
            }
            RatingControl.rating = averageRating
            numReviews.text = String(reviewsAmt) + " Reviews"
            
            catCity.text = event.eventName
            if !event.eventToDate.isEmpty {
                eventWhen.text = "When: " + event.eventFromDate + " to " + event.eventToDate
            } else {
                eventWhen.text = "When: " + event.eventFromDate + " to " + event.eventFromDate
            }
            //            eventWhere.isEditable = false
            eventWhere.text = "Where: " + event.eventVenue
            eventAddress.text = event.eventStreet + " " + event.eventCity + ", " + event.eventState + " " + event.eventZip + " " + event.eventCountry
            eventContact.text = "Contact: " + event.eventContact
            eventPhone.isEditable = false
            eventPhone.dataDetectorTypes = UIDataDetectorTypes.all
            eventPhone.text = "Phone: " + event.eventPhone
            eventEmail.isEditable = false
            eventEmail.dataDetectorTypes = UIDataDetectorTypes.all
            eventEmail.text = "Email: " + event.eventEmail
            eventWebsite.isEditable = false
            eventWebsite.dataDetectorTypes = UIDataDetectorTypes.all
            eventWebsite.text = "Website: " + event.eventWebSite
            eventFrequency.isHidden = true
            if !event.eventDetails.isEmpty {
                eventDetails.text = event.eventDetails
            } else {
                eventDetails.text = "No more details available"
            }
            
            if !event.eventFrequency.isEmpty {
                eventFrequency.text = "Frequency: " + event.eventFrequency
                eventFrequency.isHidden = false
            }
            let turnout = String(event.eventAttendance)
            eventTurnout.isHidden = true
            if event.eventAttendance != 0 {
                eventTurnout.text = "Expected turnout: " + turnout
                eventTurnout.isHidden = false
            }
            let fee = String(event.eventVendorFee)
            eventVendorFee.isHidden = true
            if !fee.isEmpty {
                eventVendorFee.text = "Vendor fee: " + fee
                eventVendorFee.isHidden = false
            }
            eventEarnings.isHidden = true
            if !event.eventAvgEarnings.isZero {
                eventEarnings.text = "Avg earnings: " + "$" + String(event.eventAvgEarnings)
                eventEarnings.isHidden = false
            }
            
            getEventLoc(name: event.eventName, street: event.eventStreet, city: event.eventCity, state: event.eventState, zip: event.eventZip)
            
            let indexPaths: [IndexPath] = []
            
            self.commentTableView.insertRows(at: indexPaths, with: .automatic)
            
            //style the fields on the viewcontroller
            setUpElements()
            
        }
        
    }
    
    func getEventLoc(name: String, street: String, city: String, state: String, zip: String) {
        
        let eventAddress:String = street + "," + " " + city + "," + " " + state + " " + zip
        
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
            
            let lattitude = eventLocation.coordinate.latitude
            let longtitude = eventLocation.coordinate.longitude
            
            let annotations = MKPointAnnotation()
            annotations.title = name
            annotations.coordinate = CLLocationCoordinate2D(latitude: lattitude, longitude: longtitude)
            self.eventMap.addAnnotation(annotations)
            
            let regionRadius: CLLocationDistance = 100
            let coordinateRegion = MKCoordinateRegion(center: eventLocation.coordinate,
                                                      latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            self.eventMap.setRegion(coordinateRegion, animated: true)
            
        }
    }
    
    //MARK: - navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if var event = event {
            let eventName = event.eventName
            let eventImage = UIImage(named: "SI1")
            //            let reviewsAmt = event.eventReviews.count
            /*
             if reviewsAmt > 0 {
             var totalRatings = 0
             //Calculate the average rating and assign it to the rating control
             for ctr in 0...reviewsAmt-1 {
             totalRatings = totalRatings + event.eventReviews[ctr].vendorRating
             }
             }
             */
            let eventImageURLs = event.eventImageURLs
            let eventCategory = event.eventCategory
            let eventFromDate = event.eventFromDate
            let eventToDate = event.eventToDate
            let eventStreet = event.eventStreet
            let eventCity = event.eventCity
            let eventState = event.eventState
            let eventCountry = event.eventCountry
            let eventContact = event.eventContact
            let eventPhone = event.eventPhone
            let eventEmail = event.eventEmail
            let eventWebSite = event.eventWebSite
            let eventCreator = event.eventCreator
            let eventFrequency = event.eventFrequency
            let eventAttendance = event.eventAttendance
            let eventAvgEarnings = event.eventAvgEarnings
            let eventVenue = event.eventVenue
            let eventVendorFee = event.eventVendorFee
            let eventZip = event.eventZip
            let eventDetails = event.eventDetails
            let eventRatingCount = event.eventRatingCount
            let eventAvgRating = event.eventAvgRating
            
            
            
            // Create the event reviews to be passed to AddEventViewController
            var reviewArray = [vendorRatings]()
            
            for reviews in event.eventReviews {
                let review = reviews
                let eventRating = review.eventRating
                let ratingUserID = review.ratingUserID
                let ratingUsername = review.ratingUsername
                let ratingComment = review.ratingComment
                let amntEarned = review.amntEarned
                let dateRated = review.dateRated
                
                guard let reviewed = vendorRatings(eventRating : eventRating, ratingUserID : ratingUserID, ratingUsername : ratingUsername, ratingComment : ratingComment, amntEarned : amntEarned, dateRated : dateRated) else {
                    fatalError("Unable to instantiate review")
                }
                reviewArray.append(reviewed)
            }
            
            event = Event(eventName : eventName, eventImage : eventImage!, eventImageURLs : eventImageURLs, eventCategory : eventCategory, eventStreet : eventStreet, eventCity : eventCity, eventState : eventState, eventCountry : eventCountry, eventContact : eventContact, eventPhone : eventPhone, eventEmail : eventEmail, eventWebSite : eventWebSite, eventFromDate : eventFromDate, eventToDate : eventToDate, eventCreator : eventCreator, eventFrequency : eventFrequency, eventAttendance : eventAttendance, eventAvgEarnings : eventAvgEarnings, eventVenue : eventVenue, eventVendorFee : eventVendorFee, eventZip : eventZip, eventRatingCount : eventRatingCount, eventAvgRating : eventAvgRating, eventDetails: eventDetails, eventReviews : reviewArray)!
            
            switch(segue.identifier ?? "") {
            
            case "EditEvent":
                guard let editEventViewController = segue.destination as? AddEventViewController else {
                    fatalError("Unexpected destination: \(String(describing: segue.destination))")
                }
                editEventViewController.event = event
                
            case "AddReviews":
                guard let addReviewViewController = segue.destination as? AddReviewViewController else {
                    fatalError("Unexpected destination: \(String(describing: segue.destination))")
                }
                addReviewViewController.event = event
                os_log("Adding a new review.", log: OSLog.default, type: .debug)
                
            case "DetailAddPhoto":
                guard let addPhotoViewController = segue.destination as? AddPhotoViewController else {
                    fatalError("Unexpected destination: \(String(describing: segue.destination))")
                }
                addPhotoViewController.event = event
                
            case "ShowReviews":
                guard let showReviewsViewController = segue.destination as? EventReviewsTableViewController else {
                    fatalError("Unexpected destination: \(String(describing: segue.destination))")
                }
                showReviewsViewController.event = event
                
            default:
                fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            }
        }
    }
    
    @IBAction func unwindToReviewList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? AddReviewViewController, let review = sourceViewController.review {
            
            // Add a new review to the comment table
            let newIndexPath = IndexPath(row: (event?.eventReviews.count)!, section: 0)
            self.event?.eventReviews.append(review)
            commentTableView.insertRows(at: [newIndexPath], with: .automatic)
            
            //now add the new review to firebase
            databaseRef = Database.database().reference()
            
            if let event = event {
                event.eventReviews.append(review)
                let fireKey = (event.eventName.trimmingCharacters(in: .whitespaces)) + " " + (event.eventCity.trimmingCharacters(in: .whitespaces))
                databaseRef?.child("Event").child(fireKey)
                let commentKey = event.eventName.trimmingCharacters(in: .whitespaces) + " " + review.ratingUsername.trimmingCharacters(in: .whitespaces)
                databaseRef?.child("Event").child(fireKey).child("Reviews")
                databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey)
                databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("Comment").setValue(review.ratingComment)
                databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("Rating").setValue(review.eventRating)
                databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("Reviewer").setValue(review.ratingUsername)
                databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("Earnings").setValue(review.amntEarned)
                databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("dateRated").setValue(review.dateRated)
                databaseRef?.child("Event").child(fireKey).child("Reviews").child(commentKey).child("ratingUserID").setValue(review.ratingUserID)
            }
        }
        /*
         if let sourceViewController = sender.source as? ShowReviewsTableViewController {
         let pathRow = sourceViewController.deleteThis
         self.reviews.remove(at: pathRow.row)
         commentTableView.deleteRows(at: [pathRow], with: .fade)
         commentTableView.reloadData()
         }
         */
    }
    
    func setUpElements() {
        
        // Style the elements
        
        Utilities.styleLabel(numReviews)
        Utilities.styleLabel(catCity)
        Utilities.styleLabel(eventWhen)
        Utilities.styleLabel(eventWhere)
        //        Utilities.styleLabel(eventStreet)
        //        Utilities.styleLabel(eventCity)
        //    Utilities.styleLabel(eventState)
        //        Utilities.styleLabel(eventCountry)
        //    Utilities.styleLabel(eventZip)
        Utilities.styleLabel(eventContact)
        Utilities.styleTextview(eventPhone)
        Utilities.styleTextview(eventEmail)
        Utilities.styleTextview(eventWebsite)
        Utilities.styleLabel(eventFrequency)
        Utilities.styleLabel(eventTurnout)
        Utilities.styleLabel(eventVendorFee)
        Utilities.styleLabel(eventEarnings)
        
    }
    
    func random(from range: ClosedRange<Int>) -> Int {
        let lowerBound = range.lowerBound
        let upperBound = range.upperBound
        
        return lowerBound + Int(arc4random_uniform(UInt32(upperBound - lowerBound + 1)))
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
    
    func reloadReviews(eventName: String) {
        self.databaseRef = Database.database().reference(withPath: "Event")
        
        let name = eventName
        self.databaseRef.queryOrderedByKey().queryEqual(toValue: name).observe(.childAdded, with: { snapshot in
            
            if !snapshot.exists() {
                print("no snapshot data mon!")
                return()
            }
            
            var reviewArray = [vendorRatings]()
            
            for reviews in snapshot.childSnapshot(forPath: "Reviews").children {
                let snap = reviews as! DataSnapshot
                let ratingComment = snap.childSnapshot(forPath: "Comment").value as! String
                let eventRating = snap.childSnapshot(forPath: "Rating").value as! Int
                let ratingUsername = snap.childSnapshot(forPath: "Reviewer").value as! String
                let ratingUserID = snap.childSnapshot(forPath: "ratingUserID").value as! String
                let amntEarned = snap.childSnapshot(forPath: "amntEarned").value as! Double
                let dateRated = snap.childSnapshot(forPath: "amntEarned").value as! String
                
                guard let review = vendorRatings(eventRating : eventRating, ratingUserID : ratingUserID, ratingUsername : ratingUsername, ratingComment : ratingComment, amntEarned : amntEarned, dateRated : dateRated) else {
                    fatalError("Unable to instantiate review")
                }
                reviewArray.append(review)
            }
        })
    }
}

// MARK: - Tableview data source for comment table

extension EventDetailsViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (event?.eventReviews.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell = commentTableView.dequeueReusableCell(withIdentifier: "MiniTableCell", for: indexPath) as! MiniTableViewCell
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.gray.withAlphaComponent(0.05) : .white
        // Fetches the appropriate event for the data source layout.
        
        if let review = event?.eventReviews[indexPath.row] {
            Utilities.styleLabel(cell.vendorName)
            cell.vendorName.text = review.ratingUsername
            Utilities.styleTextview(cell.vendorComment)
            cell.vendorComment.text = review.ratingComment
            Utilities.styleLabel(cell.avgEarningLabel)
            
            if let amtEarned = formatter.string(from: review.amntEarned as NSNumber) {
                cell.avgEarningLabel.text = "Avg Earning: \(amtEarned)"
            }
            
            cell.MiniRatingControl.rating = review.eventRating
            Utilities.styleLabel(cell.dateRatedLabel)
            cell.dateRatedLabel.text = review.dateRated
        }
        return cell
    }
    
}

extension EventDetailsViewController: GADBannerViewDelegate{
    func initBannerView(){
        bannerVu.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerVu.rootViewController = self
        bannerVu.load(GADRequest())
        bannerVu.delegate = self
    }
}
