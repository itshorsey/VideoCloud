//
//  TimelineStyle.swift
//  VideoCloud
//

import SwiftUI

enum TimelineStyle {
    enum Layout {
        static let height: CGFloat = 84
        static let trackHeight: CGFloat = 36
        static let horizontalPadding: CGFloat = 20
    }
    
    enum Colors {
        static let trackColor = Color.gray.opacity(0.3)
        static let progressColor = Color.orange
    }
    
    enum Animation {
        static let pixelsPerSecond: CGFloat = 50
    }
    
    enum Inertia {
        static let minVelocityForInertia: CGFloat = 200
        static let decelerationRate: CGFloat = 0.85
        static let inertiaUpdateInterval = 1.0 / 60.0
        static let dragVelocityMultiplier: CGFloat = 1.5  // Added this constant
    }
    
    enum Haptics {
        static let periodicFeedbackInterval: Double = 5.0
    }
}
