//
//  PlayheadView.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/16/24.
//

import SwiftUI

struct PlayheadView: View {
    let height: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: 2, height: height)
    }
}

#Preview("Playhead Default") {
    PlayheadView(height: 8)
        .padding()
        .background(Color.black)
}

#Preview("Playhead Taller") {
    PlayheadView(height: 16)
        .padding()
        .background(Color.black)
}
