//
//  TimelineStyle.swift
//  VideoCloud
//

import SwiftUI

enum TimelineStyle {
    enum Layout {
        static let height: CGFloat = 84
        static let trackHeight: CGFloat = 40
        static let horizontalPadding: CGFloat = 20
    }
    
    enum Colors {
        static let trackColor = Color.gray.opacity(0.3)
        static let progressColor = Color.orange
    }
    
    enum Animation {
        static let pixelsPerSecond: CGFloat = 75
    }
    
    enum Inertia {
        static let minVelocityForInertia: CGFloat = 50
        static let decelerationRate: CGFloat = 0.92
        static let inertiaUpdateInterval = 1.0 / 60.0
        static let dragVelocityMultiplier: CGFloat = 8.0
    }
    
    enum Haptics {
        static let periodicFeedbackInterval: Double = 5.0
    }
}
