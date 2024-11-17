//
//  VideoPlayerView.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/16/24.
//

import SwiftUI
import AVFoundation

struct VideoPlayerView: View {
    let player: AVPlayer
    @ObservedObject var videoState: VideoState
    @Binding var showSpeedIndicator: Bool
    
    var body: some View {
        ZStack {
            VideoLayerView(player: player)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .contentShape(Rectangle())
        .gesture(
            LongPressGesture(minimumDuration: 0.3)
                .onChanged { _ in
                    print("Long press started")
                    videoState.setPlaybackSpeed(true)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSpeedIndicator = true
                    }
                }
                .onEnded { _ in
                    print("Long press ended")
                    videoState.setPlaybackSpeed(false)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSpeedIndicator = false
                    }
                }
        )
        .onDisappear {
            player.pause()
            player.replaceCurrentItem(with: nil)
        }
    }
}

// UIViewRepresentable wrapper for AVPlayerLayer
struct VideoLayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerUIView {
        return PlayerUIView(player: player)
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        uiView.updatePlayer(player)
    }
}

// Custom UIView to handle AVPlayerLayer
class PlayerUIView: UIView {
    private var playerLayer: AVPlayerLayer?
    
    init(player: AVPlayer) {
        super.init(frame: .zero)
        setupPlayer(player)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPlayer(_ player: AVPlayer) {
        // Remove existing player layer if any
        playerLayer?.removeFromSuperlayer()
        
        // Create and configure new player layer
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        layer.frame = bounds
        self.layer.addSublayer(layer)
        self.playerLayer = layer
    }
    
    func updatePlayer(_ player: AVPlayer) {
        playerLayer?.player = player
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(
            player: AVPlayer(),
            videoState: VideoState(),
            showSpeedIndicator: .constant(false)
        )
            .frame(height: 300)
            .padding()
    }
}
