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
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
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
                            videoState.enableSpeedScrubbing()
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            videoState.disableSpeedScrubbing()
                        }
                )
            
            if videoState.isScrubbingAt2x {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        SpeedIndicator()
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                            .transition(.opacity)
                    }
                }
            }
        }
    }
}

#Preview {
    VideoPlayerView(player: AVPlayer(), videoState: VideoState())
        .frame(height: 300)
        .padding()
        .background(Color.black)
}
