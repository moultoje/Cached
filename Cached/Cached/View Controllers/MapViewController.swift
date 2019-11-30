//
//  MapViewController.swift
//  Cached
//
//  Created by Jeffrey Moulton on 10/16/19.
//  Copyright © 2019 Mobile Treasure Hunt. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreLocation
import Firebase

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var clueText: UITextField!
    
    let locationManager = CLLocationManager()
    
    var currentHunt: Hunt = Hunt(dictionary:["String":""],id:"")
    public var waypoints: [Waypoint] = []
    var waypointIndex = 1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.userTrackingMode = .follow
        
        checkLocationServices()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        
        if(!waypoints.isEmpty){
            clueText.text = waypoints[waypointIndex-1].clue
        }
        
        print(currentHunt)
        
        print(self.waypoints)
        
        for currentWaypoint in self.waypoints {
            print("\(currentWaypoint.name), \(currentWaypoint.clue), \(currentWaypoint.latitude), \(currentWaypoint.longitude), \(currentWaypoint.radius), \(currentWaypoint.id)")
        }
        
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            print("Please enable location services in iPhone Settings.")
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse: break
            case .denied: locationManager.requestWhenInUseAuthorization()
            case .notDetermined: break
            case .restricted: break
            case .authorizedAlways: break
        }
    }
    
    @IBAction func center(_ sender: Any) {
        if let userLocation = mapView.userLocation.location?.coordinate {
            
            let region = MKCoordinateRegion(
                center: userLocation, latitudinalMeters: 1275, longitudinalMeters: 1275)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func changeMapType(_ sender: Any) {
        if mapView.mapType == MKMapType.standard {
            mapView.mapType = MKMapType.satellite
        } else {
            mapView.mapType = MKMapType.standard
        }
    }
    
    @IBAction func unwindToMap(_ sender: UIStoryboardSegue) {}
    
    //MARK: Found Button
    @IBAction func foundButton(_ sender: Any) {
        //Waypoint found, increment waypointIndex and update clue text.
        waypointIndex += 1
        clueText.text = waypoints[waypointIndex-1].clue
        
        //Waypoint not found
        let alert = UIAlertController(title: "Outside of Waypoint Radius", message: "You have not found the waypoint yet.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
        NSLog("The \"Waypoint Not Found\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}


