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
    
    var body: some View {
        HStack(spacing: 4) {
            Text(formatTime(currentTime))
            Text("|")
            Text(formatTime(duration))
        }
        .foregroundColor(isDragging ? .black : .white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isDragging ? .white : .clear)
        .animation(.spring(response: 0.3), value: isDragging)
    }
    
    private func formatTime(_ timeInSeconds: Double) -> String {
        let minutes = Int(timeInSeconds) / 60
        let seconds = Int(timeInSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}



#Preview {
    VStack(spacing: 20) {
        DurationLabel(currentTime: 130, duration: 300, isDragging: false, useSolidFill: true)
        DurationLabel(currentTime: 130, duration: 300, isDragging: true, useSolidFill: true)
        DurationLabel(currentTime: 130, duration: 300, isDragging: true, useSolidFill: false)
    }
    .padding()
    .background(Color.gray)
}

