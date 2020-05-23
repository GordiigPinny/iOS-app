//
//  PinListViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 03.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class PinListViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Variables
    static let id = "PinsListVC"
    var pinsToShow = [Pin]() {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    private var pinGetter: PinGetter?
    private var refreshControl = UIRefreshControl()

    // MARK: - Getters
    var geoPins: [Pin] {
        pinsToShow.filter { $0.ptype! == PinType.user }
    }
    var placePins: [Pin] {
        pinsToShow.filter { $0.ptype! == PinType.place }
    }

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        getPins()
        tableView.reloadData()
    }

    // MARK: - Actions
    @objc func refreshControlValueChanged() {
        if !refreshControl.isRefreshing { return }
        getPins()
    }

    // MARK: - Request handlers
    private func getPins() {
        pinGetter = PinGetter()
        pinGetter?.getPins(completion: getPinsCompletion)
    }

    private func getPinsCompletion(_ pins: [Pin]?, _ err: PinRequester.ApiError?) {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            if let err = err {
                self.presentDefaultOKAlert(title: "Error on getting pins", msg: err.localizedDescription)
                return
            }
            self.pinsToShow = pins!
        }
    }

}


// MARK: - Table view data source
extension PinListViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filtered = section == 0
                ? placePins
                : geoPins
        return filtered.count
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Place pins" : "Geo pins"
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PinTableViewCell.id)
                as? PinTableViewCell else {
            return UITableViewCell()
        }
        let pin = indexPath.section == 0
                ? placePins[indexPath.row]
                : geoPins[indexPath.row]
        cell.setUp(pin)
        return cell
    }

}


// MARK: - Table view delegate
extension PinListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)

        guard let vc = storyboard?.instantiateViewController(identifier: PinDetailViewController.id)
                as? PinDetailViewController else {
            presentDefaultOKAlert(title: "Can't instantiate pin detail vc", msg: nil)
            return
        }
        let pin = indexPath.section == 0
                ? placePins[indexPath.row]
                : geoPins[indexPath.row]
        vc.pin = pin
        present(vc, animated: true)
    }

}
