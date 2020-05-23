//
//  StatsViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 04.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Variables
    static let id = "StatsVC"
    private let limit: UInt = 20
    private var hasNext: Bool = true
    private var downloading: Bool = false
    private var statsGetter: RequestStatsGetter?
    var statsToShow = [RequestStats]() {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        getStats()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }

    // MARK: - Request handlers
    func getStats() {
        statsGetter = RequestStatsGetter()
        downloading = true
        statsGetter?.getStats(limit: limit, offset: UInt(statsToShow.count)) { entities, hasNext, error in
            DispatchQueue.main.async {
                self.downloading = false
                if let err = error {
                    self.presentDefaultOKAlert(title: "Error on getting stats", msg: err.localizedDescription)
                    return
                }
                self.statsToShow.append(contentsOf: entities!)
                self.hasNext = hasNext!
            }
        }
    }

}


// MARK: - Table view data source
extension StatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        statsToShow.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if hasNext && !downloading && indexPath.row >= statsToShow.count - 10 {
            getStats()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatsTableViewCell.id)
                as? StatsTableViewCell else {
            return UITableViewCell()
        }
        cell.setUp(statsToShow[indexPath.row])
        return cell
    }


}


// MARK: - Table view delegate
extension StatsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}