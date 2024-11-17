//
//  TimelineView.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/16/24.
//

import SwiftUI

struct TimelineStyle {
    // Timeline
    static let height: CGFloat = 84               // Minimum touch target height
    static let trackHeight: CGFloat = 36           // Actual visible track height
    static let trackColor = Color.gray.opacity(0.3)
    static let progressColor = Color.orange
    static let pixelsPerSecond: CGFloat = 50
    
    // Layout
    static let horizontalPadding: CGFloat = 20
}

struct TimelineView: View {
    @ObservedObject var videoState: VideoState
    @State private var isDragging = false
    @State private var dragStartTime: Double = 0
    @State private var lastDragLocation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let totalTimelineWidth = CGFloat(videoState.contentDuration) * TimelineStyle.pixelsPerSecond
            
            ZStack(alignment: .leading) {
                // Timeline container - center vertically in the touch target area
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(TimelineStyle.trackColor)
                        .frame(
                            width: max(totalTimelineWidth, viewWidth),
                            height: TimelineStyle.trackHeight
                        )
                        .overlay(
                            Rectangle()
                                .fill(TimelineStyle.progressColor)
                                .frame(
                                    width: CGFloat(videoState.currentPlaybackTime) * TimelineStyle.pixelsPerSecond
                                ),
                            alignment: .leading
                        )
                        .offset(x: calculateOffset(
                            viewWidth: viewWidth,
                            timelineWidth: totalTimelineWidth
                        ))
                }
                .frame(height: TimelineStyle.height) // Set full touch target height
                
                // Centered playhead - now just visual, no gesture handling
                PlayheadView(height: TimelineStyle.trackHeight)
                    .position(x: viewWidth / 2, y: TimelineStyle.height / 2)
            }
            .contentShape(Rectangle()) // Make entire area draggable
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            dragStartTime = videoState.currentPlaybackTime
                            lastDragLocation = value.location.x
                            videoState.setPlaybackState(.interacting)
                            
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        } else {
                            // Only calculate movement from the last drag position
                            let translation = lastDragLocation - value.location.x
                            lastDragLocation = value.location.x
                            
                            let secondsPerPixel = 1.0 / Double(TimelineStyle.pixelsPerSecond)
                            let timeChange = Double(translation) * secondsPerPixel
                            
                            let newTime = max(0, min(
                                videoState.contentDuration,
                                videoState.currentPlaybackTime + timeChange
                            ))
                            
                            videoState.currentPlaybackTime = newTime
                            videoState.previewSeek(to: newTime)
                        }
                    }
                    .onEnded { _ in
                        isDragging = false
                        lastDragLocation = 0
                        
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        
                        if case .interacting = videoState.playbackState {
                            videoState.setPlaybackState(.playing)
                        }
                    }
            )
            .clipped()
        }
        .frame(height: TimelineStyle.height)
        .padding(.horizontal, TimelineStyle.horizontalPadding)
        .animation(
            videoState.playbackState == .playing ?
                .linear(duration: 0.05) :
                .easeOut(duration: 0.2),
            value: videoState.currentPlaybackTime
        )
    }
    
    private func calculateOffset(viewWidth: CGFloat, timelineWidth: CGFloat) -> CGFloat {
        let startPosition = viewWidth / 2  // Always start at center
        let currentPosition = CGFloat(videoState.currentPlaybackTime) * TimelineStyle.pixelsPerSecond
        return startPosition - currentPosition
    }
}

#Preview("Timeline") {
    TimelineView(videoState: VideoState())
        .frame(width: 300)
        .background(Color.black)
}
