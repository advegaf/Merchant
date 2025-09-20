// Rules: Main home screen with blur gating for unauthenticated users, card stack when signed in
// Inputs: UIState authentication status, card data
// Outputs: Blurred content + auth overlay OR full home with cards and panels
// Constraints: Blur entire content when not signed in, CTA for Plaid connection

import SwiftUI

struct HomeView: View {
    @Environment(UIState.self) private var uiState
    @State private var cards: [CardUI] = []
    @State private var cardProvider = MockCardArtProvider()

    var body: some View {
        ZStack {
            NeonBackground()

            VStack(spacing: ThemeSpacing.xl) {
                if !cards.isEmpty {
                    NowPanel()

                    CardsStack(cards: cards)
                        .frame(height: 240)
                } else {
                    VStack(spacing: ThemeSpacing.xl) {
                        Spacer()

                        VStack(spacing: ThemeSpacing.l) {
                            Image(systemName: "creditcard.and.123")
                                .font(.system(size: 48))
                                .foregroundStyle(ThemeColor.primaryNeon)

                            Text("Connect Your Cards")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)

                            Text("Link your accounts to see personalized recommendations")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: {
                            uiState.showPlaidLinkSheet = true
                        }) {
                            Text("Connect with Plaid")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, ThemeSpacing.l)
                                .background(ThemeColor.primaryNeon, in: RoundedRectangle(cornerRadius: ThemeRadius.container))
                        }
                        .padding(.horizontal, ThemeSpacing.xl)

                        Spacer()
                    }
                }
            }
            .blur(radius: uiState.isSignedIn ? 0 : 20)
            .disabled(!uiState.isSignedIn)

            if !uiState.isSignedIn {
                VStack(spacing: ThemeSpacing.xl) {
                    VStack(spacing: ThemeSpacing.l) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(ThemeColor.primaryNeon)

                        Text("Welcome to Merchant")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Text("Sign in to continue")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: ThemeSpacing.m) {
                        Button(action: {
                            uiState.signIn()
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .font(.headline)
                                Text("Sign in with Apple")
                                    .font(.headline)
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, ThemeSpacing.l)
                            .background(.white, in: RoundedRectangle(cornerRadius: ThemeRadius.container))
                        }

                        Button(action: {
                            uiState.signIn()
                        }) {
                            Text("Sign in with Email")
                                .font(.headline)
                                .foregroundStyle(ThemeColor.primaryNeon)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, ThemeSpacing.l)
                                .background(.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: ThemeRadius.container)
                                        .stroke(ThemeColor.primaryNeon, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, ThemeSpacing.xl)
                }
                .padding(ThemeSpacing.xl)
                .background {
                    GlassCard {
                        Color.clear
                            .frame(height: 320)
                    }
                }
                .padding(.horizontal, ThemeSpacing.xl)
            }
        }
        .task {
            if uiState.isSignedIn && cards.isEmpty {
                cards = await cardProvider.fetchCardsForReview()
            }
        }
        .onChange(of: uiState.isSignedIn) { _, newValue in
            if newValue && cards.isEmpty {
                Task {
                    cards = await cardProvider.fetchCardsForReview()
                }
            }
        }
    }
}

#Preview("Signed Out") {
    HomeView()
        .environment(UIState())
}

#Preview("Signed In") {
    let uiState = UIState()
    uiState.isSignedIn = true

    return HomeView()
        .environment(uiState)
}