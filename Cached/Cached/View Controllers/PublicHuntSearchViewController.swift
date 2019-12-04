//
//  PublicHuntSearchViewController.swift
//  Cached
//
//  Created by Jeffrey Moulton on 11/2/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//
//Resources: https://code.tutsplus.com/tutorials/getting-started-with-cloud-firestore-for-ios--cms-30910

import UIKit
import Firebase

class PublicHuntSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: Properties
    @IBOutlet weak var publicHuntsTable: UITableView!
    
    // Cancel button behavior
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    let db = Firestore.firestore()
    
    private var documents: [DocumentSnapshot] = []
    public var hunts: [Hunt] = []
    public var selectedHunt: Hunt = Hunt(dictionary: ["String":""], id:"")
    private var listener : ListenerRegistration!
    public var waypointsArray: [Waypoint] = []
    public var waypointsTemp: [Waypoint] = []
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
            }
        }
    }
    
    fileprivate func publicQuery() -> Query {
        return Firestore.firestore().collection("hunts").whereField("isPrivate", isEqualTo: false).limit(to: 10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
 
       self.query = publicQuery()


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        self.listener = query?.addSnapshotListener { (documents, error) in
            guard let snapshot = documents else {
                print("Error fetching documents results: \(error!)")
                return
            }
            
           let results = snapshot.documents.map { (document) -> Hunt in
                let hunt = Hunt(dictionary: document.data(), id: document.documentID)
                return hunt
            }
            
            self.hunts = results
            self.documents = snapshot.documents
            self.publicHuntsTable.reloadData()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.listener.remove()
    }
    
}

//MARK: TableView Delegate and DataSource methods
extension PublicHuntSearchViewController{
    
    func numberOfSections(in publicHuntsTable: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ publicHuntsTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hunts.count
    }
    
    func tableView(_ publicHuntsTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellID")
        
        let item = self.hunts[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.textLabel?.textColor = UIColor(named: "SystemTextColor")
        cell.detailTextLabel?.text = item.description
        cell.detailTextLabel?.textColor = UIColor(named: "SystemTextColor")
        cell.backgroundColor = UIColor(named: "CachedBackgroundColor")
        
        return cell
        
    }
    
    func addWaypointClosure(docRef: DocumentReference, completionHandler: @escaping (Waypoint) -> Void) -> Void  {
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let waypoint = Waypoint(dictionary: document.data() ?? ["String": ""], id: document.documentID)
                completionHandler(waypoint)
            } else {
                print("Error getting document")
            }
        }
    }
    
    func addWaypointsCompletionHandler(waypoint: Waypoint) {
        self.waypointsTemp.append(waypoint)
        print("Added waypoint \(waypoint.name)")
    }
    
    func getWaypointDoc(refID: String) -> DocumentReference {
        let docRef = Firestore.firestore().collection("waypoints").document(refID)
        return docRef
    }
    
    func wrapper(refID: String) -> Void {
        let docRef = getWaypointDoc(refID: refID)
        addWaypointClosure(docRef: docRef, completionHandler: addWaypointsCompletionHandler)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedHunt = self.hunts[indexPath.row]
        let refArray = selectedHunt.listWaypoints
        
        refArray.forEach { ref in
            wrapper(refID: ref)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let destVC = segue.destination as! MapViewController
        destVC.currentHunt = selectedHunt
        
        //place waypoints in order of input
        for id in selectedHunt.listWaypoints {
            for way in waypointsTemp {
                if way.id == id{
                    waypointsArray.append(way)
                }
            }
        }
        
        for k in waypointsArray {
            print(k.name)
        }

        destVC.waypoints = waypointsArray
        print(waypointsArray)
    }
}
