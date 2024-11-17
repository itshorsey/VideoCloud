//
//  TimelineInertia.swift
//  VideoCloud
//

import Foundation

class TimelineInertia {
    private var timer: Timer?
    private var normalizedVelocity: Double = 0  // Now represents percentage/sec
    private var contentDuration: Double = 0
    
    var onUpdate: ((Double) -> Void)?
    var onComplete: (() -> Void)?
    
    func start(initialVelocity: CGFloat, duration: Double, timelineWidth: CGFloat) {
        self.contentDuration = duration
        
        // Convert physical velocity to normalized velocity (percentage/sec)
        let velocityAsPercentage = (Double(initialVelocity) / Double(timelineWidth))
        normalizedVelocity = velocityAsPercentage * duration
        
        // Scale for natural feel (can adjust these multipliers)
        normalizedVelocity *= 2.0
        
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
        normalizedVelocity *= TimelineStyle.Inertia.decelerationRate
        
        // Calculate time change as percentage of total duration
        let percentageChange = normalizedVelocity * TimelineStyle.Inertia.inertiaUpdateInterval
        let timeChange = percentageChange
        
        onUpdate?(timeChange)
        
        // Stop when movement becomes negligible
        if abs(percentageChange) < (0.001 * contentDuration) {  // 0.1% of duration
            stop()
            onComplete?()
        }
    }
}
