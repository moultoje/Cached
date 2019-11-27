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

    let locationManager = CLLocationManager()
    
    var currentHunt: Hunt = Hunt(dictionary:["String":""],id:"")
    public var waypoints: [Waypoint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.userTrackingMode = .follow
        
        checkLocationServices()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
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
                center: userLocation, latitudinalMeters: 2000, longitudinalMeters: 2000)
            
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
    
}


