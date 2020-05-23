//
//  YandexMapsViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 04.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import YandexMapKit

class YandexMapsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var mapView: YMKMapView!
    
    // MARK: - Variables
    static let id = "YandexMapsVC"
    var place: Place!

    var coordinates: YMKPoint {
        YMKPoint(latitude: place.lat!, longitude: place.long!)
    }

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up
        mapView.clearsContextBeforeDrawing = true
        // Moving map to coordinate
        let cameraPosition = YMKCameraPosition(target: coordinates, zoom: 15, azimuth: 0, tilt: 0)
        let animation = YMKAnimation(type: .smooth, duration: 3)
        mapView.mapWindow.map.move(with: cameraPosition, animationType: animation, cameraCallback: nil)
        // Adding user to the map
        let mapKit = YMKMapKit.sharedInstance()
        let userLocationLayer = mapKit.createUserLocationLayer(with: mapView.mapWindow)
        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.setObjectListenerWith(self)
        // Adding place on map
        let mapObjects = mapView.mapWindow.map.mapObjects
        let placeImage = havePlacePinLocally() == nil ? UIImage(systemName: "chevron.down")! : havePlacePinLocally()!
        mapObjects.addPlacemark(
                with: coordinates,
                image: placeImage,
                style: YMKIconStyle(
                    anchor: CGPoint(x: 0, y: 0) as NSValue,
                    rotationType:YMKRotationType.rotate.rawValue as NSNumber,
                    zIndex: 0,
                    flat: true,
                    visible: true,
                    scale: 3,
                    tappableArea: nil))
    }

    private func havePlacePinLocally() -> UIImage? {
        guard let profile = Defaults.currentProfile,
              let pin = Pin.manager.get(id: profile.pinSpriteId),
              let imageFile = ImageFile.manager.get(id: pin.picId),
              let image = imageFile.image else {
            return nil
        }
        return image
    }

    private func haveUserPinLocally() -> UIImage? {
        guard let profile = Defaults.currentProfile,
              let pin = Pin.manager.get(id: profile.geopinSpriteId),
              let imageFile = ImageFile.manager.get(id: pin.picId),
              let image = imageFile.image else {
            return nil
        }
        return image
    }

}


// MARK: - Yandex map kit location object listener
extension YandexMapsViewController: YMKUserLocationObjectListener {
    func onObjectAdded(with view: YMKUserLocationView) {
        let pinPlacemark = view.pin.useCompositeIcon()
        let image = haveUserPinLocally() == nil ? UIImage(systemName: "person.circle.fill")! : haveUserPinLocally()!
        pinPlacemark.setIconWithName("icon",
                image: image,
                style:YMKIconStyle(
                        anchor: CGPoint(x: 0, y: 0) as NSValue,
                        rotationType:YMKRotationType.rotate.rawValue as NSNumber,
                        zIndex: 0,
                        flat: true,
                        visible: true,
                        scale: 3,
                        tappableArea: nil))
        view.accuracyCircle.fillColor = UIColor.blue
    }

    func onObjectRemoved(with view: YMKUserLocationView) {}

    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}
}
