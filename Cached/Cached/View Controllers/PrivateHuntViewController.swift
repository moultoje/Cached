//
//  PrivateHuntViewController.swift
//  Cached
//
//  Created by Jeffrey Moulton on 11/2/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//

import UIKit

class PrivateHuntViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var done_status: UIBarButtonItem!
    @IBOutlet weak var private_id_text: UITextField!
    
    // Done button behavior
    @IBAction func Done(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Cancel button behavior
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        private_id_text.delegate = self
        
        // Update done button status
        updateDoneButtonStatus()
    }
    
//MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ private_id_text: UITextField) {
        // Disable done button
        done_status.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ private_id_text: UITextField) {
        updateDoneButtonStatus()
    }
    
    func textFieldShouldReturn(_ private_id_text: UITextField) -> Bool {
        updateDoneButtonStatus()
        self.view.endEditing(true)
        
        return true
    }
    
//MARK: Private Methods
    
    private func updateDoneButtonStatus() {
        // Disable save button when text field is empty
        let text = private_id_text.text ?? ""
        done_status.isEnabled = !text.isEmpty
    }
    
}

