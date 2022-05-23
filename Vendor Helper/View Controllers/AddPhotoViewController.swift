//
//  AddPhotoViewController.swift
//  Vendor Helper
//
//  Created by Theophilus Drackett on 4/4/18.
//  Copyright © 2018 Theophilus Drackett. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import os.log
import AVKit
import Photos
import BSImagePicker

class AddPhotoViewController: UIViewController, UINavigationControllerDelegate {
    
    var event : Event?
    var selectedAssets = [PHAsset]()
    var imagesArray = [UIImage]()
    let storage = Storage.storage()
    var gotTouched = 0
    var databaseRef : DatabaseReference!
    var userName = ""
    
    private lazy var storageRef = storage.reference()

    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func selectPhoto(_ sender: Any) {
        let vc = BSImagePickerViewController()
        self.bs_presentImagePickerController(vc, animated: true, select: { (assets: PHAsset) -> Void in
            
        }, deselect: { (assets: PHAsset) -> Void in
            
        }, cancel: { (assets: [PHAsset]) -> Void in
            
        }, finish: { (assets: [PHAsset]) -> Void in
            for i in 0..<assets.count {
                self.selectedAssets.append(assets[i])
            }
            self.convertAssetsToImages()
        }, completion: nil)
    }
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // User must be logged in to add events
            _ = Auth.auth().addStateDidChangeListener { (auth, user) in
                if Auth.auth().currentUser != nil {
                    // User is signed in.
                    if let uName = (Auth.auth().currentUser?.displayName) {
                        self.userName = uName
                    }
                } else {
                    self.userMustLogIn()
                    self.navigationController?.popViewController(animated: true)
    //                self.transitionToFB()
                    return
                }
            }

        }

    
    func convertAssetsToImages() -> Void {
        if selectedAssets.count != 0 {
            for i in 0..<selectedAssets.count {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbNail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: selectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler:  { (result, info) -> Void in
                    thumbNail = result!
                })
                let data = thumbNail.jpegData(compressionQuality: 0.7)
                let newImage = UIImage(data: data!)
                self.imagesArray.append(newImage! as UIImage)
            }
            self.imageView.animationImages = self.imagesArray
            self.imageView.animationDuration = 3.0
            self.imageView.startAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func savePicButton(_ sender: Any) {
        saveImages()
        photosAdded()
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveImages() {

        // Createe a database reference
        databaseRef = Database.database().reference()
        
        let fireKey = (event?.eventName.trimmingCharacters(in: .whitespaces))! + " " + (event?.eventCity.trimmingCharacters(in: .whitespaces))!

        //Store image in firebase only if it's not the Default image
        for image in imagesArray {
                let imageRef = self.databaseRef.child("Event").child(fireKey).child("images").childByAutoId()
                let imageStorageKey = imageRef.key
//                let imageStorageRef = storageRef.child("images").child(imageStorageKey!)
            if let imageData = (image ).jpegData(compressionQuality: 0.6) {
                    let imageStorageRef = storageRef.child("images").child(imageStorageKey!)
                    let uploadTask = imageStorageRef.putData(imageData, metadata: nil) { (metadata, error) in
                        
                        // You can also access to download URL after upload.
                        imageStorageRef.downloadURL(completion: { (url, error) in
                            guard let downloadURL = url else {
                                // Uh-oh, an error occurred!
                                return
                            }
                            let imageDownloadURL = downloadURL.absoluteString
                            imageRef.child("imageDownloadURL").setValue(imageDownloadURL)
                            
                        })
                    }
                    
                }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddPhotoMode = presentingViewController is UINavigationController
        
        if isPresentingInAddPhotoMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The EventViewController is not inside a navigation controller.")
        }
    }
    
    //The user must be logged in to add or edit an event
    func userMustLogIn() {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "You must be logged in", message: "to add photos", preferredStyle: .alert)
        
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

        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }

    //Inform the user that photos have been added
    func photosAdded() {
        //Creating UIAlertController and setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Photos Added", message: "Your pictures have been added", preferredStyle: .alert)
        
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
