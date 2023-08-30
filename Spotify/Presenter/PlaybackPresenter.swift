//
//  PlaybackPresenter.swift
//  Spotify
//
//  Created by Adriancys Jesus Villegas Toro on 22/8/23.
//

import AVFoundation
import Foundation
import UIKit

protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var image: URL? { get }
}

final class PlaybackPresenter {
    
    // MARK: - Methods
    static let shared = PlaybackPresenter()
    
    var playerVC: PlayerViewController?
    
    private var track : AudioTrack?
    private var tracks = [AudioTrack]()
    private var index = 0
    
    private var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        }else if let player = self.playerQueue, !tracks.isEmpty {
           
            return tracks[index]
        }
        return nil
    }
    
    var player: AVPlayer?
    var playerQueue: AVQueuePlayer?
    // MARK: - Methods
    
    func startPlayback(
    from viewController: UIViewController,
    track: AudioTrack
    ) {
        //playSong
//        print(track.previewUrl)
        guard let url = URL(string: track.previewUrl ?? "") else {
            return
        }
        
        player = AVPlayer(url: url)
        player?.volume = 0.5 
        
        self.track = track
        self.tracks = []
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc),
                               animated: true) { [weak self] in
            self?.player?.play()
            
        }
        self.playerVC = vc
    }
    
    func startPlayback(
    from viewController: UIViewController,
    tracks: [AudioTrack]
    ) {
        self.tracks = tracks
        self.track = nil
        
        self.playerQueue = AVQueuePlayer(items: tracks.compactMap({
            guard let url = URL(string: $0.previewUrl ?? "") else { return nil }
            return AVPlayerItem(url: url)
        }))
        self.playerQueue?.volume = 0.5
        self.playerQueue?.play()
        
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        self.playerVC = vc
    }
    

}
// MARK: - PlayerDataSource

extension PlaybackPresenter: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var image: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
    
}

// MARK: - PlayerControlsViewDelegate
extension PlaybackPresenter: PlayerViewControllerDelegate {
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
    
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            }else if player.timeControlStatus == .paused {
                player.play()
            }
        }else if let playerList = playerQueue {
            if playerList.timeControlStatus == .playing{
                playerList.pause()
            }else if playerList.timeControlStatus == .paused {
                playerList.play()
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty {
            player?.pause()
        }else if let player = playerQueue {
            player.advanceToNextItem()
            index += 1
            print(index)
            playerVC?.refreshUI()
        }
    }
    
    func didTapBackward() {
        if tracks.isEmpty {
            player?.pause()
            player?.play()
        }else if let firstItem = playerQueue?.items().first {
            playerQueue?.pause()
            playerQueue?.removeAllItems()
            playerQueue = AVQueuePlayer(items: [firstItem])
            playerQueue?.volume = 0.5
            playerQueue?.play()
        }
    }
    

}
