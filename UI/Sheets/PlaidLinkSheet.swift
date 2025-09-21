// Rules: Mock Plaid connection sheet with loading state, success flow to ReviewCardsSheet
// Inputs: UIState for sheet management, MockCardArtProvider for cards
// Outputs: Mock connection UI, populates cardsToReview, triggers review sheet
// Constraints: UI only mock, realistic loading time, success leads to card review

import SwiftUI

struct PlaidLinkSheet: View {
    @Environment(UIState.self) private var uiState
    @Environment(\.dismiss) private var dismiss
    @State private var isConnecting = false
    @State private var connectionComplete = false
    @State private var cardProvider = MockCardArtProvider()

    var body: some View {
        NavigationStack {
            VStack(spacing: ThemeSpacing.xl) {
                if connectionComplete {
                    VStack(spacing: ThemeSpacing.l) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(ThemeColor.primaryNeon)

                        VStack(spacing: ThemeSpacing.s) {
                            Text("Connection Successful")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)

                            Text("We found your cards and will review them with you")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        Button("Review Cards") {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                uiState.showReviewCardsSheet = true
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ThemeSpacing.l)
                        .background(ThemeColor.primaryNeon, in: RoundedRectangle(cornerRadius: ThemeRadius.container))
                    }
                } else {
                    Spacer()

                    VStack(spacing: ThemeSpacing.l) {
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(ThemeColor.primaryNeon)
                            .symbolEffect(.pulse, isActive: isConnecting)

                        VStack(spacing: ThemeSpacing.s) {
                            Text(isConnecting ? "Connecting..." : "Connect Your Bank")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)

                            Text(isConnecting ? "Securely linking your accounts" : "Link your bank account to find your credit cards automatically")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        if isConnecting {
                            ProgressView()
                                .tint(ThemeColor.primaryNeon)
                                .scaleEffect(1.2)
                        }
                    }

                    Spacer()

                    if !isConnecting {
                        VStack(spacing: ThemeSpacing.m) {
                            Button("Continue with Plaid") {
                                connectToPlaid()
                            }
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, ThemeSpacing.l)
                            .background(ThemeColor.primaryNeon, in: RoundedRectangle(cornerRadius: ThemeRadius.container))

                            Text("Your credentials are encrypted and secure")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .padding(ThemeSpacing.xl)
            .background {
                NeonBackground()
            }
            .navigationTitle("Link Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Cancel", style: .glass, size: .small) {
                        dismiss()
                    }
                    .disabled(isConnecting)
                }
            }
        }
    }

    private func connectToPlaid() {
        isConnecting = true

        Task {
            let cards = await cardProvider.fetchCardsForReview()

            try? await Task.sleep(for: .seconds(2))

            await MainActor.run {
                uiState.cardsToReview = cards
                isConnecting = false
                connectionComplete = true

                #if os(iOS)
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                #endif
            }
        }
    }
}

#Preview("Initial") {
    PlaidLinkSheet()
        .environment(UIState())
}

#Preview("Connecting") {
    let sheet = PlaidLinkSheet()
    return sheet
        .environment(UIState())
        .onAppear {
            // Simulate connecting state for preview
        }
}