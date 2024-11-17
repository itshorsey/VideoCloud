//
//  TimelineView.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/16/24.
//

import SwiftUI

struct TimelineStyle {
    // Existing styling
    static let height: CGFloat = 84
    static let trackHeight: CGFloat = 36
    static let trackColor = Color.gray.opacity(0.3)
    static let progressColor = Color.orange
    static let pixelsPerSecond: CGFloat = 50
    static let horizontalPadding: CGFloat = 20
    
    // Inertia parameters
    static let minimumVelocityForInertia: CGFloat = 100  // Minimum velocity to trigger inertia
    static let decelerationRate: CGFloat = 0.95         // How quickly velocity decreases (0-1)
    static let inertiaUpdateInterval: TimeInterval = 1/60 // 60fps updates
    
    // Animation
    static let playbackAnimation = Animation.linear(duration: 0.05)
    static let dragEndAnimation = Animation.spring(
        response: 0.3,
        dampingFraction: 0.7,
        blendDuration: 0.1
    )
}

struct TimelineView: View {
    @ObservedObject var videoState: VideoState
    @State private var isDragging = false
    @State private var dragStartTime: Double = 0
    @State private var lastDragLocation: CGFloat = 0
    @State private var lastUpdateTime: Date = Date()
    @State private var velocity: CGFloat = 0
    @State private var inertiaTimer: Timer?
    @State private var playheadScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let totalTimelineWidth = CGFloat(videoState.contentDuration) * TimelineStyle.pixelsPerSecond
            
            ZStack(alignment: .leading) {
                // Timeline container
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
                .frame(height: TimelineStyle.height)
                
                // Centered playhead
                PlayheadView(height: TimelineStyle.trackHeight)
                    .position(x: viewWidth / 2, y: TimelineStyle.height / 2)
                    .scaleEffect(playheadScale)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDragChange(value)
                    }
                    .onEnded { value in
                        handleDragEnd(value)
                    }
            )
            .clipped()
        }
        .frame(height: TimelineStyle.height)
        .padding(.horizontal, TimelineStyle.horizontalPadding)
        .animation(
            videoState.playbackState == .playing ? TimelineStyle.playbackAnimation :
            isDragging ? nil : TimelineStyle.dragEndAnimation,
            value: videoState.currentPlaybackTime
        )
    }
    
    private func handleDragChange(_ value: DragGesture.Value) {
        // Stop any ongoing inertia
        stopInertia()
        
        if !isDragging {
            isDragging = true
            dragStartTime = videoState.currentPlaybackTime
            lastDragLocation = value.location.x
            lastUpdateTime = Date()
            videoState.setPlaybackState(.interacting)
            
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        } else {
            let translation = lastDragLocation - value.location.x
            
            // Calculate velocity
            let currentTime = Date()
            let timeDelta = currentTime.timeIntervalSince(lastUpdateTime)
            velocity = CGFloat(translation / CGFloat(timeDelta))
            
            lastDragLocation = value.location.x
            lastUpdateTime = currentTime
            
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
    
    private func handleDragEnd(_ value: DragGesture.Value) {
        isDragging = false
        
        // Only start inertia if velocity is high enough
        if abs(velocity) > TimelineStyle.minimumVelocityForInertia {
            startInertia()
        } else {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            if case .interacting = videoState.playbackState {
                videoState.setPlaybackState(.playing)
            }
        }
    }
    
    private func startInertia() {
        // Create a timer for inertia updates
        inertiaTimer = Timer.scheduledTimer(withTimeInterval: TimelineStyle.inertiaUpdateInterval, repeats: true) { timer in
            updateInertia()
        }
    }
    
    private func updateInertia() {
        // Apply deceleration
        velocity *= TimelineStyle.decelerationRate
        
        // Calculate time change based on velocity
        let secondsPerPixel = 1.0 / Double(TimelineStyle.pixelsPerSecond)
        let timeChange = Double(velocity * CGFloat(TimelineStyle.inertiaUpdateInterval)) * secondsPerPixel
        
        // Update position
        let newTime = max(0, min(
            videoState.contentDuration,
            videoState.currentPlaybackTime + timeChange
        ))
        
        videoState.currentPlaybackTime = newTime
        videoState.previewSeek(to: newTime)
        
        // Stop inertia if velocity is very low or we hit the bounds
        if abs(velocity) < 1 || newTime <= 0 || newTime >= videoState.contentDuration {
            stopInertia()
            
            if case .interacting = videoState.playbackState {
                videoState.setPlaybackState(.playing)
            }
            
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }
    
    private func stopInertia() {
        inertiaTimer?.invalidate()
        inertiaTimer = nil
        velocity = 0
    }
    
    private func calculateOffset(viewWidth: CGFloat, timelineWidth: CGFloat) -> CGFloat {
        let startPosition = viewWidth / 2
        let currentPosition = CGFloat(videoState.currentPlaybackTime) * TimelineStyle.pixelsPerSecond
        return startPosition - currentPosition
    }
}

#Preview("Timeline") {
    TimelineView(videoState: VideoState())
        .frame(width: 300)
        .background(Color.black)
}
