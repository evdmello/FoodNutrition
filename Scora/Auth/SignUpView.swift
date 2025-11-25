//
//  SignUpView.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @FocusState private var focusedField: Field?
    let onSignUpComplete: () -> Void
    let onSwitchToSignIn: () -> Void

    enum Field: Hashable {
        case firstName, lastName, email, password, confirmPassword
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text("Sign up to start your journey")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 20)

                    // Input Fields
                    VStack(spacing: 16) {
                        CustomTextField(
                            placeholder: "First Name",
                            text: $viewModel.firstName,
                            icon: "person.fill"
                        )
                        .focused($focusedField, equals: .firstName)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .lastName }

                        CustomTextField(
                            placeholder: "Last Name",
                            text: $viewModel.lastName,
                            icon: "person.fill"
                        )
                        .focused($focusedField, equals: .lastName)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .email }

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
                        .submitLabel(.next)
                        .onSubmit { focusedField = .confirmPassword }

                        CustomTextField(
                            placeholder: "Confirm Password",
                            text: $viewModel.confirmPassword,
                            icon: "lock.fill",
                            isSecure: true
                        )
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.done)
                        .onSubmit {
                            focusedField = nil
                            if viewModel.isSignUpFormValid && !viewModel.isLoading {
                                Task {
                                    await viewModel.signUp()
                                    if viewModel.isSignUpSuccessful {
                                        onSignUpComplete()
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

                    // Sign Up Button
                    PrimaryButton(
                        title: viewModel.isLoading ? "Signing Up..." : "Sign Up",
                        action: {
                            Task {
                                await viewModel.signUp()
                                if viewModel.isSignUpSuccessful {
                                    onSignUpComplete()
                                }
                            }
                        }
                    )
                    .disabled(viewModel.isLoading || !viewModel.isSignUpFormValid)
                    .opacity(viewModel.isLoading || !viewModel.isSignUpFormValid ? 0.6 : 1.0)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                    // Switch to Sign In
                    Button(action: {
                        viewModel.resetForm()
                        onSwitchToSignIn()
                    }) {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.gray)
                            Text("Sign In")
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
//        .toolbar {
//            ToolbarItemGroup(placement: .keyboard) {
//                Spacer()
//                Button("Done") {
//                    focusedField = nil
//                }
//                .foregroundColor(AppColors.primary)
//            }
//        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .words

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(.password)
                    .textInputAutocapitalization(.never)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled()
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(onSignUpComplete: {}, onSwitchToSignIn: {})
            .preferredColorScheme(.dark)
    }
}
