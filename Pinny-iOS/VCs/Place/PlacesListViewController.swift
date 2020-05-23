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
    private var placesGetter: PlaceGetter?
    private var placeGetter: PlaceGetter?
    private var deletePlaceSubscriber: AnyCancellable?
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
        placesGetter = PlaceGetter()
        placesGetter?.getPlaces(search: searchQuery) { entities, error in
            DispatchQueue.main.async {
                if let err = error {
                    self.presentDefaultOKAlert(title: "Error on getting places", msg: err.localizedDescription)
                    return
                }
                self.placesToShow = entities!
            }
        }
    }

    // MARK: - Fetching single place
    private func startFetching(_ place: Place, tappedCell cell: PlaceSearchTableViewCell) {
        placeGetter = PlaceGetter()
        placeGetter?.getPlace(place.id!) { entity, error in
            DispatchQueue.main.async {
                cell.activityIndicator.stopAnimating()
                if let err = error {
                    self.presentDefaultOKAlert(title: "Error on getting place", msg: err.localizedDescription)
                    return
                }
                let idx = self.placesToShow.firstIndex { $0.id == place.id }!
                self.placesToShow.remove(at: idx)
                self.placesToShow.insert(place, at: idx)
                self.presentDetailVC(withPlace: entity!)
            }
        }
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

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        Defaults.currentAccessLevel == AccessLevel.admin
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle != .delete {
            return
        }
        let place = self.placesToShow[indexPath.row]
        deletePlace(place)
    }

    private func deletePlace(_ place: Place) {
        deletePlaceSubscriber = PlaceRequester().deleteObject(place.id!)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let err):
                    self.deletePlaceCompletion(place, nil, err)
                case .finished:
                    break
                }
            }, receiveValue: { b in
                self.deletePlaceCompletion(place, b, nil)
            })
    }

    private func deletePlaceCompletion(_ place: Place, _ didDelete: Bool?, _ err: PlaceRequester.ApiError?) {
        if let err = err {
            self.presentDefaultOKAlert(title: "Error on deleting place", msg: err.localizedDescription)
            return
        }
        if !(didDelete!) {
            self.presentDefaultOKAlert(title: "Place is not deleted", msg: nil)
            return
        }
        Place.manager.delete(place)
        self.placesToShow.removeAll { $0.id == place.id }
        self.tableView.reloadData()
    }

}


// MARK: - Table view delegate
extension PlacesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? PlaceSearchTableViewCell else {
            presentDefaultOKAlert(title: "Can't transform cell to needed type", msg: "")
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
