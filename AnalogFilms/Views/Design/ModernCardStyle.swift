import SwiftUI

// MARK: - Modern Card Style

struct ModernCardStyle: ViewModifier {
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(
                        color: .black.opacity(0.1),
                        radius: isPressed ? 2 : 8,
                        x: 0,
                        y: isPressed ? 1 : 4
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
    }
}

// MARK: - Gradient Background

struct GradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.95, blue: 0.97),
                        Color(red: 0.98, green: 0.98, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
    }
}

// MARK: - Shimmer Effect

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.3),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 200
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    func modernCard(isPressed: Bool = false) -> some View {
        modifier(ModernCardStyle(isPressed: isPressed))
    }
    
    func gradientBackground() -> some View {
        modifier(GradientBackground())
    }
    
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}
