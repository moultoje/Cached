//
//  HuntCreationViewController.swift
//  Cached
//
//  Created by Jeffrey Moulton on 10/16/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//

import UIKit
import Firebase
import os.log

class HuntCreationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    // Cancel button behavior
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Save button behavior
    @IBAction func save(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        
        let db = Firestore.firestore()
        
        var ref: DocumentReference? = nil
        ref = db.collection("hunts").addDocument(data: [
            "name": "TestHunt",
            "isPrivate": true,
            "creator": "Katie",
            "description": "test adding a hunt",
            "generalLocation": "nowhere",
            "numberWaypoints": 0,
            "listWaypoints": []
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addNewWaypoint()
        addNewWaypoint()
        
        self.waypointTable.rowHeight = CGFloat(120)
        tableHeight.constant = CGFloat(120 * waypoints.count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadSampleWaypoint()
    }
    
    //MARK: UITableViewDataSource
    @IBOutlet weak var waypointTable: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    var waypoints = [Waypoint]()
    
    private func loadSampleWaypoint(){
        let waypoint1 = Waypoint(name: "TestWaypoint", clue: "This is a test Waypoint", latitude: 173.00, longitude: 134.00, radius: 150, id: "")
        
        waypoints += [waypoint1]
        
        self.waypointTable.reloadData()
        
        os_log("Created waypoint", log: OSLog.default, type: .debug)
    }
    
    private func addNewWaypoint(){
        let waypoint2 = Waypoint(name: "AnotherWaypoint", clue: "Another waypoint added", latitude: 123.54, longitude: 89.33, radius: 160, id: "")
        
        waypoints += [waypoint2]
        self.waypointTable.reloadData()
        
        os_log("Additional waypoing", log: OSLog.default, type: .debug)
    }
    
    func numberOfSections(in waypointTable: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ waypointTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waypoints.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:WaypointListTableViewCell? = waypointTable.dequeueReusableCell(withIdentifier: "waypoint_cell", for: indexPath) as? WaypointListTableViewCell
        
        let waypoint = waypoints[indexPath.row]
        
        cell?.nameLabel.text = waypoint.name
        cell?.clueLabel.text = waypoint.clue
        cell?.latLabel.text = String(waypoint.latitude)
        cell?.longLabel.text = String(waypoint.longitude)
        cell?.radiusLabel.text = String(waypoint.radius)
        
        return cell!
    }
    
}
