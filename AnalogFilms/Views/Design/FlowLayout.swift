import SwiftUI

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions(by: CGSize(width: 10000, height: 10000)),
            subviews: subviews,
            spacing: spacing
        )
        return result.bounds
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions(by: bounds.size),
            subviews: subviews,
            spacing: spacing
        )
        
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(
                    x: bounds.minX + result.frames[index].minX,
                    y: bounds.minY + result.frames[index].minY
                ),
                proposal: ProposedViewSize(result.frames[index].size)
            )
        }
    }
}

struct FlowResult {
    let bounds: CGSize
    let frames: [CGRect]
    
    init(in container: CGSize, subviews: LayoutSubviews, spacing: CGFloat) {
        var frames: [CGRect] = []
        var currentRow = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            
            // Check if we need to wrap to the next row
            if currentX + subviewSize.width > container.width && currentX > 0 {
                currentRow += 1
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            
            // Place the subview
            frames.append(CGRect(
                x: currentX,
                y: currentY,
                width: subviewSize.width,
                height: subviewSize.height
            ))
            
            // Update position for next subview
            currentX += subviewSize.width + spacing
            rowHeight = max(rowHeight, subviewSize.height)
        }
        
        self.frames = frames
        self.bounds = CGSize(
            width: container.width,
            height: currentY + rowHeight
        )
    }
}

// MARK: - Preview

#Preview {
    FlowLayout(spacing: 8) {
        ForEach(["135", "120", "4x5", "8x10", "11x14"], id: \.self) { type in
            Text(type)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.gray.opacity(0.2)))
        }
        
        Text("Color negative")
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.blue.opacity(0.2)))
    }
    .padding()
}