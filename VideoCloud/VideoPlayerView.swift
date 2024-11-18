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
            AVPlayerControllerRepresentable(player: player)
                .onDisappear {
                    player.pause()
                    player.replaceCurrentItem(with: nil)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .gesture(
                    LongPressGesture(minimumDuration: 0.1)
                        .onEnded { _ in
                            haptics.onSpeedChange()
                            videoState.enableSpeedScrubbing()
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            haptics.onSpeedChange()
                            videoState.disableSpeedScrubbing()
                        }
                )
            
            // 2x Speed Indicator
            if videoState.isScrubbingAt2x {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        SpeedIndicator()
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                            .transition(.opacity.combined(with: .scale))
                            .animation(.spring(response: 0.3), value: videoState.isScrubbingAt2x)
                    }
                }
            }
        }
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
