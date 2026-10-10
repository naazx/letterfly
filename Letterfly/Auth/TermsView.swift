//
//  TermsView.swift
//  PawLetter
//
//  Created by Nazar Dydyn on 10.10.2026.
//

import SwiftUI

struct TermsView: View {
    @Binding var hasAcceptedTerms: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundStyle(.pink)
                        Text("Before you start")
                            .font(.title2.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                    Text("Letterfly is a private space for you and your partner. To keep it safe, please read and accept these terms.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 14) {
                        termRow(
                            icon: "exclamationmark.shield.fill",
                            title: "Zero tolerance",
                            text: "Letterfly has zero tolerance for objectionable content or abusive behavior of any kind."
                        )
                        termRow(
                            icon: "flag.fill",
                            title: "Reporting",
                            text: "You can flag any letter that violates these rules directly from the letter."
                        )
                        termRow(
                            icon: "person.crop.circle.badge.xmark",
                            title: "Blocking",
                            text: "You can block your partner at any time from your profile. Blocking immediately ends the pairing and removes their content from your view."
                        )
                        termRow(
                            icon: "clock.fill",
                            title: "Our response",
                            text: "Reports are reviewed and acted on promptly, including removing content and ejecting users who violate these rules."
                        )
                    }

                    Text("By continuing, you agree to our [Terms of Use and Privacy Policy](https://naazx.github.io/letterfly-legal/).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                Button {
                    hasAcceptedTerms = true
                } label: {
                    Text("Agree and Continue")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .background(.ultraThinMaterial)
            }
        }
    }

    private func termRow(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    TermsView(hasAcceptedTerms: .constant(false))
}
