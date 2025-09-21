// Rules: Plaid Link entry sheet with consent, starts coordinator when ready
// Inputs: UIState for presentation, PlaidLinkViewModel for actions
// Outputs: Launch Plaid Link, errors surfaced locally, dismiss on success
// Constraints: No secrets; tokens via backend; short-lived access tokens in Keychain

import SwiftUI

struct PlaidLinkSheet: View {
    @Environment(UIState.self) private var uiState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PlaidLinkViewModel = {
        let remote = RemoteLinkTokenProvider(baseURL: PlaidAPIConfig.serverBaseURL())
        #if DEBUG
        let fallback = DebugDirectPlaidProvider()
        let provider: LinkTokenProviding? = remote ?? fallback
        #else
        let provider: LinkTokenProviding? = remote
        #endif
        return PlaidLinkViewModel(linkTokenProvider: provider)
    }()
    @State private var isLaunching = false

    var body: some View {
        NavigationStack {
            VStack(spacing: ModernSpacing.xl) {
                Spacer()

                VStack(spacing: ModernSpacing.xl) {
                    Image(systemName: "link")
                        .font(.system(size: 64))
                        .foregroundStyle(ModernColors.accent)

                    VStack(spacing: ModernSpacing.lg) {
                        Text("Connect Account")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(ModernColors.textPrimary)

                        Text("Securely link your bank via Plaid to import transactions. We never store credentials.")
                            .font(.body)
                            .foregroundStyle(ModernColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()

                VStack(spacing: ModernSpacing.md) {
                    Button(action: {
                        Task { await launchPlaid() }
                    }) {
                        HStack {
                            if isLaunching { ProgressView().tint(.black) }
                            Text(isLaunching ? "Launching…" : "Continue")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ModernSpacing.xl)
                        .background(ModernColors.accent, in: RoundedRectangle(cornerRadius: ModernRadius.container))
                    }
                    .disabled(isLaunching)

                    CleanButton("Cancel", style: .glass, size: .small) { dismiss() }
                }
            }
            .padding(ModernSpacing.xl)
            .navigationTitle("Connect Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CleanButton("Done", style: .glass, size: .small) {
                        dismiss()
                    }
                }
            }
        }
        .background(.ultraThinMaterial)
        .alert(viewModel.errorMessage ?? "", isPresented: Binding(
            get: { viewModel.hasError },
            set: { _ in viewModel.hasError = false }
        )) {
            Button("OK", role: .cancel) { viewModel.hasError = false }
        }
    }

    private func launchPlaid() async {
        isLaunching = true
        defer { isLaunching = false }
        do {
            let vm = viewModel
            let success = try await vm.beginLinkFlow()
            if success {
                uiState.dismissPlaidLink()
                dismiss()
            }
        } catch {
            // Surface via viewModel error binding
        }
    }
}

#Preview {
    PlaidLinkSheet()
        .environment(UIState())
}
