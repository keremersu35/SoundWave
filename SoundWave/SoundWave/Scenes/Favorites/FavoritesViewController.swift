//
//  FavoritesViewController.swift
//  SoundWave
//
//  Created by Kerem Ersu on 15.06.2023.
//

import UIKit

protocol FavoritesViewControllerProtocol: AnyObject {
    func setupTableView()
    func reloadData()
    func showError(_ message: String)
    func showLoadingView()
    func hideLoadingView()
    func setTitle(_ title: String)
}

final class FavoritesViewController: BaseViewController {

    var presenter: FavoritesPresenterProtocol!
    private let audioPlayer = AudioPlayer()
    @IBOutlet private weak var tableView: UITableView!
    private var previousIndex: Int? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.viewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        checkEmptyState()
    }
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(cellType: TrackCell.self, indexPath: indexPath)
        if let track = presenter.getTrackCellModel(indexPath.row) {
            cell.cellPresenter = TrackCellPresenter(view: cell, track: track)
            cell.playButtonTapped = {
                if self.previousIndex == indexPath.row && cell.checkIsPlaying() {
                    self.audioPlayer.pauseAudio()
                } else {
                    if let url = URL(string: track.previewUrl) {
                        if let previous = self.previousIndex {
                            let previousCell = tableView.cellForRow(at: IndexPath(row: previous, section: 0)) as? TrackCell
                            previousCell?.setIsPlayingAsFalse()
                            previousCell?.setButtonImageAsPlay()
                        }
                        self.audioPlayer.pauseAudio()
                        self.audioPlayer.playAudio(from: url)
                    }
                }
                self.previousIndex = indexPath.row
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRowAt(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.showAlert("Are You Sure?", "This track will be removed from favorite list.") {
                self.presenter.removeSelectedFavorite(indexPath.row)
            }
        }
    }
}

extension FavoritesViewController: FavoritesViewControllerProtocol {
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: TrackCell.self)
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.checkEmptyState()
        }
    }
    
    func showError(_ message: String) {
        self.showAlert("Error", "Error occured.")
    }
    
    func showLoadingView() {
        self.showLoading()
    }
    
    func hideLoadingView() {
        self.hideLoading()
    }
    
    func setTitle(_ title: String) {
        self.title = title
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: Constants.ColorNames.primary.rawValue)!]
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor(named: Constants.ColorNames.primary.rawValue)
    }
    
    func checkEmptyState() {
        if presenter.numberOfItems() == 0 {
            tableView.setEmptyView(
                icon: UIImage(systemName: Constants.ImageNames.favFill.rawValue)!,
                text: "Your favorite list is empty!"
            )
        } else {
            tableView.restore()
        }
    }
}
