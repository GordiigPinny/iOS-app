//
//  CreatePlaceViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 04.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class CreatePlaceViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!

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
    static let id = "CreatePlaceVC"
    private var createPlaceSubscriber: AnyCancellable?

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        addressTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        latitudeTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        longitudeTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
        addButton.isEnabled = isButtonEnabled
    }

    // MARK: - Actions
    @objc func textFieldEditingChanged() {
        addButton.isEnabled = isButtonEnabled
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        let name = self.name!
        let address = self.address!
        let latitude = self.latitude!
        let longitude = self.longitude!
        createPlace(name: name, address: address, lat: latitude, long: longitude)
    }
    
    // MARK: - Request handlers
    private func createPlace(name: String, address: String, lat: Double, long: Double) {
        createPlaceSubscriber = GatewayRequester.createPlace(name: name, address: address, lat: lat, long: long)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let err):
                self.createCompletion(nil, nil, err)
            case .finished:
                break
            }
        }, receiveValue: { place, profile in
            self.createCompletion(place, profile, nil)
        })
    }

    private func createCompletion(_ place: Place?, _ profile: Profile?, _ err: GatewayRequester.ApiError?) {
        if let err = err {
            presentDefaultOKAlert(title: "Error on creating new place", msg: err.localizedDescription)
            return
        }
        if profile == nil {
            presentDefaultOKAlert(title: "Place created", msg: "But profile didn't update")
            return
        }
        presentDefaultOKAlert(title: "Place created", msg: nil)
    }

    // MARK: - Utils
    private var isButtonEnabled: Bool {
        !nameTextField.isEmpty && !addressTextField.isEmpty && !latitudeTextField.isEmpty && !longitudeTextField.isEmpty
    }

}


// MARK: - Text field delegate
extension CreatePlaceViewController: UITextFieldDelegate {
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