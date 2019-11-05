//
//  WaypointCreationViewController.swift
//  Cached
//
//  Created by Jeffrey Moulton on 11/2/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//

import UIKit

class WaypointCreationViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var LocationPicker: UITextField!
    
    let picker = UIPickerView()
    
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        picker.delegate = self
        
        pickerData = ["Address", "Coordinates", "Pick on Map"]
        
        LocationPicker.inputView = picker
        
        createPickerDoneToolbar()
    }
    
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
