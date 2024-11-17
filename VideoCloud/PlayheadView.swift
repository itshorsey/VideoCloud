//
//  PlayheadView.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/16/24.
//

import SwiftUI

struct PlayheadStyle {
    static let touchTargetWidth: CGFloat = 44    // Touch target width
    static let lineWidth: CGFloat = 2            // Visual line width
    static let knobSize: CGFloat = 12            // Circular knob size
    static let lineHeight: CGFloat = 36          // Vertical line height
}

struct PlayheadView: View {
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // Circular knob
            Circle()
                .fill(Color.white)
                .frame(width: PlayheadStyle.knobSize, height: PlayheadStyle.knobSize)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            // Vertical line
            Rectangle()
                .fill(Color.white)
                .frame(width: PlayheadStyle.lineWidth, height: PlayheadStyle.lineHeight)
        }
        .frame(width: PlayheadStyle.touchTargetWidth)
    }
}

#Preview("Playhead Default") {
    PlayheadView(height: 8)
        .padding()
        .background(Color.black)
}
