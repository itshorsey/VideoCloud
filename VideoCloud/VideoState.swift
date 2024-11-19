import Foundation
import AVKit
import Combine

@MainActor
class VideoState: ObservableObject {
    // MARK: - Published Properties
    @Published var isPlaying: Bool = false
    @Published var currentVideoURL: URL? = nil
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    @Published var currentPlaybackTime: Double = 0
    @Published var contentDuration: Double = 0
    @Published var playbackState: PlaybackState = .paused
    @Published var isScrubbingAt2x: Bool = false
    @Published var isDragging: Bool = false
    private var stateBeforeScrubbingAt2x: PlaybackState = .paused
    
    // MARK: - Properties
    let player: AVPlayer
    private var timeObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        self.player = AVPlayer()
        setupObservers()
    }
    
    deinit {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
        }
    }
    
    // MARK: - Private Methods
    private func setupObservers() {
        // Setup periodic time observer
        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentPlaybackTime = time.seconds
        }
        
        // Observe player item status
        player.publisher(for: \.timeControlStatus)
            .receive(on: OperationQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                switch status {
                case .playing:
                    self.isPlaying = true
                    self.playbackState = .playing
                case .paused:
                    self.isPlaying = false
                    self.playbackState = .paused
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // Observe when playback ends
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .receive(on: OperationQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isPlaying = false
                self.playbackState = .paused
                Task {
                    await self.seek(to: 0)
                }
            }
            .store(in: &cancellables)
        
        // Observe current item duration
        player.publisher(for: \.currentItem?.duration)
            .receive(on: OperationQueue.main)
            .sink { [weak self] duration in
                guard let self = self else { return }
                if let duration = duration, duration.seconds.isFinite {
                    self.contentDuration = duration.seconds
                } else {
                    self.contentDuration = 0
                }
            }
            .store(in: &cancellables)
    }
    
    private func getAllVideoURLs() -> [URL] {
        let videoNames = (1...6).map { "video\($0)" }
        
        return videoNames.compactMap { name in
            if let url = Bundle.main.url(forResource: name, withExtension: "mov") {
                return url
            }
            if let url = Bundle.main.url(forResource: name, withExtension: "MOV") {
                return url
            }
            return nil
        }
    }
    
    // MARK: - Public Methods
    func togglePlayback() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    func previewSeek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let tolerance = CMTime(value: 100, timescale: 1000)
        player.seek(to: cmTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func setPlaybackState(_ state: PlaybackState) {
            playbackState = state
            // Update drag state
            isDragging = (state == .interacting)
            
            print("VideoState - Setting playback state to: \(state), isDragging: \(isDragging)")
            
            switch state {
            case .playing:
                player.play()
                isPlaying = true
            case .paused:
                player.pause()
                isPlaying = false
            case .interacting:
                player.pause()
                isPlaying = false
            }
        }
    
    func enableSpeedScrubbing() {
            guard !isScrubbingAt2x else { return }
            stateBeforeScrubbingAt2x = playbackState
            isScrubbingAt2x = true
            player.play()
            player.rate = 2.0
        }
    
    func disableSpeedScrubbing() {
            guard isScrubbingAt2x else { return }
            isScrubbingAt2x = false
            player.rate = 1.0
            
            // Restore previous state
            setPlaybackState(stateBeforeScrubbingAt2x)
        }
    
    func loadRandomVideo() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let videos = getAllVideoURLs()
                guard !videos.isEmpty else {
                    throw VideoError.noVideosAvailable
                }
                
                let randomURL = videos.randomElement()!
                let asset = AVAsset(url: randomURL)
                
                let playable = try await asset.load(.isPlayable)
                guard playable else {
                    throw VideoError.videoNotPlayable
                }
                
                let playerItem = AVPlayerItem(asset: asset)
                player.replaceCurrentItem(with: playerItem)
                currentVideoURL = randomURL
                
                isPlaying = false
                playbackState = .paused
                currentPlaybackTime = 0
                isScrubbingAt2x = false
                await seek(to: 0)
                error = nil
                
                print("Successfully loaded video: \(randomURL.lastPathComponent)")
                
            } catch {
                self.error = error
                print("Error loading video: \(error.localizedDescription)")
                if let videoError = error as? VideoError {
                    print("Available paths searched:")
                    for i in 1...4 {
                        if let path = Bundle.main.path(forResource: "video\(i)", ofType: "mov") {
                            print("video\(i).mov path: \(path)")
                        } else {
                            print("video\(i).mov not found")
                        }
                        if let path = Bundle.main.path(forResource: "video\(i)", ofType: "MOV") {
                            print("video\(i).MOV path: \(path)")
                        } else {
                            print("video\(i).MOV not found")
                        }
                    }
                }
            }
        }
    }
}

enum VideoError: LocalizedError {
    case noVideosAvailable
    case videoNotPlayable
    
    var errorDescription: String? {
        switch self {
        case .noVideosAvailable:
            return "No videos found in assets directory"
        case .videoNotPlayable:
            return "Selected video cannot be played"
        }
    }
}

enum PlaybackState {
    case playing
    case paused
    case interacting
}
