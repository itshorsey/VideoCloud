//
//  ContentView.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/16/24.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject private var videoState = VideoState()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 32) {  // Increased spacing between elements
                    // Video Player
                    VideoPlayerView(player: videoState.player)
                        .frame(
                            width: geometry.size.width * 0.9,
                            height: min(
                                geometry.size.width * 0.9 * 9/16,
                                geometry.size.height * 0.5
                            )
                        )
                        .cornerRadius(12)
                        .shadow(radius: 8)
                    
                    // Timeline - Remove extra padding/constraints
                    TimelineView(videoState: videoState)
                    // TimelineView now handles its own padding
                    
                    // Controls
                    HStack(spacing: 40) {
                        // Play/Pause Toggle Button
                        Button(action: {
                            videoState.togglePlayback()
                        }) {
                            Image(systemName: videoState.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                                .foregroundColor(.white)
                        }
                        
                        // Refresh Button
                        Button(action: {
                            videoState.loadRandomVideo()
                        }) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 44, height: 44)
                                .foregroundColor(.white)
                        }
                    }
                    
                    if videoState.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    }
                    
                    Spacer()
                }
                .padding(.top, geometry.safeAreaInsets.top)
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
