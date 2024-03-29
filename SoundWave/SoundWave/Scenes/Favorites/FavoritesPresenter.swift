//
//  FavoritesPresenter.swift
//  SoundWave
//
//  Created by Kerem Ersu on 15.06.2023.
//

import Foundation

protocol FavoritesPresenterProtocol: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func numberOfItems() -> Int
    func getTrack(_ index: Int) -> Favorite?
    func getTrackCellModel(_ index: Int) -> TrackCellModel?
    func didSelectRowAt(index: Int)
    func getAllFavorites()
    func removeFromFavorites(id: Int)
    func removeSelectedFavorite(_ index: Int)
}

final class FavoritesPresenter {
   
    unowned var view: FavoritesViewControllerProtocol
    let router: FavoritesRouterProtocol!
    let interactor: FavoritesInteractorProtocol!
    
    var tracks: [Favorite] = []
    
    init(
         view: FavoritesViewControllerProtocol,
         router: FavoritesRouterProtocol,
         interactor: FavoritesInteractorProtocol)
    {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
}

extension FavoritesPresenter: FavoritesPresenterProtocol {
    
    func removeSelectedFavorite(_ index: Int) {
        let track = getTrack(index)
        removeFromFavorites(id: Int(truncatingIfNeeded: track!.trackId))
        getAllFavorites()
    }
    
    func viewDidLoad() {
        view.setupTableView()
        view.setTitle("Favorites")
        getAllFavorites()
    }
    
    func viewWillAppear() {
        getAllFavorites()
    }
    
    func numberOfItems() -> Int {
        tracks.count
    }
    
    func getTrack(_ index: Int) -> Favorite? {
        tracks[index]
    }
    
    func getTrackCellModel(_ index: Int) -> TrackCellModel? {
        var trackCellModel: TrackCellModel? = nil
        if let model = getTrack(index) {
            trackCellModel = TrackCellModel(
                trackName: model.trackName ?? "",
                artistName: model.artistName ?? "",
                imageUrl: model.imageURL ?? "",
                previewUrl: model.previewURL ?? "")
        }
        return trackCellModel ?? nil
    }
    
    func didSelectRowAt(index: Int) {
        guard let model = getTrack(index) else { return }
        let source = Track(kind: "", trackID: Int(model.trackId), artistName: model.artistName, collectionName: model.albumName, trackName: model.trackName, previewURL: model.previewURL, artworkUrl100: model.imageURL)
        router.navigate(.detail(source: source))
    }
    
    func getAllFavorites() {
        view.showLoadingView()
        tracks = interactor.getAllFavorites() ?? []
        view.reloadData()
        view.hideLoadingView()
    }
    
    func removeFromFavorites(id: Int) {
        interactor.removeFromFavorites(id: id)
    }
}
