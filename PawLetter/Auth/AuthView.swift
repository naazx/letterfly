import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct AuthView: View {
    var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                // TODO: повернути після оформлення Apple Developer Program
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
            .navigationTitle("Login")
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
}
