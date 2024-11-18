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
        HStack(spacing: 4) {
            Text(formatTime(currentTime))
            Text("|")
            Text(formatTime(duration))
        }
        .foregroundColor(.white)
        .padding(.horizontal, isDragging ? 16 : 8)
        .padding(.vertical, isDragging ? 8 : 4)
        .background(
            Group {
                if isDragging {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.8))
                        .overlay(
                            GeometryReader { geo in
                                Rectangle()
                                    .fill(Color.orange.opacity(0.3))
                                    .frame(width: geo.size.width * progress)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        )
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .animation(.spring(response: 0.3), value: isDragging)
    }
    
    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

