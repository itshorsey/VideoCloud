struct VideoPlayerView: View {
    @StateObject private var viewModel: VideoPlayerViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Video player
                VideoPlayer(player: viewModel.player)
                    .edgesIgnoringSafeArea(.all)
                
                // Overlay controls
                VStack {
                    // Top duration label
                    Text(viewModel.durationText)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // Bottom controls
                    HStack(spacing: 24) {
                        Button(action: {
                            viewModel.togglePlayback()
                        }) {
                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        }
                        
                        Button(action: {
                            viewModel.refreshVideo()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                                .font(.system(size: 24))
                        }
                    }
                    .padding(.bottom, 40)
                }
                .edgesIgnoringSafeArea(.top)
            }
        }
    }
} 