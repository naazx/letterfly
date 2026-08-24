import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct AuthView: View {
    @State private var showError: Bool = false
    var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.pink)

                    Text("Letterfly")
                        .font(.largeTitle.bold())

                    Text("Write to each other, always.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)

                    Button {
                        Task {
                            await viewModel.signInWithGoogle()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image("google_logo")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Sign in with Google")
                                .font(.system(size: 19, weight: .medium))
                                .foregroundStyle(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)

                Text("By continuing, you agree to our [Privacy Policy](https://naazx.github.io/pawletter-legal/)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 12)
            }
            .background(Color(.systemGroupedBackground))
            .onChange(of: viewModel.authError){
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
