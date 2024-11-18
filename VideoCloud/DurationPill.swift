//
//  DurationPill.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/17/24.
//

import SwiftUI

struct DurationPill: View {
    let currentTime: Double
    let duration: Double
    let isDragging: Bool
    
    private var formattedCurrentTime: String {
        formatTime(currentTime)
    }
    
    private var formattedDuration: String {
        formatTime(duration)
    }
    
    private var progress: CGFloat {
        duration > 0 ? CGFloat(currentTime / duration) : 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: DurationPillStyle.Layout.spacing) {
                Text(formattedCurrentTime)
                    .foregroundColor(DurationPillStyle.Colors.text)
                
                Text("/")
                    .foregroundColor(DurationPillStyle.Colors.separator)
                
                Text(formattedDuration)
                    .foregroundColor(DurationPillStyle.Colors.text)
            }
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, DurationPillStyle.Layout.horizontalPadding)
            .padding(.vertical, DurationPillStyle.Layout.verticalPadding)
            .frame(minWidth: DurationPillStyle.Layout.minWidth)
            .background(
                ZStack(alignment: .leading) {
                    DurationPillStyle.Colors.background
                    
                    if isDragging {
                        DurationPillStyle.Colors.progressFill
                            .frame(width: geometry.size.width * progress)
                    }
                }
            )
            .clipShape(Capsule())
            .animation(
                .spring(
                    response: DurationPillStyle.Animation.springResponse,
                    dampingFraction: DurationPillStyle.Animation.springDamping
                ),
                value: isDragging
            )
        }
        .frame(height: DurationPillStyle.Layout.height)
    }
    
    private func formatTime(_ timeInSeconds: Double) -> String {
        let hours = Int(timeInSeconds) / 3600
        let minutes = Int(timeInSeconds) / 60 % 60
        let seconds = Int(timeInSeconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DurationPill(currentTime: 65, duration: 180, isDragging: false)
        DurationPill(currentTime: 65, duration: 180, isDragging: true)
        DurationPill(currentTime: 3665, duration: 7200, isDragging: true)
    }
    .padding()
    .background(Color.gray)
}
