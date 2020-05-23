//
//  AppleMapsViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 04.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AppleMapsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Variables
    static let id = "AppleMapsVC"
    let locationManager = CLLocationManager()
    var place: Place!
    var userAnnotation: Profile.UserMapKitAnnotation?
    var location: CLLocation {
        CLLocation(latitude: place.lat, longitude: place.long)
    }

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        // Asking permissions for loaction manager
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
        // Registering place pin view
        if havePlacePinLocally() {
            mapView.register(PlaceMapMarker.self,
                    forAnnotationViewWithReuseIdentifier: "place")
        }
        // Registering user pin view
        if haveUserPinLocally() {
            mapView.register(UserMapMarker.self,
                    forAnnotationViewWithReuseIdentifier: "user")
        }
        // Zooming to place
        mapView.delegate = self
        mapView.centerToLocation(location)
        // Constraining map for pinching and moving
        let (moscowCenterLat, moscowCenterLong) = Place.kremlinCoord
        let moscowCenter = CLLocation(latitude: moscowCenterLat, longitude: moscowCenterLong)
        let (latMeters, longMeters) = Place.moscowRadiusForPinch
        let latDistance = CLLocationDistance(latMeters)
        let longDistance = CLLocationDistance(longMeters)
        let region = MKCoordinateRegion(
                center: moscowCenter.coordinate,
                latitudinalMeters: latDistance,
                longitudinalMeters: longDistance)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: Place.maxDistanceForPinch)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        // Adding pin
        let placeAnnotation = place.mkAnnotation
        mapView.addAnnotation(placeAnnotation)
    }

    private func havePlacePinLocally() -> Bool {
        guard let profile = Defaults.currentProfile,
              let pin = Pin.manager.get(id: profile.pinSpriteId),
              let imageFile = ImageFile.manager.get(id: pin.picId),
              let _ = imageFile.image else {
            return false
        }
        return true
    }

    private func haveUserPinLocally() -> Bool {
        guard let profile = Defaults.currentProfile,
              let pin = Pin.manager.get(id: profile.geopinSpriteId),
              let imageFile = ImageFile.manager.get(id: pin.picId),
              let _ = imageFile.image else {
            return false
        }
        return true
    }

}


// MARK: - Map view delegate
extension AppleMapsViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        if annotation is Place.PlaceMapKitAnnotation {
            let id = "place"
            let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            pinView?.annotation = annotation
            return pinView
        }

        if annotation is Profile.UserMapKitAnnotation {
            let id = "user"
            let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: id)
            pinView?.annotation = annotation
            return pinView
        }

        let pinView = MKMarkerAnnotationView()
        pinView.annotation = annotation
        return pinView
    }

}


// MARK: - Core location delegate
extension AppleMapsViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = manager.location?.coordinate else {
            return
        }

        if haveUserPinLocally() {
            if let ua = userAnnotation {
                mapView.removeAnnotation(ua)
            }
            let annotation = Profile.mkAnnotation(coordinate: coord)
            userAnnotation = annotation
            mapView.addAnnotation(annotation)
        }
    }

}