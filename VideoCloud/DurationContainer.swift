//
//  DurationContainer.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/17/24.
//

import SwiftUI

struct DurationContainer: View {
    @ObservedObject var videoState: VideoState
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                DurationPill(
                    currentTime: videoState.currentPlaybackTime,
                    duration: videoState.contentDuration,
                    isDragging: videoState.playbackState == .interacting
                )
                .padding(.top, 16)
                .padding(.trailing, 16)
            }
            Spacer()
        }
    }
}

#Preview {
    DurationContainer(videoState: VideoState())
        .frame(width: 400, height: 300)
        .background(Color.black.opacity(0.5))
}
