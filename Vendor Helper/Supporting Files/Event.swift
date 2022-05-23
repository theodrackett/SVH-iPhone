//
//  Event.swift
//  Vendor Helper
//
//  Created by Theophilus Drackett on 1/6/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit
import os.log
import FirebaseDatabase
import GeoFire
import Foundation

struct FndDatabase {
    static let LOCATION = Database.database().reference().child("eventLocs")
    static let GEO_REF = GeoFire(firebaseRef: LOCATION)
}

struct userInfo {
    var userName : String
    var userEmail : String
    var isLoggedIn : Bool
}

//class userInfo {
//    var userName : String
//    var userEmail : String
//    var isLoggedIn : Bool
//
//
//    init?(userName : String, userEmail : String, isLoggedIn : Bool) {
//        self.userName = userName
//        self.userEmail = userEmail
//        self.isLoggedIn = isLoggedIn
//    }
//}

class cityState  {
    var streetPicked: String
    var cityPicked: String
    var statePicked: String
    var zipPicked: String
    
    init?(streetPicked : String, cityPicked : String, statePicked : String, zipPicked : String) {
        self.streetPicked = streetPicked
        self.cityPicked = cityPicked
        self.statePicked = statePicked
        self.zipPicked = zipPicked
    }
}


class vendorRatings  {
    
    var eventRating: Int // Can also be enum
    var ratingUserID: String
    var ratingUsername: String
    var ratingComment: String
    var amntEarned: Double
    var dateRated: String


    init?(eventRating : Int, ratingUserID : String, ratingUsername : String, ratingComment : String, amntEarned : Double, dateRated : String) {

        self.eventRating = eventRating // Can also be enum
        self.ratingUserID = ratingUserID
        self.ratingUsername = ratingUsername
        self.ratingComment = ratingComment
        self.amntEarned = amntEarned
        self.dateRated = dateRated
    }
}


class Event {
    
   
    //MARK: Properties
    var eventName : String
    var eventImage : UIImage
    var eventImageURLs = [String]()
    var eventCategory : String
    var eventStreet : String
    var eventCity : String
    var eventState : String
    var eventCountry : String
    var eventContact : String
    var eventPhone : String
    var eventEmail : String
    var eventWebSite : String
    var eventFromDate : String
    var eventToDate : String
    var eventCreator: String
    var eventFrequency : String
    var eventAttendance : Int
    var eventAvgEarnings : Double
    var eventVenue : String
    var eventVendorFee : String
    var eventZip : String
    var eventRatingCount: Int // numRatings
    var eventAvgRating: Double
    var eventDetails: String
    var eventReviews = [vendorRatings]()

    init?(eventName : String, eventImage : UIImage, eventImageURLs : [String], eventCategory : String, eventStreet : String, eventCity : String, eventState : String, eventCountry : String, eventContact : String, eventPhone : String, eventEmail : String, eventWebSite : String, eventFromDate : String, eventToDate : String, eventCreator : String, eventFrequency : String, eventAttendance : Int, eventAvgEarnings : Double, eventVenue : String, eventVendorFee : String, eventZip : String, eventRatingCount : Int, eventAvgRating : Double, eventDetails : String, eventReviews : [vendorRatings]) {
    
    // The name must not be empty
    guard !eventName.isEmpty else {
        return nil
    }
    
    // The city must not be empty
    guard !eventCity.isEmpty else {
        return nil
    }

        self.eventName = eventName
        self.eventImage = eventImage
        self.eventImageURLs = eventImageURLs
        self.eventCategory = eventCategory
        self.eventStreet = eventStreet
        self.eventCity = eventCity
        self.eventState = eventState
        self.eventCountry = eventCountry
        self.eventContact = eventContact
        self.eventPhone = eventPhone
        self.eventEmail = eventEmail
        self.eventWebSite = eventWebSite
        self.eventFromDate = eventFromDate
        self.eventToDate = eventToDate
        self.eventCreator = eventCreator
        self.eventFrequency = eventFrequency
        self.eventAttendance = eventAttendance
        self.eventAvgEarnings = eventAvgEarnings
        self.eventVenue = eventVenue
        self.eventVendorFee = eventVendorFee
        self.eventZip = eventZip
        self.eventRatingCount = eventRatingCount
        self.eventAvgRating = eventAvgRating
        self.eventDetails = eventDetails
        self.eventReviews = eventReviews
    }
}
