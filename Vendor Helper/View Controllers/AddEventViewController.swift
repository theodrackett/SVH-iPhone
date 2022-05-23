//
//  AddEventViewController.swift
//  event Helper
//
//  Created by Theophilus Drackett on 1/6/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit
import os.log
import FirebaseDatabase
import FirebaseAuth
import CoreLocation


class AddEventViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventVenueLabel: UILabel!
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var yourNameLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var numAttendeesLabel: UILabel!
    @IBOutlet weak var vendorFeeLabel: UILabel!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var addScroll: UIScrollView!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventVenue: UITextField!
    @IBOutlet weak var eventType: UITextField!
    @IBOutlet weak var eventDate: UITextField!
    @IBOutlet weak var eventToDate: UITextField!
    @IBOutlet weak var eventContact: UITextField!
    @IBOutlet weak var eventPhone: UITextField!
    @IBOutlet weak var eventEmail: UITextField!
    @IBOutlet weak var eventWebSite: UITextField!
    @IBOutlet weak var eventStreet: UITextField!
    @IBOutlet weak var eventCity: UITextField!
    @IBOutlet weak var eventZip: UITextField!
    @IBOutlet weak var eventState: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var eventCreator: UITextField!
    @IBOutlet weak var addEventImage: UIImageView!
    @IBOutlet weak var frequency: UITextField!
    @IBOutlet weak var eventCountry: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var noAttendees: UITextField!
    @IBOutlet weak var vendorFee: UITextField!
    @IBOutlet weak var eventDetails: UITextView!
    
    
    let unitedStates = ["Other","AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MS","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]
    let eventTypes = ["Arts & Craft", "Commerce", "Concert", "Farmers Market", "Food & Beverages", "Flea Market", "Other"]
    let eventAcro = ["OI", "CI", "FI", "AW", "SI"]
    let eventPickerView = UIPickerView()
    let statePickerView = UIPickerView()
    let datePickerView = UIDatePicker()
    var activeTextField = ""
    var rowSelected = 0
    var selectedImage : String?
    var userName : String?
    var userEmail : String?
    var loggedIn : Bool?
    var activeField: UITextField?
    var eventImageURLs = [String]()
    var eventImage = UIImage(named: "UploadPhoto")
    
    /*
     This value is either passed by `ShowViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new event.
     */
    var event: Event?
    
    var databaseRef : DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayToolBar()
        displayDateToolBar()
        displayToDateToolBar()
        eventName.allowsEditingTextAttributes = true
        eventPickerView.delegate = self
        eventPickerView.dataSource = self
        statePickerView.delegate = self
        statePickerView.dataSource = self
        frequency.delegate = self
        eventContact.delegate = self
        eventName.delegate = self
        eventPhone.delegate = self
        eventEmail.delegate = self
        eventWebSite.delegate = self
        eventStreet.delegate = self
        eventCity.delegate = self
        eventCountry.delegate = self
        
        registerForKeyboardNotifications()
        
        // setup theme
        setUpElements()
        
        // Fill in detail if editing view controller
        if let event = event {
            navigationItem.title = event.eventName
            eventName.text = event.eventName
            eventVenue.text = event.eventVenue
            eventType.text = event.eventCategory
            eventDate.text = event.eventFromDate
            eventToDate.text = event.eventToDate
            eventContact.text = event.eventContact
            eventPhone.text = event.eventPhone
            eventEmail.text = event.eventEmail
            eventWebSite.text = event.eventWebSite
            eventStreet.text = event.eventStreet
            eventCity.text = event.eventCity
            eventState.text = event.eventState
            eventZip.text = event.eventZip
            eventCountry.text = event.eventCountry
            frequency.text = event.eventFrequency
            eventDetails.text = event.eventDetails
            eventName.allowsEditingTextAttributes = false
            noAttendees.text = String(event.eventAttendance)
            vendorFee.text = String(event.eventVendorFee)
            
            // Save event images
            for imageURL in event.eventImageURLs {
                eventImageURLs.append(imageURL)
            }
        }
        
        // Handle the event name text field’s user input through delegate callbacks.
        eventName.delegate = self
        eventCity.delegate = self
        
        // Enable the Save button only if the text field has a valid Event name and valid event city.
        updateSaveButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // User must be logged in to add events
        _ = Auth.auth().addStateDidChangeListener { (auth, user) in
            if Auth.auth().currentUser != nil {
                // User is signed in.
                if let uName = (Auth.auth().currentUser?.displayName) {
                    self.userName = uName
                    self.eventCreator.text = self.userName
                }
                self.loggedIn = true
            } else {
                self.userMustLogIn()
                self.navigationController?.popViewController(animated: true)
//                self.transitionToFB()
                return
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addScroll.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+300)
    }
    
    //MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddEventMode = presentingViewController is UINavigationController
        
        if isPresentingInAddEventMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The EventViewController is not inside a navigation controller.")
        }
        deregisterFromKeyboardNotifications()
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }

        let eventName = self.eventName.text ?? ""
        let eventVenue = self.eventVenue.text ?? ""
        let eventCategory = self.eventType.text ?? ""
        let eventStreet = self.eventStreet.text ?? ""
        let eventCity = self.eventCity.text ?? ""
        let eventState = self.eventState.text ?? ""
        let eventZip = self.eventZip.text ?? ""
        let eventCountry = self.eventCountry.text ?? ""
        let eventContact = self.eventContact.text ?? ""
        let eventPhone = self.eventPhone.text ?? ""
        let eventEmail = self.eventEmail.text ?? ""
        let eventWebSite = self.eventWebSite.text ?? ""
        let eventFromDate = self.eventDate.text ?? ""
        let eventToDate = self.eventToDate.text ?? ""
        let eventCreator = self.eventCreator.text ?? ""
        let eventFrequency = self.frequency.text ?? ""
//        let eventImageURLs = [String]()
//        let eventImage = UIImage(named: "UploadPhoto")
            //addEventImage.image
        let eventAttendance = Int(self.noAttendees.text!) ?? 0
        let eventAvgEarnings = 0.0
        let eventVendorFee = self.vendorFee.text ?? ""
        let eventRatingCount = 0
        let eventAvgRating = 0.0
        let eventDetails = self.eventDetails.text ?? ""

        //Initialize vendor comments array
        let eventReviews = [vendorRatings]()

        event = Event(eventName : eventName, eventImage : eventImage!, eventImageURLs : eventImageURLs, eventCategory : eventCategory, eventStreet : eventStreet, eventCity : eventCity, eventState : eventState, eventCountry : eventCountry, eventContact : eventContact, eventPhone : eventPhone, eventEmail : eventEmail, eventWebSite : eventWebSite, eventFromDate : eventFromDate, eventToDate : eventToDate, eventCreator : eventCreator, eventFrequency : eventFrequency, eventAttendance : eventAttendance, eventAvgEarnings : eventAvgEarnings, eventVenue : eventVenue, eventVendorFee : eventVendorFee, eventZip : eventZip, eventRatingCount : eventRatingCount, eventAvgRating : eventAvgRating, eventDetails: eventDetails, eventReviews : eventReviews)
        
        deregisterFromKeyboardNotifications()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Disable the Save button while editing.
        activeField = textField
        if textField == self.eventName || textField == self.eventCity {
            updateSaveButtonState()
        }

        if (textField == self.eventState) {
            activeTextField = "eventState"
            if eventState.placeholder != "Enter your state or province" {
                self.eventState.inputView = statePickerView
            }
        } else if (textField == self.eventType) {
            activeTextField = "eventType"
            self.eventType.inputView = eventPickerView
        } else if (textField == self.eventDate) {
            activeTextField = "eventDate"
        } else if (textField == self.eventToDate) {
            activeTextField = "eventToDate"
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        databaseRef = Database.database().reference()
        if textField == self.eventName || textField == self.eventCity {
            updateSaveButtonState()
        }
        if textField == self.eventName {
            
            navigationItem.title = textField.text
            
            let name = textField.text
            databaseRef.child("Event").queryOrdered(byChild:"eventName").queryEqual(toValue:name).observe(.childAdded, with: { snapshot in
                // Check if event already exists
                let eventNam = snapshot.childSnapshot(forPath: "eventName").value as! String
                let eventCit = snapshot.childSnapshot(forPath: "eventCity").value as! String
                self.eventAlreadyExists(eventNam: eventNam, eventCit: eventCit)
            })
        }
        activeField = nil
        textField.resignFirstResponder()
    }
    
    //MARK: UIPickerView config
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if (activeTextField == "eventState") {
            
            let titleRow = unitedStates[row]
            return titleRow
        }
        else if (activeTextField == "eventType") {
            
            let titleRow = eventTypes[row]
            return titleRow
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        var numRows : Int = unitedStates.count
        if (activeTextField == "eventType") {
            
            numRows = self.eventTypes.count
        }
        return numRows
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        rowSelected = row
    }
    
    func displayToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(AddEventViewController.selectItem))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.barTintColor = UIColor.black
        toolBar.backgroundColor = UIColor.black
        eventType.inputAccessoryView = toolBar
        eventState.inputAccessoryView = toolBar
    }
    
    func displayDateToolBar() {
        let dateToolBar = UIToolbar()
        dateToolBar.sizeToFit()
        
        let dateDoneButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(AddEventViewController.selectDate))
        dateToolBar.setItems([dateDoneButton], animated: false)
        dateToolBar.isUserInteractionEnabled = true
        dateToolBar.barTintColor = UIColor.black
        dateToolBar.backgroundColor = UIColor.black
        datePickerView.datePickerMode = .date
        eventDate.inputView = datePickerView
        eventDate.inputAccessoryView = dateToolBar
    }
    
    func displayToDateToolBar() {
        let dateToolBar = UIToolbar()
        dateToolBar.sizeToFit()
        
        let dateDoneButton = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(AddEventViewController.selectToDate))
        dateToolBar.setItems([dateDoneButton], animated: false)
        dateToolBar.isUserInteractionEnabled = true
        dateToolBar.barTintColor = UIColor.black
        dateToolBar.backgroundColor = UIColor.black
        datePickerView.datePickerMode = .date
        eventToDate.inputView = datePickerView
        eventToDate.inputAccessoryView = dateToolBar
    }

    
    @objc func selectItem() {
        //    view.endEditing(true)
        if (activeTextField == "eventState") {
            if unitedStates[rowSelected] == "Other" {
                eventState.text = ""
                eventState.placeholder = "Enter your state or province"
                eventState.inputView = nil
                eventState.inputAccessoryView = nil
                eventCountry.text = ""
                eventCountry.placeholder = "Enter your country"
                eventCountry.isUserInteractionEnabled = true

            } else {
                eventCountry.isUserInteractionEnabled = false
                eventCountry.text = "United States"
                eventState.text = unitedStates[rowSelected]
            }
            statePickerView.resignFirstResponder()
            view.endEditing(true)
        } else if (activeTextField == "eventType") {
            eventType.text = eventTypes[rowSelected]
            eventPickerView.resignFirstResponder()
            view.endEditing(true)
        }
    }
    
    @objc func selectDate() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: datePickerView.date)
        
        eventDate.text = "\(dateString)"
        self.view.endEditing(true)
    }
    
    @objc func selectToDate() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: datePickerView.date)
        
        eventToDate.text = "\(dateString)"
        self.view.endEditing(true)
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = eventName.text ?? ""
        let text1 = eventCity.text ?? ""
        saveButton.isEnabled = !text.isEmpty
        saveButton.isEnabled = !text1.isEmpty
    }

    //Random number generator
    func random(from range: ClosedRange<Int>) -> Int {
        let lowerBound = range.lowerBound
        let upperBound = range.upperBound
        
        return lowerBound + Int(arc4random_uniform(UInt32(upperBound - lowerBound + 1)))
    }
    
        func setUpElements() {
        
            // Style the elements

            Utilities.styleLabel(eventNameLabel)
            Utilities.styleLabel(eventVenueLabel)
            Utilities.styleLabel(eventTypeLabel)
            Utilities.styleLabel(fromDateLabel)
            Utilities.styleLabel(contactLabel)
            Utilities.styleLabel(phoneLabel)
            Utilities.styleLabel(emailLabel)
            Utilities.styleLabel(websiteLabel)
            Utilities.styleLabel(cityLabel)
            Utilities.styleLabel(streetLabel)
            Utilities.styleLabel(stateLabel)
            Utilities.styleLabel(countryLabel)
            Utilities.styleLabel(yourNameLabel)
            Utilities.styleLabel(frequencyLabel)
            Utilities.styleLabel(toDateLabel)
            Utilities.styleLabel(toDateLabel)
            Utilities.styleLabel(numAttendeesLabel)
            Utilities.styleLabel(vendorFeeLabel)
            Utilities.styleLabel(zipLabel)
            
            Utilities.styleTextField(eventName)
            Utilities.styleTextField(eventVenue)
            Utilities.styleTextField(eventType)
            Utilities.styleTextField(eventDate)
            Utilities.styleTextField(eventToDate)
            Utilities.styleTextField(eventContact)
            Utilities.styleTextField(eventPhone)
            Utilities.styleTextField(eventEmail)
            Utilities.styleTextField(eventWebSite)
            Utilities.styleTextField(eventStreet)
            Utilities.styleTextField(eventCity)
            Utilities.styleTextField(eventZip)
            Utilities.styleTextField(eventState)
            Utilities.styleTextField(eventCreator)
            Utilities.styleTextField(frequency)
            Utilities.styleTextField(eventCountry)
            Utilities.styleTextField(noAttendees)
            Utilities.styleTextField(vendorFee)
                        
        }

    
    //The user must be logged in to add or edit an event
    func userMustLogIn() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "You must be logged in", message: "to add or edit events", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in
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
    
    func eventAlreadyExists(eventNam: String, eventCit: String) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: eventNam, message: "exists in \(eventCit)", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let okAction = UIAlertAction(title: "OK", style: .default)

        //adding the action to dialogbox
        alertController.addAction(okAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        // Set photoImageView to display the selected image.
//        addEventImage.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addImageCameraButton(_ sender: Any) {
        //Hide the keyboard
        eventName.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)

    }
    
    @IBAction func addEventImageGestRec(_ sender: UITapGestureRecognizer) {
        //Hide the keyboard
        eventName.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
