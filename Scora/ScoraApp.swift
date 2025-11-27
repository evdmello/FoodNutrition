//
//  ScoraApp.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//

import SwiftUI
import Supabase
import Auth

@main
struct ScoraApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @State private var isCheckingAuth = true
    @State private var showSignIn = true
    private let supabase = SupabaseClient(supabaseURL: API.supabaseURL, supabaseKey: Keys.supabaseKey)

    var body: some Scene {
        WindowGroup {
            Group {
                if isCheckingAuth {
                    ZStack {
                        AppColors.background.ignoresSafeArea()
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(AppColors.primary)
                            Text("Loading...")
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                } else if !hasCompletedOnboarding {
                    OnboardingView(dismiss: {
                        hasCompletedOnboarding = true
                    })
                } else if !isAuthenticated {
                    if showSignIn {
                        SignInView(
                            onSignInComplete: {
                                isAuthenticated = true
                            },
                            onSwitchToSignUp: {
                                showSignIn = false
                            }
                        )
                    } else {
                        SignUpView(
                            onSignUpComplete: {
                                isAuthenticated = true
                            },
                            onSwitchToSignIn: {
                                showSignIn = true
                            }
                        )
                    }
                } else {
                    MainAppView(onSignOut: {
                        isAuthenticated = false
                        showSignIn = true
                    })
                }
            }
            .preferredColorScheme(.dark)
            .onOpenURL { url in
                supabase.auth.handle(url)
            }
            .task {
                await checkAuthStatus()
                setupAuthListener()
            }
        }
    }

    private func checkAuthStatus() async {
        do {
            let session = try await supabase.auth.session

            let currentDate = Date()
            let expiresAt = Date(timeIntervalSince1970: TimeInterval(session.expiresAt))

            if expiresAt > currentDate {
                isAuthenticated = true
            } else {
                isAuthenticated = false
            }
        } catch {
            isAuthenticated = false
        }

        isCheckingAuth = false
    }

    private func setupAuthListener() {
        // Listen for auth state changes
        Task {
            for await state in supabase.auth.authStateChanges {
                await MainActor.run {
                    switch state.event {
                    case .signedIn:
                        print("User signed in: \(state.session?.user.email ?? "unknown")")
                        isAuthenticated = true
                    case .signedOut:
                        print("User signed out")
                        isAuthenticated = false
                    case .tokenRefreshed:
                        print("Token refreshed")
                        isAuthenticated = true
                    case .userUpdated:
                        print("User updated")
                    case .passwordRecovery:
                        print("Password recovery")
                    case .userDeleted:
                        print("User deleted")
                        isAuthenticated = false
                    default:
                        break
                    }
                }
            }
        }
    }
}
