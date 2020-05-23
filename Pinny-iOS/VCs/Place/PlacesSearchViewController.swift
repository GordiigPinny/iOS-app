//
//  PlacesSearchViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 02.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class PlacesSearchViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mineStackView: UIStackView!
    @IBOutlet weak var deletedStackView: UIStackView!
    @IBOutlet weak var mineSwitch: UISwitch!
    @IBOutlet weak var deletedSwitch: UISwitch!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    // MARK: - Outlets value getters
    var searchStr: String? {
        searchTextField.text
    }

    var onlyMine: Bool? {
        if Defaults.currentAccessLevel.rawValue == AccessLevel.anon.rawValue {
            return nil
        }
        return mineSwitch.isOn
    }

    var includeDeleted: Bool? {
        if Defaults.currentAccessLevel.rawValue != AccessLevel.admin.rawValue {
            return nil
        }
        return deletedSwitch.isOn
    }

    // MARK: - Variables
    private var placesGetter: PlaceGetter?

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.addTarget(self, action: #selector(searchTextFieldTextChanged), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(accessLevelChanged), name: .accessLevelChanged, object: nil)
        activityIndicator.stopAnimating()
        searchButton.isEnabled = !searchTextField.isEmpty
        accessLevelChanged()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchButton.isEnabled = !searchTextField.isEmpty
    }

    // MARK: - Actions
    @objc func accessLevelChanged() {
        deletedStackView.isHidden = Defaults.currentAccessLevel.rawValue < AccessLevel.admin.rawValue
        mineStackView.isHidden = Defaults.currentAccessLevel.rawValue == AccessLevel.anon.rawValue
        addButton.isEnabled = Defaults.currentAccessLevel.rawValue >= AccessLevel.authorized.rawValue
    }

    @objc func searchTextFieldTextChanged(_ textField: UITextField) {
        searchButton.isEnabled = !searchTextField.isEmpty
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        self.getPlaces(searchStr!)
    }

    // MARK: - Requests handlers
    private func getPlaces(_ name: String) {
        activityIndicator.startAnimating()
        searchButton.isEnabled = false
        placesGetter = PlaceGetter()
        placesGetter?.getPlaces(search: name, onlyMine: onlyMine, withDeleted: includeDeleted) { entities, error in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.searchButton.isEnabled = self.searchTextField.isEmpty
                if let err = error {
                    self.presentDefaultOKAlert(title: "Error on getting places", msg: err.localizedDescription)
                    return
                }
                guard let vc = self.storyboard?.instantiateViewController(identifier: PlacesListViewController.id)
                        as? PlacesListViewController else {
                    self.presentDefaultOKAlert(title: "Can't instantiate PlacesListVC", msg: "")
                    return
                }
                vc.placesToShow = entities!
                vc.searchQuery = name
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}
