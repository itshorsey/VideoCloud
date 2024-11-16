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
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Video Player
                VideoPlayerView(player: videoState.player)
                    .frame(height: UIScreen.main.bounds.height * 0.4)
                    .cornerRadius(12)
                    .shadow(radius: 8)
                    .padding(.horizontal)
                
                // Timeline
                TimelineView(videoState: videoState)
                    .padding(.horizontal)
                
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
                .padding()
                
                if videoState.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                
                Spacer()
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
