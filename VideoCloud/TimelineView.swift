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
    private let pixelsPerSecond: CGFloat = 50
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let totalTimelineWidth = CGFloat(videoState.contentDuration) * pixelsPerSecond
            
            ZStack {
                // Timeline container
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(timelineColor)
                        .frame(width: max(totalTimelineWidth, viewWidth), height: timelineHeight)
                        .overlay(
                            Rectangle()
                                .fill(progressColor)
                                .frame(
                                    width: CGFloat(videoState.currentPlaybackTime) * pixelsPerSecond
                                ),
                            alignment: .leading
                        )
                        .offset(x: calculateOffset(
                            viewWidth: viewWidth,
                            timelineWidth: totalTimelineWidth,
                            pixelsPerSecond: pixelsPerSecond
                        ))
                        .animation(
                            videoState.playbackState == .playing ?
                                .linear(duration: 0.05) :
                                .easeOut(duration: 0.2),
                            value: videoState.currentPlaybackTime
                        )
                }
                
                // Centered playhead
                PlayheadView(height: timelineHeight * 2)
                    .position(x: viewWidth / 2, y: timelineHeight / 2)
            }
            .clipped()
        }
        .frame(height: timelineHeight)
        .padding(.vertical, 20)
    }
    
    private func calculateOffset(viewWidth: CGFloat, timelineWidth: CGFloat, pixelsPerSecond: CGFloat) -> CGFloat {
        let startPosition = viewWidth / 2  // Always start at center
        let currentPosition = CGFloat(videoState.currentPlaybackTime) * pixelsPerSecond
        
        // For all videos, ensure the timeline starts at center position
        return startPosition - currentPosition
    }
}

// Keep existing preview helpers and previews as is
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

#Preview("Timeline - Start") {
    TimelineView(videoState: .previewState())
        .frame(width: 300)
        .padding()
        .background(Color.black)
}

#Preview("Timeline - Middle (50%)") {
    TimelineView(videoState: .previewState(currentTime: 30.0))
        .frame(width: 300)
        .padding()
        .background(Color.black)
}

#Preview("Timeline - Near End (90%)") {
    TimelineView(videoState: .previewState(currentTime: 54.0))
        .frame(width: 300)
        .padding()
        .background(Color.black)
}

#Preview("Timeline - End (100%)") {
    TimelineView(videoState: .previewState(currentTime: 60.0))
        .frame(width: 300)
        .padding()
        .background(Color.black)
}

#Preview("Timeline - Playing") {
    TimelineView(videoState: .previewState(currentTime: 15.0, playbackState: .playing))
        .frame(width: 300)
        .padding()
        .background(Color.black)
}
