import SwiftUI

struct TimelineTicksView: View {
    let width: CGFloat
    let duration: Double
    
    private let tickSpacing: CGFloat = 15  // Fixed spacing between all ticks
    private let minorTicksPerSecond: Int = 4  // Number of minor ticks between second markers
    
    var body: some View {
        Canvas { context, size in
            let numberOfTicks = Int(width / tickSpacing) + 1
            
            for i in 0..<numberOfTicks {
                let x = CGFloat(i) * tickSpacing
                let isSecondMark = i % (minorTicksPerSecond + 1) == 0
                
                let tickPath = Path { path in
                    let tickHeight = isSecondMark ? 20.0 : 10.0
                    let yOffset = (TimelineStyle.Layout.trackHeight - tickHeight) / 2
                    
                    path.addRoundedRect(
                        in: CGRect(
                            x: x - 1, // Center the 2pt wide tick
                            y: yOffset,
                            width: 2,
                            height: tickHeight
                        ),
                        cornerSize: CGSize(width: 1, height: 1)
                    )
                }
                
                context.fill(
                    tickPath,
                    with: .color(.white.opacity(isSecondMark ? 1.0 : 1.0))
                )
            }
        }
        .frame(width: width, height: TimelineStyle.Layout.trackHeight)
    }
} 