//
//  EventReviewsTableViewController.swift
//  Vendor Helper
//
//  Created by Theophilus Drackett on 1/27/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class EventReviewsTableViewController: UITableViewController {
    
    var events = [Event]()
    var event: Event?
    var numReviews  = 0
    var review: vendorRatings?
    var reviews = [vendorRatings]()
    var databaseRef : DatabaseReference!
    var deleteThis = IndexPath()
    
    let formatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatter.locale = Locale.current
        formatter.numberStyle = .currency

        if let event = event {
            navigationItem.title = event.eventName
            reviews = event.eventReviews

        }
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (reviews.count)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "ShowReviewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EventReviewsTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AddReviewCell.")
        }

        let review = reviews[indexPath.row]
        
        cell.reviewer.text = review.ratingUsername
        cell.reviewerRating.rating = review.eventRating
        cell.reviewerComment.text = review.ratingComment
        
        if let amtEarn = formatter.string(from: review.amntEarned as NSNumber) {
            cell.avgEarnings.text = "Avg Earn: \(amtEarn)"
        }
        cell.dateRated.text = review.dateRated
        
        return cell
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInShowReviewsMode = presentingViewController is UINavigationController
        
        if isPresentingInShowReviewsMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The EventViewController is not inside a navigation controller.")
        }
    }

    // MARK: - Navigation
    
    @IBAction func unwindToEventList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? EventDetailsViewController, let event = sourceViewController.event {
            numReviews = 10
                //event.eventReviews.count

        }
    }
    // MARK: Private functions
    func deleteReview(eventID:String, reviewID:String){
        //delete the event from firebase
        databaseRef = Database.database().reference()
        databaseRef.child("Event").child(eventID).child("Reviews").child(reviewID).setValue(nil)
    }
    
    //User must be logged in to delete and change reviews
    func userMustLogIn() {

        let alertController = UIAlertController(title: "You must be logged in", message: "to add or edit reviews", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
            let isPresentingInShowReviewsMode = self.presentingViewController is UINavigationController
            
            if isPresentingInShowReviewsMode {
                self.dismiss(animated: true, completion: nil)
            }
            else if let owningNavigationController = self.navigationController{
                owningNavigationController.popViewController(animated: true)
            }
            else {
                fatalError("The EventViewController is not inside a navigation controller.")
            }
        }
        
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func onlyReviewCreator() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Ony the person who created this review", message: "can edit or delete it", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
            let isPresentingInShowReviewsMode = self.presentingViewController is UINavigationController
            
            if isPresentingInShowReviewsMode {
                self.dismiss(animated: true, completion: nil)
            }
            else if let owningNavigationController = self.navigationController{
                owningNavigationController.popViewController(animated: true)
            }
            else {
                fatalError("The EventViewController is not inside a navigation controller.")
            }
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Inform the user that review has been deleted
    func reviewDeleted() {
        //Creating UIAlertController and setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Review Deleted", message: "Your review has been deleted", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
            let isPresentingInShowReviewsMode = self.presentingViewController is UINavigationController
            
            if isPresentingInShowReviewsMode {
                self.dismiss(animated: true, completion: nil)
            }
            else if let owningNavigationController = self.navigationController{
                owningNavigationController.popViewController(animated: true)
            }
            else {
                fatalError("The EventViewController is not inside a navigation controller.")
            }
            //getting the input values from user
            //            present(FacebookViewController, animated: true, completion: nil)
            
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }

}
