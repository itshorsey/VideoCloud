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
    @State private var showSpeedIndicator = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 32) {  // Increased spacing between elements
                    // Video Player
                    VideoPlayerView(
                        player: videoState.player,
                        videoState: videoState,
                        showSpeedIndicator: $showSpeedIndicator
                    )
                        .frame(
                            width: geometry.size.width * 0.9,
                            height: min(
                                geometry.size.width * 0.9 * 9/16,
                                geometry.size.height * 0.5
                            )
                        )
                        .cornerRadius(12)
                        .shadow(radius: 8)
                    
                    // Timeline
                    TimelineView(videoState: videoState)
                    
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
                
                // Speed indicator overlay
                if showSpeedIndicator {
                    SpeedIndicator()
                        .transition(.opacity)
                        .position(
                            x: geometry.size.width / 2,
                            y: min(
                                geometry.size.width * 0.9 * 9/16,
                                geometry.size.height * 0.5
                            ) + 60
                        )
                }
            }
        }
        .task {
            videoState.loadRandomVideo()
        }
    }
}

struct SpeedIndicator: View {
    var body: some View {
        ZStack {
            // Semi-transparent background fill
            Color.black.opacity(0.75)
            
            // Main indicator content
            HStack(spacing: 4) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 24))
                Text("2×")
                    .font(.system(size: 24, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .frame(width: 120, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
