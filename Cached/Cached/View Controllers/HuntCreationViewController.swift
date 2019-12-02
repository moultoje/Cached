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

class HuntCreationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    // Text field delegates
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet var textFields: [UITextField]!
    
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
            "name": nameTextField.text ?? "",
            "isPrivate": false,
            "creator": emailTextField.text ?? "",
            "description": descriptionTextField.text ?? "",
            "generalLocation": "",
            "numberWaypoints": 0,
            "listWaypoints": waypointsRef
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Hunt Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    @IBOutlet weak var saveStatus: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        waypointTable.reloadData()
        
        updateSaveButtonStatus()
        updateTableHeight()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        emailTextField.delegate = self
        
        updateSaveButtonStatus()
    }
    
    func textFieldDidEndEditing(_ textFields: UITextField) {
        updateSaveButtonStatus()
    }
    
    func textFieldShouldReturn(_ textFields: UITextField) -> Bool {
        updateSaveButtonStatus()
        self.view.endEditing(true)
        
        return true
    }
    
    
    //MARK: UITableViewDataSource
    @IBOutlet weak var waypointTable: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    var waypoints = [Waypoint]()
    var waypointsRef: [String] = []
    
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
    
    //MARK: Actions
    @IBAction func unwindToWaypointTable(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? WaypointCreationViewController, let newWaypoint = sourceViewController.waypoint{
            if let selectedIndexPath = waypointTable.indexPathForSelectedRow {
                // Update an existing waypoint.
                waypoints[selectedIndexPath.row] = newWaypoint
                waypointTable.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                let newIndexPath = IndexPath(row: waypoints.count, section: 0)
                
                waypoints.append(newWaypoint)
                waypointTable.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        
        updateSaveButtonStatus()
        updateTableHeight()
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? ""){
        case "addWaypoint":
            print("Adding a waypoint")
        case "editWaypoint":
            guard let waypointDetailViewController = segue.destination as? WaypointCreationViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
             
            guard let selectedWaypointCell = sender as? WaypointListTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
             
            guard let indexPath = waypointTable.indexPath(for: selectedWaypointCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
             
            let selectedWaypoint = waypoints[indexPath.row]
            waypointDetailViewController.waypoint = selectedWaypoint
            waypointDetailViewController.documentID = waypointsRef[indexPath.row]
        default:
            print("Unidentified waypoint")
        }
        
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonStatus() {
        // Disable save button when text field is empty
        let text1 = nameTextField.text ?? ""
        let text2 = descriptionTextField.text ?? ""
        let text3 = emailTextField.text ?? ""
        saveStatus.isEnabled = !(text1.isEmpty || text2.isEmpty || text3.isEmpty || waypoints.count == 0)
    }
    
    private func updateTableHeight(){
        self.waypointTable.rowHeight = CGFloat(120)
        tableHeight.constant = CGFloat(120 * waypoints.count)
    }
    
}
