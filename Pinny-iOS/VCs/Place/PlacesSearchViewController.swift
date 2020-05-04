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
    
    // MARK: - Outlets value getters
    var searchStr: String? {
        searchTextField.text
    }

    // MARK: - Variables
    private var placesGetter: PlaceGetter?

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.addTarget(self, action: #selector(searchTextFieldTextChanged), for: .editingChanged)
        activityIndicator.stopAnimating()
        searchButton.isEnabled = !searchTextField.isEmpty
    }

    // MARK: - Actions
    @objc func searchTextFieldTextChanged(_ textField: UITextField) {
        searchButton.isEnabled = !searchTextField.isEmpty
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        self.getPlaces(searchStr!)
        activityIndicator.startAnimating()
    }

    // MARK: - Requests handlers
    private func getPlaces(_ name: String) {
        placesGetter = PlaceGetter()
        placesGetter?.getPlaces(search: name) { entities, error in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
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
