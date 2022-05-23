//
//  AddReviewViewController.swift
//  Street Vendor Helper
//
//  Created by Theophilus Drackett on 1/27/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit
import os.log
import FirebaseAuth
import FirebaseCore

class AddReviewViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate {
   

    @IBOutlet weak var reviewer: UITextField!
    @IBOutlet weak var addStars: RatingControl!
    @IBOutlet weak var addComment: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var vendorLoot: UITextField!
    @IBOutlet weak var lootPicker: UIPickerView!
    @IBOutlet weak var vendorLootLabel: UILabel!
    @IBOutlet weak var yourNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var chooseRatingLabel: UILabel!
    
//    var userName : String?
//    var userEmail : String?
    var loggedIn : Bool?
    var event : Event?
    let vendorTake = ["Rather not say", "$0 - $300", "$300 - $600", "$600 - $900", "$900 - $1,200", "$1,200 - $1,500", "$1,500 - $1,800", "> $2,000"]

    
    var reviews = [vendorRatings]()
    var review: vendorRatings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lootPicker.delegate = self
        lootPicker.dataSource = self
        addComment.delegate = self
        vendorLoot.text = "Rather not say"
        
        if let evented = event {
            navigationItem.title = evented.eventName
        }

        // Get user's info from Firebase
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if Auth.auth().currentUser != nil {
                // User is signed in.
                let user = Auth.auth().currentUser
                if let user = user {
                    let userName = (user.displayName)
                    var components = userName!.components(separatedBy: " ")
                    if(components.count > 0)
                    {
                     let firstName = components.removeFirst()
//                     let lastName = components.joined(separator: " ")
                         self.reviewer.text = String(firstName)
                    }

                    self.loggedIn = true
                }
            } else {
                // User is not signed in
                self.userMustLogIn()
                self.navigationController?.popViewController(animated: true)
                return
            }
        }
        
        self.addComment.layer.borderWidth = 1.0
        setUpElements()
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddRatingMode = presentingViewController is UINavigationController
        
        if isPresentingInAddRatingMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The EventViewController is not inside a navigation controller.")
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.clearsOnInsertion = true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.clearsOnBeginEditing = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        let numRows = self.vendorTake.count
        
        return numRows
    }
    

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
            return vendorTake[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        vendorLoot.text = vendorTake[row]
    }
    

    // MARK: - Navigation

    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ARaddPhoto" {
            guard let addPhotoViewController = segue.destination as? AddPhotoViewController else {
                fatalError("Unexpected destination: \(String(describing: segue.destination))")
            }
            addPhotoViewController.event = event
        } else {
            
            // Configure the destination view controller only when the save button is pressed.
            guard let button = sender as? UIBarButtonItem, button === saveButton else {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
                return
            }
            let reviewer = self.reviewer.text ?? ""
            let comment = self.addComment.text ?? ""
            let rating = self.addStars.rating
            let lootDict = ["Rather not say": 0, "$0 - $300": 150, "$300 - $600": 450, "$600 - $900":750, "$900 - $1,200": 1050, "$1,200 - $1,500": 1350, "$1,500 - $1,800": 1650, "> $2,000": 2000]
            var loot = 0
            loot = lootDict[vendorLoot.text!] ?? 0
            let reviewDate = Date()
            let todaysDate = reviewDate.asString(style: .medium) // Jan 10, 2018
            let userID = Auth.auth().currentUser?.uid

            review = vendorRatings(eventRating: rating, ratingUserID: userID!, ratingUsername: reviewer, ratingComment: comment, amntEarned: Double(loot), dateRated: todaysDate)
        }
    }
    
    func setUpElements() {

        // Style the elements
        Utilities.styleTextField(reviewer)
        Utilities.styleTextview(addComment)
        Utilities.styleTextField(vendorLoot)
        Utilities.styleLabel(vendorLootLabel)
        Utilities.styleLabel(yourNameLabel)
        Utilities.styleLabel(commentLabel)
        Utilities.styleLabel(chooseRatingLabel)
    }
    
    //The user must be logged in to add or edit an event
    func userMustLogIn() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "You must be logged in to add or edit events", message: "", preferredStyle: .alert)
        
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

extension Date {
  func asString(style: DateFormatter.Style) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = style
    return dateFormatter.string(from: self)
  }
}
