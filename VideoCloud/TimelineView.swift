//
//  TimelineView.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/16/24.
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject var videoState: VideoState
    
    // Constants for timeline appearance
    private let timelineHeight: CGFloat = 4
    private let timelineColor = Color.gray.opacity(0.3)
    private let progressColor = Color.orange
    private let centerLineColor = Color.white
    private let centerLineWidth: CGFloat = 2
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let totalTimelineWidth = viewWidth * 3
            
            ZStack {
                // Container for timeline that allows horizontal movement
                HStack(spacing: 0) {
                    // Background timeline
                    Rectangle()
                        .fill(timelineColor)
                        .frame(width: totalTimelineWidth, height: timelineHeight)
                    
                    // Progress overlay (orange portion)
                        .overlay(
                            Rectangle()
                                .fill(progressColor)
                                .frame(
                                    width: calculateProgressWidth(
                                        totalWidth: totalTimelineWidth
                                    )
                                ),
                            alignment: .leading
                        )
                        // Calculate offset based on playback progress
                        .offset(x: calculateTimelineOffset(
                            viewWidth: viewWidth,
                            totalWidth: totalTimelineWidth
                        ))
                        // Animate timeline movement during playback
                        .animation(
                            videoState.playbackState == .playing ?
                                .linear(duration: 0.05) :
                                .easeOut(duration: 0.2),
                            value: videoState.currentPlaybackTime
                        )
                }
                
                // Center line (playhead position marker) - always centered
                Rectangle()
                    .fill(centerLineColor)
                    .frame(width: centerLineWidth, height: timelineHeight * 2)
                    .position(x: viewWidth / 2, y: timelineHeight / 2)
            }
            .clipped() // Prevent timeline from showing outside bounds
        }
        .frame(height: timelineHeight)
        .padding(.vertical, 20) // Touch area padding
    }
    
    /// Calculates the width of the orange progress indicator
    private func calculateProgressWidth(totalWidth: CGFloat) -> CGFloat {
        guard videoState.contentDuration > 0 else { return 0 }
        
        let progress = videoState.currentPlaybackTime / videoState.contentDuration
        return totalWidth * CGFloat(progress)
    }
    
    /// Calculates the timeline's offset to keep playhead centered while content moves left
    private func calculateTimelineOffset(viewWidth: CGFloat, totalWidth: CGFloat) -> CGFloat {
        guard videoState.contentDuration > 0 else {
            // When no video is loaded, align start of timeline with center
            return viewWidth / 2
        }
        
        let progress = videoState.currentPlaybackTime / videoState.contentDuration
        
        // Start offset is viewWidth/2 (to center start of timeline)
        // As progress increases, shift timeline left
        let startOffset = viewWidth / 2
        let progressOffset = progress * (totalWidth - viewWidth)
        
        return startOffset - progressOffset
    }
}

// MARK: - Preview Helpers
extension VideoState {
    static func previewState(
        duration: Double = 60.0,
        currentTime: Double = 0.0,
        playbackState: PlaybackState = .paused
    ) -> VideoState {
        let state = VideoState()
        state.contentDuration = duration
        state.currentPlaybackTime = currentTime
        state.playbackState = playbackState
        return state
    }
}

#Preview("Timeline - Playing (25%)") {
    TimelineView(videoState: .previewState(currentTime: 15.0, playbackState: .playing))
        .frame(width: 300)
        .padding()
        .background(Color.black)
}

#Preview("Timeline - Paused (50%)") {
    TimelineView(videoState: .previewState(currentTime: 30.0, playbackState: .paused))
        .frame(width: 300)
        .padding()
        .background(Color.black)
}

#Preview("Timeline - Near End (90%)") {
    TimelineView(videoState: .previewState(currentTime: 54.0, playbackState: .paused))
        .frame(width: 300)
        .padding()
        .background(Color.black)
}

#Preview("Timeline - Start") {
    TimelineView(videoState: .previewState())
        .frame(width: 300)
        .padding()
        .background(Color.black)
}

#Preview("Timeline - End") {
    TimelineView(videoState: .previewState(currentTime: 60.0))
        .frame(width: 300)
        .padding()
        .background(Color.black)
}
