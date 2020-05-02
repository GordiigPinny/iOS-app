//
//  PlacesListViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 23.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit

class PlacesListViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Variables
    static let id = "PlacesListVC"
    let places = ["Place 1", "Place2"]
    let refreshControl = UIRefreshControl()
    var searchQuery: String? = nil {
        didSet {
            self.title = "Найдено для: \"\(searchQuery ?? "")\""
        }
    }
    
    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
    }
    
    // MARK: - Refresh control action
    @objc func refreshControlValueChanged() {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3) {
            self.refreshControl.endRefreshing()
        }
    }
    
}


// MARK: - Table view data source
extension PlacesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let placeName = self.places[indexPath.row]
        let cellId = PlaceSearchTableViewCell.id
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? PlaceSearchTableViewCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = placeName
        return cell
    }
    
}


// MARK: - Table view delegate
extension PlacesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }
    
}
