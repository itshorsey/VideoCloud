//
//  TimelineInertia.swift
//  VideoCloud
//

import Foundation

class TimelineInertia {
    private var timer: Timer?
    private var normalizedVelocity: Double = 0
    private var contentDuration: Double = 0
    private var currentTime: Double = 0
    
    var onUpdate: ((Double) -> Void)?
    var onComplete: (() -> Void)?
    
    func start(initialVelocity: CGFloat, duration: Double, timelineWidth: CGFloat) {
        self.contentDuration = duration
        
        // Convert physical velocity to normalized velocity (percentage/sec)
        let velocityAsPercentage = (Double(initialVelocity) / Double(timelineWidth))
        normalizedVelocity = velocityAsPercentage * duration
        
        // More aggressive scaling for shorter videos
        let durationScale = max(2.0, min(5.0, 20.0 / duration))
        normalizedVelocity *= 5.0 * durationScale  // Increased base multiplier
        
        timer = Timer.scheduledTimer(
            withTimeInterval: TimelineStyle.Inertia.inertiaUpdateInterval,
            repeats: true
        ) { [weak self] _ in
            self?.update()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        normalizedVelocity = 0
    }
    
    private func update() {
        // Adaptive deceleration based on remaining distance to bounds
        let distanceToEnd = max(0, contentDuration - currentTime)
        let distanceToStart = currentTime
        let minDistance = min(distanceToEnd, distanceToStart)
        
        // Increase deceleration when approaching boundaries
        let adaptiveDeceleration = minDistance < (contentDuration * 0.1) 
            ? TimelineStyle.Inertia.decelerationRate * 0.8  // Faster deceleration near bounds
            : TimelineStyle.Inertia.decelerationRate
        
        normalizedVelocity *= adaptiveDeceleration
        
        // Calculate time change as percentage of total duration
        let percentageChange = normalizedVelocity * TimelineStyle.Inertia.inertiaUpdateInterval
        let timeChange = percentageChange
        
        currentTime += timeChange
        onUpdate?(timeChange)
        
        // Stop when movement becomes negligible
        let stopThreshold = 0.001 * contentDuration
        if abs(percentageChange) < stopThreshold {
            stop()
            onComplete?()
        }
    }
}
