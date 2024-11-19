import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject private var videoState = VideoState()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Video Player
                VideoPlayerView(player: videoState.player, videoState: videoState)
                    .edgesIgnoringSafeArea(.all)
                
                // Controls Container
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Duration Label
                    DurationLabel(
                        currentTime: videoState.currentPlaybackTime,
                        duration: videoState.contentDuration,
                        isDragging: videoState.playbackState == .interacting,
                        useSolidFill: true
                    )
                    
                    // Timeline
                    TimelineView(videoState: videoState)
                    
                    // Refresh Button
                    Button(action: { videoState.loadRandomVideo() }) {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(hex: "746767"))
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .black.opacity(0),
                            .black.opacity(0.3),
                            .black.opacity(0.7)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Loading indicator
                if videoState.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        }
        .task {
            videoState.loadRandomVideo()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
