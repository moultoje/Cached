//
//  PrivateHuntViewController.swift
//  Cached
//
//  Created by Jeffrey Moulton on 11/2/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//

import UIKit

class PrivateHuntViewController: UIViewController, UITextFieldDelegate {
    
    
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
    }
    
}

