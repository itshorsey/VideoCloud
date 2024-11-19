//
//  DurationLabel.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/17/24.
//

import SwiftUI

struct DurationLabel: View {
    let currentTime: Double
    let duration: Double
    let isDragging: Bool
    let useSolidFill: Bool
    
    private var progress: CGFloat {
        duration > 0 ? CGFloat(currentTime / duration) : 0
    }
    
    var body: some View {
        HStack(spacing: DurationLabelStyle.Layout.spacing) {
            Text(formatTime(currentTime))
                .font(DurationLabelStyle.Typography.font)
                .foregroundColor(DurationLabelStyle.Typography.color)
            
            Text("/")
                .font(DurationLabelStyle.Typography.font)
                .foregroundColor(DurationLabelStyle.Typography.color.opacity(0.5))
            
            Text(formatTime(duration))
                .font(DurationLabelStyle.Typography.font)
                .foregroundColor(DurationLabelStyle.Typography.color)
        }
        .padding(.horizontal, DurationLabelStyle.Layout.horizontalPadding)
        .padding(.vertical, DurationLabelStyle.Layout.verticalPadding)
        .background(
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    DurationLabelStyle.Colors.background
                        .blendMode(.colorBurn)
                    
                    if isDragging {
                        Rectangle()
                            .fill(Color.orange.opacity(0.3))
                            .frame(width: geo.size.width * progress)
                    }
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: DurationLabelStyle.Layout.cornerRadius))
        .animation(.spring(response: 0.3), value: isDragging)
    }
    
    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

