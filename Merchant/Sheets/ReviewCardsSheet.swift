// Rules: Placeholder sheet for future card review functionality
// Inputs: UIState for dismissal
// Outputs: Dismissal action
// Constraints: Simplified version without Plaid integration

import SwiftUI

struct ReviewCardsSheet: View {
    @Environment(UIState.self) private var uiState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: ModernSpacing.xl) {
                Spacer()

                VStack(spacing: ModernSpacing.xl) {
                    Image(systemName: "creditcard.and.123")
                        .font(.system(size: 64))
                        .foregroundStyle(ModernColors.accent)

                    VStack(spacing: ModernSpacing.lg) {
                        Text("Card Review")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(ModernColors.textPrimary)

                        Text("This feature will be available soon")
                            .font(.body)
                            .foregroundStyle(ModernColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()

                Button("Close") {
                    dismiss()
                }
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, ModernSpacing.xl)
                .background(ModernColors.accent, in: RoundedRectangle(cornerRadius: ModernRadius.container))
            }
            .padding(ModernSpacing.xl)
            .navigationTitle("Review Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .background(ModernBackground())
    }
}

#Preview {
    ReviewCardsSheet()
        .environment(UIState())
}