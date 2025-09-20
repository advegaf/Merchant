// Rules: Authentication sheet with Sign in with Apple and email options
// Inputs: UIState for sign-in control
// Outputs: Sign-in UI with branded buttons, dismiss on auth
// Constraints: UI only, toggles isSignedIn flag, no real authentication

import SwiftUI

struct AuthSheet: View {
    @Environment(UIState.self) private var uiState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: ThemeSpacing.xl) {
                Spacer()

                VStack(spacing: ThemeSpacing.l) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(ThemeColor.primaryNeon)

                    VStack(spacing: ThemeSpacing.s) {
                        Text("Welcome to Merchant")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Text("Sign in to track your rewards and get personalized recommendations")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                VStack(spacing: ThemeSpacing.m) {
                    Button(action: {
                        uiState.signIn()
                        dismiss()
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
                        dismiss()
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

                Spacer()
            }
            .padding(ThemeSpacing.xl)
            .background {
                NeonBackground()
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    AuthSheet()
        .environment(UIState())
}