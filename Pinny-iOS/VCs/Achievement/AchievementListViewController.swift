//
//  AchievementListViewController.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 03.05.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import UIKit
import Combine

class AchievementListViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Variables
    var achievementsToShow = [Achievement]() {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
            }
        }
    }
    static let id = "AchievementListVC"
    private var achievementGetter: AchievementGetter?
    private var refreshController = UIRefreshControl()

    // MARK: - Time hooks
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refreshController
        refreshController.addTarget(self, action: #selector(refreshControllerValueChanged), for: .valueChanged)
        getAchievements()
        tableView.reloadData()
    }

    // MARK: - Actions
    @objc func refreshControllerValueChanged() {
        if !refreshController.isRefreshing { return }
        getAchievements()
    }

    // MARK: - Request handlers
    private func getAchievements() {
        achievementGetter = AchievementGetter()
        achievementGetter?.getAchievements { entities, error in
            DispatchQueue.main.async {
                if let err = error {
                    self.presentDefaultOKAlert(title: "Error on getting achievements", msg: err.localizedDescription)
                    return
                }
                self.achievementsToShow = entities!
            }
        }
    }

}


// MARK: - Table view data source
extension AchievementListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        achievementsToShow.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AchievementTableViewCell.id)
                as? AchievementTableViewCell else {
            return UITableViewCell()
        }
        cell.setUp(achievementsToShow[indexPath.row])
        return cell
    }

}


// MARK: - Table view delegate
extension AchievementListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)

        guard let vc = storyboard?.instantiateViewController(identifier: AchievementDetailViewController.id)
                as? AchievementDetailViewController else {
            presentDefaultOKAlert(title: "Can't instantiate achievement detail vc", msg: nil)
            return
        }
        vc.achievement = achievementsToShow[indexPath.row]
        present(vc, animated: true)
    }

}
