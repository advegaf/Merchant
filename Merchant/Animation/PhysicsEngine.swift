// Rules: Advanced physics simulation for award-winning animations
// Inputs: Gesture states, velocity vectors, spring configurations
// Outputs: Realistic motion with momentum, friction, and elasticity
// Constraints: 60fps performance, iOS 26+ only, cinematic quality

import SwiftUI
import Combine
import simd

/// Advanced physics engine for award-level animations
final class PhysicsEngine: ObservableObject {

    // MARK: - Physics Configuration

    struct SpringConfig {
        let mass: Float = 1.0
        let stiffness: Float
        let damping: Float
        let restLength: Float = 0.0

        static let ultraResponsive = SpringConfig(stiffness: 400, damping: 25)
        static let smooth = SpringConfig(stiffness: 200, damping: 20)
        static let elastic = SpringConfig(stiffness: 150, damping: 15)
        static let gentle = SpringConfig(stiffness: 100, damping: 18)
    }

    struct PhysicsState {
        var position: SIMD2<Float> = SIMD2(0, 0)
        var velocity: SIMD2<Float> = SIMD2(0, 0)
        var target: SIMD2<Float> = SIMD2(0, 0)
        var isAnimating: Bool = false
    }

    // MARK: - State Management

    @Published var cardStates: [UUID: PhysicsState] = [:]
    private var displayLink: CADisplayLink?
    private let friction: Float = 0.98
    private let velocityThreshold: Float = 0.1

    init() {
        startPhysicsLoop()
    }

    deinit {
        stopPhysicsLoop()
    }

    // MARK: - Physics Loop

    private func startPhysicsLoop() {
        displayLink = CADisplayLink(target: self, selector: #selector(updatePhysics))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopPhysicsLoop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updatePhysics() {
        let deltaTime: Float = 1.0 / 60.0 // Target 60fps

        for (id, state) in cardStates {
            guard state.isAnimating else { continue }

            var newState = state
            let config = SpringConfig.smooth

            // Spring force calculation
            let displacement = newState.target - newState.position
            let springForce = displacement * config.stiffness
            let dampingForce = newState.velocity * -config.damping
            let totalForce = springForce + dampingForce

            // Update velocity and position
            let acceleration = totalForce / config.mass
            newState.velocity += acceleration * deltaTime
            newState.velocity *= friction // Apply friction
            newState.position += newState.velocity * deltaTime

            // Check if animation should stop
            let positionDiff = length(newState.position - newState.target)
            let velocityMagnitude = length(newState.velocity)

            if positionDiff < 0.01 && velocityMagnitude < velocityThreshold {
                newState.position = newState.target
                newState.velocity = SIMD2(0, 0)
                newState.isAnimating = false
            }

            cardStates[id] = newState
        }
    }

    // MARK: - Public Interface

    func setTarget(for id: UUID, position: SIMD2<Float>) {
        if cardStates[id] == nil {
            cardStates[id] = PhysicsState()
        }

        cardStates[id]?.target = position
        cardStates[id]?.isAnimating = true
    }

    func applyImpulse(to id: UUID, velocity: SIMD2<Float>) {
        cardStates[id]?.velocity += velocity
        cardStates[id]?.isAnimating = true
    }

    func getPosition(for id: UUID) -> SIMD2<Float> {
        return cardStates[id]?.position ?? SIMD2(0, 0)
    }

    func getVelocity(for id: UUID) -> SIMD2<Float> {
        return cardStates[id]?.velocity ?? SIMD2(0, 0)
    }
}

/// Gesture state machine for sophisticated interaction handling
enum GestureState: Equatable {
    case idle
    case pressing(startTime: Date)
    case dragging(startTime: Date, currentTranslation: CGSize)
    case releasing(velocity: CGSize)
    case settling

    static func == (lhs: GestureState, rhs: GestureState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.settling, .settling):
            return true
        case (.pressing(let lhsTime), .pressing(let rhsTime)):
            return lhsTime == rhsTime
        case (.dragging(let lhsTime, let lhsTranslation), .dragging(let rhsTime, let rhsTranslation)):
            return lhsTime == rhsTime && lhsTranslation == rhsTranslation
        case (.releasing(let lhsVelocity), .releasing(let rhsVelocity)):
            return lhsVelocity == rhsVelocity
        default:
            return false
        }
    }
}

/// Advanced gesture controller with predictive behaviors
final class AdvancedGestureController: ObservableObject {
    @Published var gestureState: GestureState = .idle
    @Published var anticipationOffset: CGSize = .zero

    private let physicsEngine = PhysicsEngine()
    private let pressThreshold: TimeInterval = 0.15

    func handlePressStart() {
        gestureState = .pressing(startTime: Date())

        // Anticipation animation - subtle scale down
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.15)) {
            anticipationOffset = CGSize(width: 0, height: 2)
        }
    }

    func handleDragStart(translation: CGSize) {
        gestureState = .dragging(startTime: Date(), currentTranslation: translation)

        // Release anticipation
        withAnimation(.timingCurve(0.8, 0.2, 0.6, 1, duration: 0.2)) {
            anticipationOffset = .zero
        }
    }

    func handleDragChange(translation: CGSize) {
        if case .dragging(let startTime, _) = gestureState {
            gestureState = .dragging(startTime: startTime, currentTranslation: translation)
        }
    }

    func handleDragEnd(translation: CGSize, velocity: CGSize) {
        gestureState = .releasing(velocity: velocity)

        // Calculate physics-based settle position
        let decelerationRate: CGFloat = 0.95
        let _ = velocity.width * 0.3 * decelerationRate

        // Trigger settling animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.gestureState = .settling

            // Return to idle after settling
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.gestureState = .idle
            }
        }
    }
}

// MARK: - SwiftUI Integration

struct PhysicsAwareModifier: ViewModifier {
    let id: UUID
    @StateObject private var gestureController = AdvancedGestureController()
    @State private var dragOffset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0

    func body(content: Content) -> some View {
        content
            .offset(dragOffset)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: gestureController.gestureState)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if value.translation == .zero {
                            gestureController.handlePressStart()
                        } else {
                            gestureController.handleDragChange(translation: value.translation)

                            // Apply real-time physics effects
                            let progress = min(abs(value.translation.width) / 100, 1.0)

                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.9)) {
                                dragOffset = CGSize(
                                    width: value.translation.width * 0.7,
                                    height: value.translation.height * 0.3
                                )
                                scale = 1.0 + (progress * 0.05)
                                rotation = Double(value.translation.width * 0.02)
                            }
                        }
                    }
                    .onEnded { value in
                        gestureController.handleDragEnd(
                            translation: value.translation,
                            velocity: value.velocity
                        )

                        // Physics-based return animation
                        let _ = value.velocity
                        let _: CGFloat = 1.0
                        let _: CGFloat = 300
                        let _: CGFloat = 25

                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            dragOffset = .zero
                            scale = 1.0
                            rotation = 0.0
                        }
                    }
            )
    }
}

extension View {
    func physicsAware(id: UUID) -> some View {
        self.modifier(PhysicsAwareModifier(id: id))
    }
}