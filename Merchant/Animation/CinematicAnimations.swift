
import SwiftUI

/// Custom spring configurations for different animation contexts
struct CinematicSprings {

    // Ultra-responsive for immediate feedback
    static let immediate = Animation.interactiveSpring(
        response: 0.25,
        dampingFraction: 0.9,
        blendDuration: 0.1
    )

    // Smooth and elegant for primary actions
    static let elegant = Animation.interactiveSpring(
        response: 0.5,
        dampingFraction: 0.8,
        blendDuration: 0.2
    )

    // Bouncy for playful interactions
    static let playful = Animation.interactiveSpring(
        response: 0.6,
        dampingFraction: 0.6,
        blendDuration: 0.15
    )

    // Gentle for ambient animations
    static let ambient = Animation.interactiveSpring(
        response: 1.0,
        dampingFraction: 0.9,
        blendDuration: 0.3
    )

    // Cinematic for dramatic reveals
    static let dramatic = Animation.timingCurve(
        0.22, 1.0, 0.36, 1.0,
        duration: 0.8
    )
}

/// Advanced timing curves inspired by film and motion graphics
struct CinematicCurves {

    // Anticipation curve - slight backwards motion before forward
    static let anticipation = Animation.timingCurve(
        0.0, 0.0, 0.2, 1.0,
        duration: 0.4
    )

    // Overshoot curve - goes past target then settles
    static let overshoot = Animation.timingCurve(
        0.34, 1.56, 0.64, 1.0,
        duration: 0.6
    )

    // Ease out expo - fast start, slow smooth end
    static let easeOutExpo = Animation.timingCurve(
        0.16, 1.0, 0.3, 1.0,
        duration: 0.7
    )

    // Ease in out back - subtle bounce at both ends
    static let easeInOutBack = Animation.timingCurve(
        0.68, -0.55, 0.265, 1.55,
        duration: 0.5
    )
}

/// Sophisticated animation sequences with choreographed timing
struct AnimationSequence {

    /// Staggered reveal animation for multiple cards
    static func staggeredReveal<T: Identifiable>(
        items: [T],
        delay: TimeInterval = 0.1,
        animation: Animation = CinematicSprings.elegant
    ) -> [T: TimeInterval] {
        var delays: [T: TimeInterval] = [:]

        for (index, item) in items.enumerated() {
            delays[item] = Double(index) * delay
        }

        return delays
    }

    /// Cascade animation with wave effect
    static func cascadeWave<T: Identifiable>(
        items: [T],
        waveSpeed: TimeInterval = 0.05
    ) -> [T: (delay: TimeInterval, animation: Animation)] {
        var config: [T: (delay: TimeInterval, animation: Animation)] = [:]

        for (index, item) in items.enumerated() {
            let delay = Double(index) * waveSpeed
            let response = 0.4 + (Double(index) * 0.05) // Slightly slower for each item
            let animation = Animation.interactiveSpring(
                response: response,
                dampingFraction: 0.8,
                blendDuration: 0.1
            )

            config[item] = (delay, animation)
        }

        return config
    }
}

/// Particle-like animation effects for visual flair
struct ParticleEffects {

    /// Sparkle burst effect for rewards
    struct SparkleParticle: Identifiable {
        let id = UUID()
        let startX: CGFloat
        let startY: CGFloat
        let endX: CGFloat
        let endY: CGFloat
        let rotation: Double
        let scale: CGFloat
        let delay: TimeInterval
    }

    static func generateSparkles(
        center: CGPoint,
        count: Int = 12,
        radius: CGFloat = 40
    ) -> [SparkleParticle] {
        var particles: [SparkleParticle] = []

        for i in 0..<count {
            let angle = (Double(i) / Double(count)) * 2 * .pi
            let distance = CGFloat.random(in: radius * 0.5...radius)

            let endX = center.x + cos(angle) * distance
            let endY = center.y + sin(angle) * distance

            let particle = SparkleParticle(
                startX: center.x,
                startY: center.y,
                endX: endX,
                endY: endY,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.0),
                delay: TimeInterval.random(in: 0...0.3)
            )

            particles.append(particle)
        }

        return particles
    }
}

/// View modifier for breathtaking entrance animations
struct CinematicEntrance: ViewModifier {
    let style: EntranceStyle
    @State private var isVisible = false

    enum EntranceStyle {
        case fadeSlideUp
        case scaleBlur
        case flipFromBottom
        case elastic
    }

    func body(content: Content) -> some View {
        Group {
            switch style {
            case .fadeSlideUp:
                content
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 30)
                    .animation(CinematicSprings.elegant, value: isVisible)

            case .scaleBlur:
                content
                    .scaleEffect(isVisible ? 1 : 0.8)
                    .opacity(isVisible ? 1 : 0)
                    .blur(radius: isVisible ? 0 : 10)
                    .animation(CinematicCurves.easeOutExpo, value: isVisible)

            case .flipFromBottom:
                content
                    .rotation3DEffect(
                        .degrees(isVisible ? 0 : 90),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom
                    )
                    .opacity(isVisible ? 1 : 0)
                    .animation(CinematicCurves.overshoot, value: isVisible)

            case .elastic:
                content
                    .scaleEffect(isVisible ? 1 : 0.1)
                    .opacity(isVisible ? 1 : 0)
                    .animation(CinematicSprings.playful, value: isVisible)
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

/// Advanced haptic feedback patterns
final class CinematicHaptics {

    enum Pattern {
        case subtle
        case confident
        case success
        case error
        case selection
        case impact(intensity: CGFloat)
    }

    static func play(_ pattern: Pattern) {
        #if os(iOS)
        switch pattern {
        case .subtle:
            let feedback = UIImpactFeedbackGenerator(style: .light)
            feedback.impactOccurred(intensity: 0.3)

        case .confident:
            let feedback = UIImpactFeedbackGenerator(style: .medium)
            feedback.impactOccurred(intensity: 0.8)

        case .success:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)

        case .error:
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.error)

        case .selection:
            let feedback = UISelectionFeedbackGenerator()
            feedback.selectionChanged()

        case .impact(let intensity):
            let feedback = UIImpactFeedbackGenerator(style: .heavy)
            feedback.impactOccurred(intensity: intensity)
        }
        #endif
    }

    /// Signature haptic pattern for card interactions
    static func playCardInteraction() {
        #if os(iOS)
        // Custom pattern: light tap followed by medium confirmation
        DispatchQueue.main.async {
            play(.subtle)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            play(.confident)
        }
        #endif
    }
}

// MARK: - View Extensions

extension View {
    func cinematicEntrance(_ style: CinematicEntrance.EntranceStyle) -> some View {
        self.modifier(CinematicEntrance(style: style))
    }

    /// Apply cinematic hover effect
    func cinematicHover() -> some View {
        self.modifier(CinematicHoverEffect())
    }
}

/// Sophisticated hover effect that responds to proximity
struct CinematicHoverEffect: ViewModifier {
    @State private var isHovered = false
    @State private var hoverIntensity: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(1 + (hoverIntensity * 0.02))
            .shadow(
                color: .black.opacity(0.1 + (hoverIntensity * 0.15)),
                radius: 5 + (hoverIntensity * 10),
                x: 0,
                y: 2 + (hoverIntensity * 8)
            )
            .animation(CinematicSprings.immediate, value: hoverIntensity)
            .onHover { hovering in
                withAnimation(CinematicSprings.elegant) {
                    isHovered = hovering
                    hoverIntensity = hovering ? 1.0 : 0.0
                }

                if hovering {
                    CinematicHaptics.play(.subtle)
                }
            }
    }
}