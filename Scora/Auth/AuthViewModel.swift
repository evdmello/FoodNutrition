//
//  AuthViewModel.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import Foundation
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSignUpSuccessful = false
    @Published var isSignInSuccessful = false

    private let supabase = SupabaseClient(
        supabaseURL: API.supabaseURL,
        supabaseKey: Keys.supabaseKey
    )

    var isSignUpFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 &&
        email.contains("@")
    }

    var isSignInFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }

    var isFormValid: Bool {
        isSignUpFormValid
    }

    func signIn() async {
        guard isSignInFormValid else {
            errorMessage = "Please enter valid email and password"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            isSignInSuccessful = true
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    func resetForm() {
        firstName = ""
        lastName = ""
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
        isSignUpSuccessful = false
        isSignInSuccessful = false
    }

    func signUp() async {
        guard isSignUpFormValid else {
            errorMessage = "Please fill in all fields correctly"
            return
        }

        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: [
                    "first_name": .string(firstName),
                    "last_name": .string(lastName)
                ]
            )
            isSignUpSuccessful = true
            isLoading = false

        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
