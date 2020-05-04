//
// Created by Dmitry Gorin on 04.05.2020.
// Copyright (c) 2020 gordiig. All rights reserved.
//

import Foundation
import MapKit

class UserMapMarker: MKAnnotationView {
    override var reuseIdentifier: String? {
        "user"
    }

    override var annotation: MKAnnotation? {
        willSet  {
            // Checking if we getting pin for place annotation
            guard let _ = newValue as? Profile.UserMapKitAnnotation else {
                return
            }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .system)

            // Getting image, if nil, then regular pin
            guard let profile = Defaults.currentProfile,
                  let pin = Pin.manager.get(id: profile.geopinSpriteId),
                  let imageFile = ImageFile.manager.get(id: pin.picId) else {
                return
            }
            image = imageFile.image
        }
    }
}
