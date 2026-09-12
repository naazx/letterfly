import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct AuthView: View {
    @State private var showError: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                Spacer()
                
                VStack(spacing: 14) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 42, weight: .medium))
                        .foregroundStyle(.pink)
                    
                    VStack(spacing: 6) {
                        Text("Letterfly")
                            .font(.largeTitle.bold())
                        
                        Text("Letters made for you.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    
                    SignInWithAppleButton(.signIn) { request in
                        viewModel.prepareAppleRequest(request)
                    } onCompletion: { result in
                        Task {
                            await viewModel.signInWithApple(result: result)
                        }
                    }
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Button {
                        Task {
                            await viewModel.signInWithGoogle()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image("google_logo")
                                .resizable()
                                .frame(width: 26, height: 26)
                                .scaleEffect(1.3)
                                .frame(width: 20, height: 20)
                                .clipped()
                            
                            Text("Sign in with Google")
                                .font(.body.weight(.medium))
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    Color.primary.opacity(colorScheme == .dark ? 0.25 : 0.12),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                
                Text("By continuing, you agree to our [Privacy Policy](https://naazx.github.io/pawletter-legal/)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea(.container, edges: .bottom)
            .onChange(of: viewModel.authError) {
                showError = true
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    viewModel.authError = nil
                }
            } message: {
                Text(viewModel.authError?.errorDescription ?? "")
            }
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
}
