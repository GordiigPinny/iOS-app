//
// Created by Dmitry Gorin on 04.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 500) {
        let coordinateRegion = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: regionRadius,
                longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }

}