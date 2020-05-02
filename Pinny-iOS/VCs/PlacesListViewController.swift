//
//  PlacesListViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 23.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class PlacesListViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Variables
    static let id = "PlacesListVC"
    var placesToShow = [Place]()
    let refreshControl = UIRefreshControl()
    var placesSubscriber: AnyCancellable?
    let requester = PlaceRequester()
    var searchQuery: String = "" {
        didSet {
            if searchQuery.isEmpty { return }
            self.title = "Найдено для: \"\(searchQuery)\""
            self.startSearching()
        }
    }
    
    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
    }
    
    // MARK: - Refresh control action
    @objc func refreshControlValueChanged(_ refreshController: UIRefreshControl) {
        if refreshController.isRefreshing {
            startSearching()
        }
    }

    // MARK: - Searching
    private func startSearching() {
        if !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        placesSubscriber = requester.searchByName(searchQuery)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.refreshControl.endRefreshing()
                switch completion {
                case .failure(let err):
                    self.searchFailure(err)
                case .finished:
                    break
                }
            }, receiveValue: { entities in
                self.searchSuccess(entities)
            })
    }

    private func searchSuccess(_ places: [Place]) {
        let manager = Place.manager
        places.forEach { manager.addLocaly($0) }
        self.placesToShow = places
        self.tableView.reloadData()
    }

    private func searchFailure(_ err: PlaceRequester.ApiError) {
        let alert = UIAlertControllerBuilder.defaultOkAlert(title: "Error on getting places", 
                msg: err.localizedDescription)
        present(alert, animated: true)
    }
    
}


// MARK: - Table view data source
extension PlacesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.placesToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = self.placesToShow[indexPath.row]
        let cellId = PlaceSearchTableViewCell.id
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? PlaceSearchTableViewCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = place.name
        return cell
    }
    
}


// MARK: - Table view delegate
extension PlacesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        guard let vc = storyboard?.instantiateViewController(identifier: PlaceDetailViewController.id)
                as? PlaceDetailViewController else {
            let alert = UIAlertControllerBuilder.defaultOkAlert(title: "Can't instantiate PlaceDetailVC", msg: "")
            present(alert, animated: true)
            return
        }
        vc.place = placesToShow[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
