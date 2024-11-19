import SwiftUI
import AVKit

struct SpeedIndicator: View {
    var body: some View {
        Text("2x")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.7))
            .cornerRadius(6)
    }
}

struct VideoPlayerView: View {
    let player: AVPlayer
    @ObservedObject var videoState: VideoState
    private let haptics = TimelineHaptics()
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .allowsHitTesting(false)
            
            // Full-screen tap area
            Color.clear
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    videoState.togglePlayback()
                }
                .onLongPressGesture(minimumDuration: 0.1) {
                    videoState.enableSpeedScrubbing()
                } onPressingChanged: { isPressing in
                    if !isPressing {
                        videoState.disableSpeedScrubbing()
                    }
                }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Custom UIViewControllerRepresentable to wrap AVPlayerViewController
struct AVPlayerControllerRepresentable: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false  // This hides the controls
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Updates not needed
    }
}

#Preview {
    VideoPlayerView(player: AVPlayer(), videoState: VideoState())
        .frame(height: 300)
        .padding()
        .background(Color.black)
}
