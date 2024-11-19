//
//  TimelineView.swift
//  VideoCloud
//

import SwiftUI

struct TimelineView: View {
    @ObservedObject var videoState: VideoState
    @State private var isDragging = false
    @State private var dragStartTime: Double = 0
    @State private var lastDragLocation: CGFloat = 0
    @State private var lastUpdateTime = Date()
    @State private var wasPlayingBeforeDrag = false
    @State private var lastHapticTime: Double = 0
    
    private let haptics = TimelineHaptics()
    private let inertia = TimelineInertia()
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let totalTimelineWidth = CGFloat(videoState.contentDuration) * TimelineStyle.Animation.pixelsPerSecond
            
            ZStack(alignment: .leading) {
                // Timeline container with progress
                TimelineProgress(
                    width: max(totalTimelineWidth, viewWidth),
                    currentTime: videoState.currentPlaybackTime,
                    duration: videoState.contentDuration
                )
                .offset(x: calculateOffset(
                    viewWidth: viewWidth,
                    timelineWidth: totalTimelineWidth
                ))
                .frame(height: TimelineStyle.Layout.height)
                
                // Centered playhead
                PlayheadView(height: TimelineStyle.Layout.trackHeight)
                    .position(x: viewWidth / 2, y: TimelineStyle.Layout.height / 2)
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
        .frame(height: TimelineStyle.Layout.height)
        .padding(.horizontal, TimelineStyle.Layout.horizontalPadding)
        .animation(
            videoState.playbackState == .playing ?
                .linear(duration: 0.05) :
                .easeOut(duration: 0.2),
            value: videoState.currentPlaybackTime
        )
        .onAppear {
            setupInertia()
        }
    }
    
    private func setupInertia() {
        inertia.onUpdate = { timeChange in
            let newTime = max(0, min(
                videoState.contentDuration,
                videoState.currentPlaybackTime + timeChange
            ))
            
            if newTime == 0 || newTime == videoState.contentDuration {
                haptics.onBoundaryReached()
            }
            
            providePeriodicHapticFeedback(currentTime: newTime)
            
            videoState.currentPlaybackTime = newTime
            videoState.previewSeek(to: newTime)
        }
        
        inertia.onComplete = {
            completeGesture()
        }
    }
    
    private func calculateOffset(viewWidth: CGFloat, timelineWidth: CGFloat) -> CGFloat {
        let startPosition = viewWidth / 2
        let currentPosition = CGFloat(videoState.currentPlaybackTime) * TimelineStyle.Animation.pixelsPerSecond
        return startPosition - currentPosition
    }
    
    private func providePeriodicHapticFeedback(currentTime: Double) {
        if abs(currentTime - lastHapticTime) >= TimelineStyle.Haptics.periodicFeedbackInterval {
            haptics.onPeriodicFeedback()
            lastHapticTime = currentTime
        }
    }
    
    private func handleDragChange(_ value: DragGesture.Value) {
        if !isDragging {
            isDragging = true
            dragStartTime = videoState.currentPlaybackTime
            lastDragLocation = value.location.x
            lastUpdateTime = Date()
            lastHapticTime = videoState.currentPlaybackTime
            
            wasPlayingBeforeDrag = videoState.isPlaying
            videoState.setPlaybackState(.interacting)
            
            haptics.onDragStart()
        } else {
            let translation = lastDragLocation - value.location.x
            
            let currentTime = Date()
            let timeDelta = currentTime.timeIntervalSince(lastUpdateTime)
            if timeDelta > 0 {
                // Apply the multiplier to the translation for adjusted drag speed
                let adjustedTranslation = translation * TimelineStyle.Inertia.dragVelocityMultiplier
                let velocity = adjustedTranslation / CGFloat(timeDelta)
                
                lastDragLocation = value.location.x
                lastUpdateTime = currentTime
                
                let secondsPerPixel = 1.0 / Double(TimelineStyle.Animation.pixelsPerSecond)
                let timeChange = Double(adjustedTranslation) * secondsPerPixel
                
                let newTime = max(0, min(
                    videoState.contentDuration,
                    videoState.currentPlaybackTime + timeChange
                ))
                
                if newTime == 0 || newTime == videoState.contentDuration {
                    haptics.onBoundaryReached()
                }
                
                providePeriodicHapticFeedback(currentTime: newTime)
                
                videoState.currentPlaybackTime = newTime
                videoState.previewSeek(to: newTime)
            }
        }
    }
    
    private func handleDragEnd(_ value: DragGesture.Value) {
        isDragging = false
        
        let endTime = Date()
        let timeDelta = endTime.timeIntervalSince(lastUpdateTime)
        if timeDelta > 0 {
            let translation = value.location.x - lastDragLocation
            let velocity = (translation / CGFloat(timeDelta)) * TimelineStyle.Inertia.dragVelocityMultiplier
            
            // Calculate total timeline width
            let totalTimelineWidth = CGFloat(videoState.contentDuration) * TimelineStyle.Animation.pixelsPerSecond
            
            if abs(velocity) > TimelineStyle.Inertia.minVelocityForInertia {
                inertia.start(
                    initialVelocity: -velocity,
                    duration: videoState.contentDuration,
                    timelineWidth: totalTimelineWidth
                )
            } else {
                completeGesture()
            }
        }
        
        haptics.onDragEnd()
    }
    
    private func completeGesture() {
        if wasPlayingBeforeDrag {
            videoState.setPlaybackState(.playing)
        } else {
            videoState.setPlaybackState(.paused)
        }
        inertia.stop()
    }
}
