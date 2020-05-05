//
//  EditPlaceViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 05.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class EditPlaceViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Outlets value getters
    var name: String? {
        nameTextField.text
    }
    var address: String? {
        addressTextField.text
    }
    var latitude: Double? {
        Double(latitudeTextField.text ?? "0")
    }
    var longitude: Double? {
        Double(longitudeTextField.text ?? "0")
    }

    // MARK: - Variables
    static var id = "EditPlaceVC"
    var place: Place! {
        didSet {
            fillView()
        }
    }
    var calleeVc: PlaceDetailViewController!
    var editSubscriber: AnyCancellable?

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        addressTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        latitudeTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        longitudeTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
        fillView()
        editButton.isEnabled = isButtonEnabled
    }

    // MARK: - Actions
    @objc func textFieldEditingChanged() {
        editButton.isEnabled = isButtonEnabled
    }

    @IBAction func editButtonPressed(_ sender: Any) {
        let name = self.name!
        let address = self.address!
        let lat = self.latitude!
        let long = self.longitude!
        editPlace(name: name, address: address, lat: lat, long: long)
    }

    // MARK: - Request handlers
    private func editPlace(name: String, address: String, lat: Double, long: Double) {
        let dictData: [String : Any] = [
            "name": name,
            "address": address,
            "latitude": lat,
            "longitude": long
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: dictData, options: .prettyPrinted)
        activityIndicator.startAnimating()
        editSubscriber = PlaceRequester().patchObject(place.id!, data: jsonData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.activityIndicator.stopAnimating()
                switch completion {
                case .failure(let err):
                    self.editPlaceCompletion(nil, err)
                case .finished:
                    break
                }
            }, receiveValue: { entity in
                self.editPlaceCompletion(entity, nil)
            })
    }

    private func editPlaceCompletion(_ place: Place?, _ err: PlaceRequester.ApiError?) {
        if let err = err {
            self.presentDefaultOKAlert(title: "Error on editing place", msg: err.localizedDescription)
            return
        }
        Place.manager.replace(place!, with: place!)
        calleeVc.place = place!
        self.dismiss(animated: true)
    }

    // MARK: - Utils
    private var isButtonEnabled: Bool {
        !nameTextField.isEmpty && !addressTextField.isEmpty && !latitudeTextField.isEmpty && !longitudeTextField.isEmpty
    }

    // MARK: - View fill
    private func fillView() {
        if !isViewLoaded { return }
        self.nameTextField.text = place.name
        self.addressTextField.text = place.address
        self.latitudeTextField.text = "\(place.lat ?? 0)"
        self.longitudeTextField.text = "\(place.long ?? 0)"
    }

}


// MARK: - Text field delegate
extension EditPlaceViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Допускаем пустую
        if string.isEmpty { return true }
        // Проверяем что символы в допустимых
        if string.rangeOfCharacter(from: CharacterSet(charactersIn: "1234567890.-")) == nil {
            return false
        }
        let currentText = textField.text ?? ""
        // Смотрим, чтобы не было двух точек
        if string.contains(".") && currentText.contains(".") {
            return false
        }
        // Смотрим чтобы не было двух минусов
        if string.contains("-") && currentText.contains("-") {
            return false
        }
        // Смотрим чтобы не было точек в начале строки
        if currentText.isEmpty && string.first! == "." {
            return false
        }
        // Минус только в начале строки
        if !currentText.isEmpty && string.contains("-") {
            return false
        }
        // Нет точки сразу после минуса
        if currentText.count == 1 && currentText.first! == "-" && string.first! == "." {
            return false
        }
        return true
    }
}
