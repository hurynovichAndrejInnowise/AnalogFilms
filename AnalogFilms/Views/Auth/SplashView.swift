import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var rotationAngle: Double = 0
    @State private var circleScale: CGFloat = 0
    @State private var particlesOpacity: Double = 0
    @State private var logoOffset: CGFloat = 0
    @State private var gradientRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var waveOffset: CGFloat = 0
    @State private var morphScale: CGFloat = 1.0
    @State private var starOpacity: Double = 0
    @State private var cameraShutter: Double = 0
    @State private var lightBeamOpacity: Double = 0
    @State private var energyRingScale: CGFloat = 0
    @State private var filmStripOffset: CGFloat = 0
    
    let onFinished: () -> Void
    
    var body: some View {
        ZStack {
            // Dynamic Background with Multiple Layers
            dynamicBackgroundLayers
            
            // Floating Film Strips
            floatingFilmStrips
            
            // Main Content
            VStack(spacing: 50) {
                // Enhanced Logo Area with Multiple Effects
                enhancedLogoSection
                
                // Dynamic Title with Typography Animation
                dynamicTitleSection
                
                // Advanced Loading Animation
                advancedLoadingSection
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .offset(y: logoOffset)
            
            // Floating Stars Background
            floatingStarsBackground
            
            // Energy Rings Effect
            energyRingsEffect
        }
        .onAppear {
            startAdvancedSplashAnimation()
        }
    }
    
    // MARK: - Dynamic Background Layers
    
    private var dynamicBackgroundLayers: some View {
        ZStack {
            // Base gradient with rotation
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.95, blue: 1.0),
                    Color(red: 0.88, green: 0.92, blue: 0.98),
                    Color(red: 0.82, green: 0.88, blue: 0.96),
                    Color(red: 0.75, green: 0.85, blue: 0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(gradientRotation * 0.3))
            .ignoresSafeArea()
            
            // Animated wave overlay
            WaveShape(offset: waveOffset)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignTokens.Colors.primaryAccent.opacity(0.1),
                            DesignTokens.Colors.secondaryAccent.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .ignoresSafeArea()
            
            // Radial gradient overlay with breathing effect
            RadialGradient(
                colors: [
                    DesignTokens.Colors.primaryAccent.opacity(0.15),
                    .clear,
                    DesignTokens.Colors.secondaryAccent.opacity(0.1)
                ],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: morphScale)
        }
    }
    
    // MARK: - Floating Film Strips
    
    private var floatingFilmStrips: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                FilmStripShape()
                    .fill(DesignTokens.Colors.primaryAccent.opacity(0.1))
                    .frame(width: 40, height: 200)
                    .offset(
                        x: CGFloat(index * 120 - 120) + filmStripOffset,
                        y: CGFloat(index * 150 - 300) - filmStripOffset * 0.3
                    )
                    .rotationEffect(.degrees(Double(index * 15) + rotationAngle * 0.2))
                    .opacity(0.6)
                    .animation(
                        .linear(duration: 10 + Double(index * 2))
                        .repeatForever(autoreverses: false),
                        value: filmStripOffset
                    )
            }
        }
    }
    
    // MARK: - Enhanced Logo Section
    
    private var enhancedLogoSection: some View {
        ZStack {
            energyRingsBehindLogo
            morphingBackgroundCircles
            mainCameraLogoWithEffects
        }
    }
    
    // MARK: - Energy Rings Behind Logo
    
    private var energyRingsBehindLogo: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                DesignTokens.Colors.primaryAccent.opacity(0.4),
                                DesignTokens.Colors.secondaryAccent.opacity(0.2),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 140 + CGFloat(index * 30), height: 140 + CGFloat(index * 30))
                    .scaleEffect(energyRingScale)
                    .rotationEffect(.degrees(rotationAngle + Double(index * 90)))
                    .opacity(0.7 - Double(index) * 0.15)
                    .animation(
                        .easeInOut(duration: 3.0 + Double(index) * 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: energyRingScale
                    )
            }
        }
    }
    
    // MARK: - Morphing Background Circles
    
    private var morphingBackgroundCircles: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DesignTokens.Colors.primaryAccent.opacity(0.2),
                                DesignTokens.Colors.secondaryAccent.opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120 + CGFloat(index * 25), height: 120 + CGFloat(index * 25))
                    .scaleEffect(circleScale * (1.0 + CGFloat(index) * 0.1))
                    .rotationEffect(.degrees(rotationAngle + Double(index * 60)))
                    .opacity(0.8 - Double(index) * 0.2)
                    .animation(
                        .easeInOut(duration: 2.5 + Double(index) * 0.7)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.4),
                        value: circleScale
                    )
            }
        }
    }
    
    // MARK: - Main Camera Logo with Effects
    
    private var mainCameraLogoWithEffects: some View {
        ZStack {
            glowingOuterRing
            cameraShutterEffect
            cameraIconWithMorphing
            lightBeamEffect
            floatingParticlesWithMotion
        }
    }
    
    // MARK: - Glowing Outer Ring
    
    private var glowingOuterRing: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [
                        DesignTokens.Colors.primaryAccent,
                        DesignTokens.Colors.secondaryAccent,
                        DesignTokens.Colors.primaryAccent
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 6
            )
            .frame(width: 100, height: 100)
            .rotationEffect(.degrees(rotationAngle))
            .scaleEffect(pulseScale)
            .shadow(color: DesignTokens.Colors.primaryAccent.opacity(0.5), radius: 10, x: 0, y: 0)
            .animation(
                .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                value: pulseScale
            )
    }
    
    // MARK: - Camera Shutter Effect
    
    private var cameraShutterEffect: some View {
        Circle()
            .trim(from: 0, to: cameraShutter)
            .stroke(
                DesignTokens.Colors.secondaryAccent,
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: 80, height: 80)
            .rotationEffect(.degrees(-90))
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: cameraShutter
            )
    }
    
    // MARK: - Camera Icon with Morphing
    
    private var cameraIconWithMorphing: some View {
        Image(systemName: "camera.vintage")
            .font(.system(size: 38, weight: .medium))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        DesignTokens.Colors.primaryAccent,
                        DesignTokens.Colors.secondaryAccent,
                        DesignTokens.Colors.primaryAccent
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .scaleEffect(pulseScale * 0.9)
            .rotationEffect(.degrees(sin(rotationAngle * .pi / 180) * 5))
            .shadow(color: DesignTokens.Colors.primaryAccent.opacity(0.7), radius: 5, x: 0, y: 0)
    }
    
    // MARK: - Light Beam Effect
    
    private var lightBeamEffect: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignTokens.Colors.primaryAccent.opacity(lightBeamOpacity),
                                .clear
                            ],
                            startPoint: .center,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 80, height: 2)
                    .offset(x: 40)
                    .rotationEffect(.degrees(Double(index * 45) + rotationAngle))
                    .animation(
                        .easeInOut(duration: 0.8).delay(Double(index) * 0.1),
                        value: lightBeamOpacity
                    )
            }
        }
    }
    
    // MARK: - Floating Particles with Motion
    
    private var floatingParticlesWithMotion: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                floatingParticle(at: index)
            }
            ForEach(6..<12, id: \.self) { index in
                floatingParticle(at: index)
            }
        }
    }
    
    // MARK: - Individual Floating Particle
    
    private func floatingParticle(at index: Int) -> some View {
        Circle()
            .fill(particleGradient)
            .frame(width: 6, height: 6)
            .offset(particleOffset(for: index))
            .opacity(particlesOpacity)
            .scaleEffect(particleScale(for: index))
            .animation(
                .easeOut(duration: 1.2).delay(Double(index) * 0.08),
                value: particlesOpacity
            )
    }
    
    // MARK: - Particle Helper Properties
    
    private var particleGradient: RadialGradient {
        RadialGradient(
            colors: [
                DesignTokens.Colors.primaryAccent.opacity(0.8),
                DesignTokens.Colors.secondaryAccent.opacity(0.4),
                .clear
            ],
            center: .center,
            startRadius: 1,
            endRadius: 4
        )
    }
    
    private func particleOffset(for index: Int) -> CGSize {
        let x = cos(Double(index) * .pi / 6 + rotationAngle * .pi / 180) * (70 + sin(rotationAngle * .pi / 90) * 20)
        let y = sin(Double(index) * .pi / 6 + rotationAngle * .pi / 180) * (70 + cos(rotationAngle * .pi / 90) * 20)
        return CGSize(width: x, height: y)
    }
    
    private func particleScale(for index: Int) -> CGFloat {
        return particlesOpacity * (0.5 + sin(Double(index) + rotationAngle * .pi / 180) * 0.5)
    }
    
    // MARK: - Dynamic Title Section
    
    private var dynamicTitleSection: some View {
        VStack(spacing: 12) {
            // Main title with character-by-character animation
            HStack(spacing: 2) {
                ForEach(Array("Analog Films".enumerated()), id: \.offset) { index, character in
                    Text(String(character))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    DesignTokens.Colors.textPrimary,
                                    DesignTokens.Colors.primaryAccent,
                                    DesignTokens.Colors.secondaryAccent
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(character == " " ? 1.0 : pulseScale)
                        .offset(y: sin(Double(index) + rotationAngle * .pi / 180) * 3)
                        .animation(
                            .easeInOut(duration: 0.8).delay(Double(index) * 0.1),
                            value: pulseScale
                        )
                }
            }
            .shadow(color: DesignTokens.Colors.primaryAccent.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Subtitle with typewriter effect
            Text("Discover the Magic of Film Photography")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(DesignTokens.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .opacity(opacity * 0.8)
                .scaleEffect(1.0 + sin(rotationAngle * .pi / 360) * 0.05)
        }
    }
    
    // MARK: - Advanced Loading Section
    
    private var advancedLoadingSection: some View {
        VStack(spacing: 20) {
            // Morphing loading dots with wave effect
            HStack(spacing: 12) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    DesignTokens.Colors.primaryAccent,
                                    DesignTokens.Colors.secondaryAccent
                                ],
                                center: .center,
                                startRadius: 1,
                                endRadius: 8
                            )
                        )
                        .frame(width: 12, height: 12)
                        .scaleEffect(0.5 + abs(sin(Double(index) + rotationAngle * .pi / 60)) * 1.5)
                        .offset(y: sin(Double(index) + rotationAngle * .pi / 60) * 8)
                        .animation(
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: rotationAngle
                        )
                }
            }
            
            // Loading progress bar with glow
            ZStack {
                Capsule()
                    .fill(DesignTokens.Colors.tertiaryBackground)
                    .frame(width: 200, height: 4)
                
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                DesignTokens.Colors.primaryAccent,
                                DesignTokens.Colors.secondaryAccent
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 200 * (rotationAngle / 360), height: 4)
                    .shadow(color: DesignTokens.Colors.primaryAccent.opacity(0.6), radius: 4, x: 0, y: 0)
                    .animation(.easeInOut(duration: 3.0), value: rotationAngle)
            }
            
            Text("Loading your film collection...")
                .font(.caption)
                .foregroundColor(DesignTokens.Colors.textTertiary)
                .opacity(0.5 + sin(rotationAngle * .pi / 180) * 0.5)
        }
    }
    
    // MARK: - Floating Stars Background
    
    private var floatingStarsBackground: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: CGFloat.random(in: 4...8)))
                    .foregroundColor(DesignTokens.Colors.primaryAccent.opacity(0.3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(starOpacity)
                    .scaleEffect(starOpacity * CGFloat.random(in: 0.5...1.5))
                    .rotationEffect(.degrees(rotationAngle * CGFloat.random(in: 0.5...2.0)))
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: starOpacity
                    )
            }
        }
    }
    
    // MARK: - Energy Rings Effect
    
    private var energyRingsEffect: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [
                                DesignTokens.Colors.primaryAccent.opacity(0.8),
                                DesignTokens.Colors.secondaryAccent.opacity(0.6),
                                .clear,
                                DesignTokens.Colors.primaryAccent.opacity(0.4),
                                .clear
                            ],
                            center: .center
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 300 + CGFloat(index * 100), height: 300 + CGFloat(index * 100))
                    .rotationEffect(.degrees(rotationAngle * (1.0 + Double(index) * 0.3)))
                    .opacity(energyRingScale * 0.3)
                    .scaleEffect(energyRingScale)
                    .animation(
                        .linear(duration: 8 + Double(index * 2))
                        .repeatForever(autoreverses: false),
                        value: rotationAngle
                    )
            }
        }
    }
    
    // MARK: - Animation Logic
    
    private func startAdvancedSplashAnimation() {
        // Initial appear animation with bounce
        withAnimation(.spring(response: 1.0, dampingFraction: 0.6, blendDuration: 0.3)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Start all rotating animations
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            rotationAngle = 360
            gradientRotation = 360
            filmStripOffset = 200
        }
        
        // Wave animation
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            waveOffset = 100
        }
        
        // Morphing scale animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            morphScale = 1.5
        }
        
        // Circle scale animation with bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                circleScale = 1.0
            }
        }
        
        // Energy rings activation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 1.5)) {
                energyRingScale = 1.0
            }
        }
        
        // Pulse animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            pulseScale = 1.3
        }
        
        // Camera shutter effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                cameraShutter = 1.0
            }
        }
        
        // Light beam effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 1.0)) {
                lightBeamOpacity = 0.8
            }
        }
        
        // Particles explosion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeOut(duration: 1.5)) {
                particlesOpacity = 1.0
            }
        }
        
        // Stars twinkle effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeInOut(duration: 1.0)) {
                starOpacity = 1.0
            }
        }
        
        // Exit animation after 3 seconds with dramatic effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                scale = 0.8
                opacity = 0
                logoOffset = -100
                energyRingScale = 2.0
                lightBeamOpacity = 0
                particlesOpacity = 0
                starOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                onFinished()
            }
        }
    }
}

// MARK: - Custom Shapes

struct WaveShape: Shape {
    let offset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let waveHeight: CGFloat = 30
        
        path.move(to: CGPoint(x: 0, y: height * 0.7))
        
        for x in stride(from: 0, through: width, by: 5) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 4 + offset * 0.02) * waveHeight
            path.addLine(to: CGPoint(x: x, y: height * 0.7 + sine))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

struct FilmStripShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Main rectangle
        path.addRect(rect)
        
        // Film holes
        let holeSize: CGFloat = 8
        let holeSpacing: CGFloat = 15
        
        for y in stride(from: holeSpacing, to: rect.height - holeSpacing, by: holeSpacing) {
            // Left holes
            path.addEllipse(in: CGRect(x: 5, y: y, width: holeSize, height: holeSize))
            // Right holes
            path.addEllipse(in: CGRect(x: rect.width - 13, y: y, width: holeSize, height: holeSize))
        }
        
        return path
    }
}

// MARK: - Preview

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView {
            print("Splash finished")
        }
    }
}