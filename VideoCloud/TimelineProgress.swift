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
        Rectangle()
            .fill(TimelineStyle.Colors.trackColor)
            .frame(
                width: max(width, width),
                height: TimelineStyle.Layout.trackHeight
            )
            .overlay(
                Rectangle()
                    .fill(TimelineStyle.Colors.progressColor)
                    .frame(width: progressWidth),
                alignment: .leading
            )
    }
}
