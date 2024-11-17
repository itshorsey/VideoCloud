//
//  TimelineHaptics.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/16/24.
//

import SwiftUI

struct TimelineHaptics {
    private let dragStartFeedback = UIImpactFeedbackGenerator(style: .light)
    private let dragEndFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let boundaryFeedback = UIImpactFeedbackGenerator(style: .rigid)
    private let periodicFeedback = UIImpactFeedbackGenerator(style: .soft)
    
    func onDragStart() {
        dragStartFeedback.prepare()
        dragStartFeedback.impactOccurred()
    }
    
    func onDragEnd() {
        dragEndFeedback.prepare()
        dragEndFeedback.impactOccurred()
    }
    
    func onBoundaryReached() {
        boundaryFeedback.prepare()
        boundaryFeedback.impactOccurred()
    }
    
    func onPeriodicFeedback() {
        periodicFeedback.prepare()
        periodicFeedback.impactOccurred(intensity: 0.5)
    }
}
