//
//  VideoPlayerView.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/16/24.
//

import SwiftUI
import AVKit

/// Custom video player view that wraps AVKit's VideoPlayer
struct VideoPlayerView: View {
    let player: AVPlayer
    
    var body: some View {
        VideoPlayer(player: player)
            .onDisappear {
                // Ensure cleanup when view disappears
                player.pause()
                player.replaceCurrentItem(with: nil)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(player: AVPlayer())
            .frame(height: 300)
            .padding()
    }
}
