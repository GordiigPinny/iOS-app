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
    var placesSubscriber: AnyCancellable?

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
        activityIndicator.startAnimating()
        placesSubscriber = PlaceRequester().searchByName(searchStr!)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.activityIndicator.stopAnimating()
                switch completion {
                case .failure(let err):
                    self.placesGetFailure(err)
                case .finished:
                    break
                }
            }, receiveValue: { entities in
                entities.forEach { Place.manager.replace($0, with: $0) }
                self.placesGetSuccess(entities)
            })
    }

    // MARK: - Requests handlers
    private func placesGetSuccess(_ places: [Place]) {
        guard let vc = storyboard?.instantiateViewController(identifier: PlacesListViewController.id)
                as? PlacesListViewController else {
            presentDefaultOKAlert(title: "Can't instantiate PlacesListVC", msg: "")
            return
        }
        vc.placesToShow = places
        vc.searchQuery = searchStr!
        navigationController?.pushViewController(vc, animated: true)
    }

    private func placesGetFailure(_ err: PlaceRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on getting places", msg: err.localizedDescription)
    }

}
