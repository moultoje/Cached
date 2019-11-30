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

         //   print("HERE!!!!!!")
 
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
//                {
                return hunt
//                } else {
//                    fatalError("Unable to initialize type \(Hunt.self) with dictionary \(document.data())")
 //               }
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
        
        //print("\(item.listWaypoints.count)")
        
        cell.textLabel?.text = item.name
        cell.textLabel?.textColor = UIColor(named: "SystemTextColor")
        cell.detailTextLabel?.text = item.description
        cell.detailTextLabel?.textColor = UIColor(named: "SystemTextColor")
        cell.backgroundColor = UIColor(named: "CachedBackgroundColor")
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedHunt = self.hunts[indexPath.row]
        
        for ref in selectedHunt.listWaypoints {
            print(ref)
            let docRef = Firestore.firestore().collection("waypoints").document(ref)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let waypoint = Waypoint(dictionary: document.data() ?? ["String": ""], id: document.documentID)
                    self.waypointsArray.append(waypoint)
                } else {
                    print("Document does not exist")
                }
            }
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let destVC = segue.destination as! MapViewController
        destVC.currentHunt = selectedHunt
        destVC.waypoints = waypointsArray
    }
    
}




