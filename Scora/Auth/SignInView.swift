//
//  SignInView.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusedField: Field?
    let onSignInComplete: () -> Void
    let onSwitchToSignUp: () -> Void
    
    enum Field: Hashable {
        case email, password
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text("Sign in to continue your journey")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 80)
                    .padding(.bottom, 40)

                    // Input Fields
                    VStack(spacing: 16) {
                        CustomTextField(
                            placeholder: "Email",
                            text: $viewModel.email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }

                        CustomTextField(
                            placeholder: "Password",
                            text: $viewModel.password,
                            icon: "lock.fill",
                            isSecure: true
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .onSubmit {
                            focusedField = nil
                            if viewModel.isSignInFormValid && !viewModel.isLoading {
                                Task {
                                    await viewModel.signIn()
                                    if viewModel.isSignInSuccessful {
                                        onSignInComplete()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)

                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Sign In Button
                    PrimaryButton(
                        title: viewModel.isLoading ? "Signing In..." : "Sign In",
                        action: {
                            Task {
                                await viewModel.signIn()
                                if viewModel.isSignInSuccessful {
                                    onSignInComplete()
                                }
                            }
                        }
                    )
                    .disabled(viewModel.isLoading || !viewModel.isSignInFormValid)
                    .opacity(viewModel.isLoading || !viewModel.isSignInFormValid ? 0.6 : 1.0)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // Switch to Sign Up
                    Button(action: {
                        viewModel.resetForm()
                        onSwitchToSignUp()
                    }) {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                            Text("Sign Up")
                                .foregroundColor(AppColors.primary)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 15))
                    }
                    .padding(.top, 16)

                    Spacer()
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(onSignInComplete: {}, onSwitchToSignUp: {})
            .preferredColorScheme(.dark)
    }
}
