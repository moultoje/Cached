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

class WaypointCreationViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, MKMapViewDelegate {
    
    // Outlets
    @IBOutlet weak var savebutton: UIBarButtonItem!
    @IBOutlet weak var waypointName: UITextField!
    @IBOutlet weak var waypointClue: UITextField!
    @IBOutlet weak var waypointRadius: UITextField!
    @IBOutlet weak var waypointMapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        picker.delegate = self
        
        pickerData = ["", "Address", "Coordinates"]
        
        LocationPicker.inputView = picker
        
        createPickerDoneToolbar()
        
        waypointMapView.userTrackingMode = .follow
    }
    
    //MARK: Navigation
    
    var waypoint: Waypoint!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === savebutton else { os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return}
        
        let name = waypointName.text
        let clue = waypointClue.text
        let lat = 0.0
        let long = 0.0
        let radius = Int(waypointRadius.text!)
        
        waypoint = Waypoint(name: name ?? "", clue: clue ?? "", latitude: lat ?? 0.0, longitude: long ?? 0.0, radius: radius ?? 0, id: "")
        
    }
    
    // Save and cancel functions
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
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

}
