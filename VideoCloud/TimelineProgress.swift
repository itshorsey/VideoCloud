//
//  TimelineProgress.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/16/24.
//

import SwiftUI

struct TimelineProgress: View {
    let width: CGFloat
    let currentTime: Double
    let duration: Double
    
    private var progressWidth: CGFloat {
        CGFloat(currentTime) * TimelineStyle.Animation.pixelsPerSecond
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Base track (transparent)
            Rectangle()
                .fill(Color.clear)
                .frame(
                    width: max(width, width),
                    height: TimelineStyle.Layout.trackHeight
                )
            
            // Tick marks
            TimelineTicksView(width: max(width, width), duration: duration)
            
            // Progress indicator (white line with glow)
            Rectangle()
                .fill(Color.white)
                .frame(width: 2, height: TimelineStyle.Layout.trackHeight)
                .shadow(color: .white.opacity(0.3), radius: 2)
                .offset(x: progressWidth - 1) // Center the 2pt wide line
        }
    }
}
