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

                // SignInWithAppleButton(.signIn) { request in
                //     viewModel.prepareAppleRequest(request)
                // } onCompletion: { result in
                //     Task {
                //         await viewModel.signInWithApple(result: result)
                //     }
                // }
                // .signInWithAppleButtonStyle(.black)
                // .frame(height: 50)
                // .padding(.horizontal)

                GoogleSignInButton {
                    Task {
                        await viewModel.signInWithGoogle()
                    }
                }
                .frame(height: 50)
                .padding(.horizontal)

                Spacer()
            }
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
            .navigationTitle("Login")
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
}
