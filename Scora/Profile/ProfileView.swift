//
//  ProfileView.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//


import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    let onSignOut: () -> Void

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        ProfileHeader(viewModel: viewModel)

                        StatsOverview(viewModel: viewModel)

                        CurrentProgramCard(program: viewModel.currentProgram)

                        SettingsSection(title: "Account", items: [
                            SettingItem(icon: "person.fill", title: "Personal Info", action: {}),
                            SettingItem(icon: "bell.fill", title: "Notifications", action: {}),
                            SettingItem(icon: "lock.fill", title: "Privacy & Security", action: {})
                        ])

                        SettingsSection(title: "Preferences", items: [
                            SettingItem(icon: "chart.bar.fill", title: "Goals & Programs", action: {}),
                            SettingItem(icon: "calendar", title: "Meal Reminders", action: {}),
                            SettingItem(icon: "info.circle.fill", title: "Dietary Restrictions", action: {})
                        ])

                        SettingsSection(title: "Support", items: [
                            SettingItem(icon: "questionmark.circle.fill", title: "Help", action: {}),
                            SettingItem(icon: "envelope.fill", title: "Support", action: {}),
                            SettingItem(icon: "star.fill", title: "Feedback", action: {})
                        ])

                        VStack(spacing: 12) {
                            Button(action: {
                                hasCompletedOnboarding = false
                            }) {
                                Text("Restart Onboarding")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(12)
                            }

                            Button(action: {
                                Task {
                                    await viewModel.logout()
                                    onSignOut()
                                }
                            }) {
                                Text("Logout")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(12)
                            }
                        }

                        Text("v1.0.0")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.bottom, 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.fetchUserProfile()
            }
        }
    }
}

struct ProfileHeader: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(AppColors.primary.opacity(0.2))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(viewModel.initials)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.primary)
                )

            VStack(spacing: 4) {
                Text(viewModel.name)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)

                Text(viewModel.email)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.vertical, 20)
    }
}

struct StatsOverview: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        HStack(spacing: 12) {
            StatCard(value: "\(viewModel.totalMeals)", label: "Meals Logged")
            StatCard(value: "\(viewModel.currentStreak)", label: "Day Streak")
            StatCard(value: "\(viewModel.avgScore)", label: "Avg Score")
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.primary)

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

struct CurrentProgramCard: View {
    let program: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Current Program")
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                Button("Change") {}
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.primary)
            }

            Text(program)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            HStack {
                ProgressView(value: 0.4)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))

                Text("Week 3 of 6")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 80)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

struct SettingsSection: View {
    let title: String
    let items: [SettingItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    SettingItemRow(item: item)

                    if index < items.count - 1 {
                        Divider()
                            .background(AppColors.textSecondary.opacity(0.2))
                            .padding(.leading, 52)
                    }
                }
            }
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}

struct SettingItem {
    let icon: String
    let title: String
    let action: () -> Void
}

struct SettingItemRow: View {
    let item: SettingItem

    var body: some View {
        Button(action: item.action) {
            HStack(spacing: 16) {
                Image(systemName: item.icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 28)

                Text(item.title)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding()
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(onSignOut: {})
            .preferredColorScheme(.dark)
    }
}
