//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by Donat Bajrami on 8.6.22.

import MediaPlayer
import AVFoundation
import Foundation
import UIKit
import AVKit

class PlayerDetailsView: UIView {
    
    //MARK: - EPISODE
    
    var episode: Episode! {
        didSet {
            miniTitleLabel.text = episode.title
            
            titleLabel.text = episode.title
            authorLabel.text = episode.author
            guard let url = URL(string: episode.imageURL ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            //miniEpisodeImageView.sd_setImage(with: url)\
            setupNowPlayingInfo()
            miniEpisodeImageView.sd_setImage(with: url) { image, _, _, _ in
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                guard let image = image else {
                    let placeholderImage = UIImage(named: "appicon")!
                    let artwork = MPMediaItemArtwork(boundsSize: placeholderImage.size) { _ in
                        return placeholderImage
                    }
                    nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    return
                }
                
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in
                    return image
                }
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
            playEpisode()
        }
    }
    
    //MARK: - Variables
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.layer.cornerRadius = 5
            episodeImageView.clipsToBounds = true
            let scale: CGFloat = 0.7
            self.episodeImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationTimeLabel: UILabel!
    
    @IBOutlet weak var currentTimeSlider: UISlider!
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    @IBOutlet weak var maximizedStackView: UIStackView!
    @IBOutlet weak var miniPlayerView: UIView!
    
    @IBOutlet weak var miniEpisodeImageView: UIImageView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet {
            miniPlayPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
            miniPlayPauseButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        }
    }
    
    @IBOutlet weak var miniFastForwardButton: UIButton! {
        didSet {
            miniFastForwardButton.addTarget(self, action: #selector(fastForwardTapped), for: .touchUpInside)
            miniFastForwardButton.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        }
    }
    
    @IBOutlet weak var miniPlayerSeparatorLine: UIView! {
        didSet {
            miniPlayerSeparatorLine.alpha = 0.3
        }
    }
    
    var panGesture: UIPanGestureRecognizer!
    
    var playlistEpisodes = [Episode]()
    
    //MARK: - Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupRemoteTransportControls()
        setupAudioSession()
        setupGestures()
        observePlayerCurrentTime()
        setupInterruptionObserver()
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            guard let self = self else { return }
            print("Episode started playing...")
            self.playButton.setImage(UIImage(named: "pause"), for: .normal)
            self.miniPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            self.enlargeEpisodeImageView()
        }
    }
    
    fileprivate func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
    }
    
    
    //https://developer.apple.com/documentation/avfaudio/avaudiosession/responding_to_audio_session_interruptions
    //https://developer.apple.com/forums/thread/652395
    @objc func handleInterruption(notification: Notification) {
        print("Interruption observed")
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            print("Interruption started... ")
            playButton.setImage(UIImage(named: "play"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
            shrinkEpisodeImageView()
        } else {
            print("Interruption ended... ")
            player.play()
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            if options == AVAudioSession.InterruptionOptions.shouldResume.rawValue {
                player.play()
                playButton.setImage(UIImage(named: "pause"), for: .normal)
                miniPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
                enlargeEpisodeImageView()
            }
        }
    }
    
    func setupNowPlayingInfo() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                self.handlePlayPause()
                self.player.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                self.handlePlayPause()
                self.player.pause()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] _ in
            self.handlePlayPause()
            return .success
        }
        
        //        commandCenter.nextTrackCommand.addTarget { [unowned self] _ in           -> This method works too, amo po provojm me #selector posht mnyre tjeter, ma clean kishe.
        //            print("print next episode... ")
        //            return .success
        //        }
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
    }
    
    @objc fileprivate func handleNextTrack() -> MPRemoteCommandHandlerStatus {
        print("Print next episode... ")
        
        if playlistEpisodes.isEmpty {
            return .commandFailed
        }
        
        let currentEpisodeIndex = playlistEpisodes.firstIndex { ep in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let currentEpisodeIndex = currentEpisodeIndex else {
            return .commandFailed
        }
        
        if currentEpisodeIndex + 1 == playlistEpisodes.count {
            //            print("Nalu babo")
            //            return .commandFailed
            self.episode = playlistEpisodes[0]
            return.success
        }
        
        let nextEpisode = playlistEpisodes[currentEpisodeIndex + 1]
        self.episode = nextEpisode
        return .success
    }
    
    @objc fileprivate func handlePreviousTrack() -> MPRemoteCommandHandlerStatus {
        print("Print prev episode... ")
        if playlistEpisodes.isEmpty {
            return .commandFailed
        }
        
        let currentEpisodeIndex = playlistEpisodes.firstIndex { ep in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let currentEpisodeIndex = currentEpisodeIndex else {
            return .commandFailed
        }
        
        if currentEpisodeIndex == 0 {
            //            print("Nalu babo")
            //            return .commandFailed
            self.episode = playlistEpisodes[playlistEpisodes.count - 1]
            return.success
        }
        
        let nextEpisode = playlistEpisodes[currentEpisodeIndex - 1]
        self.episode = nextEpisode
        return .success
    }
    
    
    fileprivate func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [ .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
    }
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
    }
    
    
    static func initFromNib() -> PlayerDetailsView {
        return Bundle.main.loadNibNamed("PlayerDetailsView", owner: self)?.first as! PlayerDetailsView
    }
    
    @IBAction func handleCurrentTimeSliderChange(_ sender: Any) {
        print("Slider value: ", currentTimeSlider.value)
        
        let percentage = currentTimeSlider.value
        
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
        
        player.seek(to: seekTime)
    }
    
    @IBAction func dismissTapped(_ sender: UIButton) {
        print("Tapperino")
        let mainTabbarController = UIApplication.mainTabBarController()
        mainTabbarController?.minimizePlayerDetails()
    }
    
    @IBAction func rewindTapped(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    
    @IBAction func fastForwardTapped(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeChange(_ sender: UISlider) {
        //MPVolumeView.setVolume(sender.value) -> Works! on device only but works!!
        player.volume = sender.value
    }
    
    fileprivate func playEpisode() {
        if let fileUrl = episode.fileUrl {
            guard let url = URL(string: fileUrl) else { return }
            let pathComponent = url.lastPathComponent
            guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            trueLocation.appendPathComponent(pathComponent)
            print("Trying to play episode locally at url: ", trueLocation.absoluteString)
            
            let playerItem = AVPlayerItem(url: trueLocation)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        } else {
            print("Trying to play episode at url: ", episode.streamUrl)
            guard let url = URL(string: episode.streamUrl) else { return }
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        }
    }
    
    
    @objc func handlePlayPause() {
        print("sumting")
        if player.timeControlStatus == .paused {
            player.play()
            playButton.setImage(UIImage(named: "pause"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            enlargeEpisodeImageView()
        } else {
            player.pause()
            playButton.setImage(UIImage(named: "play"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(named: "play"), for: .normal)
            shrinkEpisodeImageView()
        }
    }
    
    fileprivate func enlargeEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.episodeImageView.transform = .identity
        }
    }
    
    fileprivate func shrinkEpisodeImageView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            let scale: CGFloat = 0.7
            self.episodeImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTimeLabel.text = time.toDisplayString()
            let durationTime = self.player.currentItem?.duration
            self.durationTimeLabel.text = durationTime?.toDisplayString()
            self.setupLockscreenCurrentTime()
            self.updateCurrentTimeSlider()
        }
    }
    
    func setupLockscreenCurrentTime() {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        
        guard let currentItem = player.currentItem else { return }
        let durationInSeconds = CMTimeGetSeconds(currentItem.duration)
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1,timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        
        self.currentTimeSlider.value = Float(percentage)
    }
    
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}
