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
    var placesToShow = [Place]() {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    var searchQuery: String = "" {
        didSet {
            title = "Найдено для: \"\(searchQuery)\""
        }
    }
    let refreshControl = UIRefreshControl()
    var placesSubscriber: AnyCancellable?
    var fetchSubscriber: AnyCancellable?
    let requester = PlaceRequester()
    
    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.reloadData()
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
        places.forEach { manager.replace($0, with: $0) }
        self.placesToShow = places
    }

    private func searchFailure(_ err: PlaceRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on getting places", msg: err.localizedDescription)
    }

    // MARK: - Fetching single place
    private func startFetching(_ place: Place, tappedCell cell: PlaceSearchTableViewCell) {
        fetchSubscriber = Place.manager.fetch(id: place.id!)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            cell.activityIndicator.stopAnimating()
            switch completion {
            case .failure(let err):
                self.fetchFailure(err)
            case .finished:
                break
            }
        }, receiveValue: { place in
            self.fetchSuccess(place)
        })
    }

    private func fetchSuccess(_ place: Place) {
        // Changing place in placesToShow
        let idx = placesToShow.firstIndex { $0.id == place.id }!
        placesToShow.remove(at: idx)
        placesToShow.insert(place, at: idx)
        presentDetailVC(withPlace: place)
    }

    private func fetchFailure(_ err: PlaceRequester.ApiError) {
        presentDefaultOKAlert(title: "Error on getting place", msg: err.localizedDescription)
    }

    // MARK: - Present VCs
    private func presentDetailVC(withPlace place: Place) {
        guard let vc = storyboard?.instantiateViewController(identifier: PlaceDetailViewController.id)
                as? PlaceDetailViewController else {
            presentDefaultOKAlert(title: "Can't instantiate PlaceDetailVC", msg: "")
            return
        }
        vc.place = place
        navigationController?.pushViewController(vc, animated: true)
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
        cell.textLabel?.text = nil
        cell.placeNamelabel?.text = place.name
        return cell
    }
    
}


// MARK: - Table view delegate
extension PlacesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? PlaceSearchTableViewCell else {
            presentDefaultOKAlert(title: "Can't transform cell to needet type", msg: "")
            return
        }
        selectedCell.setSelected(false, animated: true)
        if placesToShow[indexPath.row].isDetailed {
            presentDetailVC(withPlace: placesToShow[indexPath.row])
            return
        }
        selectedCell.activityIndicator.startAnimating()
        startFetching(placesToShow[indexPath.row], tappedCell: selectedCell)
    }
    
}
