//
//  DurationPillStyle.swift
//  VideoCloud
//
//  Created by Jonathan Horsman on 11/17/24.
//

import SwiftUI

enum DurationPillStyle {
    enum Layout {
        static let height: CGFloat = 28
        static let minWidth: CGFloat = 80
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 6
        static let cornerRadius: CGFloat = 14
        static let spacing: CGFloat = 4
    }
    
    enum Colors {
        static let background = Color.black.opacity(0.75)
        static let text = Color.white
        static let separator = Color.white.opacity(0.3)
        static let progressFill = Color.white.opacity(0.2)
    }
    
    enum Animation {
        static let duration = 0.3
        static let springResponse = 0.4
        static let springDamping = 0.8
    }
}
