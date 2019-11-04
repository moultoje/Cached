//
//  HuntCreationViewController.swift
//  Cached
//
//  Created by Jeffrey Moulton on 10/16/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//

import UIKit

class HuntCreationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // Table View Outlets
    @IBOutlet weak var AudienceTable: UITableView!
    
    // Cancel button behavior
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Save button behavior
    @IBAction func save(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    var audienceItem = ["Private", "Public"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func numberOfSections(in AudienceTable: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ AudienceTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audienceItem.count
    }
    
    func tableView(_ AudienceTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AudienceTable.dequeueReusableCell(withIdentifier: "audienceCell", for: indexPath)
        
        cell.textLabel?.text = audienceItem[indexPath.row]
        
        return cell
    }

}

