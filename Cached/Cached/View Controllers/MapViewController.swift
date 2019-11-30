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
    var waypointIndex = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.userTrackingMode = .follow
        
        checkLocationServices()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        
        if(!waypoints.isEmpty){
            clueText.text = waypoints[waypointIndex].clue
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
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    }
    
    @IBAction func center(_ sender: Any) {
        if let userLocation = mapView.userLocation.location?.coordinate {
            
            let region = MKCoordinateRegion(
                center: userLocation, latitudinalMeters: 1275, longitudinalMeters: 1275)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    @IBOutlet weak var changeMapTypeText: UIButton!
    @IBAction func changeMapType(_ sender: Any) {
        if mapView.mapType == MKMapType.standard {
            mapView.mapType = MKMapType.satellite
            changeMapTypeText.setTitle("Standard", for: UIControl.State.normal)
        } else {
            mapView.mapType = MKMapType.standard
            changeMapTypeText.setTitle("Terrain", for: UIControl.State.normal)
        }
    }
    
    @IBAction func unwindToMap(_ sender: UIStoryboardSegue) {}
    
    //MARK: Found Button
    @IBAction func foundButton(_ sender: Any) {
        //Get the user's location
        if waypoints.isEmpty{
            let alert = UIAlertController(title: "No Hunt Started", message: "No treasure hunt has been started yet.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"Hunt Not Started\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let userLoc = locationManager.location
            let waypointLoc = CLLocation(latitude: waypoints[waypointIndex].latitude, longitude: waypoints[waypointIndex].longitude)
            var userDist:CLLocationDistance
            
            if userLoc == nil{
                let alert = UIAlertController(title: "User Location Not Determined", message: "Either location services are turned off or the app failed to update your location. If location services are on, try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"Location Undetermined\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
                userDist = Double.infinity
            } else {
                userDist = waypointLoc.distance(from: userLoc!)
            }
            
            if userDist < Double(waypoints[waypointIndex].radius) {
                //Waypoint found, increment waypointIndex and update clue text.
                waypointIndex += 1
                if waypointIndex == waypoints.count {
                    // Reset waypointIndex and waypoint array
                    waypointIndex = 0
                    waypoints = []
                    clueText.text = ""
                    // Congratulate user on winning
                    let alert = UIAlertController(title: "Treasure Hunt Complete", message: "You have found all of the waypoints. Congratulations!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"Hunt Complete\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    clueText.text = waypoints[waypointIndex].clue
                }
            } else if userDist != Double.infinity {
                //Waypoint not found
                let alert = UIAlertController(title: "Outside of Waypoint Radius", message: "You have not found the waypoint yet.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"Waypoint Not Found\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}


