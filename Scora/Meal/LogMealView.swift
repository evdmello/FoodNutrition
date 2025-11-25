//
//  LogMealView.swift
//  Scora
//
//  Created by Errol DMello on 11/23/25.
//


import SwiftUI

struct LogMealView: View {
    @StateObject private var viewModel = LogMealViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Text("Log Your Meal")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    VStack(spacing: 24) {
                        LogOptionCard(
                            icon: "camera.fill",
                            title: "Take a Photo",
                            subtitle: "Quick and easy meal logging",
                            action: { viewModel.openCamera() }
                        )
                        
                        LogOptionCard(
                            icon: "mic.fill",
                            title: "Voice Log",
                            subtitle: "Just describe what you ate",
                            action: { viewModel.openVoiceLog() }
                        )
                        
                        LogOptionCard(
                            icon: "keyboard",
                            title: "Type It In",
                            subtitle: "Manual entry for precision",
                            action: { viewModel.openManualEntry() }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Quick tips
                    VStack(spacing: 8) {
                        Text("💡 Tips for better accuracy")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Include all ingredients and portion sizes")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showCamera) {
            CameraView()
        }
        .sheet(isPresented: $viewModel.showVoiceLog) {
            VoiceLogView()
        }
        .sheet(isPresented: $viewModel.showManualEntry) {
            ManualEntryView()
        }
    }
}

struct LogOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
                    .frame(width: 32, height: 32)
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(6)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(20)
            .background(AppColors.cardBackground)
            .cornerRadius(16)
        }
    }
}

struct LogMealView_Previews: PreviewProvider {
    static var previews: some View {
        LogMealView()
            .preferredColorScheme(.dark)
    }
}
