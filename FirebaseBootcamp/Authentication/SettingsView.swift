//
//  SettingsView.swift
//  FirebaseBootcamp
//
//  Created by Kimleng Hor on 7/26/23.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthProviders() throws {
        authProviders = try AuthenticationManager.shared.getProvider()
    }
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "hello123@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "hello123"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
        self.authUser = authDataResult
    }
    
    func linkAppleAccount() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let authDataResult = try await AuthenticationManager.shared.linkApple(tokens: tokens)
        self.authUser = authDataResult
    }
    
    func linkEmailAccount() async throws {
        let email = "hellokim@gmail.com"
        let password = "123456"
        let authDataResult = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
        self.authUser = authDataResult
    }
    
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delete()
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.logOut()
                        showSignInView = true
                    } catch {
                        print("Cannot delete", error.localizedDescription)
                    }
                }
            }
            
            Button(role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignInView = true
                    } catch {
                        print("Cannot log out", error.localizedDescription)
                    }
                }
            } label: {
                Text("Delete Account")
            }
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
            if viewModel.authUser?.isAnonymous == true {
                anonymousSection
            }
        }
        .onAppear {
            do {
                try viewModel.loadAuthProviders()
                viewModel.loadAuthUser()
            } catch {
                print("Error", error.localizedDescription)
            }
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(showSignInView: .constant(false))
        }
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button("Reset password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("Password reset")
                    } catch {
                        print("Cannot reset password", error.localizedDescription)
                    }
                }
            }
            
            Button("Update email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("Email updated")
                    } catch {
                        print("Cannot update email", error.localizedDescription)
                    }
                }
            }
            
            Button("Update password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("Password updated")
                    } catch {
                        print("Cannot update password", error.localizedDescription)
                    }
                }
            }
        } header: {
            Text("Email function")
        }
    }
    
    private var anonymousSection: some View {
        Section {
            Button("Link Google Account") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("Google linked")
                    } catch {
                        print("Cannot reset password", error.localizedDescription)
                    }
                }
            }
            
            Button("Link Apple Account") {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("Apple linked")
                    } catch {
                        print("Cannot update email", error.localizedDescription)
                    }
                }
            }
            
            Button("Link Email Account") {
                Task {
                    do {
                        try await viewModel.linkEmailAccount()
                        print("Email linked")
                    } catch {
                        print("Cannot update password", error.localizedDescription)
                    }
                }
            }
        } header: {
            Text("Create account")
        }
    }
}
