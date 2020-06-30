//
//  NewPageViewController.swift
//  iLife
//
//  Created by Mirosław Witkowski.
//  Copyright © 2020 Mirosław Witkowski. All rights reserved.
//

import UIKit
import MapKit
import os.log

class NewPageViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    //MARK: Variables
    
    var history: History?
    
    var isNewPage = false
    
    var page: Page?
    
    var locationName: String = ""
    
    var activeTextView : UITextView? = nil
    
    //MARK:Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateDatePicker: UIDatePicker!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapMKMapView: MKMapView!
    @IBOutlet weak var textTextView: UITextView!
    @IBOutlet var mapTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var imageImageView: UIImageView!
    
    //MARK: Actions
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func mapTapped(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: mapMKMapView)
        let coordinate = mapMKMapView.convert(location, toCoordinateFrom: mapMKMapView)
        
        findLocalization(coordinate: coordinate)
        
        addOneAnnotationOnMap(coordinate: coordinate)
        
        updateSaveButtonState()

    }
    
    //MARK: Functions from delegate (textview)
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.activeTextView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.activeTextView = nil
    }
    
    //MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //load editable page
        if let page = page {
            titleTextField.text = page.title
            navigationItem.title = page.title
            dateDatePicker.date = page.date
            locationLabel.text = page.localizationName
            
            addOneAnnotationOnMap(coordinate: CLLocationCoordinate2D(latitude: page.locLat, longitude: page.locLon))
            
            let initialLocation = CLLocation(latitude: page.locLat, longitude: page.locLon)
            let regionRadius = 4000
            let coordinateRegion = MKCoordinateRegion(
                center: initialLocation.coordinate,
                latitudinalMeters: CLLocationDistance(regionRadius),
                longitudinalMeters: CLLocationDistance(regionRadius))
            
            mapMKMapView.setRegion(coordinateRegion, animated: true)
            
            if let img = page.image {
                imageImageView.image = img
            }
            
            textTextView.text = page.text
            
        }
        
        titleTextField.delegate = self
        
        updateSaveButtonState()
        
        
    }
    
    //MARK: Functions triggered by Observer
    
    @objc func keyboardWillShow(notification: NSNotification) {
            
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           return
        }
      
        var textViewIsSelected = false
        
        if activeTextView != nil {
            textViewIsSelected = true
        }
        
        if textViewIsSelected == true {
            self.view.frame.origin.y = 0 - keyboardSize.height
        }
        
    }

    @objc func keyboardWillHide(notification: NSNotification) {
      self.view.frame.origin.y = 0
    }
    
    //MARK: Functions from delegate (textfield)
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the Save button while editing.
        saveBarButtonItem.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveBarButtonItem else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let title: String = titleTextField.text ?? ""
        let date = dateDatePicker.date
        let locName: String = locationName
        let locLat: Double = mapMKMapView.annotations.first?.coordinate.latitude ?? 0.0
        let locLon: Double = mapMKMapView.annotations.first?.coordinate.longitude ?? 0.0
        let image: UIImage = imageImageView.image!
        let text: String = textTextView.text
        let hisID: Int = history!.id!
        
        page = Page(title: title, historyId: hisID, date: date, localizationName: locName, locLon: locLon, locLat: locLat, image: image, text: text)
        
    }
    
    
    //MARK: Image Picker
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        titleTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the follwing: \(info)")
        }
        //Set photoImageView to display the selected image.
        imageImageView.image = selectedImage
        //Dismiss the picker
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private functions
    
    private func findLocalization(coordinate: CLLocationCoordinate2D) {
        //let lLon: Double = coordinate.longitude
        //let lLat: Double = coordinate.latitude
        
        getLocationDataFromApi(coordinate: coordinate)
        //locationLabel.text = "Jesteś w: \(locDat!.address)"
    }
    
    private func getLocationDataFromApi(coordinate: CLLocationCoordinate2D) {
        let lLon: Double = coordinate.longitude
        let lLat: Double = coordinate.latitude
        
        var res: LocationData?
    
        let apiURL = "https://nominatim.openstreetmap.org/reverse?format=json&lat=\(lLat)&lon=\(lLon)&zoom=10&addressdetails=1&extratags=0&namedetails=0"
        
        if let url = URL(string: apiURL) {
           URLSession.shared.dataTask(with: url) { data, response, error in
              if let data = data {
                  do {
                     res = try JSONDecoder().decode(LocationData.self, from: data)
                    
                    DispatchQueue.main.async{
                        self.setLocationNameAndUpdateLocationLabel(locDat: res)
                    }
                  } catch let error {
                     res = nil
                    DispatchQueue.main.async{
                    self.setLocationNameAndUpdateLocationLabel(locDat: nil)
                    }
                     print(error)
                  }
               }
           }.resume()
        }
        
    }
    
    private func setLocationNameAndUpdateLocationLabel(locDat: LocationData?) {
        let miasto = locDat?.address.city ?? ""
        let kraj = locDat?.address.country ?? ""
        var location = ""
        if miasto == "" {
            location = kraj
        } else {
            location = "\(miasto), \(kraj)"
        }
        locationLabel.text = "Jesteś w: \(location)"
        locationName = location
    }
    
    private func updateSaveButtonState() {
        let text = titleTextField.text ?? ""
        if (self.mapMKMapView.annotations.count > 0) && !text.isEmpty {
            saveBarButtonItem.isEnabled = true
        } else {
            saveBarButtonItem.isEnabled = false
        }
    }
    
    private func addOneAnnotationOnMap(coordinate: CLLocationCoordinate2D) {
        let allAnnotations = self.mapMKMapView.annotations
        self.mapMKMapView.removeAnnotations(allAnnotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapMKMapView.addAnnotation(annotation)
    }
    
}
