class VideoPlayerViewModel: ObservableObject {
    @Published private(set) var isPlaying = false
    @Published private(set) var durationText = "0:00 / 0:00"
    
    private var player: AVPlayer
    private var timeObserver: Any?
    
    init() {
        // Initialize player and setup observers
    }
    
    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            player.play()
        } else {
            player.pause()
        }
    }
    
    func refreshVideo() {
        // Reset video to beginning or load new video
        player.seek(to: .zero)
        updateDurationText()
    }
    
    private func updateDurationText() {
        guard let duration = player.currentItem?.duration.seconds,
              let current = player.currentTime().seconds else {
            return
        }
        
        let currentTime = formatTime(current)
        let totalTime = formatTime(duration)
        durationText = "\(currentTime) / \(totalTime)"
    }
    
    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
} 