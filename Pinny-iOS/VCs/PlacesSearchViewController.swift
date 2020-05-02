//
//  PlacesSearchViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 02.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit

class PlacesSearchViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!

    // MARK: - Outlets value getters
    var searchStr: String? {
        searchTextField.text
    }

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.addTarget(self, action: #selector(searchTextFieldTextChanged), for: .editingChanged)
        searchButton.isEnabled = !searchTextField.isEmpty
    }

    // MARK: - Actions
    @objc func searchTextFieldTextChanged(_ textField: UITextField) {
        searchButton.isEnabled = !searchTextField.isEmpty
    }

    @IBAction func searchButtonPressed(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: PlacesListViewController.id)
                as? PlacesListViewController else {
            let alert = UIAlertControllerBuilder.defaultOkAlert(title: "Can't instantiate PlacesListVC", msg: "")
            present(alert, animated: true)
            return
        }
        vc.searchQuery = searchStr
        navigationController?.pushViewController(vc, animated: true)
    }

}
