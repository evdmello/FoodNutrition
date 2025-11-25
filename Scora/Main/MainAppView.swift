//
//  MainAppView.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//


import SwiftUI
import Supabase

struct MainAppView: View {
    @State private var selectedTab = 0
    @State private var isValidatingSession = false
    let onSignOut: () -> Void

    private let supabase = SupabaseClient(
        supabaseURL: API.supabaseURL,
        supabaseKey: Keys.supabaseKey
    )

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            LogMealView()
                .tabItem {
                    Label("Log", systemImage: "camera.fill")
                }
                .tag(1)

            ScoresView()
                .tabItem {
                    Label("Scores", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)

            ProfileView(onSignOut: onSignOut)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(AppColors.primary)
        .task {
            await validateUserSession()
        }
    }

    private func validateUserSession() async {
        isValidatingSession = true

        do {
            // Validate the current session
            let session = try await supabase.auth.session

            // Check if session is expired
            let currentDate = Date()
            let expiresAt = Date(timeIntervalSince1970: TimeInterval(session.expiresAt))

            if expiresAt <= currentDate {
                print("⚠️ Session expired in MainAppView")
                onSignOut()
            } else {
                print("✅ Valid session in MainAppView for user: \(session.user.email ?? "unknown")")
            }
        } catch {
            print("❌ Session validation failed in MainAppView: \(error.localizedDescription)")
            onSignOut()
        }

        isValidatingSession = false
    }
}


struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView(onSignOut: {})
            .preferredColorScheme(.dark)
    }
}
