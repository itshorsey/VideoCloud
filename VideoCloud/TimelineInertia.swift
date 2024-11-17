//
//  TimelineInertia.swift
//  VideoCloud
//

import Foundation

class TimelineInertia {
    private var timer: Timer?
    private var velocity: CGFloat = 0
    
    var onUpdate: ((Double) -> Void)?
    var onComplete: (() -> Void)?
    
    func start(initialVelocity: CGFloat) {
        velocity = initialVelocity
        
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
        velocity = 0
    }
    
    private func update() {
        velocity *= TimelineStyle.Inertia.decelerationRate
        
        let translation = velocity * TimelineStyle.Inertia.inertiaUpdateInterval
        let secondsPerPixel = 1.0 / Double(TimelineStyle.Animation.pixelsPerSecond)
        let timeChange = Double(translation) * secondsPerPixel
        
        onUpdate?(timeChange)
        
        if abs(velocity) < TimelineStyle.Inertia.minVelocityForInertia {
            stop()
            onComplete?()
        }
    }
}
