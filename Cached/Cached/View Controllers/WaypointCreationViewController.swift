//
//  WaypointCreationViewController.swift
//  Cached
//
//  Created by Jeffrey Moulton on 11/2/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreLocation
import os.log
import Firebase

class WaypointCreationViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var savebutton: UIBarButtonItem!
    @IBOutlet weak var waypointName: UITextField!
    @IBOutlet weak var waypointClue: UITextField!
    @IBOutlet weak var waypointRadius: UITextField!
    @IBOutlet weak var waypointMapView: MKMapView!
    
    let locationManager = CLLocationManager()
        
    @IBOutlet var textFields: [UITextField]!
    
    func wayPointMapView(_ waypointMapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {print("no MKPointAnnotations"); return nil}
        
        let reuseID = "pin"
        var pinView = waypointMapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoDark)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
        
        }
    
    func waypointMapView(_ waypointMapView: MKMapView, didSelect view: MKAnnotationView) {
        print("tapped on pin")
    }
    
    func wayPointMapView(_ waypointMapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let doSomething = view.annotation?.title! {
                print("do something")
            }
        }
    }
    
    var documentID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        waypointName.delegate = self
        waypointClue.delegate = self
        waypointRadius.delegate = self
        addressEntry.delegate = self
        latitudeEntry.delegate = self
        longitudeEntry.delegate = self
        
        picker.delegate = self
        
        pickerData = ["", "Address", "Coordinates"]
        
        LocationPicker.inputView = picker
        
        createPickerDoneToolbar()
        
        waypointMapView.delegate = self
        waypointMapView.userTrackingMode = .follow
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        waypointMapView.addGestureRecognizer(longTapGesture)
        
        self.view.layoutIfNeeded()
        
        setupAddressInfo()
        setupAddressEntry()
        setupLatitudeInfo()
        setupLatitudeEntry()
        setupLongitudeInfo()
        setupLongitudeEntry()
        
        textFields += [addressEntry, longitudeEntry, latitudeEntry]
        
        if let curWaypoint = waypoint{
            waypointName.text = curWaypoint.name
            waypointClue.text = curWaypoint.clue
            waypointRadius.text = String(curWaypoint.radius)
            latitudeEntry.text = String(curWaypoint.latitude)
            longitudeEntry.text = String(curWaypoint.longitude)
            picker.selectRow(2, inComponent: 0, animated: true)
            LocationPicker.text = pickerData[2]
            locationMethod = pickerData[2]
            addCoordinatesTextFields()
        } else {
            LocationEntryHeight.constant = CGFloat(0)
        }
        
        updateSaveButtonStatus()
        
        
    }
    
    //MARK: Navigation
    
    var waypoint: Waypoint!
    var locationLatLong = CLLocation()

    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        // Check that a location picking method was chosen
        if LocationPicker.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Pick Location Entry Method", message: "Pick a location entry method and enter the location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in NSLog("The \"Location Entry Method Empty\" alert occured.")}))
            self.present(alert, animated: true, completion: nil)
            return false
        }
    
        //validating text values
        var response:Valid
        if LocationPicker.text == "Address" {
            response = Validation.shared.validate(values: (ValidationType.name, waypointName.text ?? ""), (ValidationType.clue, waypointClue.text ?? ""), (ValidationType.radius, waypointRadius.text ?? ""), (ValidationType.address, addressEntry.text ?? ""))
        } else {
            response = Validation.shared.validate(values: (ValidationType.name, waypointName.text ?? ""), (ValidationType.clue, waypointClue.text ?? ""), (ValidationType.radius, waypointRadius.text ?? ""), (ValidationType.coordinate, latitudeEntry.text ?? ""), (ValidationType.coordinate, longitudeEntry.text ?? ""))
        }
         
        switch response {
        case .success:
            return true
        case .failure(_, let message):
            print(message.localized())
            let alert = UIAlertController(title: "Check Input", message: message.rawValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"Hunt Input Fields Empty or Invalid\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            return false
         }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === savebutton else { os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return}
        
        var lat = 0.0
        var long = 0.0
        
        if locationMethod == "Coordinates" {
            lat = Double(latitudeEntry.text!)!
            long = Double(longitudeEntry.text!)!
        } else if locationMethod == "Address" {
            print(locationLatLong)
            lat = locationLatLong.coordinate.latitude
            long = locationLatLong.coordinate.longitude
        }
        
        let name = waypointName.text
        let clue = waypointClue.text
        let radius = Int(waypointRadius.text!)
        
        waypoint = Waypoint(name: name ?? "", clue: clue ?? "", latitude: lat, longitude: long, radius: radius ?? 0, id: "")
 
        let db = Firestore.firestore()
        
        if documentID == "" {
                var ref: DocumentReference? = nil
                ref = db.collection("waypoints").addDocument(data: [
                "name": waypointName.text ?? "",
                "clue": waypointClue.text ?? "",
                "latitude": lat,
                "longitude": long,
                "radius": Int(waypointRadius.text!) ?? 20
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Waypoint Document added with ID: \(ref!.documentID)")
                    let destVC = segue.destination as! HuntCreationViewController
                    destVC.waypointsRef.append(ref!.documentID)
                }
            }
        } else  {
            let ref = db.collection("waypoints").document(documentID)
            //update the waypoint selected
            ref.updateData([
                "name": waypointName.text ?? "",
                "clue": waypointClue.text ?? "",
                "latitude": lat,
                "longitude": long,
                "radius": Int(waypointRadius.text!) ?? 20
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
    
    // Save and cancel functions
    @IBAction func cancel(_ sender: Any) {
        let addingNewWaypoint = presentingViewController is UINavigationController
        
        if addingNewWaypoint {
            dismiss(animated: true, completion: nil)
        } else if let owningNavController = navigationController {
            owningNavController.popViewController(animated: true)
        } else {
            fatalError("Waypoint View Controller not in navigation controller")
        }
    }
    
    @IBAction func save(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //MARK: UIPickerView
    
    @IBOutlet weak var LocationPicker: UITextField!
    
    let picker = UIPickerView()
    
    var pickerData: [String] = [String]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        LocationPicker.text = pickerData[row]
        
        if pickerData[row] == "Coordinates" {
            if locationMethod == "Address" {
                removeAddressTextFields()
                addCoordinatesTextFields()
            } else if locationMethod == "" {
                addCoordinatesTextFields()
            }
            locationMethod = pickerData[row]
        } else if pickerData[row] == "Address" {
            if locationMethod == "Coordinates" {
                removeCoordinatesTextFields()
                addAddressTextFields()
            } else if locationMethod == "" {
                addAddressTextFields()
            }
            locationMethod = pickerData[row]
        } else {
            if locationMethod == "Address" {
                removeAddressTextFields()
            } else if locationMethod == "Coordinates" {
                removeCoordinatesTextFields()
            }
            locationMethod = pickerData[row]
        }
        
        updateSaveButtonStatus()
    }
    
    func createPickerDoneToolbar(){
        let pickerToolbar = UIToolbar()
        pickerToolbar.sizeToFit()
        let pickerDone = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(WaypointCreationViewController.closePickerView))
        pickerToolbar.setItems([pickerDone], animated: false)
        pickerToolbar.isUserInteractionEnabled = true
        LocationPicker.inputAccessoryView = pickerToolbar
    }
    
    @objc func closePickerView(){
        view.endEditing(true)
    }
    
    //MARK: Location Entry
    
    @IBOutlet weak var LocationEntryView: UIView!
    @IBOutlet weak var LocationEntryHeight: NSLayoutConstraint!
    
    var locationMethod = ""
    var addressEntry = UITextField()
    var latitudeEntry = UITextField()
    var longitudeEntry = UITextField()
    var addressInfo = UILabel()
    var latitudeInfo = UILabel()
    var longitudeInfo = UILabel()
    
    private func setupAddressEntry(){
        addressEntry.frame = CGRect(x: 0, y: 44, width: Int(LocationEntryView.bounds.size.width), height: 38)
        addressEntry.borderStyle = UITextField.BorderStyle.roundedRect
        addressEntry.placeholder = "Enter address..."
        addressEntry.keyboardType = UIKeyboardType.default
        addressEntry.returnKeyType = UIReturnKeyType.default
        addressEntry.font = UIFont.systemFont(ofSize: 16)
        addressEntry.textColor = UIColor(named: "SystemTextColor")
        addressEntry.backgroundColor = UIColor(named: "CachedSecondaryBackgroundColor")
    }
    
    private func setupLatitudeEntry(){
        latitudeEntry.frame = CGRect(x: 0, y: 44, width: Int(LocationEntryView.frame.width), height: 38)
        latitudeEntry.borderStyle = UITextField.BorderStyle.roundedRect
        latitudeEntry.placeholder = "Enter latitude..."
        latitudeEntry.keyboardType = UIKeyboardType.numbersAndPunctuation
        latitudeEntry.returnKeyType = UIReturnKeyType.default
        latitudeEntry.font = UIFont.systemFont(ofSize: 16)
        latitudeEntry.textColor = UIColor(named: "SystemTextColor")
        latitudeEntry.backgroundColor = UIColor(named: "CachedSecondaryBackgroundColor")
    }
    
    private func setupLongitudeEntry(){
        longitudeEntry.frame = CGRect(x: 0, y: 136, width: Int(LocationEntryView.frame.width), height: 38)
        longitudeEntry.borderStyle = UITextField.BorderStyle.roundedRect
        longitudeEntry.placeholder = "Enter longitude..."
        longitudeEntry.keyboardType = UIKeyboardType.numbersAndPunctuation
        longitudeEntry.returnKeyType = UIReturnKeyType.default
        longitudeEntry.font = UIFont.systemFont(ofSize: 16)
        longitudeEntry.textColor = UIColor(named: "SystemTextColor")
        longitudeEntry.backgroundColor = UIColor(named: "CachedSecondaryBackgroundColor")
    }
    
    private func setupAddressInfo(){
        addressInfo.frame = CGRect(x: 0, y: 10, width: Int(LocationEntryView.frame.width), height: 24)
        addressInfo.text = "Address"
        addressInfo.font = UIFont.systemFont(ofSize: 20)
        addressInfo.textColor = UIColor(named: "SystemTextColor")
        addressInfo.backgroundColor = UIColor(named: "CachedBackgroundColor")
    }
    
    private func setupLatitudeInfo(){
        latitudeInfo.frame = CGRect(x: 0, y: 10, width: Int(LocationEntryView.frame.width), height: 24)
        latitudeInfo.text = "Latitude"
        latitudeInfo.font = UIFont.systemFont(ofSize: 20)
        latitudeInfo.textColor = UIColor(named: "SystemTextColor")
        latitudeInfo.backgroundColor = UIColor(named: "CachedBackgroundColor")
    }
    
    private func setupLongitudeInfo(){
        longitudeInfo.frame = CGRect(x: 0, y: 98, width: Int(LocationEntryView.frame.width), height: 24)
        longitudeInfo.text = "Longitude"
        longitudeInfo.font = UIFont.systemFont(ofSize: 20)
        longitudeInfo.textColor = UIColor(named: "SystemTextColor")
        longitudeInfo.backgroundColor = UIColor(named: "CachedBackgroundColor")
    }
    
    private func removeAddressTextFields(){
        addressEntry.removeFromSuperview()
        addressInfo.removeFromSuperview()
        LocationEntryHeight.constant = CGFloat(0)
    }
    
    private func removeCoordinatesTextFields(){
        latitudeEntry.removeFromSuperview()
        longitudeEntry.removeFromSuperview()
        latitudeInfo.removeFromSuperview()
        longitudeInfo.removeFromSuperview()
        LocationEntryHeight.constant = CGFloat(0)
    }
    
    private func addAddressTextFields(){
        LocationEntryView.addSubview(addressInfo)
        LocationEntryView.addSubview(addressEntry)
        LocationEntryHeight.constant = CGFloat(92)
    }
    
    private func addCoordinatesTextFields(){
        LocationEntryView.addSubview(latitudeEntry)
        LocationEntryView.addSubview(longitudeEntry)
        LocationEntryView.addSubview(latitudeInfo)
        LocationEntryView.addSubview(longitudeInfo)
        LocationEntryHeight.constant = CGFloat(184)
    }
    
    //MARK: UITextField
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == addressEntry {
            getLatLong(addressString: addressEntry.text!)
        }
        
        if LocationPicker.text == "Coordinates" {
            if !(latitudeEntry.text?.isEmpty ?? true) && !(longitudeEntry.text?.isEmpty ?? true) {
                let response = Validation.shared.validate(values: (ValidationType.coordinate, latitudeEntry.text ?? ""), (ValidationType.coordinate, longitudeEntry.text ?? ""))
                switch response {
                case .success:
                    // Add call to add annotation here. Use DOUBLE(latitudeEntry.text) and DOUBLE(longitudeEntry.text) for coordinates. When call is added, remove print statement
                    print("Coordinates valid")
                case .failure:
                    let alert = UIAlertController(title: "Coordinates Invalid", message: "Either the latitude or longitude is in an invalid format.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                        NSLog("The \"Coordinates invalid\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }
        
        updateSaveButtonStatus()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateSaveButtonStatus()
        self.view.endEditing(true)
                
        return true
    }
    
    //MARK: Private Functions
    private func updateSaveButtonStatus(){
        // Disable save button when text field is empty
        let text1 = waypointName.text ?? ""
        let text2 = waypointClue.text ?? ""
        let text3 = waypointRadius.text ?? ""
        let text4 = addressEntry.text ?? ""
        let text5 = latitudeEntry.text ?? ""
        let text6 = longitudeEntry.text ?? ""
        if locationMethod == "Address" {
            saveButton.isEnabled = !(text1.isEmpty || text2.isEmpty || text3.isEmpty || text4.isEmpty)
        } else if locationMethod == "Coordinates" {
            saveButton.isEnabled = !(text1.isEmpty || text2.isEmpty || text3.isEmpty || text5.isEmpty || text6.isEmpty)
        } else {
            saveButton.isEnabled = false
        }
    }

    private func getLatLong(addressString: String) {
        if !(addressEntry.text?.isEmpty ?? true) {
            // Add call to add annotation here. Use locationLatLong variable to access address lat and long
            let response = Validation.shared.validate(values: (ValidationType.address, addressEntry.text ?? ""))
            switch response {
            case .success:
                let geoCoder = CLGeocoder()
                geoCoder.geocodeAddressString(addressString) { (placemarks, error) in
                    guard
                        let placemarks = placemarks,
                        let location = placemarks.first?.location
                    else {
                        // handle no location found
                        return
                    }
                    print(location)
                    self.locationLatLong = location
                    // Add call to add annotation here. Use locationLatLong for coordinates
                }
            case .failure:
                let alert = UIAlertController(title: "Address Invalid", message: "Address is in an invalid format.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"Address invalid\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func longTap(sender: UIGestureRecognizer) {
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: waypointMapView)
            let locationOnMap = waypointMapView.convert(locationInView, toCoordinateFrom: waypointMapView)
            addAnnotation(location: locationOnMap)
        }
    }
    
    func addAnnotation(location: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Waypoint"
        annotation.subtitle = "Current"
        self.waypointMapView.addAnnotation(annotation)
    }
}

