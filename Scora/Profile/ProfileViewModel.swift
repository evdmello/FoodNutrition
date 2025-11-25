//
//  ProfileViewModel.swift
//  Scora
//
//  Created by Errol DMello on 11/25/25.
//

import Foundation
import SwiftUI
import Supabase

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var totalMeals: Int = 0
    @Published var currentStreak: Int = 0
    @Published var avgScore: Int = 0
    @Published var currentProgram: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let supabase = SupabaseClient(
        supabaseURL: API.supabaseURL,
        supabaseKey: Keys.supabaseKey
    )

    var initials: String {
        guard !name.isEmpty else { return "?" }
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.joined()
    }

    func fetchUserProfile() async {
        isLoading = true
        errorMessage = nil

        do {
            // Get current user
            let user = try await supabase.auth.session.user

            // Set email from auth user
            email = user.email ?? ""

            // Get first and last name from user metadata
            if let firstName = user.userMetadata["first_name"]?.stringValue,
               let lastName = user.userMetadata["last_name"]?.stringValue {
                name = "\(firstName) \(lastName)"
            } else {
                name = email.components(separatedBy: "@").first ?? "User"
            }

            // TODO: Fetch additional profile data from your database
            // For now using mock data
            totalMeals = 127
            currentStreak = 12
            avgScore = 82
            currentProgram = "Gut Restore"

            isLoading = false
        } catch {
            print("❌ Error fetching profile: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func logout() async {
        do {
            try await supabase.auth.signOut()
            print("✅ Successfully logged out")
        } catch {
            print("❌ Logout error: \(error.localizedDescription)")
        }
    }
}
