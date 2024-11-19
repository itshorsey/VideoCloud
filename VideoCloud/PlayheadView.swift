//
//  PlayheadView.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/16/24.
//

import SwiftUI

struct PlayheadStyle {
    static let width: CGFloat = 2            // Line width
    static let height: CGFloat = 42          // Line height
    static let touchTargetWidth: CGFloat = 44    // Touch target width
}

struct PlayheadView: View {
    let height: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: PlayheadStyle.width, height: PlayheadStyle.height)
            .frame(width: PlayheadStyle.touchTargetWidth) // Wider touch target
    }
}

#Preview("Playhead Default") {
    PlayheadView(height: 8)
        .padding()
        .background(Color.black)
}
